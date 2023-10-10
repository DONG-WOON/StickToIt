//
//  EditImageViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/10/23.
//

import UIKit

final class EditImageViewController: UIViewController {
    
    private let viewModel = EditImageViewModel(
        useCase: EditImageUseCaseImpl(
            repository: PlanRepositoryImpl(
                networkService: nil,
                databaseManager: PlanDatabaseManager()
            )
        )
    )
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var editCompleteButton = ResizableButton(
        title: "사진 올리기",
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(editCompleteButtonDidTapped)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        setConstraints()
    }
}

extension EditImageViewController {
    @objc private func editCompleteButtonDidTapped() {
        viewModel.upload(data: imageView.image?.pngData())
        self.dismiss(animated: true)
    }
}

extension EditImageViewController {
    private func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editCompleteButton)
    }
    
    private func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
