//
//  EpisodeDetailTableViewCell.swift
//  Rick and Morty
//
//  Created by itay gervash on 03/03/2022.
//

import UIKit

class EpisodeDetailTableViewCell: UITableViewCell {

    static let identifier: String = "EpisodeDetailTableViewCell"

    lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16 * heightModifier, weight: .medium)
        label.contentMode = .left
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    lazy var detail: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16 * heightModifier, weight: .regular)
        label.contentMode = .right
        label.numberOfLines = 2
        label.textAlignment = .right
        label.textColor = .label.withAlphaComponent(0.66)
        label.minimumScaleFactor = 0.66
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    
    func addSubviews() {

        self.addSubview(title)
        self.addSubview(detail)
    }
    
    func setConstraintsToSubviews() {
        
        title.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(36 * widthModifier)
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.greaterThanOrEqualToSuperview().multipliedBy(0.5)
        }
        
        detail.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-36 * widthModifier)
            make.height.equalToSuperview().multipliedBy(0.75)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
        }
        
        
    }
    
    func setCellContent(with data: EpisodeDetailTableViewCellViewModel, indexPath: IndexPath) {
        //make sure that selected row can be represented inside relevant data array (prevent index out of range crashes)
        guard indexPath.row < (indexPath.section == 0 ? data.details.count : data.characterNames.count) else { return }
        
        //depending on cell section - populate with relevant data from details or episodeDetails tuple
        title.text = indexPath.section == 0 ? (data.details[indexPath.row].0.rawValue + ":").capitalized : data.characterNames[indexPath.row]
        detail.text = indexPath.section == 0 ? data.details[indexPath.row].1 : ""
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        
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
