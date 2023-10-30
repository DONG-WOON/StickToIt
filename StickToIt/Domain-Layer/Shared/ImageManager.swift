//
//  ImageManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import Foundation
import PhotosUI
import RxSwift
import RxCocoa

typealias ImageAsset = PHAsset
typealias ImageAssets = [PHAsset]

final class ImageManager {
    
    typealias ImageManagerDelegate = UIViewController & PHPhotoLibraryChangeObserver
    
    // MARK: Properties
    var imageAssets = BehaviorRelay<ImageAssets>(value: [])
    var currentImageCountToFetch = BehaviorRelay<Int>(value: 0)
    var completion: ((ImageAssets) -> Void)?
    
    private let phImageManager = PHImageManager()
    private let disposeBag = DisposeBag()
    
    // MARK: Life Cycle
    init() {
        _ = Observable
            .combineLatest(
                imageAssets
                    .map { $0.count },
                currentImageCountToFetch
                    .map{ $0 }
            )
            .filter { $0.0 == $0.1 && $0 != (0,0) }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self) { (_self, isEnabled) in
                _self.completion?(_self.imageAssets.value)
                _self.imageAssets.accept([])
            }
            .disposed(by: disposeBag)
    }
    
    func checkAuth() -> PHAuthorizationStatus {
        let auth = PHPhotoLibrary
            .authorizationStatus(
                for: .addOnly
            )
        return auth
    }
    
    func register(viewController: ImageManagerDelegate) {
        PHPhotoLibrary.shared().register(viewController)
    }
    
    func requestAuth(
        completion: @escaping (PHAuthorizationStatus) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization(
            for: .readWrite,
            handler: completion
        )
    }
    
    func getImageAssets(
        completion: @escaping ([PHAsset]) -> Void
    ) {
        self.completion = completion
        self.fetchImage()
    }
    
    @MainActor
    func getThumbnailImage(
        for asset: PHAsset,
        completion: @escaping (UIImage?) -> Void
    ) -> PHImageRequestID {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        return self.phImageManager
            .requestImage(
                for: asset,
                targetSize: CGSize.thumbnail,
                contentMode: .aspectFit,
                options: requestOptions,
                resultHandler: { (image, info) in
            completion(image)
        })
    }
    
    func getImage(
        for asset: PHAsset,
        completion: @escaping (Data?) -> Void
    ) -> PHImageRequestID {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        return self.phImageManager
            .requestImageDataAndOrientation(
                for: asset,
                options: requestOptions
            ) { data, uti, orientation, info in
            completion(data)
        }
    }
}

extension ImageManager {
    
    private func fetchImage() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        let imageCount = fetchResult.countOfAssets(with: .image)
        
        currentImageCountToFetch.accept(imageCount)
        
        fetchResult.enumerateObjects { [weak self] (asset, _, _) in
            guard let images = self?.imageAssets.value else { return }
            self?.imageAssets
                .accept(images + [asset])
        }
    }
}
