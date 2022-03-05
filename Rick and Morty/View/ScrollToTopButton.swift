//
//  ScrollToTopButton.swift
//  Rick and Morty
//
//  Created by itay gervash on 05/03/2022.
//

import UIKit
import SnapKit

class ScrollToTopButton: UIButton {
    
    var anchorDirection: AnchorDirection = .bottom
    
    lazy var arrowImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.\(anchorDirection.rawValue).circle")
        view.tintColor = .label
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    //MARK: view set up
    

    func setUpView() {
        self.setTitle(nil, for: .normal)
        self.backgroundColor = .systemBackground
        
        switch anchorDirection {
        case .top:
            self.roundCorners([.bottomCorners], radius: 10 * heightModifier)
        case .right:
            self.roundCorners([.layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 10 * heightModifier)
        case .bottom:
            self.roundCorners([.topCorners], radius: 10 * heightModifier)
        case .left:
            self.roundCorners([.layerMaxXMaxYCorner, .layerMaxXMinYCorner], radius: 10 * heightModifier)
        }
        
        addSubviews()
        addConstraintsToSubviews()
    }
    
    func addSubviews() {
        
        self.addSubview(arrowImageView)

    }
    
    func addConstraintsToSubviews() {
        arrowImageView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setNeedsLayout()
        setUpView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setNeedsLayout()
        setUpView()
    }
    
    init(anchorTo direction: AnchorDirection) {
        super.init(frame: .zero)
        self.anchorDirection = direction
        setNeedsLayout()
        setUpView()

    }
    
    enum AnchorDirection: String {
        //strings are used to get image for button
        case top = "bottom"
        case right = "left"
        case bottom = "top"
        case left = "right"
    }

}

