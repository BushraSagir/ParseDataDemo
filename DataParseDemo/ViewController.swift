//
//  ViewController.swift
//  DataParseDemo
//
//  Created by Bushra-Sagir on 27/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
 
    @IBAction func downloadAction(_ sender: Any) {
         ProgressView.shared.showProgressView(self.view)
        // Create destination URL
        self.clearTempFolder()
        let fileName = "Weather.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "region_code,weather_param,year, key, value\n"
        let countries = ["UK","England","Wales","Scotland"]
        let features = ["Tmax", "Tmin", "Tmean", "Sunshine", "Rainfall"]
        for country in countries {
            for feature in features {
                 let fileURL = URL(string: "https://www.metoffice.gov.uk/pub/data/weather/uk/climate/datasets/"+feature+"/date/"+country+".txt")
                print(fileURL ?? "")
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                //let csv = CkoCsv()
                let request = URLRequest(url:fileURL!)
                let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                let destinationFileUrl = documentsUrl.appendingPathComponent(country+feature+".txt")
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                    } else {
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "");
                    }
                }
                task.resume()
                let content =  try? String(contentsOfFile: destinationFileUrl.path, encoding: String.Encoding.utf8)
                let lineArray = content?.components(separatedBy: "\n")
                var headerArr = lineArray![7].components(separatedBy: " ")
                headerArr = headerArr.filter{$0 != ""}
                for i in 0..<headerArr.count {
                    if headerArr[i].contains("\r") {
                        var element = headerArr[i]
                        element = element.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
                        headerArr.remove(at: i)
                        headerArr.insert(element, at: i)
                    }
                }
                var dataLine:[String] = []
                for line in 8..<lineArray!.count-1{
                     dataLine = lineArray![line].components(separatedBy: "  ")
                    if let index = dataLine.contains(subarray: ["","","",""]) {
                        dataLine.remove(at: index)
                        dataLine.insert("N/A", at: index)
                    }
                    dataLine = dataLine.filter{$0 != ""}
                    for i in 0..<dataLine.count {
                        if dataLine[i].contains("--") {
                            dataLine.remove(at: i)
                            dataLine.insert("N/A", at: i)
                        }
                    }
                    if headerArr.count != dataLine.count {
                        for i in 0..<dataLine.count {
                            if dataLine[i].contains("\r") {
                                var element = dataLine[i]
                                element = element.replacingOccurrences(of: "\r", with: "", options: NSString.CompareOptions.literal, range: nil)
                                dataLine.remove(at: i)
                                dataLine.insert(element, at: i)
                                dataLine.insert("N/A", at: i+1)
                            }
                        }
                    }
                    if dataLine.count > 1 {
                        for i in 1..<dataLine.count {
                            csvText = csvText.appending(country+","+feature+","+dataLine[0]+","+headerArr[i]+","+dataLine[i]+"\n")
                        }
                    }
                }
            }
        }
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        ProgressView.shared.hideProgressView()

    }
    
    func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: tempFolderPath + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    
}
extension ViewController : MFMailComposeViewControllerDelegate {
    @IBAction func btnMailClicked(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File")
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
        let fileName = "Weather.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            
        if let fileData = NSData(contentsOfFile: (path?.path)!) {
                print("File data loaded.")
            emailController.addAttachmentData(fileData as Data, mimeType: "text/csv", fileName: fileName)
            }
        
        return emailController
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension Array where Element: Equatable {
    func contains(subarray: [Element]) -> Index? {
        var found = 0
        var startIndex:Index = 0
        for (index, element) in self.enumerated() where found < subarray.count {
            if element != subarray[found] {
                found = 0
            }
            if element == subarray[found]  {
                if found == 0 { startIndex = index }
                found += 1
            }
        }
        
        return found == subarray.count ? startIndex : nil
    }
}

