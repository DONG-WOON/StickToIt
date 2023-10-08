//
//  ImageSelectionViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

final class ImageSelectionViewModel<ImageUseCase: FetchImageUseCase, CameraUseCase: OpenCameraUseCase> {
    
    private let imageUseCase: ImageUseCase
    private let cameraUseCase: CameraUseCase
    private let mainQueue: DispatchQueue
    
    var imageDataList: BehaviorRelay<ImageAssets> = BehaviorRelay(value: [])
    
    init(imageUseCase: ImageUseCase,
         cameraUseCase: CameraUseCase,
         mainQueue: DispatchQueue
    ) {
        self.imageUseCase = imageUseCase
        self.cameraUseCase = cameraUseCase
        self.mainQueue = mainQueue
    }
    
    func viewDidLoad() {
        
    }
    
    func fetchImage() {
        
    }
    
    func fetchImageAssets() {
    
    }
    
    func fetchImageAsset() {
        
    }
    
    func requestCameraAuth() {
    }
}
