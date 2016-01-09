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


class ZYScrollSegmentBar: UIView{
    // MARK: Properties
    weak var dataSource: ZYScrollSegmentBarDataSource?
    weak var delegate: ZYScrollSegmentBarDelegate?

    private var _segmentBar = UIView()
    private var _scrollView = UIScrollView()
    private var _itemButtons = [UIButton]()
    private var _subViewControllers = [UIViewController]()
    private var _isDragging: Bool = false
    private var _canLayoutSubviews: Bool = false
    private var _itemButtonWidth: CGFloat!
    private var selectedTabIndex: Int = 0

    private let _selectedLine = CALayer()

    var appearance: ZYScrollSegmentBarAppearance! {
        didSet {
            reloadView()
        }
    }

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        appearance = ZYScrollSegmentBarAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadView() {
        configureView()
        selectTabWithIndex(selectedTabIndex, animated: true)
    }

    // MARK: - Setup View
    private func reset () {
        for sub in subviews {
            sub.removeFromSuperview()
        }
        _subViewControllers = []
        _itemButtons = []
    }

    private func configureView() {
        reset()
        _canLayoutSubviews = false
        guard let dataSource = dataSource else { return }
        _segmentBar.frame = CGRect(x: 0, y: 0, width: frame.width, height: appearance.tabBarHeight)
        addSubview(_segmentBar)

        _scrollView.frame = CGRectMake(0, appearance.tabBarHeight, frame.width, frame.height - appearance.tabBarHeight)
        _scrollView.delegate = self
        _scrollView.pagingEnabled = true
        _scrollView.userInteractionEnabled = true
        _scrollView.bounces = true
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.autoresizingMask = [.FlexibleHeight, .FlexibleBottomMargin, .FlexibleWidth]
        addSubview(_scrollView)

        let number = dataSource.numberOfItems(self)
        _itemButtonWidth = (self.frame.width - appearance.tabMargin*2) / CGFloat(number)
        for index in 0..<number {
            // add SubViewController into scrollView
            let viewController = dataSource.viewControllerForScrollTabBar(self, atIndex: index)
            _subViewControllers.append(viewController)
            _scrollView.addSubview(viewController.view)

            // Add itemButtons
            let itemButton = UIButton(type: .Custom)
            itemButton.tag = index
            itemButton.titleLabel?.baselineAdjustment = .AlignCenters
            itemButton.titleLabel?.font = appearance.font
            itemButton.setTitle(viewController.title, forState: .Normal)
            itemButton.setTitleColor(appearance.textColor, forState: .Normal)
            itemButton.setTitleColor(appearance.selectedTextColor, forState: .Selected)
            itemButton.addTarget(self, action: Selector("onTabButtonSelected:"), forControlEvents: .TouchUpInside)
            _itemButtons.append(itemButton)
            _segmentBar.addSubview(itemButton)
        }

        // Add Selected Line
        _selectedLine.frame = CGRect(x: appearance.tabMargin,
            y: appearance.tabBarHeight - appearance.bottomLineHeight,
            width: _itemButtonWidth,
            height: appearance.bottomLineHeight)
        _selectedLine.backgroundColor = appearance.bottomLineColor.CGColor
        _segmentBar.layer.addSublayer(_selectedLine)

        _segmentBar.backgroundColor = UIColor.whiteColor()
        _canLayoutSubviews = true
        setNeedsLayout()
    }

    override func layoutSubviews() {
        if !_canLayoutSubviews { return }
        _scrollView.contentSize = CGSize(width: frame.width * CGFloat(_subViewControllers.count), height: appearance.tabBarHeight)
        for (index, vc) in _subViewControllers.enumerate() {
            vc.view.frame = CGRect(x: _scrollView.frame.width * CGFloat(index), y: 0, width: frame.width, height: _scrollView.frame.height)
        }

        for (index, button) in _itemButtons.enumerate() {
            button.frame = CGRect(x: appearance.tabMargin + _itemButtonWidth*CGFloat(index), y: 0, width: _itemButtonWidth, height: appearance.tabBarHeight)
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
        let currentButton = _itemButtons[index]
        setSelectedItemButton(index)
        let moveSelectedLine: () -> Void =  {
            self._selectedLine.frame = CGRect(x: currentButton.frame.origin.x,
                y: self.appearance.tabBarHeight - self.appearance.bottomLineHeight,
                width: self._itemButtonWidth,
                height: self.appearance.bottomLineHeight)
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
        _scrollView.setContentOffset(CGPoint(x: CGFloat(index) * frame.width, y: 0), animated:animated)
        _isDragging = false
    }

    private func setSelectedItemButton(selectedIndex: Int) {
        for button in _itemButtons {
            button.titleLabel?.font = appearance.font
            button.selected = false
            if button.tag == selectedIndex {
                button.selected = true
                button.titleLabel?.font = appearance.selectedFont
                selectedTabIndex = selectedIndex
            } else {
                button.selected = false
            }
        }
    }
}

// MARK: - UI_scrollViewDelegate
extension ZYScrollSegmentBar: UIScrollViewDelegate{
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView === _scrollView {
            _isDragging = true
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView === _scrollView {
            if _isDragging {
                move_selectedLineWithContentOffsetX(_scrollView.contentOffset.x)
            }
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if _scrollView === _scrollView {
            _isDragging = false
            selectTabWithIndex(Int(_scrollView.contentOffset.x / bounds.width), animated: true)
        }
    }
    
    // Move selectedLine
    private func move_selectedLineWithContentOffsetX(offsetX: CGFloat) {
        if offsetX < 0 || offsetX > bounds.width * CGFloat(_itemButtons.count - 1){
            return
        }
        
        let targetX = appearance.tabMargin + offsetX * _itemButtonWidth / (frame.width)
        _selectedLine.frame = CGRect(x: targetX, y: _selectedLine.frame.origin.y, width: _selectedLine.frame.width, height: _selectedLine.frame.height)
    }
}