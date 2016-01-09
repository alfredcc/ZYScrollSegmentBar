# Preview
![](https://raw.githubusercontent.com/alfredcc/ZYScrollSegmentBar/master/gif/preview.gif)

# Installation
#### Manually
1. Download the source directory.
2. Drag the source directory to your Xcode project.

# Usage
Very easy to use, just like `UITableViewController`, you just need to implement the `datasource` and `delegate` (optional)

First:  create the `ZYScrollSegmentBar()`
``` swift
var viewControllers:[UIViewController] = []
override func viewDidLoad() {
  super.viewDidLoad()
  let scrollSegmentBar = ZYScrollSegmentBar(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20))
  view.addSubview(scrollSegmentBar)
  
  // add you viewControllers
  // viewControllers.append(viewController1)
  // viewControllers.append(viewController2)
  // ...

  scrollSegmentBar.dataSource = self
  scrollSegmentBar.delegate = self
  scrollSegmentBar.reloadView()
}
```
Second: implement 'ZYScrollSegmentBarDataSource' and 'ZYScrollSegmentBarDelegate'
``` swift
extension ViewController:ZYScrollTabBarDataSource, ZYScrollTabBarDelegate {
  // return the number of items
  func numberOfItems(tabBar: ZYScrollTabBar) -> Int {
    return viewControllers.count
  }
  // return the viewContrller in order to construct the ZYScrollSegmentBar view
  func viewControllerForScrollTabBar(scrollTabBar: ZYScrollTabBar, atIndex: Int) -> UIViewController {
    return viewControllers[atIndex]
  }
  
  func tabBarDidScrollAtIndex(tabBar: ZYScrollTabBar, index: Int) {
    print("scroll to \(index)th view controller!")
  }
}
```

# Appearance
``` swift
public struct ZYScrollSegmentBarAppearance {
    var textColor: UIColor = UIColor.darkGrayColor()
    var selectedTextColor: UIColor = UIColor.redColor()
    var font: UIFont = UIFont.systemFontOfSize(12)
    var selectedFont: UIFont = UIFont.systemFontOfSize(14)
    var bottomLineColor: UIColor = UIColor.redColor()
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
`ZYScrollSegmentBar` is provided under the `MIT license`. See LICENSE file for details.
