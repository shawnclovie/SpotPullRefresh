//
//  PullStateLabelGroup.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

struct PullStateLabelGroup {
	let view = UILabel()
	var stateTitles: [PullState: String] = [:]
	
	var textWidth: CGFloat {
		view.font?.spot_renderSize(for: view.text).width ?? 0
	}
	
	func setText(state: PullState, default: @autoclosure ()->String?) {
		view.text = stateTitles[state] ?? `default`()
	}
}

struct PullAnimatableImageViewGroup {
	let view = UIImageView()
	var stateImages: [PullState: [UIImage]] = [:]
	private var stateDurations: [PullState: TimeInterval] = [:]
	
	func setImages(state: PullState) {
		view.stopAnimating()
		guard let images = stateImages[state], !images.isEmpty else {return}
		if images.count == 1 {
			view.image = images[0]
		} else {
			view.animationImages = images
			view.animationDuration = stateDurations[state] ?? 0
			view.startAnimating()
		}
	}
	
	mutating func set(images: [UIImage], _ duration: TimeInterval = -1, for state: PullState) {
		stateImages[state] = images
		stateDurations[state] = duration >= 0 ? duration : Double(images.count) * 0.1
		if let image = images.first, image.size.height > view.bounds.height {
			view.bounds.size.height = image.size.height
		}
	}
}
