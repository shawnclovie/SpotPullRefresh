//
//  PullLoadView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullLoadView: PullBaseView {
	
    public var ignoredScrollViewContentInsetBottom: CGFloat = 0
	
	public var shouldAutomaticallyRefresh = true
	/// Reveal rate while pan scroll view but not loose may trigger refresh, 0~1 means 0~100%
	public var panRevealRateMayTriggerRefresh: CGFloat = 1
	
	public var isRefreshWorkOnceOnly = false
	
	var isNewPanGestureDetected = false
	
	public override init(_ refreshment: @escaping () -> Void) {
		super.init(refreshment)
		bounds.size.height = Self.footerHeight
    }
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override open var isHidden: Bool {
		set {
			let oldValue = super.isHidden
			super.isHidden = newValue
			if !oldValue && newValue {
				set(state: .idle)
				superScrollView?.spot_increase(inset: \.bottom, -bounds.height)
			} else if oldValue && !newValue {
				superScrollView?.spot_increase(inset: \.bottom, bounds.height)
				frame.origin.y = superScrollView?.contentSize.height ?? 0
			}
		}
		get {super.isHidden}
	}
	
	override open func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		if newSuperview != nil {
			if !isHidden {
				superScrollView?.spot_increase(inset: \.bottom, bounds.height)
			}
			frame.origin.y = superScrollView?.contentSize.height ?? 0
		} else if !isHidden {
			superScrollView?.spot_increase(inset: \.bottom, -bounds.height)
		}
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		switch state {
		case .refreshing:
			executeBeginRefreshingHandlers()
		case .noMoreData, .idle:
			if oldValue == .refreshing {
				executeEndRefreshingHandler()
			}
		default:break
		}
	}
	
	override open func beginRefresh() {
		if !isNewPanGestureDetected && isRefreshWorkOnceOnly {
			return
		}
		super.beginRefresh()
		isNewPanGestureDetected = false
	}
	
	open override func scrollView(_ view: UIScrollView, didChangeContentSize change: NSKeyValueObservedChange<CGSize>) {
		super.scrollView(view, didChangeContentSize: change)
		frame.origin.y = superScrollView?.contentSize.height ?? 0
	}
	
	open override func scrollView(_ view: UIScrollView, didChangeContentOffset change: NSKeyValueObservedChange<CGPoint>) {
	   super.scrollView(view, didChangeContentOffset: change)
		if state != .idle || !shouldAutomaticallyRefresh || frame.origin.y == 0 {
			return
		}
		guard let scrollView = superScrollView else {return}
		let inset = scrollView.spot_inset
		let contentH = scrollView.contentSize.height
		let scrollH = scrollView.bounds.height
		// content height should over one screen
		guard inset.top + contentH > scrollH else {return}
		let viewHeight = bounds.height
		// 防止手松开时连续调用
		guard scrollView.contentOffset.y >= contentH - scrollH + viewHeight * abs(panRevealRateMayTriggerRefresh) + inset.bottom - viewHeight else {return}
		// 当底部刷新控件完全出现时，才刷新
		if change.newValue?.y ?? 0 <= change.oldValue?.y ?? 0 {return}
		beginRefresh()
	}
	
	open override func scrollViewPanGesture(_ reco: UIGestureRecognizer, didChangeState change: NSKeyValueObservedChange<UIGestureRecognizer.State>) {
		super.scrollViewPanGesture(reco, didChangeState: change)
		guard let scrollView = superScrollView, state == .idle else {return}
		switch scrollView.panGestureRecognizer.state {
		case .began:
			isNewPanGestureDetected = true
		case .ended:
			if scrollView.spot_inset.top + scrollView.contentSize.height <= scrollView.bounds.height {
				// if content less than one screen and dragging up
				if scrollView.contentOffset.y >= scrollView.spot_inset.top {
					beginRefresh()
				}
			} else if scrollView.contentOffset.y >= scrollView.contentSize.height + scrollView.spot_inset.bottom - scrollView.bounds.height {
				beginRefresh()
			}
		default:break
		}
	}
	
    public func endRefreshingWithNoMoreData() {
        DispatchQueue.main.async {[weak self] in
			self?.set(state: .noMoreData)
        }
    }
	
    public func resetState() {
        DispatchQueue.main.async {[weak self] in
			self?.set(state: .idle)
        }
    }
}
