//
//  ViewController.swift
//  AMRefresher
//
//  Created by Artur Mkrtchyan on 10/3/18.
//  Copyright © 2018 arturdev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var items = 11
    var maxItems = 20
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.am.addPullToRefresh {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.scrollView.am.pullToRefreshView?.stopRefreshing()
            })
        }
        
        scrollView.am.addInfiniteScrolling {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.items = min(self.maxItems, self.items + 3)
                (self.scrollView as? UITableView)?.reloadData()
                self.scrollView.am.infiniteScrollingView?.stopRefreshing()
                if self.items >= self.maxItems {
                    self.scrollView.am.infiniteScrollingView?.hideInfiniteScrollingView()
                }
            })
        }
    }

    func setupParallaxHeader() {
        let headerView = UIImageView(image: #imageLiteral(resourceName: "bg"))
        headerView.contentMode = .scaleAspectFill
        scrollView.parallaxHeader.view = headerView
        scrollView.parallaxHeader.height = 150
        scrollView.parallaxHeader.mode = .fill
        scrollView.parallaxHeader.minimumHeight = 20
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = "\(indexPath.row)"
        
        return cell!
    }
}

