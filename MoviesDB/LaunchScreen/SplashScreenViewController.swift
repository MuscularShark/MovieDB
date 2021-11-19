//
//  SpalashScreenViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 10.11.2021.
//

import UIKit

class SplashScreenViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var activitYIndicator: UIActivityIndicatorView!
    
    var movieViewController: MovieViewController?
    let story = UIStoryboard(name: "Main", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieViewController = story.instantiateViewController(withIdentifier: "MovieViewController") as? MovieViewController
        activitYIndicator.startAnimating()
        activitYIndicator.color = UIColor.red
        movieViewController?.delegate = self
        let _ = movieViewController?.view
    }
}

extension SplashScreenViewController: MovieViewControllerDelegate {
    func movieViewControllerDataLoaded() {
        DispatchQueue.main.async {
            let tabBarController = self.story.instantiateViewController(identifier: "TabBarViewController")
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true, completion: nil)
        }
        
    }
}
