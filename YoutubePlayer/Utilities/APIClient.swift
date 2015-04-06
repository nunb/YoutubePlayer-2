//
//  APIClient.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/06.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Alamofire
import Bolts
import Realm


struct APIClient {}

// MARK: - Fetch Videos Extension

extension APIClient {
    
    static func fetchMostPopularVideos(#pageToken: String?) -> BFTask {
        var source = BFTaskCompletionSource()
        var URLRequest = Router.MostPopular(pageToken: pageToken)
        
        Alamofire.request(URLRequest).responseJSON { (_, _, json, error) in
            
            if error == nil {

                // Save in background
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    var videos = [VideoItem]()
                    
                    if let json: AnyObject = json {
                        videos = VideoItem.collection(representation: json)
                    }
                    
                    source.setResult(videos)
                }
            
            } else {
                source.setError(error)
            }
        }
        
        return source.task
    }
}
