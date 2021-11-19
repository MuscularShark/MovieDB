//
//  TabBarViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 27.10.2021.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    func setupTabBar() {
        let appearance = UITabBarAppearance()
        tabBar.scrollEdgeAppearance = appearance
    }
}
