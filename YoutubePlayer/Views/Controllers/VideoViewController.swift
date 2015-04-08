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
        
        playerView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        
        if let viewModel = viewModel {
            
            if let videoId = viewModel.videoId {
                playerView.loadWithVideoId(videoId, playerVars: nil)
                indicator.startAnimating()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension VideoViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        println("playerViewDidBecomeReady:")
        
        UIView.animateWithDuration(1.0,
            animations: {
                self.playerMaskView.alpha = 0.0
            },
            completion: { (finished) in
                if finished {
                    self.indicator.stopAnimating()
                    self.playerMaskView.removeFromSuperview()
                }
            })
        //playerView.playVideo()
    }
}
