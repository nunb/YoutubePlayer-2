//
//  SearchResultsViewModel.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/05.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit
import Bolts

class SearchResultsViewModel: NSObject {
    
    let kMaxItemCount = 100
    
    private(set) var results = [FeedItemViewModel]()
    private(set) var loading = false
    private(set) var pagingEnabled = true
    private(set) var searchingQuery: String?
    private var nextPageToken: String?
   
    override init() {
        super.init()
    }
    
    func fetchSearchResults(#query: String?, refresh: Bool) -> BFTask {
        var fetchTask = BFTask(result: nil)
        
        loading = true
        
        if refresh {
            searchingQuery = nil
            nextPageToken = nil
        }
        
        // For pagination
        searchingQuery = query
        
        fetchTask = fetchTask.continueWithBlock({ (task) -> AnyObject! in
            return APIClient.searchVideos(query: query, pageToken: self.nextPageToken)
        })
        
        fetchTask = fetchTask.continueWithSuccessBlock({ (task) -> AnyObject! in
            if let dictionary = task.result as? [String: AnyObject] {
                var items = [FeedItemViewModel]()
                
                if let videos = dictionary["videos"] as? [VideoItem] {
                    items = videos.map { (video: VideoItem) -> FeedItemViewModel in
                        return FeedItemViewModel(item: video)
                    }
                    
                    if refresh {
                        self.results = items
                    } else {
                        self.results += items
                    }
                }
                
                if let nextPageToken = dictionary["nextPageToken"] as? String {
                    self.nextPageToken = nextPageToken
                } else {
                    self.pagingEnabled = false
                }
                
                return BFTask(result: items)
            }
            
            return task
        })
        
        fetchTask = fetchTask.continueWithBlock({ (task) -> AnyObject! in
            self.loading = false
            
            return task
        })
        
        return fetchTask
    }
}
