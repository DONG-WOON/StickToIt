//
//  ImageSelectionViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit

final class ImageSelectionViewController: UIViewController {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    
    private enum Section: Int {
        case main = 0
    }
    
    enum ImageAuthorization {
        case authorized
        case limited
        case denied
    }
    
    private let currentAuth: ImageAuthorization
    private var dataSource: DataSource?
    
    let viewModel = ImageSelectionViewModel()
    
    // MARK: - UI Properties
    private let mainView: UIView
    private lazy var dismissButton = ResizableButton(
        image: UIImage(systemName: Const.Image.xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    // MARK: - View Life Cycle
    init(authorization: ImageAuthorization) {
        self.currentAuth = authorization
        
        switch authorization {
        case .authorized:
            mainView = ImageSelectionView()
        case .limited:
            mainView = ImageSelectionView()
        case .denied:
            mainView = ImageSelectionDeniedView()
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        
        if let deniedView = mainView as? ImageSelectionDeniedView {
            deniedView.deniedButtonDelegate = self
        }
        configureViews()
        takeSnapshot()
    }
    
    // MARK: - Methods
    
    func takeSnapshot() {
        guard let dataSource else { return }
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        
        switch currentAuth {
        case .authorized, .limited:
            snapshot.appendItems(["사진찍기"], toSection: .main)
        case .denied:
            break
        }
        snapshot.appendItems(viewModel.selectedImage, toSection: .main)
    
        dataSource.apply(snapshot)
    }
    
    private func configureDataSource() {
        guard let _mainView = mainView as? UICollectionView else { return }
        let cellRegistration = UICollectionView
            .CellRegistration<UICollectionViewCell, String>
        { cell, indexPath, item in
            
            cell.contentView.backgroundColor = .green
            if item == "사진찍기" {
                cell.contentView.backgroundColor = .red
            }
        }
        
        self.dataSource = DataSource(
            collectionView: _mainView,
            cellProvider: { collectionView, indexPath, item in
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
                return cell
            }
        )
    }
    
    private func configureViews() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
}

extension ImageSelectionViewController {
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
}

extension ImageSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ImageSelectionViewController: DeniedButtonDelegate {
    func goToSetting() {
        print("해해")
    }
}


