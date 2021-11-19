//
//  SearchViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 09.11.2021.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet private weak var collectionViewContainer: GenericCollectionView!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var imageSearch: UIImageView!
    @IBOutlet private weak var textSearch: UILabel!
    
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    private var searchWord = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        navigationItem.backButtonTitle = ""
        collectionViewContainer.searchBarDelegate = self
        collectionViewContainer.activityIndicator.stopAnimating()
    }
}

extension SearchViewController {
    private func loadSearchMovies(_ sender: SearchViewController, searchString: String) {
        DataLoadMoviesModel.shared.loadArraySearchMovie(word: searchWord) { result in
            if let result = result {
                self.collectionViewContainer.movies = result
                DispatchQueue.main.async {
                    self.collectionViewContainer.collectionView.reloadData()
                }
            }
        }
    }
    
    private func setupDelegate() {
        searchBar.delegate = self
        collectionViewContainer.delegate = self
    }
    
    private func reloadCollection() {
        collectionViewContainer.collectionView.reloadData()
        collectionViewContainer.collectionView.setContentOffset(.zero, animated: true)
    }
}

extension SearchViewController: GenericCollectionViewDelegate {
    func genericCollectionView(_ sender: GenericCollectionView, currentPage: Int) {
    }
    
    func pushDetailFilmViewController(idCell: Int) {
        let detailInfo = DetailFilmViewController()
        detailInfo.configureId(id: idCell)
        navigationController?.pushViewController(detailInfo, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWord = searchText
        searchWord = searchWord.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        if searchText != "" {
            loadSearchMovies(self, searchString: searchWord)
            imageSearch.alpha = 0
            textSearch.alpha = 0
            collectionViewContainer.alpha = 1
            reloadCollection()
        }
        else {
            imageSearch.alpha = 1
            textSearch.alpha = 1
            collectionViewContainer.alpha = 0
            reloadCollection()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


extension SearchViewController: HideSearchBarDelegate {
    func hideSearchBar() {
        searchBar.resignFirstResponder()
    }
}
