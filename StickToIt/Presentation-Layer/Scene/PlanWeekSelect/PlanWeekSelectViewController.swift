//
//  PlanWeekSelectViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import UIKit

protocol PlanWeekSelectDelegate: AnyObject {
    
    func planWeekSelected(week: Int)
}

final class PlanWeekSelectViewController: UIViewController {
    
    var currentWeek: Int
    weak var delegate: PlanWeekSelectDelegate?
    
    // MARK: UI Properties
    
    private let tableView = UITableView()
    
    init(currentWeek: Int) {
        self.currentWeek = currentWeek
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
    }
    
    
}

extension PlanWeekSelectViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentWeek
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "WEEK \(indexPath.item + 1)"
        
        if indexPath.item + 1 == currentWeek {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
}

extension PlanWeekSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentWeek = indexPath.item + 1
        delegate?.planWeekSelected(week: currentWeek)
        
        navigationController?.popViewController(animated: true)
    }
}

extension PlanWeekSelectViewController {
    private func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

