//
//  NotFoundView.swift
//  Rick and Morty
//
//  Created by itay gervash on 04/03/2022.
//

import UIKit
import SnapKit

class NotFoundView: UIView {
    
    private lazy var imageContainer: UIImageView = {
       let view = UIImageView()
        view.image = K.images.notFound
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13 * heightModifier, weight: .medium)
        label.contentMode = .center
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .label.withAlphaComponent(0.5)
        label.text = "Looks like nothing\nwas found"
        return label
    }()
    
    private func addSubviews() {
        addSubview(imageContainer)
        addSubview(label)
    }
    
    private func setConstraintsToSubviews() {
        imageContainer.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(imageContainer.snp.width)
        }
        
        label.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.top.equalTo(imageContainer.snp.bottom).offset(24 * heightModifier)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setConstraintsToSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
}
