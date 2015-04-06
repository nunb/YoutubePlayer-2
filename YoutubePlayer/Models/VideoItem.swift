//
//  VideoItem.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/06.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation
import Realm

class VideoItem: RLMObject {
    dynamic var itemId = ""
    dynamic var title = ""
    dynamic var itemDescription = ""

    override class func primaryKey() -> String! {
        return "itemId"
    }
}
