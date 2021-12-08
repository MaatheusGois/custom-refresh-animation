//
//  SpinnerAnimationController.swift
//  PullToRefreshDemo
//
//  Created by Mansi Vadodariya on 22/03/21.
//

import UIKit
import SSCustomPullToRefresh

final class SpinnerAnimationController: UIViewController {

    // Variables

    private var spinnerAnimation: SpinnerAnimationView?
    private var cellsCount: Int = 1

    // Outlets

    @IBOutlet private weak var tableView: UITableView!

    // Lofecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSpinnerAnimation()
    }
}

// MARK: - Methods

fileprivate extension SpinnerAnimationController {
    func setUpSpinnerAnimation() {
        spinnerAnimation = SpinnerAnimationView(
            viewData: .init(
                resource: .loading(tintColor: .black)),
            parentView: tableView,
            startRefresh: { [weak self] in
                self?.startRefresh()
            },
            endRefresh: { [weak self] in
                self?.endRefresh()
            }
        )

        spinnerAnimation?.setup()
    }

    func startRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.spinnerAnimation?.endRefreshing()
        }
    }

    func endRefresh() {
        cellsCount += 1
        tableView.reloadData()
    }
}

// MARK: - TableView

extension SpinnerAnimationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = .init(style: .default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = "Row \(indexPath.row + 1)"

        return cell ?? .init()
    }
}
