//
//  SearchResultsViewController.swift
//  YoutubePlayer
//
//  Created by Ryoichi Hara on 2015/04/30.
//  Copyright (c) 2015年 Ryoichi Hara. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    private let kCellId = "Cell"

    @IBOutlet weak var tableView: UITableView!
    
    var results = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellId)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SearchResultsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellId, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel?.text = results[indexPath.row]
        
        return cell
    }
}

extension SearchResultsViewController: UITableViewDelegate {
}
