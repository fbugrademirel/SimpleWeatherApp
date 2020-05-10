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
    @IBOutlet private var fillingView: UIView!
    @IBOutlet private var bottomButtonsStackView: UIStackView!
    @IBOutlet private var buttons: [UIButton]!
    @IBOutlet private var dayForecastSlider: UISlider!
    @IBOutlet private var dayIndicator: UILabel!

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

    //MARK: - objc
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

    //MARK: - UI
    private func setUI() {
        // Slider
        let thumbImage = UIImage(systemName: "arrow.up")!.withRenderingMode(.alwaysTemplate)
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
            each.layer.cornerRadius = 25
            each.backgroundColor = .systemBackground
        }

        //scroll view
        containerScrollView.delegate = self

        // Images
        weatherImage.tintColor = AppColor.primary
        windDirection.tintColor = AppColor.primary
        windImage.tintColor = AppColor.primary

        // Nav.Bar
        navigationController?.navigationBar.isHidden = true

        // Bottom StackView
        bottomButtonsStackView.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        bottomButtonsStackView.addBackground(color: .systemBackground)
        bottomButtonsStackView.subviews.first?.layer.cornerRadius = 30

        //SizingView
        fillingView.backgroundColor = AppColor.primary
        fillingView.alpha = 0

        //CollectionView
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

    //MARK: - Operations
    private func handle(action: WelcomeViewModel.Action) {
        switch action {
        case .updateUI(with: let model):
            updateUIforCurrentWeatherLabels(with: model)
        case .presentSearchView(viewModel: let viewModel):
            presentSearchView(with: viewModel)
        case .reloadCollectionView:
            updateUIForForecastCells()
        }
    }

    private func updateUIforCurrentWeatherLabels(with model: WelcomeViewModel.CurrentWeatherModel) {
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
                self.fillingView.alpha = 0
            }) { _ in
                self.collectionView.reloadData()
                self.transformCells(scrollView: self.collectionView)
                UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
                    self.collectionView.alpha = 1
                    self.fillingView.alpha = 1
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
       self.temperatureLabel.text = info.temperatureString
       self.weatherImage.image = UIImage(systemName: info.conditionNameForSFIcons)
       self.weatherDescriptionLabel.text = info.conditionDescription
       self.windSpeed.text = info.windSpeedString
       self.windDirection.image = UIImage(systemName: info.windDirectionString)
    }

    private func setDayIndicator(value: CGFloat) {
        let index = collectionView.contentSize.width / CGFloat(viewModel.forecastColletionViewCellModels.count)
        let pointer = Int(((value + (collectionView.frame.width/2)) / index).rounded(.towardZero))
        let fixedPointer = pointer < 0 ? 0 : pointer
        let date = viewModel.forecastColletionViewCellModels[fixedPointer].date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd MMM HH:mm"
        self.dayIndicator.text = dateFormatter.string(from: date)
    }
}

//MARK: - ScrollViewDelegate
extension WelcomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == containerScrollView {
            lockForUpwardsScroll(scrollView: scrollView)
        } else if scrollView == collectionView {
            transformCells(scrollView: scrollView)
            if !dayForecastSlider.isHighlighted {
                setSliderPosition(scrollView: scrollView)
            }
            setDayIndicator(value: scrollView.contentOffset.x)
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
