//
//  FavoritesViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 25.10.2021.
//

import UIKit

class FavoritesViewController: UIViewController {

    @IBOutlet weak var collectionViewContainer: GenericCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageTitle()
        navigationItem.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionViewContainer.movies = CoreDataModel.shared.getListMoviesFromFavoriteMovies()
        collectionViewContainer.collectionView.reloadData()
        collectionViewContainer.activityIndicator.stopAnimating()
        collectionViewContainer.delegate = self
    }
}

extension FavoritesViewController: GenericCollectionViewDelegate {
    func genericCollectionView(_ sender: GenericCollectionView, currentPage: Int) {
    }
    
    func pushDetailFilmViewController(idCell: Int) {
        let detailInfo = DetailFilmViewController()
        detailInfo.configureId(id: idCell)
        navigationController?.pushViewController(detailInfo, animated: true)
    }
}
