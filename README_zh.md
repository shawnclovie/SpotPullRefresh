# SpotPullRefresh
简易地可实现下拉刷新与上拉加载更多的方式。本repo借鉴了著名下拉刷新组件MJRefresh。

[![SwiftPackageManager Compatible](https://img.shields.io/badge/SwiftPackageManager-compatible-orange)](https://img.shields.io/badge/SwiftPackageManager-compatible-orange)

## 特色
- [x] 顶部下拉刷新
- [x] 底部上拉加载更多
- [x] 基础配置以显示刷新或加载的状态
- [ ] 刷新视图的布局更多样化
- [ ] 文本易于国际化

## 需求
* iOS 8.0+
* Xcode 11
* Swift 5.1

### 本刷新控件可用于哪些类？
UIScrollView及其子类。

## 安装
### Swift Package Manager
将此依赖添加到你的库的Package.swift中：
```
dependencies: [
.package(url: "https://github.com/shawnclovie/SpotPullRefresh", .branch("master")),
]
```
或按照菜单"File - Swift Package - Add Package Dependency..."打开添加依赖的界面，并按照上面的URL进行添加。

### Carthage
在Cartfile中添加依赖：
```
github "shawnclovie/SpotPullRefresh" "master"
```

## 使用指南
请参考SpotPullRefreshDemo/ViewController.swift中的可执行示例代码。
### 可用的控件
```
// 其它view的基类
PullBaseView
```
* 下拉刷新
```
// 下拉刷新的基类
class PullRefreshView: PullBaseView

// 可显示状态标签与最后刷新时间
class PullRefreshStateView: PullRefreshView

// 可显示箭头图片与刷新菊花（载入中显示，在状态标签左侧） 
class PullRefreshIndicationStateView: PullRefreshStateView

// 可显示逐帧动画（载入中显示）
class PullRefreshAnimationStateView: PullRefreshStateView
```
在viewDidLoad()中添加：
```
let refresher = PullRefreshIndicationStateView { [weak self] in
	// 在其它线程做事情，如网络请求
	...
	// 完成后，通知refresher
	DispatchQueue.main.async {
		guard let self = self else {return}
		self.scrollView.spot_pullDownRefreshView?.endRefreshing()
	}
}
// 配置refresher，如：
// 设置arrowView，添加图片或子类（子类的center需为.zero）
// 给refresher设置stateTitleRenderer与lastUpdatedTimeTextRenderer，以显示国际化文本
// refresher.lastUpdatedTimeLabelEnabled = true/false

scrollView.spot_pullDownRefreshView = refresher
```
* 上拉加载更多
```
// 上拉加载的基类
class PullLoadView: PullBaseView

// 可显示状态标签
class PullLoadStateView: PullLoadView

// 可显示加载菊花（载入中显示，在状态标签左侧）
class PullLoadIndicationStateView: PullLoadStateView

// 可显示逐帧动画（载入中显示）
class PullLoadAnimationStateView: PullLoadStateView
```
在viewDidLoad()添加，与下拉刷新组件类似：
```
let moreDataLoader = PullLoadIndicationStateView { [weak self] in
	// 在其它线程做事情，如网络请求
	...
	// 完成后，通知moreDataLoader
	DispatchQueue.main.async {
		guard let self = self,
			let pullUp = self.tableView.spot_pullUpLoadView
			else {return}
		if /* 已加载所有且无更多 */ {
			pullUp.endRefreshingWithNoMoreData()
		} else {
			pullUp.endRefreshing()
		}
	}
}
// 配置moreDataLoader，如：
// 设置moreDataLoader.stateTitleRenderer以国际化文本
scrollView.spot_pullUpLoadView = moreDataLoader
```

## 协议
SpotPullRefresh以MIT协议发行。
