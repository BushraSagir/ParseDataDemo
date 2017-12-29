//
//  ProgressView.swift
//  Diaspark CRM
//
//  Created by Rajni-Patil on 12/08/16.
//  Copyright © 2016 Diaspark Inc. All rights reserved.
//

import UIKit

  class ProgressView {
    
    var containerView = UIView()
    var progressView = UIView()
    
    var activityIndicator = UIActivityIndicatorView()

    struct Static {
        static let instance: ProgressView = ProgressView()
    }
    
    static var shared: ProgressView {
        return Static.instance
    }
    
      func showProgressView(_ view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 0.3)
        
        progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        progressView.center = view.center
        progressView.backgroundColor = UIColor.black
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
      func hideProgressView() {
        
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            self.containerView.removeFromSuperview()
        })
     
    }
}
