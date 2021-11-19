//
//  MovieGridCollectionViewCell.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 28.10.2021.
//

import UIKit

protocol MovieGridListCollectionViewCellDelegate: AnyObject {
    func addToFavoritePressed(byIndex index: Int)
}

class MovieGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var ratedLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var tintView: UIView!
    
    private var cornerRadius: CGFloat = 10
    private var shadowOpacity: Float = 0.8
    
    weak var delegate: MovieGridListCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.layer.cornerRadius = cornerRadius
        setupShadow()
    }
    
    @IBAction func addToFavoritesButtonPressed(_ sender: UIButton) {
        delegate?.addToFavoritePressed(byIndex: self.tag)
    }
    
    func updateMovie(currentMovie: MovieModel) {
        guard let backgroundImage = currentMovie.backdropImage?.image else { return }
        backgroundImageView.image = UIImage(data: backgroundImage)
        titleLabel.text = currentMovie.title
        ratedLabel.text = "\(currentMovie.vote_average)"
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = shadowOpacity
        tintView.layer.cornerRadius = cornerRadius
    }
}
