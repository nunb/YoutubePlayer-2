//
//  User.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/12.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var userId = "1"
    
    // MARK: - Relation
    
    dynamic let bookmarks = List<VideoItem>()
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}
