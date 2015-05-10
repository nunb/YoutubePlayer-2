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

private var myContext = 0

class SearchResultsViewController: UIViewController {

    private let tableView = ASTableView(frame: .zeroRect, style: .Plain, asyncDataFetching: true)
    private let refreshControl = UIRefreshControl()
    private let viewModel = SearchResultsViewModel()
    private var footerView: FeedFooterView!
    var delegate: SearchResultsViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        footerView = {
            let nib = UINib(nibName: "FeedFooterView", bundle: nil)
            let view = nib.instantiateWithOwner(nil, options: nil).last as! FeedFooterView
            view.delegate = self
            view.state = .Neutral
            
            return view
        }()
        
        tableView.tableFooterView = footerView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.addObserver(self,
            forKeyPath: "pagingEnabled", options: .New, context: &myContext)
        viewModel.addObserver(self,
            forKeyPath: "loading", options: .New, context: &myContext)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Manually fix footerView frame for iPhone6+,
        footerView.frame = CGRect(
            x: footerView.frame.origin.x,
            y: footerView.frame.origin.y,
            width: tableView.frame.width,
            height: 50.0
        )
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!viewModel.pagingEnabled) {
            footerView.state = .BottomOfPage
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.removeObserver(self, forKeyPath: "pagingEnabled", context: &myContext)
        viewModel.removeObserver(self, forKeyPath: "loading", context: &myContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Key-Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context == &myContext {
            
            if keyPath == "pagingEnabled" && !viewModel.pagingEnabled {
                footerView.state = .BottomOfPage
            }
            
            if keyPath == "loading" {
                
                if viewModel.loading {
                    footerView.state = .Loading
                } else if footerView.state != .BottomOfPage {
                    footerView.state = .Neutral
                }
            }
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Action
    
    func refresh() {
        if viewModel.loading {
            return
        }
        
        viewModel
            .fetchSearchResults(query: viewModel.searchingQuery, refresh: true)
            .continueWithBlock { [weak self] (task: BFTask!) -> BFTask! in
            
                if let wself = self {
                    wself.refreshControl.endRefreshing()
                    
                    if task.error != nil {
                        println(task.error)
                    }
                
                    wself.tableView.reloadData()
                }
            
                return nil
            }
    }
    
    // MARK: - Public
    
    func search(#query: String?) {
        // FIXME: Change manually
        footerView.state = .Loading
        
        viewModel.fetchSearchResults(query: query, refresh: true).continueWithBlock {
            [weak self] (task: BFTask!) -> BFTask! in
            
            if let wself = self {
                if task.error != nil {
                    println(task.error)
                }
                
                wself.footerView.state = .Neutral
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
        } else {
            context.completeBatchFetching(true)
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

// MARK: - FeedFooterViewDelegate

extension SearchResultsViewController: FeedFooterViewDelegate {
    
    func footerView(footerView: FeedFooterView, didTouchUpInsideButton button: UIButton) {
    }
}
