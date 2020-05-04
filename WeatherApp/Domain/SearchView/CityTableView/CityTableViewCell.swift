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
        cityName.attributedText = nil
        country.text = nil
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func configure() {

        let fullString = NSMutableAttributedString(string: viewModel.city.name)
        if let boldPart = viewModel.searchString {
            fullString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSRange(location: 0, length: boldPart.count))
        }

        cityName.attributedText = fullString
        country.text = viewModel.city.country
    }
}
