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

    //MARK: - IBOutlet
    @IBOutlet private var containerScrollView: UIScrollView!
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
    @IBOutlet private var dayForecastSlider: UISlider!
    @IBOutlet private var dayIndicator: UILabel!
    @IBOutlet private var segmentedUnitSelector: UISegmentedControl!
    @IBOutlet private var blockView: UIView!
    @IBOutlet private var locationButton: ActivityIndicatorButton!

    //MARK: - Properties
    var viewModel: WelcomeViewModel!

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didReceiveAction = { [weak self] action in
            self?.handle(action: action)
        }

        viewModel.viewDidLoad()
        setUI()
        setConstraints()
        setFirstScene()
        ///For general core data debuging purposes
        ///print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    }

    //MARK: - IBAction
    @IBAction func findByLocationButtonPressed(_ sender: UIButton) {
        if !isLocationServicesEnabled() {
            let alertController = UIAlertController(title: "This feature requires Location Services enabled", message: "Please change your settings under:\n Settings -> Privacy -> Location Services", preferredStyle: .actionSheet)
            let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { success in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alertController, animated: true, completion: nil)
        } else {
            viewModel.weatherInfoByLocationRequired()
        }
    }

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        viewModel.citySearchRequired()
    }

    @IBAction func favoritesButtonPressed(_ sender: UIButton) {
        let vc = FavoritesViewController.instantiate(with: FavoritesViewModel())
        vc.delegate = self
        let navCon = UINavigationController(rootViewController: vc)
        navigationController?.present(navCon, animated: true, completion: nil)
    }

    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        blockView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.4) {
            self.blockView.alpha = 0.9
            self.segmentedUnitSelector.alpha = 1
        }
        segmentedUnitSelector.isUserInteractionEnabled = true
    }

    @IBAction func temperatureSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.settingsManager.setUnit(to: .celcius)
        case 1:
            viewModel.settingsManager.setUnit(to: .fahrenheit)
        default:
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.blockView.alpha = 0
            self.segmentedUnitSelector.alpha = 0
        }
        segmentedUnitSelector.isUserInteractionEnabled = false
        blockView.isUserInteractionEnabled = false
    }

    //MARK: - Objc
    @objc func slideToCell (sender: UISlider) {
        let index = (collectionView.contentSize.width - collectionView.frame.width) / 100
        let point = CGPoint(x: index * CGFloat(sender.value), y: collectionView.contentOffset.y)
        collectionView.setContentOffset(point, animated: false)
        transformCells(scrollView: collectionView)
    }

    @objc func changeThumbLocation(sender: UITapGestureRecognizer) {
        let pointTouched = sender.location(ofTouch: 0, in: dayForecastSlider)
        let index = pointTouched.x / dayForecastSlider.frame.width
        dayForecastSlider.setValue(Float(index * 100), animated: true)
        let x = (collectionView.contentSize.width - collectionView.frame.width) / 100
        let point = CGPoint(x: (x * CGFloat(dayForecastSlider.value)), y: collectionView.contentOffset.y)
        collectionView.setContentOffset(point, animated: false)
        transformCells(scrollView: collectionView)
    }

    @objc func pulledToRefresh(_ sender: AnyObject) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        if let id = viewModel.currentWeatherInfo?.id {
            viewModel.weatherInfoByCityIdRequired(with: id, saveAsFavorite: false)
        }
        refreshControl.alpha = 0
        UIView.animate(withDuration: 1) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "arrow.up")?.withTintColor(AppColor.primary!)
            self.refreshControl.attributedTitle = NSAttributedString(attachment: imageAttachment)
            self.refreshControl.alpha = 1
            }
        refreshControl.endRefreshing()
    }

    @objc func blockViewTapped() {
        UIView.animate(withDuration: 0.3) {
            self.blockView.alpha = 0
            self.segmentedUnitSelector.alpha = 0
        }
        segmentedUnitSelector.isUserInteractionEnabled = false
        blockView.isUserInteractionEnabled = false
    }

    //MARK: - Handle
    private func handle(action: WelcomeViewModel.Action) {
        switch action {
        case .updateUI(with: let model):
            updateUIforCurrentWeatherLabels(with: model)
        case .presentSearchView(viewModel: let viewModel):
            presentSearchView(with: viewModel)
        case .reloadCollectionView:
            updateUIForForecastCells()
        case .setTempLabel(to: let tempUnit):
            setTempLabel(to: tempUnit)
        case .setUnitSegmentController(to: let tempUnit):
            setUnitSegmentController(to: tempUnit)
        case .setActivityIndicator(to: let setting):
            setActivityIndicator(with: setting)
        }
    }

    //MARK: - UI
    private func setUI() {

        // segmentedUnitSelector
        segmentedUnitSelector.alpha = 0
        segmentedUnitSelector.isUserInteractionEnabled = false
        blockView.isUserInteractionEnabled = false

        // blockView
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(blockViewTapped))
        blockView.addGestureRecognizer(tapRecognizer)

        // dayForecastSlider
        let thumbImage = UIImage(systemName: "circle.fill")!.withRenderingMode(.alwaysTemplate)
        let thumgImageForSliding = UIImage(systemName: "arrowtriangle.up.fill")!.withRenderingMode(.alwaysTemplate)
        dayForecastSlider.setThumbImage(thumbImage, for: .normal)
        dayForecastSlider.setThumbImage(thumgImageForSliding, for: .highlighted)
        dayForecastSlider.tintColor = .systemBackground
        dayForecastSlider.addTarget(self, action: #selector(slideToCell(sender:)), for: .valueChanged)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeThumbLocation(sender:)))
        dayForecastSlider.addGestureRecognizer(gesture)

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
            each.backgroundColor = .systemBackground
        }

        // containerScrollView
        containerScrollView.delegate = self
        refreshControl.addTarget(self, action: #selector(pulledToRefresh(_:)), for: .valueChanged)
        containerScrollView.addSubview(refreshControl)

        // Images
        weatherImage.tintColor = AppColor.primary
        windDirection.tintColor = AppColor.primary
        windImage.tintColor = AppColor.primary

        // Nav.Bar.
        navigationController?.navigationBar.isHidden = true

        // bottomButtonsStackView
        bottomButtonsStackView.layoutMargins = UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 24)
        bottomButtonsStackView.addBackground(color: .systemBackground)
        bottomButtonsStackView.subviews.first?.layer.cornerRadius = 30

        // collectionView
        collectionView.layer.cornerRadius = 30
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        collectionView.backgroundColor = AppColor.primary
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.register(UINib(nibName: ForecastCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: ForecastCollectionViewCell.nibName)
        collectionView.alpha = 0
    }

    //MARK: - Constraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            refreshControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            refreshControl.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 50)])
    }

    //MARK: - Operations
    private func setTempLabel(to unit: TemperatureSettingsManager.TempUnit) {
        if let text = temperatureLabel.text {
            temperatureLabel.text = viewModel.settingsManager.convertTemp(temp: text ,to: unit)
        }
    }

    private func setActivityIndicator(with: WelcomeViewModel.ActivityIndicatorSetting) {
        switch with {
        case .start:
            DispatchQueue.main.async {
                self.locationButton.startActivity()
            }
        case .stop:
            DispatchQueue.main.async {
                self.locationButton.stopActivity()
            }
        }
    }

    private func updateUIforCurrentWeatherLabels(with model: WelcomeViewModel.CurrentWeatherModel) {
        viewModel.saveAsLastCityOnWelcomeScreen(id: model.id)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.infoStackView.alpha = 0
            }) { _ in
                self.updateCurrentWeatherUIelements(with: model)
             UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
             self.infoStackView.alpha = 1
                }, completion: nil)
            }
        }
    }

    private func updateUIForForecastCells() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                self.collectionView.alpha = 0
            }) { _ in
                self.collectionView.reloadData()
                self.transformCells(scrollView: self.collectionView)
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
                    self.collectionView.alpha = 1
                }) { _ in
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        self.transformCells(scrollView: self.collectionView)
                        self.collectionView.scrollToItem(at: IndexPath(item: 2, section: 0), at: .centeredHorizontally, animated: true)
                    }, completion: nil)
                }
            }
        }
    }

    private func presentSearchView(with viewModel: SearchViewModel) {
        let vc = SearchViewController.instantiate(with: viewModel)
        vc.delegate = self
        navigationController?.present(vc, animated: true, completion: nil)
    }

    private func updateCurrentWeatherUIelements(with info: WelcomeViewModel.CurrentWeatherModel) {
        self.cityNameLabel.text = info.cityName
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd MMM HH:mm"
        self.forecastTimeLabel.text = dateFormatter.string(from: info.date)

        switch viewModel.tempUnit {
        case .celcius:
            self.temperatureLabel.text = info.temperatureString
        case .fahrenheit:
            self.temperatureLabel.text = viewModel.settingsManager.convertTemp(temp: info.temperatureString, to: .fahrenheit)
        }
        
        self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
        self.weatherDescriptionLabel.text = info.conditionDescription
        self.windSpeed.text = info.windSpeedString
        self.windDirection.image = UIImage(systemName: info.windDirectionStringForSFImage)
        windDirection.transform  = CGAffineTransform(rotationAngle: CGFloat(info.windDirectionInt))
    }

    private func setForecastDayIndicator(value: CGFloat) {
        let index = collectionView.contentSize.width / CGFloat(viewModel.forecastColletionViewCellModels.count)
        var pointer = Int(((value + (collectionView.frame.width/2)) / index).rounded(.towardZero))
        if pointer < 0 {
            pointer = 0
        } else if pointer > viewModel.forecastColletionViewCellModels.count - 1 {
            pointer = 0
        }
        if !viewModel.forecastColletionViewCellModels.isEmpty {
            let date = viewModel.forecastColletionViewCellModels[pointer].date
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMM HH:mm"
            self.dayIndicator.text = dateFormatter.string(from: date)

        }
    }

    private func isLocationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }

    private func setUnitSegmentController(to: TemperatureSettingsManager.TempUnit) {
        switch to {
        case .celcius:
            segmentedUnitSelector.selectedSegmentIndex = 0
        case .fahrenheit:
            segmentedUnitSelector.selectedSegmentIndex = 1
        }
    }

    private func setFirstScene() {
        let lastCityInfo = viewModel.lastCityOnWelcomeScreen
        if !isLocationServicesEnabled() && lastCityInfo == nil {
            viewModel.citySearchRequired()
        } else if let lastCityInfo = lastCityInfo {
            viewModel.weatherInfoByCityIdRequired(with: lastCityInfo, saveAsFavorite: false)
        }
    }


    //MARK: - UI Components
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "arrow.down")?.withTintColor(AppColor.primary!)
        refreshControl.attributedTitle = NSAttributedString(attachment: imageAttachment)
        refreshControl.tintColor = .clear
        refreshControl.layer.zPosition = -1
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        return refreshControl
    }()
}

//MARK: - ScrollViewDelegate
extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == containerScrollView {
            lockForUpwardsScroll(scrollView: scrollView)
            if scrollView.contentOffset.y > -4 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(systemName: "arrow.down")?.withTintColor(AppColor.primary!)
                refreshControl.attributedTitle = NSAttributedString(attachment: attachment)
            }
        } else if scrollView == collectionView {
            transformCells(scrollView: scrollView)
            if !dayForecastSlider.isHighlighted {
                setSliderPosition(scrollView: scrollView)
            }
            setForecastDayIndicator(value: scrollView.contentOffset.x)
        }
    }

    private func lockForUpwardsScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            scrollView.contentOffset.y = 0
        }
    }

    private func setSliderPosition(scrollView: UIScrollView) {
        let indexPosition =  scrollView.contentOffset.x / (scrollView.contentSize.width - collectionView.frame.width)
        dayForecastSlider.setValue(Float(indexPosition * 100), animated: true)
    }

    private func transformCells(scrollView: UIScrollView) {
       // centerX is the middle point of collectionView
        let centerX = scrollView.contentOffset.x + scrollView.frame.size.width/2
        for cell in collectionView.visibleCells {
           // offsetX is the distance between cell center and the centerX(middle point)
                var offsetX = centerX - cell.center.x
           // Make offsetX positive if negative
                offsetX = offsetX < 0 ? (offsetX * -1) : offsetX
           // original cell
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
           // if the offset is bigger than 50, calculate a scale value and transform
            if offsetX > 50 {
                let offsetPercentage = (offsetX - 50) / collectionView.bounds.width
                var scaleX = 1-offsetPercentage
                if scaleX < 0.8 {
                    scaleX = 0.8
                }
                cell.transform = CGAffineTransform(scaleX: scaleX, y: scaleX)
                collectionView.layoutIfNeeded()
            }
        }
    }
}

//MARK: - CollectionViewFlowLayout
extension WelcomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewInset: CGFloat = 10
        let minimumInterimSpacing: CGFloat = 0
        let numberOFCellsInPortraitMode = 5

        let marginsAndInsets = (collectionViewInset * 2) + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + (minimumInterimSpacing * CGFloat(numberOFCellsInPortraitMode - 1))
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(numberOFCellsInPortraitMode)).rounded(.down)
        let itemHeight = (collectionView.frame.size.height) * 0.8

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 10, bottom: (collectionView.frame.size.height * 0.15), right: 10)
    }
}

//MARK: - CollectionViewDataSource
extension WelcomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.forecastColletionViewCellModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.nibName, for: indexPath) as! ForecastCollectionViewCell
        cell.viewModel = viewModel.forecastColletionViewCellModels[indexPath.row]
        return cell
    }
}

//MARK: - FavoriteCityVC Delegate
extension WelcomeViewController: FavoritesViewControllerDelegate {
    func didSelectCity(_ favoriteViewController: FavoritesViewController, cityID: Int) {
        viewModel.weatherInfoByCityIdRequired(with: cityID)
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
