//
//  PullLoadStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullLoadStateView: PullLoadView {
	
	/// To render title  with state, idle/refreshing/noMoreData are available.
	public var stateTitleRenderer: ((PullState)->String)?
	
    public var stateLabelMarginLeft: CGFloat
	public var shouldHideStateLabelWhileRefreshing = false
	
	private(set) var stateLabelGroup = PullStateLabelGroup()
	
	public override init(_ refreshment: @escaping () -> Void) {
		stateLabelMarginLeft = Self.stateLabelMarginLeft
		super.init(refreshment)
		Self.decorate(label: stateLabelGroup.view)
        addSubview(stateLabelGroup.view)
        
        stateLabelGroup.view.isUserInteractionEnabled = true
        stateLabelGroup.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(recognize(tapStateLabel:))))
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
        if stateLabelGroup.view.constraints.isEmpty {
			stateLabelGroup.view.frame = bounds
        }
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		if state == .refreshing && shouldHideStateLabelWhileRefreshing {
			stateLabelGroup.view.text = nil
		} else {
			stateLabelGroup.setText(state: state, default: stateTitleRenderer?(state))
		}
    }
	
	public func set(stateTitle: String, for state: PullState) {
		stateLabelGroup.stateTitles[state] = stateTitle
	}
	
	@objc private func recognize(tapStateLabel reco: UITapGestureRecognizer) {
        if state == .idle {
            beginRefresh()
        }
    }
}
