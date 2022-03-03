//
//  CharacterCellViewModel.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import UIKit

struct CharacterCellViewModel {
    var name: String
    
    var imageUrl: String
    
    var image: UIImage? = nil
    
    init(with character: Character) {
        self.name = character.name
        self.imageUrl = character.image
    }
}
