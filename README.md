# ZYScrollTabBar
# Preview
![](https://raw.githubusercontent.com/alfredcc/ZYScrollTabBar/master/gif/preview.gif)

# Installation
#### Manually
1. Download 'ZYScrollTabBar.swift' file in the source directory.
2. Add the source file to your Xcode project.

# Usage
Very easy to use, just like UITableViewController, you just need to implement the 'datasource' and 'delegate' (optional)

First:  create the ZYScrollTabBar()
``` swift
var viewControllers:[UIViewController] = []
override func viewDidLoad() {
  super.viewDidLoad()
  let scrollTabBar = ZYScrollTabBar(frame: frame)
  view.addSubview(scrollTabBar)

  scrollTabBar.dataSource = self
  scrollTabBar.delegate = self
  scrollTabBar.reloadView()
  
  // add you viewControllers
  // viewControllers.append(viewController1)
  // viewControllers.append(viewController2)
  // ...
```
Second: implement 'ZYScrollTabBarDataSource' and 'ZYScrollTabBarDelegate'
``` swift
extension ViewController:ZYScrollTabBarDataSource, ZYScrollTabBarDelegate {
  // return the number of items
  func numberOfItems(tabBar: ZYScrollTabBar) -> Int {
    return viewControllers.count
  }
  // return the viewContrller in order to construct the controller
  func viewControllerForScrollTabBar(scrollTabBar: ZYScrollTabBar, atIndex: Int) -> UIViewController {
    return viewControllers[atIndex]
  }
   
  func tabBarDidScrollAtIndex(tabBar: ZYScrollTabBar, index: Int) {
    print("SCROLL TO \(index)th VIEWCONTROLLER!")
  }
}
```

# Appearance
``` swift
struct ZYScrollTabBarAppearance {
  var textColor: UIColor = UIColor.darkGrayColor()
  var selectedTextColor: UIColor = UIColor.redColor()
  var font: UIFont = UIFont.systemFontOfSize(15)
  var selectedFont: UIFont = UIFont.systemFontOfSize(15)
  var bottomLineColor: UIColor = UIColor.cyanColor()
  var bottomLineHeight: CGFloat = 2.0
  var tabBarHeight: CGFloat = 40.0
  var tabMargin: CGFloat = 20.0
}
```

``` swift
  scrollTabBar.appearance.textColor = UIColor.darkGrayColor()
```
# Requirements
Swift 2.0, iOS 8.0

# License
ZYScrollTabBar is provided under the MIT license. See LICENSE file for details.
