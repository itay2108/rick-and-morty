//
//  ViewController.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    // pagination / infinite scroll. when scrolling almost to the end of the gallery, this value turns into true (once!) and the character data method gets called with the next page url from the last response which is saved under nextCharacterPageURL
    private var didReachScrollingRefreshPoint: Bool = false {
        didSet {
            
            if didReachScrollingRefreshPoint {
                guard let nextCharacterPageURL = nextCharacterPageURL else { return }
                
                getCharacterData(from: nextCharacterPageURL)
            }
        }
    }
    var nextCharacterPageURL: String?
    
    private var characterDataSource: [Character] = [] {
        didSet {
            characterGallery.reloadData()
            didReachScrollingRefreshPoint = false
        }
    }
    
    //MARK: - UI Elements Declaration
    
    private lazy var characterGallery: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16 * heightModifier
        layout.minimumInteritemSpacing = 12 * widthModifier
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    private lazy var galleryProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = K.colors.pickleGreen
        progressView.backgroundColor = K.colors.pickleGreen?.withAlphaComponent(0.3)
        
        return progressView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate setting
        characterGallery.delegate = self; characterGallery.dataSource = self
        
        //setup visual elements
        setUpUI()
        
        // retrieve characters
        getCharacterData(from: CharacterRetriever.baseURL)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        galleryProgressView.circlize()
    }
    
    //MARK: - UI Methods
    
    private func setUpUI() {
        
        self.view.backgroundColor = K.colors.background
        title = "Rick and Morty"
        
        addSubviews()
        setConstraintsForSubviews()
        
    }
    
    private func addSubviews() {
        view.addSubview(characterGallery)
        view.addSubview(galleryProgressView)
    }
    
    private func setConstraintsForSubviews() {
        
        characterGallery.snp.makeConstraints { (make) in
            
            make.top.equalTo(view.safeAreaLayoutGuide).offset((36 * heightModifier))
            make.left.equalToSuperview().offset(24 * widthModifier)
            make.right.equalToSuperview().offset(-24 * widthModifier)
            make.bottom.equalTo(galleryProgressView.snp.top).offset(-32 * heightModifier)
            
        }
        
        galleryProgressView.snp.makeConstraints { make in
            make.height.equalTo(8 * heightModifier)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32 * heightModifier)
        }
        
    }
    
    private func getCharacterData(from url: String) {
        CharacterRetriever.shared.getCharacters(url: url) { [weak self] success, result, nextPage, error in
            
            if success {
                if let resultAsCharacters = result as? [Character] {
                    self?.characterDataSource += resultAsCharacters
                    self?.nextCharacterPageURL = nextPage
                    print("character data source added")
                }
            } else {
                print("could get characters: \(String(describing: error))")
            }
            
        }
    }
    
}

//MARK: - Collectionview Methods

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterDataSource.count
    }
    
    //define cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 18) / 2
        let height = (collectionView.frame.height - 32) / 2
        
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //set cell as custom character cell class
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        
        //error cell is an empty cell that displays if theres an "index out of range" bug for any reason, to prevent crashes.
        let errorCell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCell.identifier, for: indexPath) as! CharacterCell
        errorCell.title.text = ""
        
        guard characterDataSource.count != 0,
              characterDataSource.count > indexPath.row
        else { return errorCell }
        
        //populate cell data
        let character = characterDataSource[indexPath.row]
        let cellData = CharacterCellViewModel(with: character)
        
        cell.setContent(with: cellData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //sometimes cells dont load when returning to view. this makes sure they do.
        let cellData = CharacterCellViewModel(with: characterDataSource[indexPath.row])
        
        if let cell = cell as? CharacterCell {
            if cell.imageContainer.image == nil {
                cell.setContent(with: cellData)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //remove cell image data when not displayed to save memory
        
        if let cell = cell as? CharacterCell {
            cell.imageContainer.image = nil
            cell.title.text = nil
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard characterDataSource.count > indexPath.row, characterDataSource.count != 0 else { return }
        
        let destination = CharacterDetailViewController()
        var characterToDisplay = characterDataSource[indexPath.row]
        
        //get list of [Episode] objects to show in the destination/
        CharacterRetriever.shared.getEpisodes(by: characterToDisplay.numericEpisodeList()) { success, result, error in
            if success {
                characterToDisplay.episodeList = result
                destination.viewModel = CharacterDetailTableViewCellViewModel(with: characterToDisplay)
            } else {
                print("error: \(String(describing: error))")
            }
        }
        
        destination.characterImage = (collectionView.cellForItem(at: indexPath) as? CharacterCell)?.imageContainer.image
        
        self.navigationController?.pushViewController(destination, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let contentXoffset = scrollView.contentOffset.x
        let distanceFromEnd = scrollView.contentSize.width - contentXoffset
        let scrollProgress = contentXoffset / (scrollView.contentSize.width - scrollView.frame.width)
        
        //trigger refresh point a little bit before the end of the collection view.
        if distanceFromEnd - (view.frameWidth / 1.5) < width && scrollView.contentSize.width > 0 {
            //set this value only once so didSet doesnt cause the api to be called numerous times in a row. after the gallery is updated with additional data, this value is reset to false.
            if !didReachScrollingRefreshPoint {
                didReachScrollingRefreshPoint = true
            }
        }
        
        galleryProgressView.setProgress(Float(scrollProgress), animated: true)
    }
    
}
