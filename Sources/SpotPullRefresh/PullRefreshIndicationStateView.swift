//
//  PullRefreshIndicationStateView.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

open class PullRefreshIndicationStateView: PullRefreshStateView {
	
	public let arrowView = UIImageView()
	public let loadingView = UIActivityIndicatorView(style: .gray)
	
	public var shouldAnimateArrowView = false {
		didSet {
			circleLayer.isHidden = !shouldAnimateArrowView
		}
	}
	
	public let circleLayer = CAShapeLayer()
	
	public override init(_ refreshment: @escaping () -> Void) {
		super.init(refreshment)
		arrowView.contentMode = .scaleAspectFill
		addSubview(arrowView)
		loadingView.hidesWhenStopped = true
		addSubview(loadingView)
		circleLayer.fillColor = UIColor.clear.cgColor
		circleLayer.strokeColor = UIColor.gray.cgColor
		circleLayer.lineWidth = 1.5
		circleLayer.lineCap = .round
		circleLayer.strokeStart = 0
		circleLayer.speed = 2
		circleLayer.bounds = CGRect(x: 0, y: 0, width: 36, height: 36)
		circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: 18, y: 18), radius: 18, startAngle: -.pi / 2, endAngle: .pi * 3 / 2, clockwise: true).cgPath
		circleLayer.isHidden = true
		layer.addSublayer(circleLayer)
		// since arrowView.image may over size
		clipsToBounds = true
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
		get {loadingView.style}
		set {
			loadingView.style = newValue
			setNeedsLayout()
		}
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		var arrowCenter = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
		if !stateLabelGroup.view.isHidden {
			let textWidth = max(stateLabelGroup.textWidth, lastUpdatedTimeLabelWidth)
			arrowCenter.x -= textWidth / 2 + stateLabelMarginLeft
		}
		if arrowView.constraints.isEmpty {
			if let image = arrowView.image {
				arrowView.bounds = CGRect(origin: .zero, size: image.size)
			}
			arrowView.center = arrowCenter
			circleLayer.position = arrowCenter
		}
		arrowView.tintColor = Self.labelTextColor
		if loadingView.constraints.isEmpty {
			loadingView.center = arrowCenter
		}
	}
	
	open override func set(pullingPercent: CGFloat) {
		super.set(pullingPercent: pullingPercent)
		if shouldAnimateArrowView {
			UIView.animate(withDuration: 0.1) {
				let percent = pullingPercent
				self.circleLayer.strokeEnd = percent
				self.arrowView.transform = CGAffineTransform(rotationAngle: .pi * 2 * min(1, percent) - .pi)
			}
		}
	}
	
	open override func stateDidChange(oldValue: PullState) {
		super.stateDidChange(oldValue: oldValue)
		switch state {
		case .idle:
			if oldValue == .refreshing {
				arrowView.transform = .identity
				UIView.animate(withDuration: Self.slowAnimationDuration, animations: {
					self.loadingView.alpha = 0
				}) { (finished) in
					// 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
					guard self.state == .idle else {return}
					self.loadingView.alpha = 1
					self.loadingView.stopAnimating()
					self.arrowView.isHidden = false
					if self.shouldAnimateArrowView {
						self.circleLayer.isHidden = false
					}
				}
			} else {
				loadingView.stopAnimating()
				arrowView.isHidden = false
				if shouldAnimateArrowView {
					circleLayer.isHidden = false
					UIView.animate(withDuration: Self.fastAnimationDuration) {
						self.arrowView.transform = .init(rotationAngle: .pi)
					}
				} else {
					UIView.animate(withDuration: Self.fastAnimationDuration) {
						self.arrowView.transform = .identity
					}
				}
			}
		case .pulling:
			loadingView.stopAnimating()
			arrowView.isHidden = false
			if shouldAnimateArrowView {
				circleLayer.isHidden = false
			} else {
				UIView.animate(withDuration: Self.fastAnimationDuration) {
					self.arrowView.transform = .init(rotationAngle: .pi)
				}
			}
		case .refreshing:
			if shouldAnimateArrowView {
				circleLayer.isHidden = true
			}
			// 防止refreshing -> idle的动画完毕动作没有被执行
			loadingView.alpha = 1
			loadingView.startAnimating()
			arrowView.isHidden = true
		default:break
		}
	}
}
