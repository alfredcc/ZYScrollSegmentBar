//
//  ViewController.swift
//  ZYScrollSegmentBar
//
//  Created by race on 15/11/20.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var viewControllers: [TestViewController] = []
    //  var scrollTabBar: ZYScrollSegmentBar?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let scrollSegmentBar = ZYScrollSegmentBar(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20))
        view.addSubview(scrollSegmentBar)

        let testVC1 = TestViewController()
        testVC1.title = "FIRST"
        testVC1.viewColor = UIColor.darkGrayColor()
        testVC1.URLString = "https://github.com"
        viewControllers.append(testVC1)

        let testVC2 = TestViewController()
        testVC2.title = "SECOND"
        testVC2.viewColor = UIColor.cyanColor()
        viewControllers.append(testVC2)

        let testVC3 = TestViewController()
        testVC3.title = "THIRD"
        testVC3.viewColor = UIColor.brownColor()
        viewControllers.append(testVC3)

        scrollSegmentBar.dataSource = self
        scrollSegmentBar.delegate = self
        scrollSegmentBar.reloadView()

    }
}
extension ViewController:ZYScrollSegmentBarDataSource, ZYScrollSegmentBarDelegate {
    func numberOfItems(tabBar: ZYScrollSegmentBar) -> Int {
        return viewControllers.count
    }

    func viewControllerForScrollTabBar(scrollTabBar: ZYScrollSegmentBar, atIndex: Int) -> UIViewController {
        return viewControllers[atIndex]
    }
    
    func tabBarDidScrollAtIndex(tabBar: ZYScrollSegmentBar, index: Int) {
        print("scroll to \(index)th view controller!")
    }
    
}

