//
//  CharacterRetrieverError.swift
//  Rick and Morty
//
//  Created by itay gervash on 06/03/2022.
//

import Foundation

enum CharacterRetrieverError: Error {
    case badURL
    case badData
    case badResponse
}
