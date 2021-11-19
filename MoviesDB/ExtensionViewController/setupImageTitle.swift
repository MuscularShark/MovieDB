//
//  SetupImageTitle.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 10.11.2021.
//

import UIKit

extension UIViewController {
    func setupImageTitle() {
        let logo = UIImage(named: "title")
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
    }
}
