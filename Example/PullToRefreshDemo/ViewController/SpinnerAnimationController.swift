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

    var spinnerAnnimation: SpinnerAnimationView!
    var cells: Int = 1
    var colors: (UIColor, UIColor) {
        if cells % 2 == 0 {
            return (.black, .white)
        } else {
            return (.white, .black)
        }
    }

    // Outlets

    @IBOutlet weak var tableView: UITableView!
    
    // Lofecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSpinnerAnimation()
    }
    
    // Refresh Control

    func setUpSpinnerAnimation() {
        spinnerAnnimation = SpinnerAnimationView(viewData: .init(resource: .loading(tintColor: colors.0), background: colors.1), parentView: tableView, delegate: self)
        spinnerAnnimation.setupRefreshControl()
    }
}

// MARK: - TableView

extension SpinnerAnimationController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell";
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.text = "Row \(indexPath.row + 1)"
        return cell!
    }
}

// MARK: - RefreshDelegate

extension SpinnerAnimationController: RefreshDelegate {
    func startRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.spinnerAnnimation.endRefreshing()
        }
    }
    
    func endRefresh() {
        cells += 1
        tableView.reloadData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.spinnerAnnimation.setupData(viewData: .init(resource: .loading(tintColor: self.colors.0), background: self.colors.1))
        }
    }
}

// MARK: - Extensions

extension UIScrollView {

}
