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
    
    private var searchController: UISearchController?
    
    // TODO: Search History
    var histories = [String]()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellId)
        
        let searchResultsVC = storyboard?
            .instantiateViewControllerWithIdentifier("SearchResultsViewController")
            as! SearchResultsViewController
        
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController!.hidesNavigationBarDuringPresentation = false
        
        navigationItem.titleView = searchController!.searchBar
        
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = histories[indexPath.row]
        
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
}
