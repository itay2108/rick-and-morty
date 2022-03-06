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
    
    var nextCharacterPageURL: String?
    var isDisplayingSearchResults: Bool = false
    
    //main data source for gallery. when set we reload the collection view
    private var characterDataSource: [Character] = [] {
        didSet {
            characterGallery.reloadData()
        }
    }
    
    //used to store original data when searching for different characters, so when the user closes the search - the gallert shows the original data.
    private var characterDataSnapshot: [Character]?
    private var nextPageURLSnapshot: String?
    
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
        
        cv.decelerationRate = .fast
        return cv
    }()
    
    private lazy var galleryProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = K.colors.pickleGreen
        
        progressView.trackTintColor = K.colors.pickleGreen?.withAlphaComponent(0.13)
        return progressView
    }()
    
    private lazy var scrollToTopButton: ScrollToTopButton = {
        let button = ScrollToTopButton(anchorTo: .right)
        button.arrowImageView.tintColor = K.colors.pickleGreen
        button.backgroundColor = K.colors.pickleGreen?.withAlphaComponent(0.13)
        button.isHidden = true
        
        button.addTarget(self, action: #selector(scrollToTopButtonTapped(_:)), for: .touchUpInside)
        return button
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        characterGallery.reloadData()
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
        view.addSubview(scrollToTopButton)
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
            make.bottom.equalTo(galleryProgressView.snp.top).offset(-24 * heightModifier)
            
        }
        
        galleryProgressView.snp.makeConstraints { make in
            make.height.equalTo(8 * heightModifier)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-38 * heightModifier)
        }
        
        scrollToTopButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalTo(48 * heightModifier)
            make.width.equalTo(56 * widthModifier)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-18 * heightModifier)
        }
        
    }
    
    //MARK: - Character Logic
    
    //method used for getting the initial data (first page)
    private func getCharacterData(from url: String) {
        
        CharacterRetriever.shared.getCharacters(url: url) { [weak self] success, result, nextPage, error in
            
            if success {
                if let resultAsCharacters = result {
                    self?.characterDataSource += resultAsCharacters
                }
            } else {
                print("could get characters: \(String(describing: error))")
            }
            
            self?.nextCharacterPageURL = nextPage
            self?.nextPageURLSnapshot = nextPage
        }
        

    }
    
    //used for character search
    private func getCharacterData(by name: String) {
        
        CharacterRetriever.shared.getCharacters(by: name) { [weak self] success, result, nextPage, error in
            
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
            
                //set data source as search result
                self?.characterDataSource = result ?? []
                self?.isDisplayingSearchResults = true
                self?.nextCharacterPageURL = nextPage
            
            if let error = error  {
                print(error.errorDescription ?? "unknown error getting characters by name")
            }
            
        }
    }
    
    //used to restore initial data after clearing search
    private func restoreCharacterDataFromSnapshot() {
        if let characterDataSnapshot = characterDataSnapshot {
            
            characterDataSource = characterDataSnapshot
            nextCharacterPageURL = nextPageURLSnapshot
            isDisplayingSearchResults = false

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
        if !isDisplayingSearchResults {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        searchBar.resignFirstResponder()
    }
    
    @objc private func searchBarXButtonTapped(_ button: UIButton) {

        let numberOfItems = characterGallery.numberOfItems(inSection: 0)

        if numberOfItems >= 4 {
            characterGallery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        }
    }
    
    @objc private func promptFeedback() {
        let alert = UIAlertController(title: "Let me know what you think", message: "Thanks for taking the time to review my app! I've put a lot of thoght and care into this mini-project to make sure it stands out 😊", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let cta = UIAlertAction(title: "Contact Me", style: .default) { [weak self] action in
            self?.sendEmail()
        }
        alert.addAction(cancel)
        alert.addAction(cta)
        present(alert, animated: true)
    }
    
    @objc private func scrollToTopButtonTapped(_ button: UIButton) {
        let numberOfItems = characterGallery.numberOfItems(inSection: 0)
        if numberOfItems >= 4 {
            characterGallery.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        }
        
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
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        self.searchBar.resignFirstResponder()
        
        //if we are displaying search results leave the cancel button enabled
        if isDisplayingSearchResults {
            if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
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
        
        //if theres no data yet -
        if characterDataSource.count == 0 {
            //and no memory of any data - it means we still havent loaded the first results; load 4 dummy cells
            if characterDataSnapshot == nil {
                notFoundView.isHidden = true
                return 4
            } else {
                //if there is memory of data, it means we are searched with no results. dont load dummy characters and show Jerry
                notFoundView.isHidden = false
                return 0
            }
        } else {
            //if there is data we show it and save it to memory.
            notFoundView.isHidden = true
            collectionViewCellCountSnapshot = characterDataSource.count
            return characterDataSource.count
        }
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
        
        //when populating last cell - load next page if available
        if indexPath.row == characterDataSource.count - 3 {
            guard let nextCharacterPageURL = nextCharacterPageURL else { return cell }
            print("getting next page")
            getCharacterData(from: nextCharacterPageURL)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //sometimes cells dont load when returning to view. this makes sure they do.

        if let cell = cell as? CharacterCell {
            if cell.imageContainer.image == nil {
                guard characterDataSource.count > indexPath.row else { return }
                let cellData = CharacterCellViewModel(with: characterDataSource[indexPath.row])
                
                cell.stopShimmering()
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
        let contentXoffset = scrollView.contentOffset.x
        let scrollProgress = contentXoffset / (scrollView.contentSize.width - scrollView.frame.width)
        
        galleryProgressView.setProgress(Float(scrollProgress), animated: true)
        
        //fade scroll button in and out dependint on how much of the gallery is scrolled
        if contentXoffset > view.frameWidth / 3 && scrollToTopButton.isHidden {
            scrollToTopButton.fadeIn()
        } else if contentXoffset < view.frameWidth / 3 && !scrollToTopButton.isHidden {
            scrollToTopButton.fadeOut()
        }
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
