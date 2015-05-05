//
//  NSUserDefaultsExtensions.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/05.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation


extension NSUserDefaults {
    
    func searchHistories() -> [String] {
        if let histories = arrayForKey("searchHistories") as? [String] {
            return histories
        }
        
        return [String]()
    }
    
    func addSearchHistory(query: String?) {
        if let query = query {
            var histories = searchHistories()
            
            if !contains(histories, query) {
                histories.append(query)
            } else {
                // TODO: Re-sorting
            }
            
            setObject(histories, forKey: "searchHistories")
            synchronize()
        }
    }
    
    func clearSearchHistories() {
        removeObjectForKey("searchHistories")
        synchronize()
    }
}
