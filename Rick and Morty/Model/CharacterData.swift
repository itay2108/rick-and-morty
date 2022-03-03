//
//  CharacterData.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import Foundation

struct CharacterData: Codable {
    
    let info : Info?
    let results: [Character]
    
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }

}
