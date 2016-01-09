//
//  ZYScrollSegmentBar.swift
//  ZYScrollSegmentBar
//
//  Created by race on 15/11/20.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol ZYScrollSegmentBarDataSource: NSObjectProtocol {
  func numberOfItems(scrollTabBar: ZYScrollSegmentBar) -> Int
  func viewControllerForScrollTabBar(scrollTabBar: ZYScrollSegmentBar, atIndex: Int) -> UIViewController

}

@objc protocol ZYScrollSegmentBarDelegate: NSObjectProtocol {
  optional func tabBarDidScrollAtIndex(tabBar: ZYScrollSegmentBar, index:Int)
}

// MARK: - Appearance
struct ZYScrollSegmentBarAppearance {

  var textColor: UIColor = UIColor.darkGrayColor()
  var selectedTextColor: UIColor = UIColor.redColor()
  var font: UIFont = UIFont.systemFontOfSize(15)
  var selectedFont: UIFont = UIFont.systemFontOfSize(15)
  var bottomLineColor: UIColor = UIColor.cyanColor()
  var bottomLineHeight: CGFloat = 2.0
  var tabBarHeight: CGFloat = 40.0
  var tabMargin: CGFloat = 20.0
}


class ZYScrollSegmentBar: UIView{
  // MARK: Properties
  weak var dataSource: ZYScrollSegmentBarDataSource?
  weak var delegate: ZYScrollSegmentBarDelegate?
  var appearance: ZYScrollSegmentBarAppearance! {
    didSet {
      self.configureView()
    }
  }

  private var tabView = UIView()
  private let selectedLine = CALayer()
  private var scrollView = UIScrollView()
  private var itemButtons = [UIButton]()
  private var subViewControllers = [UIViewController]()
  private var isDragging: Bool = false
  private var canLayoutSubviews: Bool = false
  private var itemButtonWidth: CGFloat!
  var selectedTabIndex: Int = 0 //当前选中页 默认为0

  // MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    appearance = ZYScrollSegmentBarAppearance()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func reloadView() {
    configureView()
  }

  // MARK: - Configure View
  private func reset () {
    for sub in subviews {
      sub.removeFromSuperview()
    }
    subViewControllers = []
    itemButtons = []
  }

  private func configureView() {
    reset()
    canLayoutSubviews = false
    guard let dataSource = dataSource else { return }
    tabView.frame = CGRect(x: 0, y: 0, width: frame.width, height: appearance.tabBarHeight)
    addSubview(tabView)

    scrollView.frame = CGRectMake(0, appearance.tabBarHeight, frame.width, frame.height - appearance.tabBarHeight)
    scrollView.delegate = self
    scrollView.pagingEnabled = true
    scrollView.userInteractionEnabled = true
    scrollView.bounces = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.autoresizingMask = [.FlexibleHeight, .FlexibleBottomMargin, .FlexibleWidth]
    addSubview(scrollView)

    let number = dataSource.numberOfItems(self)
    itemButtonWidth = (self.frame.width - appearance.tabMargin*2) / CGFloat(number)
    for index in 0..<number {
      // add SubViewController into scrollView
      // 添加 ViewController
      let viewController = dataSource.viewControllerForScrollTabBar(self, atIndex: index)
      subViewControllers.append(viewController)
      scrollView.addSubview(viewController.view)

      // Add ItemButtons
      // 添加按钮
      let itemButton = UIButton(type: .Custom)
      itemButton.tag = index
      itemButton.titleLabel?.baselineAdjustment = .AlignCenters
      itemButton.titleLabel?.font = appearance.font
      itemButton.setTitle(viewController.title, forState: .Normal)
      itemButton.setTitleColor(appearance.textColor, forState: .Normal)
      itemButton.setTitleColor(appearance.selectedTextColor, forState: .Selected)
      itemButton.addTarget(self, action: Selector("onTabButtonSelected:"), forControlEvents: .TouchUpInside)
      itemButtons.append(itemButton)
      tabView.addSubview(itemButton)
    }

    // Add Selected Line
    // 添加选择横线
    selectedLine.frame = CGRect(x: appearance.tabMargin, y: appearance.tabBarHeight - 2, width: itemButtonWidth, height: 2)
    selectedLine.backgroundColor = UIColor.redColor().CGColor
    tabView.layer.addSublayer(selectedLine)

    tabView.backgroundColor = UIColor.whiteColor()
    canLayoutSubviews = true
    setNeedsLayout()
  }

  // Tips: Do Not Add SubViews Here! It Will Load More Than Once.
  // 尽量不要在这里添加子View，因为这个方法被调用多次，如果要这样做必须加额外逻辑判断
  override func layoutSubviews() {
    if !canLayoutSubviews { return }
    scrollView.contentSize = CGSize(width: frame.width * CGFloat(subViewControllers.count), height: appearance.tabBarHeight)
    for (index, vc) in subViewControllers.enumerate() {
      vc.view.frame = CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: frame.width, height: scrollView.frame.height)
    }

    for (index, button) in itemButtons.enumerate() {
      button.frame = CGRect(x: appearance.tabMargin + itemButtonWidth*CGFloat(index), y: 0, width: itemButtonWidth, height: appearance.tabBarHeight)
    }
  }


  func onTabButtonSelected(button: UIButton) {
    if abs(button.tag - selectedTabIndex) > 1 {
      selectTabWithIndex(button.tag, animated:false)
    } else {
      selectTabWithIndex(button.tag, animated:true)
    }
  }

  func selectTabWithIndex(index: Int, animated: Bool) {
    let currentButton = itemButtons[index]
    setSelectedItemButton(index)
    let moveSelectedLine: () -> Void =  {
      self.selectedLine.frame = CGRect(x: currentButton.frame.origin.x, y: self.appearance.tabBarHeight - 2, width: self.itemButtonWidth, height: 2)
    }
    // Move Selected Line
    if (animated) {
      UIView.animateWithDuration(0.3, animations: moveSelectedLine, completion: nil)
    } else {
      moveSelectedLine()
    }
    scrollViewToIndex(index, animated: animated)
    delegate?.tabBarDidScrollAtIndex?(self, index: index)
  }

  private func scrollViewToIndex(index: Int, animated: Bool) {
    scrollView.setContentOffset(CGPoint(x: CGFloat(index) * frame.width, y: 0), animated:animated)
    isDragging = false
  }

  private func setSelectedItemButton(selectedIndex: Int) {
    for button in itemButtons {
      if button.tag == selectedIndex {
        button.selected = true
        selectedTabIndex = selectedIndex
      } else {
        button.selected = false
      }
    }
  }

}

// MARK: - UIScrollViewDelegate
extension ZYScrollSegmentBar: UIScrollViewDelegate{
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      isDragging = true
    }
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      if isDragging {
        moveSelectedLineWithContentOffsetX(scrollView.contentOffset.x)
      }
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      isDragging = false
      selectTabWithIndex(Int(scrollView.contentOffset.x / bounds.width), animated: true)
    }
  }

  // Move SelectedLine
  private func moveSelectedLineWithContentOffsetX(offsetX: CGFloat) {
    // 处理左右的边界条件
    if offsetX < 0 || offsetX > bounds.width * CGFloat(itemButtons.count - 1){
      return
    }

    let targetX = appearance.tabMargin + offsetX * itemButtonWidth / (frame.width)
    selectedLine.frame = CGRect(x: targetX, y: selectedLine.frame.origin.y, width: selectedLine.frame.width, height: selectedLine.frame.height)
  }
}