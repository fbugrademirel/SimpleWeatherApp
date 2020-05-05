//
//  ViewController.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 15.04.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit
import CoreLocation

final class WelcomeViewController: UIViewController {

    //MARK: - Properties
    @IBOutlet private var cityNameLabel: UILabel!
    @IBOutlet private var forecastTimeLabel: UILabel!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var weatherImage: UIImageView!
    @IBOutlet private var weatherDescriptionLabel: UILabel!
    @IBOutlet private var temperatureUnitIndicator: UILabel!
    @IBOutlet private var windImage: UIImageView!
    @IBOutlet private var windSpeed: UILabel!
    @IBOutlet private var windDirection: UIImageView!
    @IBOutlet private var windSpeedUnitIndicator: UILabel!
    @IBOutlet private var infoStackView: UIStackView!
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var bottomButtonsStackView: UIStackView!
    @IBOutlet private var buttons: [UIButton]!

    var viewModel: WelcomeViewModel!

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceiveAction = { [weak self] action in
            self?.handle(action: action)
        }
        viewModel.viewDidLoad()

        setUI()
    }

    //MARK: - IBAction
    @IBAction func findByLocationButtonPressed(_ sender: UIButton) {
        viewModel.weatherInfoByLocationRequired()
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        viewModel.citySearchRequired()
    }

    //MARK: - UI

    private func setUI() {

        // Labels
        cityNameLabel.textColor = AppColor.primary
        forecastTimeLabel.textColor = AppColor.primary
        temperatureLabel.textColor = AppColor.primary
        weatherDescriptionLabel.textColor = AppColor.primary
        windSpeed.textColor = AppColor.primary
        temperatureUnitIndicator.textColor = AppColor.primary
        windSpeedUnitIndicator.textColor = AppColor.primary


        // Buttons
        for each in buttons {
            each.tintColor = AppColor.primary
            each.layer.cornerRadius = 25
            each.backgroundColor = .systemBackground
        }

        // Images
        weatherImage.tintColor = AppColor.primary
        windDirection.tintColor = AppColor.primary
        windImage.tintColor = AppColor.primary

        // Nav. Bar
        navigationController?.navigationBar.isHidden = true

        // Bottom StackView
        bottomButtonsStackView.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        bottomButtonsStackView.addBackground(color: .systemBackground)
        bottomButtonsStackView.subviews.first?.layer.cornerRadius = 30

        //CollectionView
        collectionView.layer.cornerRadius = 30
        collectionView.backgroundColor = AppColor.primary

    }

    //MARK: - Operations
    private func handle(action: WelcomeViewModel.Action) {
        switch action {
        case .updateUI(weatherInfo: let info):
           updateUI(with: info)
        case .presentSearchView(viewModel: let viewModel):
            presentSearchView(with: viewModel)
        }
    }

    private func updateUI(with info: WelcomeViewModel.WeatherModel) {
        DispatchQueue.main.async {
           UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
               self.infoStackView.alpha = 0
           }) { _ in
               self.updateLabels(with: info)
               UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                   self.infoStackView.alpha = 1
               }, completion: nil)
           }
       }
    }

    private func presentSearchView(with viewModel: SearchViewModel) {
        let vc = SearchViewController.instantiate(with: viewModel)
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }

    private func updateLabels(with info: WelcomeViewModel.WeatherModel) {
       self.cityNameLabel.text = info.cityName
       let dateFormatter = DateFormatter()
       dateFormatter.locale = NSLocale.current
       dateFormatter.dateFormat = "dd-MMM HH:mm"
       self.forecastTimeLabel.text = dateFormatter.string(from: info.date)
       self.temperatureLabel.text = info.temperatureString
       self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
       self.weatherDescriptionLabel.text = info.conditionDescription
       self.windSpeed.text = info.windSpeedString
       self.windDirection.image = UIImage(systemName: info.windDirectionString)
    }
}

//MARK: - SearchVC Delegate

extension WelcomeViewController: SearchViewControllerDelegate {
    func didSelectCity(_ id: Int) {
        viewModel.weatherInfoByCityIdRequired(with: id)
    }
}

// MARK: - Storyboard Instantiable
extension WelcomeViewController: StoryboardInstantiable {
    static var storyboardName: String {
        return "WelcomeView"
    }

    public static func instantiate(with viewModel: WelcomeViewModel) -> WelcomeViewController {
        let viewController = instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}





//UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
//    self.cityNameLabel.alpha = 0
//    self.forecastTimeLabel.alpha = 0
//    self.temperatureLabel.alpha = 0
//    self.weatherImage.alpha = 0
//    self.weatherDescriptionLabel.alpha = 0
//    self.windSpeed.alpha = 0
//    self.windDirection.alpha = 0
//}) { (bool) in
//    self.cityNameLabel.text = info.cityName
//    let dateFormatter = DateFormatter()
//    dateFormatter.locale = NSLocale.current
//    dateFormatter.dateFormat = "dd-MMM HH:mm"
//    self.forecastTimeLabel.text = dateFormatter.string(from: info.date)
//    self.temperatureLabel.text = info.temperatureString
//    self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
//    self.weatherDescriptionLabel.text = info.conditionDescription
//    self.windSpeed.text = info.windSpeedString
//    self.windDirection.image = UIImage(systemName: info.windDirectionString)
//
//    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
//        self.cityNameLabel.alpha = 1
//        self.forecastTimeLabel.alpha = 1
//        self.temperatureLabel.alpha = 1
//        self.weatherImage.alpha = 1
//        self.weatherDescriptionLabel.alpha = 1
//        self.windSpeed.alpha = 1
//        self.windDirection.alpha = 1
//    }, completion: nil)
