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
	
	static let keyPathContentOffset = "contentOffset"
	static let keyPathContentSize = "contentSize"
	static let keyPathState = "state"
	
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
	public private(set) weak var superScrollView: UIScrollView?
	
	public init(_ refreshment: @escaping ()->Void) {
		self.refreshment = refreshment
		super.init(frame: .zero)
		autoresizingMask = .flexibleWidth
		backgroundColor = .clear
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var isRefreshing: Bool {
		state == .refreshing || state == .willRefresh
	}
	
	override open func willMove(toSuperview newView: UIView?) {
		super.willMove(toSuperview: newView)
		removeObservers()
		guard let scrollView = newView as? UIScrollView else {return}
		superScrollView = scrollView
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
	
	open func scrollView(_ view: UIScrollView, didChangeContentOffset change: [NSKeyValueChangeKey : Any]?) {}
	
	open func scrollView(_ view: UIScrollView, didChangeContentSize change: [NSKeyValueChangeKey : Any]?) {}
	
	open func scrollViewPanGesture(_ view: UIScrollView, didChangeState change: [NSKeyValueChangeKey : Any]?) {}
	
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
		view.addObserver(self, forKeyPath: Self.keyPathContentOffset, options: options, context: nil)
		view.addObserver(self, forKeyPath: Self.keyPathContentSize, options: options, context: nil)
		pan = view.panGestureRecognizer
		pan?.addObserver(self, forKeyPath: Self.keyPathState, options: options, context: nil)
	}
	
	private func removeObservers() {
		if let view = superview {
			view.removeObserver(self, forKeyPath: Self.keyPathContentOffset)
			view.removeObserver(self, forKeyPath: Self.keyPathContentSize)
		}
		pan?.removeObserver(self, forKeyPath: Self.keyPathState)
		pan = nil
	}
	
	open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard isUserInteractionEnabled,
			let view = superScrollView else {return}
		if keyPath == Self.keyPathContentSize {
			scrollView(view, didChangeContentSize: change)
		}
		if !isHidden {
			switch keyPath {
			case Self.keyPathContentOffset:
				self.scrollView(view, didChangeContentOffset: change)
			case Self.keyPathState:
				self.scrollViewPanGesture(view, didChangeState: change)
			default:break
			}
		}
	}
}
