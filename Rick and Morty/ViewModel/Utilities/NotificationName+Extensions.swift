//
//  NotificationName+Extensions.swift
//  Eight-Six
//
//  Created by itay gervash on 13/11/2020.
//

import UIKit

extension Notification.Name {
    static var imageHasFinishedLoading: Notification.Name {
            return .init(rawValue: "Gallery.ImageHasFinishedLoading")
        }
    
    static var thumbHasFinishedLoading: Notification.Name {
            return .init(rawValue: "Gallery.ThumbHasFinishedLoading")
        }

}

