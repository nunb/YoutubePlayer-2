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
        
        Alamofire.request(URLRequest).responseJSON {
            (_, _, JSONDictionary, error) in
            
            if error == nil {

                // Save in background
                var result: [String: AnyObject]!
                var videos = [VideoItem]()
                var nextPageToken: String?
                    
                if let JSONDictionary: AnyObject = JSONDictionary {
                    let json = JSON(JSONDictionary)
                    videos = VideoItem.collection(json: json)
                        
                    if let pageToken = json["nextPageToken"].string {
                        nextPageToken = pageToken
                    }
                }

                result = ["videos": videos]
                    
                if let nextPageToken = nextPageToken {
                    result["nextPageToken"] = nextPageToken
                }
                    
                source.setResult(result)
                
            } else {
                source.setError(error)
            }
        }
        
        return source.task
    }
}
