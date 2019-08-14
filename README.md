# SpotPullRefresh
An easy way to use pull-to-refresh and pull-to-load-more. This repo was learn from MJRefresh, a famous pull-refresh component.

[![SwiftPackageManager Compatible](https://img.shields.io/badge/SwiftPackageManager-compatible-orange)](https://img.shields.io/badge/SwiftPackageManager-compatible-orange)

## Features
- [x] Pull Down from top to Refresh.
- [x] Pull Up from bottom to load more data.
- [x] Basic configuration to display refresh/load state.
- [] Layout of pull views can be more diverse.
- [] Easy to Localization.

## Requirements
* iOS 8.0+
* Xcode 11
* Swift 5.1

### What kinds of controls to refresh can use it?
UIScrollView and all of subclass of it.

## Installation
### Swift Package Manager
Append dependence into your library's Package.swift
```
dependencies: [
.package(url: "https://github.com/shawnclovie/SpotPullRefresh", .branch("master")),
]
```
Or append with the URL and branch from menu "File - Swift Package - Add Package Dependency..."

### Carthage
Append dependence into your Cartfile
```
github "shawnclovie/SpotPullRefresh" "master"
```

## How to use
Please look code in SpotPullRefreshDemo/ViewController.swift for runnable example.
### Kinds of controls
```
// Superclass of all other view
PullBaseView
```
* Pull down Refresh
```
// Superclass of pull down refresh view
class PullRefreshView: PullBaseView

// View with state label and last updated time label
class PullRefreshStateView: PullRefreshView

// View with arrowView and indicator (show on loading, left of state label) 
class PullRefreshIndicationStateView: PullRefreshStateView

// View with imageView to present animation (show on loading)
class PullRefreshAnimationStateView: PullRefreshStateView
```
In your viewDidLoad():
```
let refresher = PullRefreshIndicationStateView { [weak self] in
	// do something like make URLRequest on sub thread
	...
	// after finished, notify refresher
	DispatchQueue.main.async {
		guard let self = self else {return}
		self.scrollView.spot_pullDownRefreshView?.endRefreshing()
	}
}
// do something to config refresher, e.g.
// setup arrowView, set image or add subviews (center to .zero)
// set stateTitleRenderer and lastUpdatedTimeTextRenderer of refresher for localization.
// refresher.lastUpdatedTimeLabelEnabled = true/false

scrollView.spot_pullDownRefreshView = refresher
```
* Pull up Load more
```
// Superclass of pull down refresh view
class PullLoadView: PullBaseView

// View with state label and last updated time label
class PullLoadStateView: PullLoadView

// View with arrowView and indicator (show on loading, left of state label) 
class PullLoadIndicationStateView: PullLoadStateView

// View with imageView to present animation (show on loading)
class PullLoadAnimationStateView: PullLoadStateView
```
In your viewDidLoad(), do almost same thing to make pull view:
```
let moreDataLoader = PullLoadIndicationStateView { [weak self] in
	// do something like make URLRequest on sub thread
	...
	// after finished, notify refresher
	DispatchQueue.main.async {
		guard let self = self,
			let pullUp = self.tableView.spot_pullUpLoadView
			else {return}
		if /* did load all data and no more */ {
			pullUp.endRefreshingWithNoMoreData()
		} else {
			pullUp.endRefreshing()
		}
	}
}
// do something to config refresher, e.g.
// set moreDataLoader.stateTitleRenderer for localization.
scrollView.spot_pullUpLoadView = moreDataLoader
```

## License
SpotPullRefresh is released under the MIT license.
