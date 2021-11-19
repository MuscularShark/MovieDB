//
//  MovieListCollectionViewCell.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 28.10.2021.
//

import UIKit

class MovieListCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var ratedLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    private var cornerRadius: CGFloat = 10
    private var shadowOpacity: Float = 0.8
    
    weak var delegate: MovieGridListCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.layer.cornerRadius = cornerRadius
        setupShadow()
    }
    
    @IBAction func addToFavoritesButtonPressed(_ sender: UIButton) {
        delegate?.addToFavoritePressed(byIndex: self.tag)
    }
    
    func updateMovie(currentMovie: MovieModel) {
        guard let posterImage = currentMovie.posterImage?.image else { return }
        posterImageView.image = UIImage(data: posterImage)
        ratedLabel.text = "\(currentMovie.vote_average)"
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = shadowOpacity
    }
}
