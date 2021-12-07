//
//  SpinnerAnimationController.swift
//  PullToRefreshDemo
//
//  Created by Mansi Vadodariya on 22/03/21.
//

import UIKit
import SSCustomPullToRefresh

class SpinnerAnimationController: UIViewController {
    
    // Variables

    private var spinnerAnimation: SpinnerAnimationView?
    private var cells: Int = 1

    // Outlets

    @IBOutlet private weak var tableView: UITableView!
    
    // Lofecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSpinnerAnimation()
    }
    
    // Refresh Control

    func setUpSpinnerAnimation() {
        spinnerAnimation = SpinnerAnimationView(
            viewData: .init(
                resource: .loading(tintColor: .black)),
            parentView: tableView,
            delegate: self
        )

        spinnerAnimation?.setup()
    }
}

// MARK: - TableView

extension SpinnerAnimationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = "Row \(indexPath.row + 1)"

        return cell ?? .init()
    }
}

// MARK: - RefreshDelegate

extension SpinnerAnimationController: RefreshDelegate {
    func startRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.spinnerAnimation?.endRefreshing()
        }
    }
    
    func endRefresh() {
        cells += 1
        tableView.reloadData()
    }
}
