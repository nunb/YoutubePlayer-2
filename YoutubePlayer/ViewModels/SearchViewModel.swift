//
//  SearchViewModel.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/06.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import Foundation


class SearchViewModel: NSObject {
    private(set) var histories = [String]()
    
    override init() {
        super.init()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        histories = userDefaults.searchHistories()
    }
    
    func recordSearchHistory(#query: String?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.addSearchHistory(query)
    }
}
