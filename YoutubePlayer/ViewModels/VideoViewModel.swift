//
//  VideoViewModel.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/08.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation
import RealmSwift

class VideoViewModel: NSObject {
    private(set) var videoId        : String?
    private(set) var title          : String?
    private(set) var itemDescription: String?
    dynamic private(set) var bookmarked = false
    
    private var itemViewModel: FeedItemViewModel?
    
    init(itemViewModel: FeedItemViewModel) {
        super.init()
        
        videoId = itemViewModel.itemId
        title   = itemViewModel.title
        itemDescription = itemViewModel.itemDescription
        bookmarked = itemViewModel.bookmarked
        
        self.itemViewModel = itemViewModel
    }
    
    func bookmark() {
        let realm = Realm()
        
        if let videoId = videoId {
            
            if let user = realm.objectForPrimaryKey(User.self, key: "1") {
                
                if let videoItem = realm.objectForPrimaryKey(VideoItem.self, key: videoId) {
                    realm.beginWrite()
                    
                    if let index = user.bookmarks.indexOf(videoItem) {
                        user.bookmarks.removeAtIndex(index)
                        bookmarked = false
                    } else {
                        user.bookmarks.append(videoItem)
                        bookmarked = true
                    }
                    
                    realm.commitWrite()
                    
                    // Update feed item property
                    if let itemViewModel = itemViewModel {
                        itemViewModel.bookmarked = bookmarked
                    }
                }
            }
        }
    }
}
