//
//  SpinnerButton.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 17.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

class ACtivityIndicatorButton: UIButton {

    let spinner = UIActivityIndicatorView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setActivityIndicator()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setActivityIndicator()
    }

    private func setActivityIndicator() {
        spinner.isHidden = false
        spinner.alpha = 0
        spinner.tintColor = .systemBackground
        spinner.isUserInteractionEnabled = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)])
    }

    func startActivity() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.imageView?.alpha = 0
            self.titleLabel?.alpha = 0
            self.spinner.isHidden = false
            self.spinner.startAnimating()
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.spinner.alpha = 1
            }, completion: nil)
        }
    }

    func stopActivity() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
            self.spinner.alpha = 0
            self.spinner.stopAnimating()
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.imageView?.alpha = 1
                self.titleLabel?.alpha = 1
                self.spinner.isHidden = true
            }, completion: nil)
        }
    }
}
