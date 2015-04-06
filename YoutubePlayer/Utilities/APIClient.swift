//
//  APIClient.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/06.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Alamofire
import Bolts

// Reference: github.com/Alamofire/Alamofire#generic-response-object-serialization
@objc public protocol ResponseCollectionSerializable {
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request {
    
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        
        let serializer: Serializer = {
            (request, response, data) in
            
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            
            if response != nil && JSON != nil {
                return (T.collection(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: {
            (request, response, object, error) in
            
            completionHandler(request, response, object as? [T], error)
        })
    }
}

struct APIClient {}

// MARK: - Fetch Videos Extension

extension APIClient {
    
    static func fetchMostPopularVideos(#pageToken: String?) -> BFTask {
        var source = BFTaskCompletionSource()
        var URLRequest = Router.MostPopular(pageToken: pageToken)
        
        Alamofire.request(URLRequest).responseJSON { (_, _, items, error) -> Void in
            
            if error == nil {
                source.setResult(items)
            } else {
                source.setError(error)
            }
        }
        
        return source.task
    }
}
