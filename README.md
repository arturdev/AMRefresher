# AMRefresher
Super easy way to use "Pull To Refresh" and "Infinite Scrolling" with 1 line of code

<img src="https://raw.githubusercontent.com/arturdev/AMRefresher/master/demo.gif">


## Usage

Adding PullToRefresh and InfiniteScroll to any <b>UIScrollView</b> is pretty easy: 

```Swift
override func viewDidLoad() {
    super.viewDidLoad()

    //Adding Pull To Refresh
    tableView.am.addPullToRefresh { [unowned self] in
        //Do your heavy job.
        //modify your datasource
        //...
        self.tableView.reloadData() //or insert cells at top of tableView
        self.tableView.am.pullToRefreshView?.stopRefreshing()
    }
 
    //Adding Infinite Scrolling
    tableView.am.addInfiniteScrolling { [unowned self] in
        //Do your heavy job.
        //append to your datasource
        //...
        self.tableView.reloadData() //or insert cells at bottom of tableView
        self.tableView.am.infiniteScrollingView?.stopRefreshing()
    }
}
```

If you’d like to programmatically trigger the refresh (for instance in viewDidAppear:), you can do so with:
```Swift
tableView.am.pullToRefreshView?.trigger()
```

## Customization

Both `AMPullToRefreshViewView` and `AMInfiniteScrollingView` have public method 
```Swift
public func setCustomView(_ view: UIView, for state: AM.State)
```
So you can call this method and pass any UIView you want to show for each state.
