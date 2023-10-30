//
//  SettingViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/30/23.
//

import UIKit

final class SettingViewController: UIViewController {

    let viewModel: SettingViewModel
    
    // MARK: UI Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: Life Cycle
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView()
        configureViews()
        setConstraints()
    }
}

extension SettingViewController {
    private func settingTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingViewCell")
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
    }
}

extension SettingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeaderInSection(section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingViewCell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = viewModel.rowTitle(at: indexPath)
        configuration.textProperties.font = .systemFont(ofSize: Const.FontSize.subTitle, weight: .medium)
        
        cell.contentConfiguration = configuration
        cell.backgroundColor = .assetColor(.accent4).withAlphaComponent(0.3)
     
        if viewModel.isFirstSection(at: indexPath) {
            cell.accessoryType = .disclosureIndicator
        } else {
            if viewModel.isVersionInfo(at: indexPath) {
                let label = UILabel()
                label.text = "1.0"
                label.sizeToFit()
                cell.accessoryView = label
            }
        }
        
        
        return cell
    }
}

extension SettingViewController: BaseViewConfigurable {
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        tableView.backgroundColor = .systemBackground
    }
    
    func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

