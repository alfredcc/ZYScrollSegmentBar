# ZYScrollTabBar

# Installation
Just drag the source file to you project

# Usage
Very easy to use, just like UITableViewControll, you just need to implement the 'datasource' and 'delegate' with optional!

First
``` swift
override func viewDidLoad() {
  super.viewDidLoad()
  let scrollTabBar = ZYScrollTabBar(frame: frame)
  view.addSubview(scrollTabBar!)

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



