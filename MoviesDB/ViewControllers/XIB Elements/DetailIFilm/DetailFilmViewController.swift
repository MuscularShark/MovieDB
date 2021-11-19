//
//  DetailFilmViewController.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 31.10.2021.
//

import UIKit

class DetailFilmViewController: UIViewController {
    @IBOutlet private weak var detailContainerView: UIView!
    @IBOutlet private weak var detailTagContainer: UIView!
    @IBOutlet private weak var detailImageView: UIImageView!
    @IBOutlet private weak var detailNameLabel: UILabel!
    @IBOutlet private weak var detailInfoTextView: UITextView!
    @IBOutlet private weak var detailDurationLabel: UILabel!
    @IBOutlet private weak var detailDateLabel: UILabel!
    @IBOutlet private weak var detailCountryLabel: UILabel!
    @IBOutlet private weak var detailAverage: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var activityIndicatorTitle: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    private var status = false
    
    private var ratingColor = UIColor.white
    private var idFilm: Int?
    private var currentMovie: [MovieModel] = []
    let coreDataMovie = CoreDataModel.shared.getListMoviesFromFavoriteMovies()
    
    override func viewWillAppear(_ animated: Bool) {
        setdata()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideContainerView()
        setupBtn()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        let begginURL = "https://www.themoviedb.org/movie/"
        guard let begginTitle = detailNameLabel.text, let id = idFilm else { return }
        let title = begginTitle.lowercased().replacingOccurrences(of: " ", with: "-")
        let url = [URL(string: begginURL + "\(id)-" + title)]
        let share = UIActivityViewController(activityItems: url, applicationActivities: nil)
        present(share, animated: true)
    }
    
    @IBAction func addToFavoriteTap(_ sender: UIButton) {
        if coreDataMovie.contains(where: { movie in
            detailNameLabel.text == movie.title
        }) {
            let alertController = UIAlertController(title: title, message: "Мovie has already been liked", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okBtn)
            present(alertController, animated: true, completion: nil)
        }
        else {
            CoreDataModel.shared.saveMovieInFavoriteMovies(movie: currentMovie[0])
            let alertController = UIAlertController(title: title, message: "Movie has been added to favorites", preferredStyle: .alert)
            let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okBtn)
            present(alertController, animated: true, completion: nil)
            likeBtn.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
            likeBtn.isEnabled = false
            
        }
    }
    
    func configureId(id: Int) {
        idFilm = id
    }
    
    func hideBtn() {
        status = true
    }
}

extension DetailFilmViewController {
    private func setdata() {
        guard let idFilm = idFilm else { return }
        DataLoadMoviesModel.shared.loadArrayWithOneMovies(idMovie: idFilm) { [weak self] movie in
            if let movie = movie {
                DispatchQueue.main.async { [self] in
                    let movieCurrent = movie[0]
                    self?.currentMovie = [movieCurrent]
                    guard let image = movieCurrent.posterImage?.image,
                          let runtime = movieCurrent.runtime,
                          let countries = movieCurrent.production_countries,
                          let coreData = self?.coreDataMovie
                    else { return }
                    self?.setColorRating(rating: movieCurrent.vote_average)
                    self?.setupContaioner()
                    for country in countries {
                        self?.detailCountryLabel.text = country["name"]
                    }
                    self?.detailImageView.image = UIImage(data: image)
                    self?.detailNameLabel.text = movieCurrent.title
                    self?.navigationItem.title = movieCurrent.title
                    self?.detailInfoTextView.text = movieCurrent.overview
                    self?.setupTextView()
                    
                    self?.detailDateLabel.text = movieCurrent.release_date
                    self?.detailDurationLabel.text = String(runtime) + "min"
                    self?.detailAverage.text = String(movieCurrent.vote_average)
                    self?.showContainerView()
                    self?.activityIndicator.stopAnimating()
                    if coreData.contains(where: { movie in
                        self?.detailNameLabel.text == movie.title
                    }) {
                        self?.likeBtn.setImage(UIImage(systemName: "suit.heart.fill"), for: .normal)
                        self?.likeBtn.isEnabled = false
                    }
                    else {
                        self?.likeBtn.setImage(UIImage(systemName: "suit.heart"), for: .normal)
                    }
                }
            }
        }
    }

    private func setColorRating(rating: Double) {
        if rating >= 7 {
            ratingColor = UIColor.blue
        }
        else if rating < 7 && rating >= 5 {
            ratingColor = UIColor.systemGreen
        }
        else {
            ratingColor = UIColor.red
        }
    }

    private func setupContaioner() {
        detailTagContainer.backgroundColor = ratingColor
        detailTagContainer.layer.cornerRadius = 0.5 * detailTagContainer.bounds.size.width
        detailTagContainer.layer.shadowColor = ratingColor.cgColor
        detailTagContainer.layer.shadowRadius = 7
        detailTagContainer.layer.shadowOpacity = 0.3
        detailTagContainer.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    private func setupView() {
        guard let background = UIImage(named: "background") else { return }
        view.backgroundColor = UIColor(patternImage: background)
    }
    
    private func hideContainerView() {
        detailContainerView.alpha = 0
        activityIndicatorTitle.alpha = 1
    }
    
    private func showContainerView() {
        detailContainerView.alpha = 1
        activityIndicatorTitle.alpha = 0
    }
    
    private func setupTextView() {
        detailInfoTextView.translatesAutoresizingMaskIntoConstraints = true
        detailInfoTextView.sizeToFit()
        detailInfoTextView.isScrollEnabled = false
    }
    
    private func setupBtn() {
        if status {
            likeBtn.isHidden = true
        }
        else {
            likeBtn.isHidden = false
        }
    }
}
