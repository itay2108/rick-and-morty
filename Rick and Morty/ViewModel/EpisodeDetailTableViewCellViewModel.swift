//
//  EpisodeTableViewCellViewModel.swift
//  Rick and Morty
//
//  Created by itay gervash on 03/03/2022.
//

import Foundation

struct EpisodeDetailTableViewCellViewModel {
    var details: [(Detail, String)] = []
    var characterNames: [String] = []
    
    //initialize after setting episode.characterNames
    init(with episode: Episode) {
        details.append((.name, episode.name))
        details.append((.airDate, episode.airDate))
        details.append((.episode, episode.episode))
        
        if let names = episode.characterNames {
            for characterName in names {
                characterNames.append(characterName)
            }
        }

    }
    
    enum Detail: String, CaseIterable {
        case name = "name"
        case airDate = "air date"
        case episode = "episode"


    }

}
