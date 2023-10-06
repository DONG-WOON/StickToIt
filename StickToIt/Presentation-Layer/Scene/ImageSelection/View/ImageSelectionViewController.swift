//
//  ImageSelectionViewController.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import UIKit
import Photos
import RxSwift

final class ImageSelectionViewController: UIViewController {
    
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    
    private enum Section: Int {
        case main = 0
    }
    
    private var currentAuth: PHAuthorizationStatus
    private var cameraManager: CameraManageable?
    private let imageManager: ImageManageable
    private var dataSource: DataSource?
    
    let viewModel = ImageSelectionViewModel()
    
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Properties
    private let mainView: UIView
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    // MARK: - View Life Cycle
    init(imageManager: ImageManageable, cameraManager: CameraManageable) {
        self.imageManager = imageManager
        
        let authorization = imageManager.checkAuth()
        
        self.currentAuth = authorization
        
        switch authorization {
        case .authorized, .limited, .notDetermined:
            self.cameraManager = cameraManager
            mainView = ImageSelectionView()
        case .denied, .restricted:
            mainView = ImageSelectionDeniedView()
        @unknown default:
            fatalError()
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
        
        if let deniedView = mainView as? ImageSelectionDeniedView {
            deniedView.delegate = self
        } else {
            configureDataSource()
        }
    
        configureViews()
        
        bindUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Methods
    
    private func takeSnapshot(item: [String]? = nil , toSection section: Section) {
        guard let dataSource else { return }
        
        var snapshot = Snapshot()
        
        snapshot.appendSections([.main])
        snapshot.appendItems([UUID().uuidString], toSection: section)
        
        case .authorized, .limited:
        snapshot.appendItems(viewModel.selectedImage, toSection: .main)
        return snapshot
    
    private func bindUI() {
        
        viewModel.imageDataList
            .bind(with: self) { (_self, datas) in
                let id = datas.map { $0.localIdentifier }
                _self.takeSnapshot(item: id, toSection: .main)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func configureDataSource() {
        guard let _mainView = mainView as? UICollectionView else { return }
        
        #warning("항상 고정으로 존재하는 사진찍기 이미지 Cell인데 이런식으로 셀을 등록해서 사용할 필요가 있나.")
        let cameraCellRegistration = UICollectionView
            .CellRegistration<CameraCell, String>
        { cell, indexPath, item in
            
           
        }
        
        let selectableImageCellRegistration = UICollectionView
            .CellRegistration<SelectableImageCell, String>
        { cell, indexPath, id in
            
            let imageAssets = self.viewModel.imageDataList.value
            let asset = imageAssets[indexPath.item - 1]
            
            DispatchQueue.main.async {
                self.imageManager.getImage(for: asset) { image in
                    cell.imageView.image = image
                }
            }
        }
        
        
        self.dataSource = DataSource(
            collectionView: _mainView,
            cellProvider: { collectionView, indexPath, item in
                if indexPath.item == 0 {
                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: cameraCellRegistration,
                        for: indexPath,
                        item: item
                    )
                    return cell
                } else {
                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: selectableImageCellRegistration,
                        for: indexPath,
                        item: item
                    )
                    return cell
                }
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
        if indexPath.item == 0 {
            cameraManager?.requestAuth(in: self)
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageCell else { return }
            
            cell.cellIsSelected.toggle()
            
            if cell.cellIsSelected {
                viewModel.selectedImageData.accept(indexPath.item - 1)
            } else {
                viewModel.selectedImageData.accept(nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.item != 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) as? SelectableImageCell else { return }
            
            cell.cellIsSelected = false
        }
    }
}

extension ImageSelectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
    
        imageManager.getImageAssets(self) { [weak self] datas in
            self?.viewModel.imageDataList.accept(datas)
        }
    }
}

extension ImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}

extension ImageSelectionViewController: SettingButtonDelegate {
    func goToSetting() {
        imageManager.goToSetting()
    }
}


