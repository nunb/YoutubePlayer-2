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

    private let tableView = ASTableView(frame: .zeroRect, style: .Plain, asyncDataFetching: true)
    private let viewModel = SearchResultsViewModel()
    var delegate: SearchResultsViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        
        view.addSubview(tableView)
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
            [weak self] (task: BFTask!) -> BFTask! in
            
            if let wself = self {
                if task.error != nil {
                    println(task.error)
                }
                
                wself.tableView.reloadData()
            }
            
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
    
    func tableView(tableView: ASTableView!, willBeginBatchFetchWithContext context: ASBatchContext!) {
        
        if !viewModel.loading &&
            viewModel.pagingEnabled && viewModel.results.count > 0 {
                
            viewModel
                .fetchSearchResults(query: viewModel.searchingQuery, refresh: false)
                .continueWithBlock { [weak self] (task: BFTask!) -> BFTask! in
                    
                    if let wself = self {
                        
                        if task.error != nil {
                            println(task.error)
                            
                        } else if let newItems = task.result as? [FeedItemViewModel] {
                            let updatedItemCount = wself.viewModel.results.count
                            let firstIndex = updatedItemCount - newItems.count
                            
                            var indexPaths = [NSIndexPath]()
                            
                            for index in firstIndex..<updatedItemCount {
                                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                                indexPaths.append(indexPath)
                            }
                            
                            wself.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                        }
                        
                        context.completeBatchFetching(true)
                    }
                    
                    return nil
                }
        }
    }
    
    func shouldBatchFetchForTableView(tableView: ASTableView!) -> Bool {
        // TODO: No network connection
        
        return viewModel.results.count < viewModel.kMaxItemCount
    }
}

extension SearchResultsViewController: ASCommonTableViewDelegate {
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let itemVM = viewModel.results[indexPath.row]

        delegate?.searchResultDidSelect!(itemVM)
    }
}
