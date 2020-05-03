//
//  CityTableViewCell.swift
//  WeatherApp
//
//  Created by Faruk Buğra DEMIREL on 3.05.2020.
//  Copyright © 2020 F. Bugra Demirel. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    static let nibName = "CityTableViewCell"
    
    var viewModel: CityTableViewCellViewModel! {
        didSet {
            configure()
        }
    }

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var country: UILabel!

    override func prepareForReuse() {
        cityName.text = nil
        country.text = nil
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func configure() {
        cityName.text = viewModel.city.name
        country.text = viewModel.city.country

    }
}
