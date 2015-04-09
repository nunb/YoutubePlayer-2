//
//  VideoViewController.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/08.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var playerMaskView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    var viewModel: VideoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        playerView.delegate = self
        
        if let viewModel = viewModel {
            
            if let videoId = viewModel.videoId {
                playerView.loadWithVideoId(videoId, playerVars: ["showinfo": 0])
                indicator.startAnimating()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "playerMaskDidTap:")
        playerMaskView.addGestureRecognizer(tapGesture)
        playerMaskView.userInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Action
    
    func playerMaskDidTap(sender: AnyObject) {
        playerView.playVideo()
    }
}

extension VideoViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        
        // FIX: github.com/youtube/youtube-ios-player-helper/issues/86
        let intervalId = playerView.webView
            .stringByEvaluatingJavaScriptFromString("window.setInterval('', 9999);")

        if let intervalId = intervalId {
            playerView.webView
                .stringByEvaluatingJavaScriptFromString(
                    "for (var i = 1; i < \(intervalId); i++) { window.clearInterval(i); }")
        }
        
        UIView.animateWithDuration(0.6,
            animations: {
                self.playerMaskView.backgroundColor = UIColor.clearColor()
            },
            completion: { (finished) in
                if finished {
                    self.indicator.stopAnimating()
                }
            })
    }
}
