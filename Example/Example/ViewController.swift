//
//  ViewController.swift
//  Example
//
//  Created by Artur Mkrtchyan on 10/8/18.
//  Copyright © 2018 arturdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    let kMaxItemCount = 30
    let kPageLength   = 10
    
    var items: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.am.addPullToRefresh { [unowned self] in
            self.fetchDataFromStart(completion: { (fetchedItems) in
                self.items = fetchedItems
                self.tableView.reloadData()
                self.tableView.am.pullToRefreshView?.stopRefreshing()
            })
        }
        
        tableView.am.addInfiniteScrolling { [unowned self] in
            self.fetchMoreData(completion: { (fetchedItems) in
                self.items.append(contentsOf: fetchedItems)
                self.tableView.reloadData()
                self.tableView.am.infiniteScrollingView?.stopRefreshing()
                if fetchedItems.count == 0 {
                    //No more data is available
                    self.tableView.am.infiniteScrollingView?.hideInfiniteScrollingView()
                }
            })
        }
        tableView.am.pullToRefreshView?.trigger()
    }
    
    func fetchDataFromStart(completion handler:@escaping (_ fetchedItems: [Int])->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let fetchedItems = Array(0..<self.kPageLength)
            handler(fetchedItems)
        }
    }
    
    func fetchMoreData(completion handler:@escaping (_ fetchedItems: [Int])->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.items.count >= self.kMaxItemCount {
                handler([])
                return
            }
            
            let fetchedItems = Array(self.items.count..<(self.items.count + self.kPageLength))
            handler(fetchedItems)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = "Item \(indexPath.row)"
        return cell!
    }
}

