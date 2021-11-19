//
//  DataLoadMoviesModel.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 03.11.2021.
//

import Foundation

typealias DataLoadComplitionalBlock = (_ result: [MovieModel]?) -> ()

class DataLoadMoviesModel{
    private var completionMovie: DataLoadComplitionalBlock? = nil
    private var movies = [MovieModel]()
    
    static let shared = DataLoadMoviesModel()
    
    private init() {}

    // MARK: - func
    
    func loadMovies(searchString: String, page: Int, completion: @escaping DataLoadComplitionalBlock) {
        completionMovie = completion

        NetworkManager.shared.callListOfMoviesRequest(searchString: searchString, page: page) { [weak self](movieModels) in
                    if let movieModels = movieModels{
                        self?.movies = movieModels
                        self?.loadImage()
                    }
        }
    }
    
    func loadArraySearchMovie(word: String, completion: @escaping DataLoadComplitionalBlock) {
        completionMovie = completion
        
        NetworkManager.shared.searchMovieRequest(word: word) { [weak self](movie) in
            if let movie = movie {
                self?.movies = movie
                self?.loadImage()
            }
        }
    }
    
    func loadArrayWithOneMovies(idMovie: Int, completion: @escaping DataLoadComplitionalBlock) {
        completionMovie = completion
        
        NetworkManager.shared.callMovieRequest(idMovie: idMovie) { [weak self](movie) in
                    if let movie = movie{
                        self?.movies = [movie]
                        self?.loadImage()
                    }
        }
    }
    
    // MARK: - Private func
    
    private func loadImage(){
        movies.forEach { movie in
            NetworkManager.shared.callImageRequest(string: movie.poster_path ?? "") { result in
                if let result = result, let index = self.movies.firstIndex(where: {$0.id == movie.id}){
                    self.movies[index].posterImage = MyImage.init(image: result)
                    self.loadSecondImage(movie: self.movies[index])
                }
            }
        }
    }
    
    private func loadSecondImage(movie: MovieModel){
        NetworkManager.shared.callImageRequest(string: movie.backdrop_path ?? "") { result in
            if let result = result {
                if let index = self.movies.firstIndex(where: {$0.id == movie.id}){
                    self.movies[index].backdropImage = MyImage.init(image: result)
                    self.movies[index].check = true
                    self.isComplited()
                }
            }
        }
    }
    
    private func isComplited(){
        var allImageUploaded = true
            for movie in movies {
                if movie.check == false || movie.check == nil {
                    allImageUploaded = false
                }
            }
        
        if allImageUploaded, let completionMovie = self.completionMovie{
                completionMovie(self.movies)
        }
    }
}
