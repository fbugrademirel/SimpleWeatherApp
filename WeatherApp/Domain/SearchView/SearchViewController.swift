//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 2.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    var viewModel: SearchViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

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
