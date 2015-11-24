//
//  TestViewController.swift
//  TestViewController
//
//  Created by race on 15/11/20.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

  var viewColor: UIColor?
  var URLString: String?

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    let testView = UIView(frame: frame)
    self.view.addSubview(testView)
    testView.backgroundColor = viewColor


    if let URL = URLString {
      let webView = UIWebView(frame: frame)
      view.addSubview(webView)
      webView.scalesPageToFit = true;
      webView.scrollView.directionalLockEnabled = true;
      webView.scrollView.showsHorizontalScrollIndicator = false;
      let req = NSURLRequest(URL: NSURL(string: URL)!)
      webView.loadRequest(req)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

