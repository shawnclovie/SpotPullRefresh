//
//  PullRefreshView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullRefreshView: PullBaseView {
	
	private static let lastUpdatedTimeKey = "\(DNSPrefix)PullRefresh.LastUpdatedTime"
	static var lastUpdatedTime: TimeInterval {
		get {UserDefaults.standard.double(forKey: lastUpdatedTimeKey)}
		set {
			let user = UserDefaults.standard
			user.set(newValue, forKey: lastUpdatedTimeKey)
			user.synchronize()
		}
	}
	
    public var ignoredScrollViewContentInsetTop: CGFloat = 0 {
        didSet {
            frame.origin.y = -bounds.height - ignoredScrollViewContentInsetTop
        }
    }
	
    private var insetTopDelta: CGFloat = 0
	private var scrollViewOriginalInset: UIEdgeInsets?
	
	public override init(_ refreshment: @escaping () -> Void) {
		super.init(refreshment)
		bounds.size.height = Self.headerHeight
    }
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func willMove(toSuperview newView: UIView?) {
		super.willMove(toSuperview: newView)
		// record initial contentInset
		scrollViewOriginalInset = (newView as? UIScrollView)?.spot_inset
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		// position y should be changed since height changed
		frame.origin.y = -bounds.height - ignoredScrollViewContentInsetTop
    }
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		switch state {
		case .idle:
			if oldValue != .refreshing {break}
			Self.lastUpdatedTime = Date().timeIntervalSince1970
			UIView.animate(withDuration: Self.slowAnimationDuration, animations: {
				if let view = self.superScrollView {
					view.spot_increase(inset: \.top, self.insetTopDelta)
				}
				if self.shouldGraduallyAlpha {
					self.alpha = 0
				}
			}) { (finished) in
				self.set(pullingPercent: 0)
				self.executeEndRefreshingHandler()
			}
		case .refreshing:
			DispatchQueue.main.async { [weak self] in
				guard let self = self,
					let originalInset = self.scrollViewOriginalInset,
					let scrollView = self.superScrollView else {return}
				UIView.animate(withDuration: Self.fastAnimationDuration, animations: {
					let top = originalInset.top + self.bounds.height
					scrollView.spot_set(inset: \.top, top)
					scrollView.contentOffset.y = -top
				}, completion: { (_) in
					self.executeBeginRefreshingHandlers()
				})
			}
		default:break
		}
    }
    
	open override func scrollView(_ view: UIScrollView, didChangeContentOffset change: [NSKeyValueChangeKey : Any]?) {
		super.scrollView(view, didChangeContentOffset: change)
        guard let scrollView = superScrollView,
			let originalInset = scrollViewOriginalInset
			else {return}
		let offsetY = scrollView.contentOffset.y
        if state == .refreshing {
            // do nothing if wasn't attach to any window
            if window == nil {
				return
			}
            // fix sectionheader holding
            var insetTop = max(-offsetY, originalInset.top)
            insetTop = min(insetTop, (bounds.height + originalInset.top))
			scrollView.spot_set(inset: \.top, insetTop)
            insetTopDelta = originalInset.top - insetTop
            return
        }
		// contentInset may changed if view controller changed
        scrollViewOriginalInset = scrollView.spot_inset
        if offsetY > -originalInset.top {
			// do nothing if scroll up not enough
            return
        }
        let pullingOffsetY = -originalInset.top - bounds.height
        let pullingPercent = (-originalInset.top - offsetY) / bounds.height
        if scrollView.isDragging {
			set(pullingPercent: pullingPercent)
            if state == .idle && offsetY < pullingOffsetY {
				set(state: .pulling)
            } else if state == .pulling && offsetY >= pullingOffsetY {
                set(state: .idle)
            }
        } else if state == .pulling {
            beginRefresh()
        } else if pullingPercent < 1 {
            set(pullingPercent: pullingPercent)
        }
    }
}
