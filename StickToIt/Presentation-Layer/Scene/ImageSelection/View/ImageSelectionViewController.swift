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
    
    private enum Section: Int { case main = 0 }
    
    private let viewModel = ImageSelectionViewModel(
        imageUseCase: FetchImageUseCaseImpl(),
        cameraUseCase: OpenCameraUseCaseImpl(),
        mainQueue: .main
    )
    
    private var imageManager: ImageManager
    private var cameraManager: CameraManager?
    private var dataSource: DataSource?
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Properties
    private let mainView: UIView
    
    private lazy var dismissButton = ResizableButton(
        image: UIImage(resource: .xmark),
        symbolConfiguration: .init(scale: .large),
        tintColor: .label, target: self,
        action: #selector(dismissButtonDidTapped)
    )
    
    // MARK: - Life Cycle
    init(imageManager: ImageManager) {
        self.imageManager = imageManager
        
        imageManager.requestAuth { status in
            switch status {
            case .notDetermined:
                print("notDetar")
            case .restricted:
                print("restricted")
            case .denied:
                print("denied")
            case .authorized:
                print("authorized")
            case .limited:
                print("limited")
            @unknown default:
                fatalError()
            }
        }
        
        let authorization = imageManager.checkAuth()
        
        switch authorization {
        case .notDetermined:
            mainView = ImageSelectionView()
            self.cameraManager = CameraManager()
        case .limited:
            mainView = ImageSelectionView()
            self.cameraManager = CameraManager()
        case .authorized:
            mainView = ImageSelectionView()
            self.cameraManager = CameraManager()
        case .denied, .restricted:
            mainView = ImageSelectionDeniedView()
        @unknown default:
            fatalError()
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.viewDidLoad()
        setViewsAndDelegate()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mainView is ImageSelectionView {
            imageManager.getImageAssets { [weak self] imageAssets in
                self?.viewModel.imageDataList.accept(imageAssets)
            }
        }
    }
    
    // MARK: - Methods
    
    private func bindUI() {
        viewModel.imageDataList
            .bind(with: self) { (_self, datas) in
                let id = datas.map { $0.localIdentifier }
                _self.takeSnapshot(item: id, toSection: .main)
            }
            .disposed(by: disposeBag)
    }
    
    func setViewsAndDelegate() {
        if let _mainView = mainView as? ImageSelectionView {
            configureDataSource(of: _mainView)
            _mainView.delegate = self
            imageManager.register(viewController: self)
            
        }
        
        if mainView is ImageSelectionDeniedView {
            (mainView as? ImageSelectionDeniedView)?.delegate = self
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
}


extension ImageSelectionViewController {
    @objc private func dismissButtonDidTapped() {
        self.dismiss(animated: true)
    }
}

// MARK: CollectionViewDataSource

extension ImageSelectionViewController {
    private func configureDataSource(of collectionView: UICollectionView) {

        #warning("항상 고정으로 존재하는 사진찍기 이미지 Cell인데 이런식으로 셀을 등록해서 사용할 필요가 있나.")
        let cameraCellRegistration = UICollectionView
            .CellRegistration<CameraCell, String>
        { cell, indexPath, item in }
        
        let selectableImageCellRegistration = UICollectionView
            .CellRegistration<SelectableImageCell, String>
        { cell, indexPath, id in
            
            let imageAssets = self.viewModel.imageDataList.value
            let asset = imageAssets[indexPath.item - 1]
            
            DispatchQueue.main.async { [weak self] in
                self?.imageManager.getImage(for: asset) { image in
                    cell.imageView.image = image
                }
            }
        }
        
        
        self.dataSource = DataSource(
            collectionView: collectionView,
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
    
    private func takeSnapshot(item: [String]? = nil , toSection section: Section) {
        var snapshot = Snapshot()
        
        snapshot.appendSections([section])
        snapshot.appendItems([UUID().uuidString], toSection: section)
        
        if let item {
            snapshot.appendItems(item, toSection: section)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: UICollectionViewDelegate
extension ImageSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            cameraManager?.requestAuthAndOpenCamera(in: self)
        } else {
            // 이미지 확대, 이동
        }
    }
}


// MARK: PHPhotoLibraryChangeObserver
extension ImageSelectionViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        imageManager.getImageAssets { [weak self] imageAssets in
            self?.viewModel.imageDataList.accept(imageAssets)
        }
    }
}


// MARK: UIImagePickerControllerDelegate

extension ImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate { }


extension ImageSelectionViewController: SettingButtonDelegate {
    func settingButtonDidTapped() {
        self.goToSetting()
    }
}


