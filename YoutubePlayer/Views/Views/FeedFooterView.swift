//
//  FeedFooterView.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/10.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit

enum FeedFooterViewState {
    case Neutral, Loading, BottomOfPage, Error
}

final class FeedFooterView: UIView {
    
    // MARK: - Property
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var state: FeedFooterViewState = .Neutral {
        didSet {
            update(state: state)
        }
    }
    
    weak var delegate: FeedFooterViewDelegate?
    
    // MARK: - Action
    
    @IBAction func buttonDidTouchUpInside(sender: UIButton) {
        delegate?.footerView(self, didTouchUpInsideButton: sender)
    }
    
    // MARK: - Private
    
    private func update(#state: FeedFooterViewState) {
        var hidden       = false
        var buttonHidden = false
        var buttonTitle: String? = nil
        var shouldStartAnimating = false
        
        switch state {
        case .Neutral:
            hidden = true
            buttonHidden = true
            buttonTitle = NSLocalizedString("footerTitleBottomOfPage", comment: "")
            
        case .Loading:
            buttonHidden = true
            shouldStartAnimating = true
            
        case .BottomOfPage:
            buttonTitle = NSLocalizedString("footerTitleBottomOfPage", comment: "")
            
        case .Error:
            buttonTitle = NSLocalizedString("footerTitleError", comment: "")
        }
        
        if shouldStartAnimating {
            indicator.startAnimating()
        } else {
            indicator.stopAnimating()
        }
        
        button.setTitle(buttonTitle, forState: .Normal)
        button.hidden = buttonHidden
        self.hidden = hidden
    }
}

@objc protocol FeedFooterViewDelegate {
    func footerView(footerView: FeedFooterView, didTouchUpInsideButton button: UIButton)
}
