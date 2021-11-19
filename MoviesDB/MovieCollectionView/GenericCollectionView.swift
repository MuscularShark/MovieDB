//
//  GenericCollectionView.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 05.11.2021.
//

import UIKit

protocol GenericCollectionViewDelegate: AnyObject {
    func genericCollectionView(_ sender: GenericCollectionView, currentPage: Int)
    func pushDetailFilmViewController(idCell: Int)
}

protocol HideSearchBarDelegate: AnyObject {
    func hideSearchBar()
}

class GenericCollectionView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    private let viewNibName = "GenericCollectionView"
    private let listCellIdentifier = "MovieListCollectionViewCell"
    private let gridCellIdentifier = "MovieGridCollectionViewCell"
    
    private var isListView = false
    private var currentPage = 1
    var movies: [MovieModel] = []
    
    weak var delegate: GenericCollectionViewDelegate?
    weak var searchBarDelegate: HideSearchBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        configureCollectionView()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(viewNibName, owner: self, options: nil)
        self.layoutSubviews()
        sharedLayout()
    }
    
    private func configureCollectionView() {
        guard let background = UIImage(named: "background") else { return }
        collectionView.backgroundColor = UIColor(patternImage: background)
        collectionView.showsVerticalScrollIndicator = false
        registerCell(forReuseIdentifier: listCellIdentifier)
        registerCell(forReuseIdentifier: gridCellIdentifier)
        collectionView.register(CollectionViewFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: CollectionViewFooterView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func sharedLayout() {
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.trailingAnchor.constraint(equalTo:self.trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    private func registerCell(forReuseIdentifier identifier: String) {
        collectionView.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    @IBAction func switcherGirdToList(_ sender: UIButton) {
        if isListView {
            sender.setImage(UIImage(systemName: "rectangle.grid.2x2"), for: .normal)
            isListView = false
        } else {
            sender.setImage(UIImage(systemName: "list.bullet"), for: .normal)
            isListView = true
        }
        collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource
extension GenericCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isListView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listCellIdentifier, for: indexPath) as? MovieListCollectionViewCell else { return UICollectionViewCell() }
            cell.updateMovie(currentMovie: movies[indexPath.row])
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellIdentifier, for: indexPath) as? MovieGridCollectionViewCell else { return UICollectionViewCell() }
            cell.updateMovie(currentMovie: movies[indexPath.row])
            cell.tag = indexPath.row
            cell.delegate = self
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate
extension GenericCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pushDetailFilmViewController(idCell: movies[indexPath.row].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: CollectionViewFooterView.identifier, for: indexPath) as! CollectionViewFooterView
        footer.addSubview(activityIndicator)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        activityIndicator.startAnimating()
        if indexPath.item == movies.count - 1 {
            currentPage += 1
            delegate?.genericCollectionView(self, currentPage: currentPage)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarDelegate?.hideSearchBar()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension GenericCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let listHeight: CGFloat = 300
        let gridHeight: CGFloat = 200
        let distanceBetweenCells: CGFloat = 5
        if isListView {
            return CGSize(width: width / 2 - distanceBetweenCells, height: listHeight)
        } else {
            return CGSize(width: width, height: gridHeight)
        }
    }
}

//MARK: - MovieGridCollectionViewCellDelegate and MovieListCollectionViewCellDelegate
extension GenericCollectionView: MovieGridListCollectionViewCellDelegate {
    func addToFavoritePressed(byIndex index: Int) {
        let coreDataMovies = CoreDataModel.shared.getListMoviesFromFavoriteMovies()
        if !coreDataMovies.contains(where: { movie in
            movie.id == movies[index].id
        }) {
            CoreDataModel.shared.saveMovieInFavoriteMovies(movie: movies[index])
        }
        collectionView.reloadData()
        print("Tapped")
    }
}




