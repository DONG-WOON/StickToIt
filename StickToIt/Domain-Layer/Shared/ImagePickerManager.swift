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
    
    func getImageAssets<T: UIViewController>(
        _ viewController: T,
        completion: @escaping ([PHAsset]) -> Void) where T: PHPhotoLibraryChangeObserver
    
   
    func getImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void)
    
    func photoLibraryDidChange<T: UIViewController>(
        _ viewController: T,
        _ changeInstance: PHChange)
    where T: PHPhotoLibraryChangeObserver

    func goToSetting()
//    func showPHPicker(_ viewController: UIViewController)
}

final class ImagePickerManager {
    
    private let phImageManager = PHImageManager()
    var imageAssets = BehaviorRelay<[PHAsset]>(value: [])
    var currentImageCountToFetch = BehaviorRelay<Int>(value: 0)
    var completion: (([PHAsset]) -> Void)?
    
    var disposeBag = DisposeBag()
    
    init() {
        _ = Observable.combineLatest(imageAssets.map { $0.count }, currentImageCountToFetch.map{ $0 })
            .filter { $0.0 == $0.1 && $0 != (0,0) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, isEnabled) in
                _self.completion?(_self.imageAssets.value)
                _self.imageAssets.accept([])
            }
            .disposed(by: disposeBag)
    }
}


extension ImagePickerManager: ImageManageable {
    
    func getImageAssets<T: UIViewController>(_ viewController: T, completion: @escaping ([PHAsset]) -> Void) where T: PHPhotoLibraryChangeObserver {
        self.completion = completion
        requestAuth(viewController) { [weak self] in
            self?.getImageThatUserSelected()
        }
    }
    
    @MainActor
    func getImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        
        self.phImageManager.requestImage(for: asset, targetSize: CGSize.thumbnail, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, info) in
            completion(image)
        })
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
//                    self?.showPHPicker(viewController)
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
    
    private func getImageThatUserSelected() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        let imageCount = fetchResult.countOfAssets(with: .image)
        
        currentImageCountToFetch.accept(imageCount)
        
        fetchResult.enumerateObjects { [self] (asset, _, _) in
            self.imageAssets.accept(self.imageAssets.value + [asset])
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
