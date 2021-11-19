//
//  CardView.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 04.11.2021.
//

import UIKit

protocol CardDelegate: AnyObject {
    func infoButtonTapped(_ sender: CardView)
    func cardViewShouldDidStart(_ sender: CardView)
    func cardViewShouldGetRight(_ sender: CardView)
    func cardViewShouldGetLeft(_ sender: CardView)
}

class CardView: UIView {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var tintView: UIView!
    @IBOutlet private weak var filmImageView: UIImageView!
    @IBOutlet private weak var filmTitleLabel: UILabel!
    @IBOutlet private weak var filmGenreLabel: UILabel!
    @IBOutlet private weak var ignoreButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var likeLabel: UILabel!
    @IBOutlet private weak var ignoreLabel: UILabel!
    @IBOutlet private weak var gradientView: UIView!
    
    private let cornerRadius: CGFloat = 10
    
    //TimeAnimations:
    private let moveCardTimeAnimation: Double = 0.58
    private let showTagAnimation: Double = 0.2
    
    //Colors:
    private let shadowCardColor = UIColor.black.cgColor
    private let shadowActionBtnColor = UIColor.systemIndigo
    private let shadowInfoBtnColor = UIColor.white
    private let favoriteColor = UIColor.systemIndigo
    private let ignoreColor = UIColor.red
    
    //Tag angles:
    private let ignoreAngle: CGFloat = 0.11
    private let favoriteAngle: CGFloat = -0.11
    
    enum State {
        case left
        case right
    }
    
    private let primaryPanGestureRecognizer = UIPanGestureRecognizer()
    private var panGestureAnchorPoint: CGPoint?
    
    private let xibName = "CardView"
    
    weak var delegate: CardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        setup()
        setupGestures()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setup()
        setupGestures()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
    }
    
    func configurate(data: MovieModel){
        guard let image = data.posterImage?.image else { return }
        filmImageView.image = UIImage(data: image)
        filmTitleLabel.text = data.title
        filmGenreLabel.text = "IMDB: " + "\(data.vote_average)"
    }
    
    @IBAction private func ignoreButtonTapped(_ sender: UIButton) {
        setButtons(state: .right, angle: ignoreAngle)
    }
    
    @IBAction private func likeButtonTapped(_ sender: UIButton) {
        setButtons(state: .left, angle: favoriteAngle)
    }
    
    @IBAction private func infoButtonTapped(_ sender: UIButton) {
        delegate?.infoButtonTapped(self)
    }
    
    private func setButtons(state: State, angle: CGFloat) {
        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        switch state {
        case .right:
            delegate?.cardViewShouldDidStart(self)
            getRight(card: contentView, pointCard: 0, pointParent: centerOfParentContainer)
        case .left:
            delegate?.cardViewShouldDidStart(self)
            getLeft(card: contentView, pointCard: 0, pointParent: centerOfParentContainer)
        }
        rotateMajorCard(card: contentView, angle: angle)
    }
}

// MARK: - Call all requireds setup

extension CardView {
    private func setup() {
        setupShadowMinorCard(shadowView: contentView, color: shadowCardColor)
        setupView(view: cardView)
        setupGradient(gradient: gradientView)
        setupLabels(label: ignoreLabel, color: ignoreColor, angle: ignoreAngle)
        setupLabels(label: likeLabel, color: favoriteColor, angle: favoriteAngle)
        setupButton(button: ignoreButton, color: shadowActionBtnColor)
        setupButton(button: likeButton, color: shadowActionBtnColor)
        setupButton(button: infoButton, color: shadowInfoBtnColor)
    }
}

// MARK: - Setup gesture

extension CardView {
    private func setupGestures() {
        primaryPanGestureRecognizer.addTarget(self, action: #selector(panGesture(_:)))

        contentView.addGestureRecognizer(primaryPanGestureRecognizer)
    }
    
    @objc private func panGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let card = gestureRecognizer.view!
        let point = gestureRecognizer.translation(in: self)
        
        let centerOfParentContainer = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        card.center = CGPoint(x: centerOfParentContainer.x + point.x, y: centerOfParentContainer.y)
        
        let distanceFromCenter = ((UIScreen.main.bounds.width / 2) - card.center.x)
        
        switch gestureRecognizer.state {
            case .began:
            hideTags(favoriteTag: likeLabel, ignoreTag: ignoreLabel)
            delegate?.cardViewShouldDidStart(self)
            case .changed:
            if point.x > 0 {
                rotateMajorCard(card: contentView, angle: favoriteAngle)
            }
            else {
                rotateMajorCard(card: contentView, angle: ignoreAngle)
            }
            if point.x < -70 {
                showTag(tag: ignoreLabel)
            }
            else if point.x > 70 {
                showTag(tag: likeLabel)
            }
            else {
                hideTags(favoriteTag: likeLabel, ignoreTag: ignoreLabel)
            }
            case .ended:
            hideTags(favoriteTag: likeLabel, ignoreTag: ignoreLabel)
                if distanceFromCenter > 60 {
                    getRight(card: card, pointCard: point.x, pointParent: centerOfParentContainer)
                    }
                else if distanceFromCenter < -60 {
                    getLeft(card: card, pointCard: point.x, pointParent: centerOfParentContainer)
                }
                else {
                   rotateMajorCard(card: contentView, angle: 0)
                   getCenter(card: card)
                }
        default:
            break
        }
    }
}

// MARK: - Functions for card

extension CardView {
    private func showTag(tag: UILabel) {
        UIView.animate(withDuration: showTagAnimation, animations: {
            tag.alpha = 1
        })
    }
    
    private func hideTags(favoriteTag: UILabel, ignoreTag: UILabel) {
        UIView.animate(withDuration: showTagAnimation, animations: {
            favoriteTag.alpha = 0
            ignoreTag.alpha = 0
        })
    }
    
    private func getLeft(card: UIView, pointCard: CGFloat, pointParent: CGPoint){
        UIView.animate(withDuration: moveCardTimeAnimation, animations: {
            card.center = CGPoint(x: pointParent.x + pointCard + 800, y: pointParent.y)
            self.layoutIfNeeded()
        }) { _ in
            
            card.transform = .identity
            self.delegate?.cardViewShouldGetLeft(self)
            card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
    }
    
    private func getRight(card: UIView, pointCard: CGFloat, pointParent: CGPoint){
        UIView.animate(withDuration: moveCardTimeAnimation, animations: {
            card.center = CGPoint(x: pointParent.x + pointCard - 800, y: pointParent.y)
            self.layoutIfNeeded()
        }) { _ in
           
            card.transform = .identity
            self.delegate?.cardViewShouldGetRight(self)
            card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        }
    }
    
    private func getCenter(card: UIView) {
        UIView.animate(withDuration: moveCardTimeAnimation, animations: {
            card.center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            self.layoutIfNeeded()
        })
    }
    
    private func rotateMajorCard(card: UIView, angle: CGFloat) {
        let rotateTimeAnimation: Double = 0.3
        UIView.animate(withDuration: rotateTimeAnimation, animations: {
            card.transform = CGAffineTransform.identity.rotated(by: angle)
        })
    }
}

// MARK: - Setups

extension CardView {
    private func setupView(view: UIView) {
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
    }
    
    private func setupShadowMinorCard(shadowView: UIView, color: CGColor?) {
        shadowView.layer.cornerRadius = cornerRadius
        shadowView.layer.shadowColor = color
        shadowView.layer.shadowRadius = 7
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
    
    private func setupLabels(label: UILabel, color: UIColor, angle: CGFloat) {
        label.textColor = color
        label.layer.borderColor = color.cgColor
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.alpha = 0
        label.transform = CGAffineTransform.identity.rotated(by: angle)
    }
    
    private func setupGradient(gradient: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = gradient.bounds
        gradient.layer.addSublayer(gradientLayer)
    }
    
    private func setupButton(button: UIButton, color: UIColor) {
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.layer.shadowColor = color.cgColor
        button.layer.shadowRadius = 7
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
    }
}
