//
//  FavoritesViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol FavoritesViewControllerDelegate: class {
    func didSelectCity(_ favoriteViewController: FavoritesViewController, cityID: Int)
}

final class FavoritesViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet private var tableView: UITableView!

    //MARK: - Properties
    var viewModel: FavoritesViewModel!
    weak var delegate: FavoritesViewControllerDelegate?

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceivedAction = { [ weak self ] action in
            self?.handle(action: action)
        }
        viewModel.fetchFavoriteCityWeathers()
        setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    //MARK: - Handle
    func handle(action: FavoritesViewModel.Action) {
        switch action {
        case .reload:
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        case .presentSearchView(with: let viewModel):
            presentSearchView(with: viewModel)
        }
    }

    //MARK: - Objc
    @objc func cancelButtonPressed() {
        dismiss(animated: true, completion: nil)
    }

    @objc func addButtonPressed() {
        viewModel.searchViewConrollerRequired()
    }

    //MARK: - UI
    private func setUI() {
        //Nav.Bar.
        title = "Favorites"
        let rightButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        rightButton.tintColor = AppColor.primary
        navigationItem.rightBarButtonItem = rightButton

        let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        leftButton.tintColor = AppColor.primary
        navigationItem.leftBarButtonItem = leftButton

        //TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: FavoriteCityTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: FavoriteCityTableViewCell.nibName)
        tableView.separatorInset = .zero
        tableView.contentInset = UIEdgeInsets(top: -tableView.sectionHeaderHeight, left: 0, bottom: 0, right: 0)
    }

    //MARK: - Operations
    private func presentSearchView(with viewModel: SearchViewModel) {
        let vc = SearchViewController.instantiate(with: viewModel)
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }
}

//MARK: - TableView DataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCityTableViewCell.nibName, for: indexPath) as! FavoriteCityTableViewCell
        cell.delegate = self
        cell.viewModel = viewModel.favoriteCityCellViewModels[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCityCellViewModels.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

//MARK: - TableView Delegate
extension FavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCity(self, cityID: viewModel.favoriteCityCellViewModels[indexPath.row].id)
        dismiss(animated: true, completion: nil)
    }

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
            let id = self.viewModel.favoriteCityCellViewModels[indexPath.row].id
            self.viewModel.updateFavoriteCities(id: id, updateType: .selectAsUnfavorite)
            self.viewModel.favoriteCityCellViewModels.remove(at: indexPath.row)
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
        viewModel.updateFavoriteCities(id: id, updateType: .selectAsFavorite)
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
