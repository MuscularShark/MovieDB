//
//  MoviesResponseModel.swift
//  MoviesDB
//
//  Created by Сергей Гнидь on 03.11.2021.
//

import Foundation

struct MoviesResponseModel: Codable {
    let page: Int
    let results: [MovieModel]
    let total_pages: Int
    let total_results: Int
}
