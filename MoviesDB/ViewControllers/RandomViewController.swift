//
//  RandomViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 25.10.2021.
//

import UIKit

class RandomViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorTitle: UILabel!
    
    private var arrayFilm: [MovieModel] = []
    
    //Cards
    private var primaryCard = CardView()
    private var secondaryCard = CardView()
    
    //Counters:
    private var initialCounter = 0
    private var primaryCounter = 0
    private var pageValue = 1
    private var cardNow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        addCards(card: &primaryCard)
        addCards(card: &secondaryCard)
        hideCard(cards: [primaryCard, secondaryCard])
        setDelegate()
        setArray(page: CoreDataModel.shared.getNumberPage())
        self.setupImageTitle()
    }
}

// MARK: - Data load

extension RandomViewController {
    private func setArray(page: Int) {
        let popular = "movie/popular"
        
        DataLoadMoviesModel.shared.loadMovies(searchString: popular, page: page, completion: { movies in
            if let movies = movies {
                DispatchQueue.main.async { [self] in
                    arrayFilm = movies.shuffled()
                    CoreDataModel.shared.saveNumberPage(numberPage: CoreDataModel.shared.getNumberPage() + 1)
                    secondaryCard.configurate(data: arrayFilm[primaryCounter])
                    primaryCounter += 1
                    primaryCard.configurate(data: arrayFilm[primaryCounter])
                    showCard(cards: [primaryCard, secondaryCard])
                    activityIndicator.stopAnimating()
                }
            }
        })
    }

    private func setData() {
        let amountFilms = 20
        
        if primaryCounter == amountFilms {
            hideCard(cards: [primaryCard, secondaryCard])
            activityIndicator.startAnimating()
            setArray(page: CoreDataModel.shared.getNumberPage())
            primaryCounter = 0
            initialCounter = 0
        }
    }
}

// MARK: - Setups

extension RandomViewController {
    private func setupView() {
        guard let background = UIImage(named: "background") else { return }
        self.view.backgroundColor = UIColor(patternImage: background)
        navigationItem.backButtonTitle = ""
        navigationItem.backBarButtonItem?.action = #selector((closeDetailVC))
    }
    
    @objc private func closeDetailVC() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setDelegate() {
        primaryCard.delegate = self
        secondaryCard.delegate = self
    }
    
    private func changeCardCounter() {
        if cardNow != 1 {
            cardNow = 1
        }
        else {
            cardNow = 0
        }
    }
    
    private func addCards(card: inout CardView) {
        card = CardView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.94, height: UIScreen.main.bounds.height * 0.74))
        card.center = self.view.center
        self.view.addSubview(card)
    }
    
    private func hideCard(cards: [CardView]) {
        for card in cards {
            card.alpha = 0
            activityIndicatorTitle.isHidden = false
        }
    }
    
    private func showCard(cards: [CardView]) {
        for card in cards {
            card.alpha = 1
            activityIndicatorTitle.isHidden = true
        }
    }
}

// MARK: - CardDelegate

extension RandomViewController: CardDelegate {
    private func setupAction() {
        if cardNow == 0 {
            self.view.sendSubviewToBack(secondaryCard)
            self.view.bringSubviewToFront(primaryCard)
            setData()
            secondaryCard.configurate(data: arrayFilm[primaryCounter])
            primaryCounter += 1
            initialCounter += 1
            changeCardCounter()
        }
        else {
            self.view.sendSubviewToBack(primaryCard)
            self.view.bringSubviewToFront(secondaryCard)
            setData()
            primaryCard.configurate(data: arrayFilm[primaryCounter])
            primaryCounter += 1
            initialCounter += 1
            changeCardCounter()
        }
    }
    
    func cardViewShouldGetLeft(_ sender: CardView) {
        CoreDataModel.shared.saveMovieInFavoriteMovies(movie: arrayFilm[initialCounter])
        setupAction()
    }
    
    func cardViewShouldGetRight(_ sender: CardView) {
        CoreDataModel.shared.saveIdMovieInIgnoreMovies(idMovie: arrayFilm[initialCounter].id)
        setupAction()
    }
    
    func cardViewShouldDidStart(_ sender: CardView) {
        if cardNow == 0{
            setData()
            primaryCard.configurate(data: arrayFilm[primaryCounter])
        }
        else {
            setData()
            secondaryCard.configurate(data: arrayFilm[primaryCounter])
        }
    }
    
    func infoButtonTapped(_ sender: CardView) {
        let detailInfo = DetailFilmViewController()
            if arrayFilm.isEmpty {
                print("Empty array")
            }
            else {
                detailInfo.hideBtn()
                detailInfo.configureId(id: arrayFilm[initialCounter].id)
            }
        navigationController?.pushViewController(detailInfo, animated: true)
    }
}
