//
//  SearchResultsViewController.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/30.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Bolts


@objc protocol SearchResultsViewControllerDelegate {
    optional func searchResultDidSelect(result: FeedItemViewModel)
}

class SearchResultsViewController: UIViewController {

    private let tableView = ASTableView()
    private let viewModel = SearchResultsViewModel()
    var delegate: SearchResultsViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        
        view.addSubview(tableView)
        
        // TODO: Pagination
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Public
    
    func search(#query: String?) {
        viewModel.fetchSearchResults(query: query, refresh: true).continueWithBlock {
            (task) -> AnyObject! in
            
            if task.error != nil {
                println(task.error)
            }
            
            self.tableView.reloadData()
            
            return nil
        }
    }
}

extension SearchResultsViewController: ASTableViewDataSource {
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let itemVM = viewModel.results[indexPath.row]
        
        return FeedVideoNode(viewModel: itemVM)
    }
}

extension SearchResultsViewController: ASCommonTableViewDataSource {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }
}

extension SearchResultsViewController: ASTableViewDelegate {
}

extension SearchResultsViewController: ASCommonTableViewDelegate {
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let itemVM = viewModel.results[indexPath.row]

        delegate?.searchResultDidSelect!(itemVM)
    }
}
