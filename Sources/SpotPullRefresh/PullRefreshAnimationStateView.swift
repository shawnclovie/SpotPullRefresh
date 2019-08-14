//
//  PullRefreshAnimationStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullRefreshAnimationStateView: PullRefreshStateView {

	private var imageViewGroup = PullAnimatableImageViewGroup()
	
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
		if stateLabelGroup.view.isHidden && lastUpdatedTimeLabel.isHidden {
			imageViewGroup.view.contentMode = .center
		} else {
			imageViewGroup.view.contentMode = .right
			let textWidth = max(stateLabelGroup.textWidth, lastUpdatedTimeLabelWidth)
			imageViewGroup.view.bounds.size.width = bounds.width * 0.5 - textWidth * 0.5 - stateLabelMarginLeft
		}
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		switch state {
		case .pulling, .refreshing:
			imageViewGroup.setImages(state: state)
		case .idle:
			imageViewGroup.view.stopAnimating()
		default:break
		}
	}
	
	open override func set(pullingPercent: CGFloat) {
		super.set(pullingPercent: pullingPercent)
		guard state == .idle,
			let images = imageViewGroup.stateImages[.idle], !images.isEmpty
			else {return}
		imageViewGroup.view.stopAnimating()
		let index = min(Int(CGFloat(images.count) * pullingPercent), images.count - 1)
		imageViewGroup.view.image = images[index]
	}
	
	public func set(images: [UIImage], _ duration: TimeInterval = -1, for state: PullState) {
		imageViewGroup.set(images: images, duration, for: state)
	}
}
