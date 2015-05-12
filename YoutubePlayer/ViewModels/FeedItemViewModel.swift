//
//  FeedItemViewModel.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/07.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation
import RealmSwift

class FeedItemViewModel: NSObject {
    
    private(set) var itemId: String
    private(set) var title: String?
    private(set) var itemDescription: String?
    private(set) var publishedAt: NSDate?
    private(set) var thumbnailUrl: String?
    
    var bookmarked = false
    
    init(item: VideoItem) {
        //
        // Sharing Realm instances across threads is not supported.
        //
        // Reference: realm.io/docs/swift/latest/#using-a-realm-across-threads
        //
        itemId = item.itemId
        title = item.title
        itemDescription = item.itemDescription
        publishedAt = item.publishedAt
        
        let realm = Realm()
        
        if let user = realm.objectForPrimaryKey(User.self, key: "1") {
            let predicate = NSPredicate(format: "itemId = %@", itemId)
            let results = user.bookmarks.filter(predicate)

            if results.count > 0 {
                bookmarked = true
            }
        }
        
        let resolutions = ["maxres", "standard", "high", "medium", "default"]
        
        for resolution in resolutions {
            let predicate = NSPredicate(format: "resolution = %@", resolution)
            let results = item.thumbnails.filter(predicate)

            if results.count > 0 {
                
                if let thumbnail = results.last {
                    thumbnailUrl = thumbnail.url
                }
                
                break
            }
        }
        
        super.init()
    }
}
