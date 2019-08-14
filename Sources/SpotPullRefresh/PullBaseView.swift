//
//  PullBaseView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

/// State of pull controls
public enum PullState {
	case idle
	case pulling
	case refreshing
	case willRefresh
	case noMoreData
}

open class PullBaseView: UIView {
	public static var labelFont = UIFont.boldSystemFont(ofSize: 14)
	public static var labelTextColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    
	static let stateLabelMarginLeft: CGFloat = 25
    static let headerHeight: CGFloat = 54
    static let footerHeight: CGFloat = 44
    static let fastAnimationDuration = 0.25
    static let slowAnimationDuration = 0.4
	
	open class func decorate(label: UILabel) {
		label.font = labelFont
		label.textColor = labelTextColor
		label.autoresizingMask = .flexibleWidth
		label.textAlignment = .center
		label.backgroundColor = .clear
	}
   
	private let refreshment: ()->Void
	
	private var beginRefreshingHandler: (()->Void)?
	private var endRefreshingHandler: (()->Void)?
	
	public private(set) var state: PullState = .idle
	
	public private(set) var pullingPercent: CGFloat = 0
	
	/// Change alpha in pulling
	public var shouldGraduallyAlpha = false {
		didSet {
			if !isRefreshing {
				alpha = shouldGraduallyAlpha ? pullingPercent : 1
			}
		}
	}
	
	private var pan: UIPanGestureRecognizer?
	
	private var observers: [NSKeyValueObservation] = []
	
	public init(_ refreshment: @escaping ()->Void) {
		self.refreshment = refreshment
		super.init(frame: .zero)
		autoresizingMask = .flexibleWidth
		backgroundColor = .clear
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	var superScrollView: UIScrollView? {
		superview as? UIScrollView
	}
	
	public var isRefreshing: Bool {
		return self.state == .refreshing || self.state == .willRefresh
	}
	
	override open func willMove(toSuperview newView: UIView?) {
		super.willMove(toSuperview: newView)
		removeObservers()
		guard let scrollView = newView as? UIScrollView else {return}
		bounds.size.width = scrollView.bounds.width
		frame.origin.x = -scrollView.spot_inset.left
		scrollView.alwaysBounceVertical = true
		addObservers(to: scrollView)
	}
	
	override open func draw(_ rect: CGRect) {
		super.draw(rect)
		if state == .willRefresh {
			// prevent calling beginRefreshing() before view displaied
			set(state: .refreshing)
		}
	}
	
	func set(state: PullState) {
		guard self.state != state else {return}
		let oldValue = self.state
		self.state = state
		stateDidChange(oldValue: oldValue)
		DispatchQueue.main.async { [weak self] in
			self?.setNeedsLayout()
		}
	}
	
	open func stateDidChange(oldValue: PullState) {
	}
	
	open func set(pullingPercent: CGFloat) {
		self.pullingPercent = pullingPercent
		if !isRefreshing && shouldGraduallyAlpha {
			alpha = pullingPercent
		}
	}
	
	open func scrollView(_ view: UIScrollView, didChangeContentOffset change: NSKeyValueObservedChange<CGPoint>) {
	}
	
	open func scrollView(_ view: UIScrollView, didChangeContentSize change: NSKeyValueObservedChange<CGSize>) {
	}
	
	open func scrollViewPanGesture(_ reco: UIGestureRecognizer, didChangeState change: NSKeyValueObservedChange<UIGestureRecognizer.State>) {
	}
	
	public func beginRefresh() {
		UIView.animate(withDuration: Self.fastAnimationDuration) {
			self.alpha = 1
		}
		// force the percent as full value
		pullingPercent = 1
		if window != nil {
			set(state: .refreshing)
		} else if state != .refreshing {
			// prevent refresh again, it can lead to set header inset not worked.
			// refresh at next render frame, to avoid the state of pop back VC.
			set(state: .willRefresh)
			setNeedsDisplay()
		}
	}
	
	public func beginRefreshing(completion: (()->Void)?) {
		beginRefreshingHandler = completion
		beginRefresh()
	}
	
	public func endRefreshing() {
		DispatchQueue.main.async { [weak self] in
			self?.set(state: .idle)
		}
	}
	
	public func endRefreshing(completion: (()->Void)?) {
		endRefreshingHandler = completion
		endRefreshing()
	}
	
	func executeBeginRefreshingHandlers() {
		DispatchQueue.main.async { [weak self] in
			guard let self = self else {return}
			self.refreshment()
			if let fn = self.beginRefreshingHandler {
				self.beginRefreshingHandler = nil
				fn()
			}
		}
	}
	
	func executeEndRefreshingHandler() {
		guard let fn = endRefreshingHandler else {return}
		endRefreshingHandler = nil
		DispatchQueue.main.async(execute: fn)
	}
	
	private func addObservers(to view: UIScrollView) {
		let options: NSKeyValueObservingOptions = [.new, .old]
		observers = [
			view.observe(\.contentOffset, options: options) {
				guard !self.isHidden else {return}
				self.scrollView($0, didChangeContentOffset: $1)
			},
			view.observe(\.contentSize, options: options, changeHandler: scrollView(_:didChangeContentSize:)),
		]
		pan = view.panGestureRecognizer
		if let pan = pan {
			observers.append(pan.observe(\.state, options: options) {
				guard !self.isHidden else {return}
				self.scrollViewPanGesture($0, didChangeState: $1)
			})
		}
	}
	
	private func removeObservers() {
		observers.forEach{$0.invalidate()}
		observers.removeAll()
		pan = nil
	}
}
