//
//  CharacterDetailViewModel.swift
//  Rick and Morty
//
//  Created by itay gervash on 03/03/2022.
//

import Foundation

struct CharacterDetailTableViewCellViewModel {
    var details: [(Detail, String)] = []
    var episodes: [Episode]?
    var episodeDetails: [(String, String)] = []
    
    init(with character: Character) {
        details.append((Detail.name, character.name))
        details.append((Detail.status, character.status))
        details.append((Detail.species, character.species))
        details.append((Detail.gender, character.gender))
        details.append((Detail.origin, character.origin.name))
        details.append((Detail.location, character.location.name))
        
        if let episodes = character.episodeList {
            for episode in episodes {
                episodeDetails.append((episode.episode, episode.name))
            }
        }
        
        episodes = character.episodeList
    }
    
    enum Detail: String, CaseIterable {
        case name = "name"
        case status = "status"
        case species = "species"
        case gender = "gender"
        case origin = "origin"
        case location = "location"

    }

}
