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

    var viewModel: FavoritesViewModel!

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceivedAction = { [ weak self ] action in
            self?.handle(action: action)
        }
        setUI()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    func handle(action: FavoritesViewModel.Action) {
        switch action {
        case .reload:
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private func setUI() {
        //TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "FavoriteCityCellTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteCityCellTableViewCell")
        tableView.separatorInset = .zero
    }
}

//MARK: - TableView DataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCityCellTableViewCell", for: indexPath) as! FavoriteCityCellTableViewCell
        cell.delegate = self
        cell.viewModel = viewModel.favoriteCityCellViewModels[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCityCellViewModels.count
    }
}

//MARK: - TableView Delegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05 * Double(indexPath.row),
                       animations: {
                        cell.alpha = 1
        })
    }
}


//MARK: - SwipeTableViewDelegate
extension FavoritesViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.viewModel.favoriteCities.remove(at: indexPath.row)
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

//MARK: - SearchCity Delegate

extension FavoritesViewController: SearchViewControllerDelegate {
    func didSelectCity(_ id: Int) {
        viewModel.updateFavoriteCities(id: id)
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
