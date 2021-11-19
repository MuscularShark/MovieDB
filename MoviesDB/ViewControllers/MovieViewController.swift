//
//  MovieViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 25.10.2021.
//

import UIKit

enum MovieType: String {
    case popular = "movie/popular"
    case topRated = "movie/top_rated"
    case upcoming = "movie/upcoming"
}

protocol MovieViewControllerDelegate: AnyObject {
    func movieViewControllerDataLoaded()
}

class MovieViewController: UIViewController {
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionViewContainer: GenericCollectionView!
    
    weak var delegate: MovieViewControllerDelegate?
    
    private var currentPage = 1
    private var currentType: MovieType = .popular {
        didSet(newValue) {
            if newValue != currentType {
                self.collectionViewContainer.movies = []
                self.currentPage = 1
                self.collectionViewContainer.collectionView.reloadData()
                self.collectionViewContainer.collectionView.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        collectionViewContainer.delegate = self
        setupDataByType(self, onType: currentType)
        disposableSetPage()
    }
    
    @IBAction func movieTypeSegmentedControlPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: currentType = .popular
            setupDataByType(self, onType: currentType)
        case 1: currentType = .topRated
            setupDataByType(self, onType: currentType)
        case 2: currentType = .upcoming
            setupDataByType(self, onType: currentType)
        default: break
        }
    }
    
    //MARK: - setup View
    private func setupView() {
        self.setupImageTitle()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .selected)
        navigationItem.backButtonTitle = ""
    }
    
    private func disposableSetPage(){
        if CoreDataModel.shared.getListMoviesFromFavoriteMovies().isEmpty && CoreDataModel.shared.getListMoviesFromIgnoreMovies().isEmpty{
            CoreDataModel.shared.saveNumberPage(numberPage: 5)
        }
    }
}

//MARK: - setup Data
extension MovieViewController {
    func setupDataByType(_ sender: MovieViewController, onType searchString: MovieType) {
        DataLoadMoviesModel.shared.loadMovies(searchString: searchString.rawValue, page: currentPage, completion: { [weak self] (movies) in
            if let movies = movies {
                self?.collectionViewContainer.movies += movies
                DispatchQueue.main.async {
                    self?.collectionViewContainer.collectionView.reloadData()
                }
                self?.delegate?.movieViewControllerDataLoaded()
            }
        })
    }
}

//MARK: - GenericCollectionViewDelegate
extension MovieViewController: GenericCollectionViewDelegate {
    func pushDetailFilmViewController(idCell: Int) {
        let detailInfo = DetailFilmViewController()
        detailInfo.configureId(id: idCell)
        navigationController?.pushViewController(detailInfo, animated: true)
    }
    
    func genericCollectionView(_ sender: GenericCollectionView, currentPage: Int) {
        self.currentPage = currentPage
        setupDataByType(self, onType: currentType)
    }
}
