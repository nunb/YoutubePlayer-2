//
//  VideoViewModel.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/08.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation


class VideoViewModel: NSObject {
    private(set) var videoId        : String?
    private(set) var title          : String?
    private(set) var itemDescription: String?
    
    init(itemViewModel: FeedItemViewModel) {
        super.init()
        
        videoId = itemViewModel.itemId
        title   = itemViewModel.title
        itemDescription = itemViewModel.itemDescription
    }
}
