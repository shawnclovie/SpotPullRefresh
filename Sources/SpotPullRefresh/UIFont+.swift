//
//  UIFont+.swift
//  SpotPullRefresh
//
//  Created by Shawn Clovie on 14/8/2019.
//  Copyright © 2018 Spotlit Club. All rights reserved.
//

import UIKit

extension UIFont {
	/// Calculate size for rendering string.
	///
	/// - Parameters:
	///   - text: String to render with the font
	///   - constrainedSize: Constrained size, default by (.greatestFiniteMagnitude, .greatestFiniteMagnitude)
	///   - lineBreakMode: Line break mode, default by word wrapping
		func spot_renderSize(for text: String?,
							 constrainedSize: CGSize = .init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
							 _ lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
		guard let text = text, !text.isEmpty else {return .zero}
		let paraStyle = NSMutableParagraphStyle()
		paraStyle.lineBreakMode = lineBreakMode
		return (text as NSString)
			.boundingRect(with: constrainedSize, options: [.usesLineFragmentOrigin],
						  attributes: [.font: self, .paragraphStyle: paraStyle],
						  context: nil)
			.size
	}
}

