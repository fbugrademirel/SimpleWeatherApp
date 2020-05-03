//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 2.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func didSelectCity(_ id: Int)
}

final class SearchViewController: UIViewController {

    var delegate: SearchViewControllerDelegate?
    var viewModel: SearchViewModel!

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceiveAction = { [weak self] action in
            self?.handle(action)
        }
        setUI()
    }

    func handle(_ action: SearchViewModel.Action) {
        switch action {
        case .reload:
            tableView.reloadData()
        }
    }

    private func setUI() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tableView.register(UINib(nibName: CityTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: CityTableViewCell.nibName)
        tableView.separatorInset = .zero
    }
}
//MARK: - SearchBar Delegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            viewModel.cityListRequired(for: text)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            viewModel.cityListRequired(for: text)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            viewModel.cityListRequired(for: text)
        }
    }
}

//MARK: - TableView Delegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectCity(viewModel.cityTableViewCellModels[indexPath.row].city.id)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}


//MARK: - TableView DataSource

extension SearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cityTableViewCellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.nibName, for: indexPath) as! CityTableViewCell
        cell.viewModel = viewModel.cityTableViewCellModels[indexPath.row]
        return cell
    }

}


//MARK: - Storyboard Instantiable

extension SearchViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "SearchView"
    }

    public static func instantiate(with viewModel: SearchViewModel) -> SearchViewController {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
