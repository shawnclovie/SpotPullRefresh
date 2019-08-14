//
//  UIScrollView+.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

private var headerKey: UInt8 = 0
private var footerKey: UInt8 = 0

extension UIScrollView {
	
	public var spot_pullDownRefreshView: PullRefreshView? {
		get {objc_getAssociatedObject(self, &headerKey) as? PullRefreshView}
		set(view) {
			let oldValue = spot_pullDownRefreshView
			guard oldValue != view else {return}
			oldValue?.removeFromSuperview()
			view.map{self.insertSubview($0, at: 0)}
			objc_setAssociatedObject(self, &headerKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	public var spot_pullUpLoadView: PullLoadView? {
		get {objc_getAssociatedObject(self, &footerKey) as? PullLoadView}
		set(view) {
			let oldValue = spot_pullUpLoadView
			guard oldValue != view else {return}
			oldValue?.removeFromSuperview()
			view.map{self.insertSubview($0, at: 0)}
			objc_setAssociatedObject(self, &footerKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
    public var spot_inset: UIEdgeInsets {
		if #available(iOS 11.0, *) {
			return adjustedContentInset
		}
		return contentInset
    }
	
	public func spot_set(inset keyPath: WritableKeyPath<UIEdgeInsets, CGFloat>, _ value: CGFloat) {
		var value = value
		if #available(iOS 11.0, *) {
			value -= (adjustedContentInset[keyPath: keyPath] - contentInset[keyPath: keyPath])
		}
		contentInset[keyPath: keyPath] = value
	}
	
	public func spot_increase(inset keyPath: WritableKeyPath<UIEdgeInsets, CGFloat>, _ value: CGFloat) {
		spot_set(inset: keyPath, value + spot_inset[keyPath: keyPath])
	}
}
