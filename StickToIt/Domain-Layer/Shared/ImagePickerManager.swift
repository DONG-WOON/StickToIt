//
//  ImagePickerManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import Foundation
import PhotosUI
import RxSwift
import RxCocoa

protocol ImageManageable: AnyObject {
    func checkAuth() -> PHAuthorizationStatus
    
    func getImage<T: UIViewController>(
        _ viewController: T,
        completion: @escaping ([Data]) -> Void)
    where T: PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange<T: UIViewController>(
        _ viewController: T,
        _ changeInstance: PHChange)
    where T: PHPhotoLibraryChangeObserver

    func goToSetting()
    func showPHPicker(_ viewController: UIViewController)
}

final class ImagePickerManager {
    
    var currentImageDatas = BehaviorRelay<[Data]>(value: [])
    var currentImageCountToFetch = BehaviorSubject<Int>(value: 0)
    var completion: (([Data]) -> Void)?
    
    var disposeBag = DisposeBag()
    
    init() {
        _ = Observable.combineLatest(currentImageDatas.map { $0.count }, currentImageCountToFetch.map{ $0 })
            .filter { $0.0 == $0.1 && $0 != (0,0) }
            .observe(on:MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, bool) in
                _self.completion?(_self.currentImageDatas.value)
                _self.currentImageDatas.accept([])
            }
            .disposed(by: disposeBag)
    }
}


extension ImagePickerManager: ImageManageable {
    
    func getImage<T: UIViewController>(_ viewController: T, completion: @escaping ([Data]) -> Void) where T: PHPhotoLibraryChangeObserver {
        self.completion = completion
        requestAuth(viewController) { [weak self] in
            self?.getImageThatUserSelected()
        }
    }
    
    func checkAuth() -> PHAuthorizationStatus {
        let auth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return auth
    }
    
    private func requestAuth<T: UIViewController>(
        _ viewController: T,
        completion: @escaping () -> Void)
    where T: PHPhotoLibraryChangeObserver {
        DispatchQueue.main.async { [weak self] in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .notDetermined, .restricted, .denied:
                    break
                case .authorized:
                    print("authorized")
                    completion()
                    self?.showPHPicker(viewController)
                case .limited:
                    print("limited")
                    completion()
                    PHPhotoLibrary.shared().register(viewController)
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func photoLibraryDidChange<T: UIViewController>(
        _ viewController: T,
        _ changeInstance: PHChange)
    where T: PHPhotoLibraryChangeObserver {
        viewController.photoLibraryDidChange(changeInstance)
    }
    
    func showPHPicker(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            
//            configuration.preselectedAssetIdentifiers = self.imagesID
            
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            viewController.present(picker, animated: true)
        }
    }
    
    private func getImageThatUserSelected() {
        let fetchOptions = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        let requestOptions = PHImageRequestOptions()
        let phImageManager = PHImageManager()
        
        requestOptions.isSynchronous = true

        currentImageCountToFetch.onNext(fetchResult.count)
        
        fetchResult.enumerateObjects { (asset, index, _) in
            
            phImageManager.requestImageDataAndOrientation(for: asset, options: requestOptions) { (data, string, orientation, info) in
                guard let _data = data else { return }
                
                self.currentImageDatas.accept(self.currentImageDatas.value + [_data])
            }
        }
    }
    
    func goToSetting() {
        DispatchQueue.main.async {
            guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingURL) else { return }
            UIApplication.shared.open(settingURL, options: [:])
        }
    }
}

extension ImagePickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
//                if let _image = image as? UIImage {
//                    DispatchQueue.main.async {
//                        self.imageSelectAction?(_image)
//                    }
//                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }
    
}
