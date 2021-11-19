//
//  CoreDataModel.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 10.11.2021.
//

import UIKit
import CoreData

class CoreDataModel {
    static let shared = CoreDataModel()
    
    private init() {}
    
    // MARK: - func FavoriteMovies
    
    func saveMovieInFavoriteMovies(movie: MovieModel){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteMovies", in: context) else { return }
    
        let movieObject = FavoriteMovies(entity: entity, insertInto: context)
        
        movieObject.id = Int32(movie.id)
        movieObject.title = movie.title
        movieObject.overview = movie.overview
        movieObject.popularity = movie.popularity
        movieObject.release_date = movie.release_date
        movieObject.vote_average = movie.vote_average
        
        if movie.runtime != nil {
            movieObject.runtime = Int32(movie.runtime!)
        }
        movieObject.production_countries = movie.production_countries as NSObject?
        movieObject.poster_path = movie.poster_path
        movieObject.backdrop_path = movie.backdrop_path
        movieObject.posterImage = movie.posterImage?.image
        movieObject.backdropImage = movie.backdropImage?.image
        if movie.check != nil {
            movieObject.check = movie.check!
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func getListMoviesFromFavoriteMovies() -> [MovieModel] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<FavoriteMovies> = FavoriteMovies.fetchRequest()
        
        var favoriteMovies = [FavoriteMovies]()
        
        do {
            favoriteMovies = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        var result = [MovieModel]()
        
        for favoriteMovie in favoriteMovies {
            let movie: MovieModel = MovieModel.init(id: Int(favoriteMovie.id),
                                                    title: favoriteMovie.title ?? "",
                                                    overview: favoriteMovie.overview ?? "",
                                                    popularity: favoriteMovie.popularity,
                                                    release_date: favoriteMovie.release_date ?? "",
                                                    vote_average: favoriteMovie.vote_average,
                                                    runtime: Int(favoriteMovie.runtime),
                                                    production_countries: favoriteMovie.production_countries as? [Dictionary<String, String>],
                                                    poster_path: favoriteMovie.poster_path,
                                                    backdrop_path: favoriteMovie.backdrop_path,
                                                    posterImage: MyImage.init(image: (UIImage(data: favoriteMovie.posterImage!)!)),
                                                    backdropImage: MyImage.init(image: (UIImage(data: favoriteMovie.backdropImage!)!)),
                                                    check: favoriteMovie.check)
            result.append(movie)
        }
        return result
    }
    
    // MARK: - func IgnoreMovies
    
    func saveIdMovieInIgnoreMovies(idMovie: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "IgnoreMovies", in: context) else { return }
    
        let movieObject = IgnoreMovies(entity: entity, insertInto: context)
        
        movieObject.id = Int32(idMovie)
    
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func getListMoviesFromIgnoreMovies() -> [Int] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<IgnoreMovies> = IgnoreMovies.fetchRequest()
        
        var ignoreMovies = [IgnoreMovies]()
        
        do {
            ignoreMovies = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        var result = [Int]()
        
        for ignoreMovie in ignoreMovies {
            result.append(Int(ignoreMovie.id))
        }
        return result
    }
    
    // MARK: - func Page
    
    func saveNumberPage(numberPage: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Page", in: context) else { return }
    
        let pageObject = Page(entity: entity, insertInto: context)
        
        pageObject.number = Int32(numberPage)
    
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func getNumberPage() -> Int {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Page> = Page.fetchRequest()
        
        var pages = [Page]()
        
        do {
            pages = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return Int(pages[pages.count-1].number)
    }
}
