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
    @IBOutlet private var windSpeed: UILabel!
    @IBOutlet private var windDirection: UIImageView!
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var searchCityButton: UIView!
    @IBOutlet private var collectionView: UICollectionView!

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
    @IBAction func locationBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.weatherInfoByLocationRequired()
    }

    @IBAction func searchBarButtonItemPressed(_ sender: UIBarButtonItem) {
        viewModel.citySearchRequired()
    }

    //MARK: - UI

    private func setUI() {
        navigationController?.navigationBar.isHidden = true

        searchCityButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        searchCityButton.layer.cornerRadius = searchCityButton.frame.size.width / 2
        searchCityButton.clipsToBounds = true
//        searchCityButton.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        searchCityButton.layer.shadowRadius = 1
//        searchCityButton.layer.shadowOpacity = 1 



        collectionView.layer.cornerRadius = collectionView.frame.size.width / 10


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
               self.stackView.alpha = 0
           }) { _ in
               self.updateLabels(with: info)
               UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                   self.stackView.alpha = 1
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
