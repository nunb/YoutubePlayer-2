//
//  SearchViewController.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/05/04.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let kCellId = "Cell"
    
    // MARK: - Property
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = SearchViewModel()
    private var searchController: UISearchController?
    private var searchResultsController: SearchResultsViewController?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellId)
        
        searchResultsController = storyboard?
            .instantiateViewControllerWithIdentifier("SearchResultsViewController")
            as? SearchResultsViewController
        searchResultsController?.delegate = self
        
        searchController = UISearchController(searchResultsController: searchResultsController)
        searchController!.hidesNavigationBarDuringPresentation = false
        searchController!.delegate = self
        searchController!.searchBar.delegate = self
        
        navigationItem.titleView = searchController!.searchBar
        
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.histories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = viewModel.histories[indexPath.row]
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Search Histories"
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let query = searchBar.text
        
        searchResultsController?.search(query: query)
        viewModel.recordSearchHistory(query: query)
    }
}

extension SearchViewController: SearchResultsViewControllerDelegate {
    
    func searchResultDidSelect(result: VideoItem) {
        let videoVM = VideoViewModel(videoItem: result)
        
        let videoVC = storyboard?
            .instantiateViewControllerWithIdentifier("VideoViewController")
            as! VideoViewController
        
        videoVC.viewModel = videoVM
        
        navigationController?.showViewController(videoVC, sender: self)
    }
}

extension SearchViewController: UISearchControllerDelegate {
    
    func willDismissSearchController(searchController: UISearchController) {
        viewModel.refreshHistories()
        tableView.reloadData()
    }
}
