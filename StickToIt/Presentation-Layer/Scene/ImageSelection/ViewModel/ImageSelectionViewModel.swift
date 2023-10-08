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
    
    var selectedImageData: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    var imageDataList: BehaviorRelay<[PHAsset]> = BehaviorRelay(value: [])
}
