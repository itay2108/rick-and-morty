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
    
    var image: UIImage?
    
    init(with character: Character, image characterImage: UIImage) {
        self.name = character.name
        self.imageUrl = character.imageURL
        
        self.image = characterImage
    }
}
