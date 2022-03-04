//
//  NavigationController.swift
//  Emotional Aid
//
//  Created by itay gervash on 14/06/2021.
//

import UIKit
import ShimmerSwift

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.tintColor = .label

        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.label]
    }
    
}

