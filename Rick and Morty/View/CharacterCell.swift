import UIKit
import SnapKit

class CharacterCell: UICollectionViewCell {
    
    static let identifier: String = "CharacterCell"
    
    lazy var imageContainer: UIImageView = {
       let view = UIImageView()
        view.backgroundColor = UIColor(red: 0.854, green: 0.886, blue: 0.929, alpha: 0.85)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 6 * heightModifier
        return view
    }()

    private lazy var titleContainer: UIView = {
        return UIView()
    }()

    
    lazy var title: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14 * heightModifier, weight: .medium)
        label.minimumScaleFactor = 10 * heightModifier
        label.contentMode = .left
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .darkGray
        return indicator
    }()
    
    func addSubviews() {
        self.addSubview(imageContainer)
        self.addSubview(titleContainer)

        titleContainer.addSubview(title)
        
        self.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func setConstraintsToSubviews() {
        imageContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        titleContainer.snp.makeConstraints { (make) in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.2)
        }
        
        
        title.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16 * widthModifier)
            make.height.equalToSuperview().multipliedBy(0.75)
        }
        
        loadingIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(self.imageContainer.snp.center)
            make.height.equalTo(self.imageContainer.snp.height).multipliedBy(0.14)
            make.width.equalTo(self.imageContainer.snp.height).multipliedBy(0.14)
        }
        
    }
    
    func setContent(with data: CharacterCellViewModel) {

        self.title.text = data.name
        
        if data.image != nil {
            self.imageContainer.image = data.image!
        } else {
            CharacterRetriever.shared.getCharacterImage(of: data.imageUrl) { success, result, error in
                if success {
                    if let image = result {
                        self.imageContainer.image = image
                        self.loadingIndicator.stopAnimating()
                    }
                }
            }
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
