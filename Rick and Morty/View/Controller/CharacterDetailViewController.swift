//
//  CharacterDetailViewController.swift
//  Rick and Morty
//
//  Created by itay gervash on 02/03/2022.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    var characterImage: UIImage?
    
    var viewModel: CharacterDetailTableViewCellViewModel? {
        didSet {
            characterDetailTableView.reloadData()
            self.title = viewModel?.details[0].1
        }
    }
    
    private lazy var contentContainer: UIView = {
        return UIView()
    }()
    
    private lazy var characterImageView: UIImageView = {
       let view = UIImageView()

        view.layer.masksToBounds = false
        view.contentMode = .scaleToFill
        
        return view
    }()
    
    private lazy var characterDetailTableView: UITableView = {
        let table = UITableView()
        table.register(CharacterDetailTableViewCell.self, forCellReuseIdentifier: CharacterDetailTableViewCell.identifier)
        
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        
//      Did you mean this when asking about cell height during the interview?
//      table.rowHeight = UITableView.automaticDimension
//      table.estimatedRowHeight = 96.0 * heightModifier
        
        return table
    }()
    
    private lazy var shareButton: UIButton = {
        
        var config = UIButton.Configuration.filled()
        let title = AttributedString("Share", attributes: AttributeContainer([.font : UIFont.systemFont(ofSize: 14 * heightModifier, weight: .semibold)]))
        
        config.attributedTitle = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 16 * heightModifier, leading: 12 * heightModifier, bottom: 16 * heightModifier, trailing: 12 * heightModifier)
        config.image = UIImage(systemName: "square.and.arrow.up")
        config.imagePlacement = .trailing
        config.imagePadding = 16 * widthModifier
        config.buttonSize = .large
        config.baseBackgroundColor = K.colors.pickleGreen
        config.baseForegroundColor = K.colors.background
        config.cornerStyle = .medium
        
        let button = UIButton(configuration: config, primaryAction: UIAction(handler: { [weak self] action in
            self?.shareButtonTapped()
        }))
        

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //delegate setting
        characterDetailTableView.delegate = self; characterDetailTableView.dataSource = self
        
        //setup visual elements
        setUpUI()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //set tableView row height to be dependent on number of rows and height of the view
        self.characterDetailTableView.rowHeight = (349 * heightModifier) / CGFloat(characterDetailTableView.numberOfRows(inSection: 0))
        
        //circlize character image view once frame is not 0.0
        characterImageView.circlize()
        
    }
    
    private func setUpUI() {

        view.backgroundColor = K.colors.background
        title = viewModel?.details[0].1
        
        addSubviews()
        setConstraintsForSubviews()
        
        characterImageView.image = characterImage
        
    }
    
    private func addSubviews() {
        view.addSubview(contentContainer)
        contentContainer.addSubview(characterImageView)
        contentContainer.addSubview(characterDetailTableView)
        view.addSubview(shareButton)
    }
    
    private func setConstraintsForSubviews() {
        
        contentContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset((36 * heightModifier))
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalTo(shareButton.snp.top).offset(-24 * heightModifier)
            
        }
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.centerX.equalToSuperview()
            make.height.equalTo(characterImageView.snp.width)
        }

        characterDetailTableView.snp.makeConstraints { make in

            make.top.equalTo(characterImageView.snp.bottom).offset((24 * heightModifier))
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
        
        shareButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24 * heightModifier)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(48 * heightModifier)
            make.centerX.equalToSuperview()
        }
        
        
    }
    
    //MARK: - Targets
    
    private func shareButtonTapped() {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: contentContainer.frame.size.width, height: contentContainer.frame.size.height + (56 * heightModifier)), true, 0.0)
        self.view.drawHierarchy(in: CGRect(x: view.bounds.minX, y: view.bounds.minY - (safeAreaSize(from: .top) + (self.navigationController?.navigationBar.bounds.height ?? 0)), width: view.bounds.width, height: view.bounds.height),afterScreenUpdates: false)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let img = img else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
        present(activityViewController, animated: true, completion: nil)
    }

}

extension CharacterDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Details" }
        else if section == 1 { return "Episodes"}
        else { return nil }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return CharacterDetailTableViewCellViewModel.Detail.allCases.count
        } else {
            return viewModel?.episodeDetails.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell as custom character cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: CharacterDetailTableViewCell.identifier, for: indexPath) as! CharacterDetailTableViewCell
        
        guard let viewModel = viewModel else { return cell }
        
        cell.setCellContent(with: viewModel, indexPath: indexPath)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            let destination = EpisodeTableViewController()
            
            if var episode = viewModel?.episodes?[indexPath.row] {
                
                CharacterRetriever.shared.getCharacterNames(from: episode) { success, result, error in
                    if success {
                        if let characterNames = result {
                            episode.characterNames = characterNames
                            let episodeViewModel = EpisodeDetailTableViewCellViewModel(with: episode)

                            destination.viewModel = episodeViewModel
                        }
                    }
                }
                
                destination.cellHeight = tableView.rowHeight
                self.navigationController?.pushViewController(destination, animated: true)
            }

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}
