//
//  ViewController.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import UIKit
import SnapKit
import MessageUI

class MainViewController: UIViewController {
    
    // pagination / infinite scroll. when scrolling almost to the end of the gallery, this value turns into true (once!) and the character data method gets called with the next page url from the last response which is saved under nextCharacterPageURL
    private var didReachScrollingRefreshPoint: Bool = false {
        didSet {
            
            if didReachScrollingRefreshPoint && !isDisplayingSearchResults {
                guard let nextCharacterPageURL = nextCharacterPageURL else { return }
                
                getCharacterData(from: nextCharacterPageURL)
            }
        }
    }
    var nextCharacterPageURL: String?
    var isDisplayingSearchResults: Bool = false
    
    //main data source for gallery. when set we reload the collection view
    private var characterDataSource: [Character] = [] {
        didSet {

            DispatchQueue.global(qos: .userInitiated).sync { [weak self] in
                self?.characterGallery.reloadData()
            }

            didReachScrollingRefreshPoint = false
        }
    }
    
    //used to store original data when searching for different characters, so when the user closes the search - the gallert shows the original data.
    private var characterDataSnapshot: [Character]?
    
    //used to compare later when data changes, so if there were populated cells that were cleared (e.g. search results are empty) - we can show the notFoundView
    private var collectionViewCellCountSnapshot: Int?
    
    //MARK: - UI Elements Declaration
    
    private lazy var notFoundView: NotFoundView = {
        let view = NotFoundView()
        view.isHidden = true
        return view
    }()
    
    private lazy var hireMeButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Feedback", style: .plain, target: self, action: #selector(promptFeedback))
        return item
    }()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.tintColor = .gray
        bar.searchBarStyle = .minimal
        bar.placeholder = "Search"
        bar.returnKeyType = .search
        
        bar.enablesReturnKeyAutomatically = false
        
        //setup keyboard toolbar with done button that resigns keyboard
        let toolbar = UIToolbar()
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let hide = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboardBarItemTapped(_:)))
        toolbar.items = [leftSpace, hide]
        toolbar.sizeToFit()
        bar.searchTextField.inputAccessoryView = toolbar
        
        //close keyboard when x button tapped in search bar
        if let clearButton = bar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.addTarget(self, action: #selector(searchBarXButtonTapped(_:)), for: .touchUpInside)

        }
        
        bar.searchTextField.addTarget(self, action: #selector(searchBarTextDidChange(_:)), for: .editingChanged)
        return bar
    }()
    
    private lazy var characterGallery: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 24 * heightModifier
        layout.minimumInteritemSpacing = 24 * widthModifier
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CharacterCell.self, forCellWithReuseIdentifier: CharacterCell.identifier)
        
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 24 * widthModifier)
        
        cv.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 10 * heightModifier)
        
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
        characterGallery.delegate = self; characterGallery.dataSource = self; searchBar.delegate = self
        
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
        title = "Characters"
        
        addSubviews()
        setConstraintsForSubviews()
        
        setupToHideKeyboardOnTapOnView()
        
        navigationItem.rightBarButtonItem = hireMeButton
        
    }
    
    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(notFoundView)
        view.addSubview(characterGallery)
        view.addSubview(galleryProgressView)
    }
    
    private func setConstraintsForSubviews() {
        
        searchBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12 * widthModifier)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12 * heightModifier)
            make.height.equalTo(56 * heightModifier)
        }
        
        notFoundView.snp.makeConstraints { make in
            make.centerY.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.greaterThanOrEqualTo(notFoundView.snp.width).offset(22 * heightModifier)
        }
        
        characterGallery.snp.makeConstraints { (make) in
            
            make.top.equalTo(searchBar.snp.bottom).offset(28 * heightModifier)
            make.left.equalToSuperview().offset(24 * widthModifier)
            make.right.equalToSuperview()//.offset(-24 * widthModifier)
            make.bottom.equalTo(galleryProgressView.snp.top).offset(-12 * heightModifier)
            
        }
        
        galleryProgressView.snp.makeConstraints { make in
            make.height.equalTo(8 * heightModifier)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32 * heightModifier)
        }
        
    }
    
    //MARK: - Character Logic
    
    //method used for getting the initial data (first page)
    private func getCharacterData(from url: String) {
        CharacterRetriever.shared.getCharacters(url: url) { [weak self] success, result, nextPage, error in
            
            if success {
                if let resultAsCharacters = result {
                    self?.characterDataSource += resultAsCharacters
                    self?.nextCharacterPageURL = nextPage
                }
            } else {
                print("could get characters: \(String(describing: error))")
            }
            
        }
    }
    
    //used for character search
    private func getCharacterData(by name: String) {
        
        CharacterRetriever.shared.getCharacters(by: name) { [weak self] success, result, nextPageURL, error in
            
            //create a snapshot of initial character data to restore later
            if self?.characterDataSnapshot == nil {
                self?.characterDataSnapshot = self?.characterDataSource
            }
            
            //don't update ui if result is same as previous search
            if result ?? [] == self?.characterDataSource {
                return
            }
            
            //load results and loading ui logic (remove image when loading results, load with shimmer effect and delay to make UI smoother
            
            if let visibleCells = self?.characterGallery.visibleCells as? [CharacterCell] {
                for cell in visibleCells {
                    cell.imageContainer.image = nil
                    cell.title.text = ""
                }
            }
            
            if let numberOfItems = self?.characterGallery.numberOfItems(inSection: 0),
               numberOfItems >= 4 {
                self?.characterGallery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                //set data source as search result
                self?.characterDataSource = result ?? []
                
                self?.isDisplayingSearchResults = true
            }
            
            if let error = error  {
                print(error.errorDescription ?? "unknown error getting characters by name")
            }
            
        }
    }
    
    //used to restore initial data after clearing search
    private func restoreCharacterDataFromSnapshot() {
        if let characterDataSnapshot = characterDataSnapshot {
            
            //without the delay - dataSource updates that are coming from textFieldObserver are slower to arrive, which was causing unexpected behaviour when deleting search text quickly.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) { [weak self] in
                self?.characterDataSource = characterDataSnapshot
                self?.isDisplayingSearchResults = false
            }

        }
    }
    
    //MARK: - Selectors
    
    @objc private func searchBarTextDidChange(_ textField: UITextField) {
        if let name = textField.text,
           name != "" {
            getCharacterData(by: name)
        } else {
            restoreCharacterDataFromSnapshot()
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
    
    @objc private func hideKeyboardBarItemTapped(_ item: UIBarButtonItem) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func searchBarXButtonTapped(_ button: UIButton) {

        let numberOfItems = characterGallery.numberOfItems(inSection: 0)

        if numberOfItems >= 4 {
            characterGallery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        }
    }
    
    @objc private func promptFeedback() {
        let alert = UIAlertController(title: "Let me know what you think", message: "Thanks for taking the time to review my app! I've put a lot of thoght and effort into this mini-project to make sure it stands out. Let me know what you think of it 😊", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cta = UIAlertAction(title: "Contact Me", style: .default) { [weak self] action in
            self?.sendEmail()
        }
        alert.addAction(cancel)
        alert.addAction(cta)
        present(alert, animated: true)
    }
    
    
}

//MARK: - SearchBar Methods

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let name = searchBar.searchTextField.text ,
           name != "" {
            getCharacterData(by: name)
        } else {
            restoreCharacterDataFromSnapshot()
        }
        
        self.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        restoreCharacterDataFromSnapshot()
    }

}

//MARK: - Collectionview Methods

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //if we had shown cells and now we dont (which means that search result returned with 0 results - show notFoundView
            if let _ = collectionViewCellCountSnapshot,
               characterDataSource.count == 0 {
                notFoundView.isHidden = false
            } else {
                notFoundView.isHidden = true
            }
        
        collectionViewCellCountSnapshot = characterDataSource.count
        return characterDataSource.count
    }
    
    //define cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width) / 2
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
        
        //get list of [Episode] objects to show in the destination
        CharacterRetriever.shared.getEpisodes(by: characterToDisplay.numericEpisodeList()) { success, result, error in
            if success {
                characterToDisplay.episodeList = result
                destination.viewModel = CharacterDetailTableViewCellViewModel(with: characterToDisplay)
                destination.characterImage = (collectionView.cellForItem(at: indexPath) as? CharacterCell)?.imageContainer.image
                destination.title = characterToDisplay.name.capitalized
            } else {
                print("error: \(String(describing: error))")
            }
            
            self.navigationController?.pushViewController(destination, animated: true)
        }
        
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

extension MainViewController: MFMailComposeViewControllerDelegate {
    
    @objc private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["gervash@icloud.com"])
            mail.setSubject("Rick and Morty App Feedback")
            if let glutie = UIImage(named: "glutie"),
               let glutieAsPng = glutie.pngData() {
                mail.addAttachmentData(glutieAsPng, mimeType: "image/png", fileName:  "glutie.png")
            }

            present(mail, animated: true)
        } else {
            // show failure alert
            let alert = UIAlertController(title: "Unable to Send E-Mails", message: "Make sure you are connected to the internet and try again.", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Dismiss", style: .cancel)
            alert.addAction(cancel)
            
            present(alert, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
