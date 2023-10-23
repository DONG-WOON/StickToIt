//
//  ImageSelectionViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/2/23.
//

import Foundation
import RxSwift
import Photos

final class ImageSelectionViewModel<CameraUseCase: OpenCameraUseCase> {
    
    private let imageUseCase: (any FetchImageUseCase)?
    private let cameraUseCase: CameraUseCase
    private let mainQueue: DispatchQueue
    
    var imageDataList = BehaviorSubject(value: [ImageAsset]())
    
    init(imageUseCase: some FetchImageUseCase,
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
