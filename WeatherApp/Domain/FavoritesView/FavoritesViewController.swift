//
//  FavoritesViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 11.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {

    var viewModel: FavoritesViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
