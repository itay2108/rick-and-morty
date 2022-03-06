//
//  Character.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import Foundation
import UIKit

struct Character: Codable, Equatable {
    static func == (lhs: Character, rhs: Character) -> Bool {
        if lhs.name == rhs.name { return true }
        else { return false }
    }
    
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let imageURL: String
    let episodeURLList: [String]
    var episodeList: [Episode]? = nil
    let origin: Origin
    let location: Location
    
    
    struct Origin: Codable {
        let name: String
    }
    
    struct Location: Codable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case status
        case species
        case gender
        case imageURL = "image"
        case episodeURLList = "episode"
        case origin
        case location
    }
    
    func numericEpisodeList() -> [Int] {
        var list: [Int] = []
        
        for episode in episodeURLList {
            if let episodeID = Int(episode.components(separatedBy: .decimalDigits.inverted).joined()) {
                list.append(episodeID)
            }
        }
        
        return list
    }
}
