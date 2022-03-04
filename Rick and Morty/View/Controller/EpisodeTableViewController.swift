//
//  EpisodeTableViewController.swift
//  Rick and Morty
//
//  Created by itay gervash on 03/03/2022.
//

import UIKit

class EpisodeTableViewController: UITableViewController {
    
    var cellHeight: CGFloat = 72 {
        didSet {
            tableView.rowHeight = cellHeight
        }
    }
    
    var viewModel: EpisodeDetailTableViewCellViewModel? {
        didSet {
            tableView.reloadData()
            self.title = viewModel?.details[2].1.capitalized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        view.backgroundColor = K.colors.background
        tableView.register(EpisodeDetailTableViewCell.self, forCellReuseIdentifier: EpisodeDetailTableViewCell.identifier)
        
        //tableView.rowHeight = cellHeight

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "Details" }
        else if section == 1 { return "Characters"}
        else { return nil }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return EpisodeDetailTableViewCellViewModel.Detail.allCases.count
        } else {
            return viewModel?.characterNames.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //set cell as custom character cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeDetailTableViewCell.identifier, for: indexPath) as! EpisodeDetailTableViewCell
        
        guard let viewModel = viewModel else { return cell }
        
        cell.setCellContent(with: viewModel, indexPath: indexPath)
        
        return cell
        
    }

}
