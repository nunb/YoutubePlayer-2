//
//  Thumbnail.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/06.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation
import Realm

class Thumbnail: RLMObject {
    dynamic var resolution = ""  // default, medium, high, standard, maxres
    dynamic var url        = ""
    dynamic var width      = 0
    dynamic var height     = 0
}
