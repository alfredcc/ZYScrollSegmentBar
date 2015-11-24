# ZYScrollTabBar
# Preview
![](https://raw.githubusercontent.com/alfredcc/ZYScrollTabBar/master/gif/preview.gif)

# Installation
#### Manually
1. Download 'ZYScrollTabBar.swift' file in the source directory.
2. Add the source file to your Xcode project.

# Usage
Very easy to use, just like UITableViewController, you just need to implement the 'datasource' and 'delegate' (optional)

First
``` swift
override func viewDidLoad() {
  super.viewDidLoad()
  let scrollTabBar = ZYScrollTabBar(frame: frame)
  view.addSubview(scrollTabBar)

  scrollTabBar.dataSource = self
  scrollTabBar.delegate = self
  scrollTabBar.reloadView()
```
Second
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
# Requirements
Swift 2.0, iOS 8.0

# License
ZYScrollTabBar is provided under the MIT license. See LICENSE file for details.
