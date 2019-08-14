//
//  PullLoadAnimationStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullLoadAnimationStateView: PullLoadStateView {

    var imageViewGroup = PullAnimatableImageViewGroup()
	
	public override init(_ refreshment: @escaping () -> Void) {
		super.init(refreshment)
        addSubview(imageViewGroup.view)
        stateLabelMarginLeft = 20
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		guard imageViewGroup.view.constraints.isEmpty else {return}
        imageViewGroup.view.frame = bounds
        if shouldHideStateLabelWhileRefreshing {
            imageViewGroup.view.contentMode = .center
        } else {
            imageViewGroup.view.contentMode = .right
            imageViewGroup.view.bounds.size.width = bounds.width * 0.5 - stateLabelGroup.textWidth * 0.5 - stateLabelMarginLeft
        }
    }
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		switch state {
		case .refreshing:
			imageViewGroup.setImages(state: state)
		case .idle, .noMoreData:
			imageViewGroup.view.stopAnimating()
			imageViewGroup.view.isHidden = true
		default:break
		}
    }
	
	public func set(images: [UIImage], _ duration: TimeInterval = -1, for state: PullState) {
		imageViewGroup.set(images: images, duration, for: state)
	}
}
