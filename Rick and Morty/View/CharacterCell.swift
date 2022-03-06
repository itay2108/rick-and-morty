import UIKit
import SnapKit
import ShimmerSwift

class CharacterCell: UICollectionViewCell {
    
    static let identifier: String = "CharacterCell"
    
    private var imageChangeObservation: NSKeyValueObservation?
    
    var onReuse: () -> Void = {}
    
    private lazy var shimmerContainer: ShimmeringView = {
       let shimmer = ShimmeringView()
        shimmer.isShimmering = false
        shimmer.shimmerAnimationOpacity = 0.75
        shimmer.roundCorners(.allCorners, radius: 10 * heightModifier)
        return shimmer
    }()
    
    lazy var imageContainer: UIImageView = {
       let view = UIImageView()
        view.backgroundColor = UIColor(red: 0.854, green: 0.886, blue: 0.929, alpha: 0.85)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.roundCorners(.allCorners, radius: 10 * heightModifier)
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
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    func addSubviews() {
        self.addSubview(shimmerContainer)
        shimmerContainer.contentView = imageContainer
        
        self.addSubview(titleContainer)

        titleContainer.addSubview(title)
    }
    
    func setConstraintsToSubviews() {
        shimmerContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.67)
        }
        
        titleContainer.snp.makeConstraints { (make) in
            make.top.equalTo(imageContainer.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        
        title.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16 * widthModifier)
            make.height.equalToSuperview().multipliedBy(0.75)
        }
        
    }
    
    func setContent(with data: CharacterCellViewModel) {
        
        self.title.text = data.name
        self.imageContainer.image = data.image

    }
    
    func setupKVOs() {
        imageChangeObservation = imageContainer.observe(\.image, options: [.new]) { [weak self] (object, change) in
            if self?.imageContainer.image == nil {
                self?.shimmerContainer.isShimmering = true
            } else {
                self?.shimmerContainer.isShimmering = false
            }
        }
    }
    
    func stopShimmering() {
        self.shimmerContainer.isShimmering = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setConstraintsToSubviews()
        
        //shimmering on when image is nil
        setupKVOs()
        
        
        
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      onReuse()
      imageContainer.image = nil
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    deinit {
        imageChangeObservation?.invalidate()
    }
}
