//
//  PullLoadIndicationStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullLoadIndicationStateView: PullLoadStateView {

    public var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
		get {loadingView.style}
        set {
            loadingView.style = newValue
            setNeedsLayout()
        }
    }
    
	public let loadingView = UIActivityIndicatorView(style: .gray)
    
	public override init(_ refreshment: @escaping () -> Void) {
		super.init(refreshment)
        addSubview(loadingView)
        loadingView.hidesWhenStopped = true
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		let size = bounds.size
        loadingView.center = CGPoint(
			x: size.width * 0.5 - (shouldHideStateLabelWhileRefreshing ? 0 : stateLabelGroup.textWidth * 0.5 + stateLabelMarginLeft),
			y: size.height * 0.5)
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		if state == .noMoreData || state == .idle {
			loadingView.stopAnimating()
		} else if state == .refreshing {
			loadingView.startAnimating()
		}
    }
}
