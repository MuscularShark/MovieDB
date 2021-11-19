//
//  NetworkManager.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 03.11.2021.
//

import Foundation
import UIKit

typealias MoviesLoadComplitionalBlock = (_ result: [MovieModel]?) -> ()
typealias MovieLoadComplitionalBlock = (_ result: MovieModel?) -> ()
typealias ImageLoadComplitionalBlock = (_ result: UIImage?) -> ()

class NetworkManager{
    private let beginApi = "https://api.themoviedb.org/3/"
    private let apiKey = "api_key=7682947471ea97daf7aeb06f2ace62fa"
    private let beginApiForImage = "https://www.themoviedb.org/t/p/w500"
    
    private let session = URLSession.shared
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - func
    
    func callListOfMoviesRequest(searchString: String, page: Int, completion: @escaping MoviesLoadComplitionalBlock) {
        let urlString = beginApi + "\(searchString)?" + "page=\(page)&" + apiKey
        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { (data, response , error) in
            var movieModels = [MovieModel]()
            
            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let moviesResponseModel: MoviesResponseModel = try decoder.decode(MoviesResponseModel.self, from: data)
                movieModels = moviesResponseModel.results
            } catch {
                print(error)
            }

            completion(movieModels)
        }.resume()
    }
    
    func callMovieRequest(idMovie: Int, completion: @escaping MovieLoadComplitionalBlock) {
        let urlString = beginApi + "movie/\(idMovie)?" + apiKey
        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { (data, response , error) in
            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let movieModel  = try decoder.decode(MovieModel.self, from: data)
                    
                completion(movieModel)
            } catch {
                print(error)
            }
        }.resume()
    }
         
    func searchMovieRequest(word: String, completion: @escaping MoviesLoadComplitionalBlock) {
        let urlString = beginApi + "search/movie?query=\(word)&" + apiKey
        guard let url = URL(string: urlString) else { return }

        session.dataTask(with: url) { data, _, error in
            var movieModels = [MovieModel]()

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                let moviesResponseModel: MoviesResponseModel = try decoder.decode(MoviesResponseModel.self, from: data)
                movieModels = moviesResponseModel.results
            } catch {
                print(error)
            }

            completion(movieModels)

        }.resume()
    }

    func callImageRequest(string: String, completion: @escaping ImageLoadComplitionalBlock) {
        if string == ""{
            completion(UIImage(named: "noImage"))
        } else {
            let urlString = beginApiForImage + string
            guard let url = URL(string: urlString) else { return }

            session.dataTask(with: url) { (data, response , error) in
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                }
            }.resume()
        }
    }
}
