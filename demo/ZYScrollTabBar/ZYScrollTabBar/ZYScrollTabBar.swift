//
//  ZYScrollTabBar.swift
//  ZYScrollTabBar
//
//  Created by race on 15/11/20.
//  Copyright © 2015年 alfredcc. All rights reserved.
//

import UIKit

// MARK: - Protocol
protocol ZYScrollTabBarDataSource: NSObjectProtocol {
  func numberOfItems(scrollTabBar: ZYScrollTabBar) -> Int
  func viewControllerForScrollTabBar(scrollTabBar: ZYScrollTabBar, atIndex: Int) -> UIViewController
}

// MARK: - Appearance
struct ZYScrollTabBarAppearance {

  var textColor: UIColor
  var font: UIFont
  var selectedTextColor: UIColor
  var selectedFont: UIFont
  var bottomLineColor: UIColor
  var selectorColor: UIColor
  var bottomLineHeight: CGFloat
  var selectorHeight: CGFloat
}


class ZYScrollTabBar: UIView{
  // MARK: Properties
  weak var dataSource: ZYScrollTabBarDataSource?
  //  var appearance: YSSegmentedControlAppearance?

  private var scrollView: UIScrollView!
  private var subViewControllers: [UIViewController] = []
  var selectedTabIndex: Int = 0 //当前选中页
  var tabButtonTitleNormalColor: UIColor = UIColor.blackColor()
  var tabButtonTitleSelectedColor: UIColor = UIColor.redColor()
  var tabView: UIView!
  var selectedLine: UIView!
  var itemButtons: [UIButton] = []

  var isDragging: Bool = false
  private var canLayout: Bool = false
  let tabMargin: CGFloat = 30.0
  let tabBarHeight: CGFloat = 40.0
  let tabButtonFontSize: CGFloat = 14.0
//  private var startOffsetX: CGFloat = 0.0
  private var selectedLineOffsetXBeforeMoving: CGFloat = 0.0
  private var itemButtonWidth: CGFloat {
    return (self.frame.width - tabMargin*2) / CGFloat(itemButtons.count)
  }
  // MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)

    configureView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func reloadView() {
    configureView()
  }
  // MARK: - Configure View
  func configureView() {
    canLayout = false
    guard let dataSource = dataSource else { return }

    tabView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: tabBarHeight))
    addSubview(tabView)

    scrollView = UIScrollView(frame: CGRectMake(0, tabBarHeight, frame.width, frame.height - tabBarHeight))
    scrollView.delegate = self
    scrollView.pagingEnabled = true
    scrollView.userInteractionEnabled = true
    scrollView.bounces = true
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.autoresizingMask = [.FlexibleHeight, .FlexibleBottomMargin, .FlexibleWidth]
    addSubview(scrollView)

    let number = dataSource.numberOfItems(self)
    for index in 0..<number {
      /// add SubViewController into scrollView
      /// 添加 ViewController
      let viewController = dataSource.viewControllerForScrollTabBar(self, atIndex: index)
      subViewControllers.append(viewController)
      scrollView.addSubview(viewController.view)

      /// Add ItemButtons
      /// 添加按钮
      let itemButton = UIButton(type: .Custom)
      itemButton.tag = index
      itemButton.titleLabel?.baselineAdjustment = .AlignCenters
      itemButton.titleLabel?.font = UIFont.systemFontOfSize(tabButtonFontSize)
      itemButton.setTitle(viewController.title, forState: .Normal)
      itemButton.setTitleColor(tabButtonTitleNormalColor, forState: .Normal)
      itemButton.setTitleColor(tabButtonTitleSelectedColor, forState: .Normal)
      itemButton.addTarget(self, action: Selector("onTabButtonSelected:"), forControlEvents: .TouchUpInside)
      itemButtons.append(itemButton)
      tabView.addSubview(itemButton)
    }

    selectedLine = UIView(frame: CGRect(x: tabMargin, y: tabBarHeight - 2, width: itemButtonWidth, height: 2))
    selectedLine.backgroundColor = UIColor.redColor()
    tabView.addSubview(selectedLine)

    tabView.backgroundColor = UIColor.whiteColor()
    canLayout = true
    setNeedsLayout()
  }

  /// Tips: Do Not Add SubViews Here! It Will Load More Than Once.
  /// 尽量不要在这里添加子View，因为这个方法被调用多次，如果要这样做必须加额外逻辑判断
  override func layoutSubviews() {
    if !canLayout { return }
    scrollView.contentSize = CGSize(width: frame.width * CGFloat(subViewControllers.count), height: tabBarHeight);
    for (index, vc) in subViewControllers.enumerate() {
      vc.view.frame = CGRect(x: scrollView.frame.width * CGFloat(index), y: 0, width: frame.width, height: scrollView.frame.height)
    }
    // Offset each button's origin by the length of the button.

    for (index, button) in itemButtons.enumerate() {
      button.frame = CGRect(x: tabMargin + itemButtonWidth*CGFloat(index), y: 0, width: itemButtonWidth, height: tabBarHeight)
    }
  }


  func onTabButtonSelected(button: UIButton) {
    selectTabWithIndex(button.tag, animated:true)
  }

  func selectTabWithIndex(index: Int, animated: Bool) {
    let currentButton = itemButtons[index];
    currentButton.selected = true;
    selectedTabIndex = index;
    let moveSelectedLine: () -> Void =  {
      self.selectedLine.center = CGPoint(x: currentButton.center.x, y: self.selectedLine.center.y);
      self.selectedLineOffsetXBeforeMoving = self.selectedLine.frame.origin.x;
    }
    //移动select line
    if (animated) {
      UIView.animateWithDuration(0.3, animations: moveSelectedLine, completion: nil)
    } else {
      moveSelectedLine()
    }
    scrollViewToIndex(index, animated: animated)

  }

  func scrollViewToIndex(index: Int, animated: Bool) {
    scrollView.setContentOffset(CGPoint(x: CGFloat(index) * frame.width, y: 0), animated:animated)
    isDragging = false;
  }
}

extension ZYScrollTabBar: UIScrollViewDelegate{
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      isDragging = true
    }
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      if isDragging {
        moveSelectedLineByScrollWithOffsetX(scrollView.contentOffset.x)
      }
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    if scrollView === self.scrollView {
      isDragging = false
    }
  }

  func moveSelectedLineByScrollWithOffsetX(offsetX: CGFloat) {
    if offsetX < 0 || offsetX > bounds.width * CGFloat(itemButtons.count - 1){
      return
    }

    let targetX = tabMargin + offsetX * itemButtonWidth / (frame.width)
    selectedLine.frame = CGRect(x: targetX, y: self.selectedLine.frame.origin.y, width: self.selectedLine.frame.width, height: self.selectedLine.frame.height)
  }
}



