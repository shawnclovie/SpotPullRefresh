//
//  PullRefreshStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullRefreshStateView: PullRefreshView {
	
	/// To render title  with state, idle/pulling/refreshing are available.
	public var stateTitleRenderer: ((PullState)->String)?
	
	public var lastUpdatedTimeTextRenderer: ((_ lastUpdatedTime: TimeInterval) -> String)?
	
	public let lastUpdatedTimeLabel = UILabel()
	private(set) var stateLabelGroup = PullStateLabelGroup()
	
	public var stateLabelMarginLeft: CGFloat
	
	public override init(_ refreshment: @escaping () -> Void) {
		stateLabelMarginLeft = Self.stateLabelMarginLeft
		super.init(refreshment)
		Self.decorate(label: lastUpdatedTimeLabel)
		addSubview(lastUpdatedTimeLabel)
		Self.decorate(label: stateLabelGroup.view)
		addSubview(stateLabelGroup.view)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public var stateLabel: UILabel {stateLabelGroup.view}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		guard !stateLabelGroup.view.isHidden else {return}
		if lastUpdatedTimeLabel.isHidden {
			if stateLabelGroup.view.constraints.isEmpty {
				stateLabelGroup.view.frame = bounds
			}
		} else {
			let height = bounds.height * 0.5
			if stateLabelGroup.view.constraints.isEmpty {
				stateLabelGroup.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
			}
			if lastUpdatedTimeLabel.constraints.isEmpty {
				lastUpdatedTimeLabel.frame = CGRect(x: 0, y: height, width: bounds.width, height: bounds.height - height)
			}
		}
	}
	
	open override func willMove(toSuperview newView: UIView?) {
		super.willMove(toSuperview: newView)
		updateStateLabel()
		updateLastUpdateTimeLabel()
	}
	
	var lastUpdatedTimeLabelWidth: CGFloat {
		lastUpdatedTimeLabel.isHidden ? 0 : lastUpdatedTimeLabel.font?.spot_renderSize(for: lastUpdatedTimeLabel.text).width ?? 0
	}
	
	public func set(stateTitle: String, for state: PullState) {
		stateLabelGroup.stateTitles[state] = stateTitle
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		updateStateLabel()
		updateLastUpdateTimeLabel()
	}
	
	private func updateStateLabel() {
		stateLabelGroup.setText(state: state, default: stateTitleRenderer?(state))
		setNeedsDisplay()
	}
	
	open func updateLastUpdateTimeLabel() {
		guard !lastUpdatedTimeLabel.isHidden, let fn = lastUpdatedTimeTextRenderer else {return}
		lastUpdatedTimeLabel.text = fn(Self.lastUpdatedTime)
		setNeedsDisplay()
	}
}
