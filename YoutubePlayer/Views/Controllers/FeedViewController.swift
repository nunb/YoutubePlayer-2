//
//  FeedViewController.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/07.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Bolts

class FeedViewController: UIViewController {

    private let viewModel = FeedViewModel()
    private let tableView = ASTableView(frame: .zeroRect, style: .Plain, asyncDataFetching: true)
    private let refreshControl = UIRefreshControl()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "YoutubePlayer"
        navigationController?.hidesBarsOnSwipe = true

        applyTheme()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        
        view.addSubview(tableView)

        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.Search,
            target: self,
            action: "searchButtonDidTouchUpInside:"
        )
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.items.count == 0 {
            refresh()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Action
    
    func searchButtonDidTouchUpInside(sender: UIBarButtonItem) {
        let searchVC = storyboard?
            .instantiateViewControllerWithIdentifier("SearchViewController")
            as! SearchViewController
        
        navigationController?.showViewController(searchVC, sender: self)
    }
    
    func refresh() {
        if viewModel.loading {
            return
        }
        
        viewModel
            .fetchMostPopularVideos(refresh: true)
            .continueWithBlock({ [weak self] (task: BFTask!) -> BFTask! in
                
                if let wself = self {
                    wself.refreshControl.endRefreshing()
                    
                    if task.error != nil {
                        println(task.error)
                    }
                    
                    wself.tableView.reloadData()
                }
                
                return nil
            })
    }
    
    // MARK: - Private
    
    private func applyTheme() {
        
        if let navigationController = navigationController {
            
            //navigationController.navigationBar.barTintColor = UIColor.customColor()
            
            setNeedsStatusBarAppearanceUpdate()
            
            let tintColor =
                UIColor(red: 233.0/255.0, green: 30.0/255.0, blue: 90.0/255.0, alpha: 1.0)
            
            navigationController.navigationBar.tintColor = tintColor
            
            navigationController.navigationBar.titleTextAttributes = [
                NSForegroundColorAttributeName: tintColor
            ]
        }
    }
}

extension FeedViewController: ASTableViewDataSource {
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let itemVM = viewModel.items[indexPath.row]
        
        return FeedVideoNode(viewModel: itemVM)
    }
}

extension FeedViewController: ASCommonTableViewDataSource {
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}

extension FeedViewController: ASTableViewDelegate {
    
    func tableView(tableView: ASTableView!, willBeginBatchFetchWithContext context: ASBatchContext!) {

        if !viewModel.loading &&
            viewModel.pagingEnabled && viewModel.items.count > 0 {
                
            viewModel
                .fetchMostPopularVideos(refresh: false)
                .continueWithBlock({ [weak self] (task: BFTask!) -> BFTask! in

                    if let wself = self {
                            
                        if task.error != nil {
                            println(task.error)
                        
                        } else if let newItems = task.result as? [FeedItemViewModel] {
                            let updatedItemCount = wself.viewModel.items.count
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
                })
        }
    }
    
    func shouldBatchFetchForTableView(tableView: ASTableView!) -> Bool {
        // TODO: No network connection
        
        return viewModel.items.count < viewModel.kMaxItemCount
    }
}

extension FeedViewController: ASCommonTableViewDelegate {
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let itemVM = viewModel.items[indexPath.row]
        let videoVM = VideoViewModel(itemViewModel: itemVM)
        
        let videoVC = storyboard?.instantiateViewControllerWithIdentifier("VideoViewController") as! VideoViewController
        videoVC.viewModel = videoVM
        
        navigationController?.showViewController(videoVC, sender: self)
    }
}
