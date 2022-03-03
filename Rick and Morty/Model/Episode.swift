//
//  Episode.swift
//  Rick and Morty
//
//  Created by itay gervash on 03/03/2022.
//

import Foundation

struct Episode: Codable {
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    
    var characterNames: [String]? = nil
    
    enum CodingKeys: String, CodingKey {
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
    }
    
    func numericCharacterIDList() -> [Int] {
        var list: [Int] = []
        
        for character in characters {
            if let characterID = Int(character.components(separatedBy: .decimalDigits.inverted).joined()) {
                list.append(characterID)
            }
        }
        
        return list
    }
    
}
