//
//  FavoritesViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import SwipeCellKit

final class FavoritesViewController: UIViewController {

    var testArray: [Int] = [1,2,3,4,5]

    var viewModel: FavoritesViewModel!
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FavoriteCityCellTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteCityCellTableViewCell")
        tableView.separatorInset = .zero

    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}


extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCityCellTableViewCell") as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        testArray.count
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension FavoritesViewController: SwipeTableViewCellDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.testArray.remove(at: indexPath.row)
            action.fulfill(with: .delete)
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }

}
//MARK: - StoryboardInstantiable

extension FavoritesViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "FavoritesView"
    }

    public static func instantiate(with viewModel: FavoritesViewModel) -> FavoritesViewController {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
