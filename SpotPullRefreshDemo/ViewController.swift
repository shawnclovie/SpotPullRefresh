//
//  ViewController.swift
//  SpotPullRefreshDemo
//
//  Created by Shawn Clovie on 14/8/2019.
//

import UIKit
import SpotPullRefresh

class ViewController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()
		let root = UIViewController(nibName: nil, bundle: nil)
		root.navigationItem.rightBarButtonItems = [
			.init(title: "Push", style: .plain, target: self, action: #selector(touchUpPush)),
			.init(title: "Present", style: .plain, target: self, action: #selector(touchUpPresent)),
			]
		viewControllers = [root]
	}
	
	@objc private func touchUpPush() {
		pushViewController(TestPullViewController(style: .grouped), animated: true)
	}
	
	@objc private func touchUpPresent() {
		present(TestPullViewController(style: .grouped), animated: true, completion: nil)
	}
}

class TestPullViewController: UITableViewController {
	
	static let maxDataCount = 50
	static let dataGrowStep = 10
	
	private var data: [String] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .refresh, target: self, action: #selector(touchUp(reload:)))
		reloadData()
		
		let fnRefresh = { [weak self] in
			print("pull down: refreshing")
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self?.tableView.spot_pullDownRefreshView?.endRefreshing()
			}
		}
		let refresher = PullRefreshIndicationStateView(fnRefresh)
		let arrow = UILabel()
		arrow.text = "⇩"
		arrow.sizeToFit()
		arrow.center = .zero
		refresher.arrowView.addSubview(arrow)
		refresher.lastUpdatedTimeTextRenderer = {
			if $0 > 0 {
				let date = Date(timeIntervalSince1970: $0)
				let calendar = NSCalendar(calendarIdentifier: .gregorian)
				let cmp1 = calendar?.components([.year, .month, .day, .hour, .minute], from: date)
				let cmp2 = calendar?.components([.year, .month, .day, .hour, .minute], from: Date())
				
				let formatter = DateFormatter()
				if cmp1?.day == cmp2?.day {
					formatter.dateFormat = "HH:mm"
				} else if cmp1?.year == cmp2?.year {
					formatter.dateFormat = "MM-dd HH:mm"
				} else {
					formatter.dateFormat = "yyyy-MM-dd HH:mm"
				}
				let time = formatter.string(from: date)
				// TODO: localizable
				return "last update on \(time)"
			}
			// TODO: localizable
			return "there isn't refreshing."
		}
		refresher.stateTitleRenderer = {
			// TODO: localizable
			"state: \($0)"
		}
		tableView.spot_pullDownRefreshView = refresher
		
		let moreDataLoader = PullLoadIndicationStateView { [weak self] in
			print("pull up: load more")
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				guard let self = self else {return}
				let count = self.data.count
				let range = ((count + 1)...(count + Self.dataGrowStep))
				self.data.append(contentsOf: range.map{"\($0)"})
				self.tableView.reloadData()
				guard let pullUp = self.tableView.spot_pullUpLoadView else {
					print("pullUpLoadView is nil")
					return
				}
				if count + Self.dataGrowStep >= Self.maxDataCount {
					pullUp.endRefreshingWithNoMoreData()
				} else {
					pullUp.endRefreshing()
				}
			}
		}
		moreDataLoader.stateTitleRenderer = {
			// TODO: localizable
			"state: \($0)"
		}
		tableView.spot_pullUpLoadView = moreDataLoader
	}
	
	@objc private func touchUp(reload: Any) {
		reloadData()
	}
	
	private func reloadData() {
		data = (0..<Self.dataGrowStep).map{"\($0)"}
		tableView.reloadData()
	}
	
	// MARK: - TableView
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		data.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = data[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		80
	}
}
