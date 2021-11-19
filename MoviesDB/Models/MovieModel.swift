//
//  MovieModel.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 03.11.2021.
//

import Foundation
import UIKit

struct MovieModel: Codable {
    let id: Int
    let title: String
    let overview: String
    
    let popularity: Double
    let release_date: String
    let vote_average: Double
    
    let runtime: Int?
    let production_countries: [Dictionary<String, String>]?
    
    let poster_path: String?
    let backdrop_path: String?
 
    var posterImage: MyImage?
    var backdropImage: MyImage?
    
    var check: Bool?
}

public struct MyImage: Codable {
    public var image: Data?
    
    public init(image: UIImage) {
        self.image = image.pngData()!
    }
}
