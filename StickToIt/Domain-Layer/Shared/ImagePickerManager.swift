//
//  ImagePickerManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/1/23.
//

import Foundation
import PhotosUI

protocol ImageManageable {
    static var shared: ImageManageable { get }
    
    func getImage(_ viewController: UIViewController, completion: @escaping (UIImage?) -> Void)
    func requestAuth(_ viewController: UIViewController)
    func checkAuth(_ viewController: UIViewController)
    
    func showGoToSettingAlert(_ viewController: UIViewController)
    func showImagePicker(_ viewController: UIViewController)
}


final class ImagePickerManager: ImageManageable {
    static let shared: ImageManageable = ImagePickerManager()
    
    private init() { }
    private var imageSelectAction: ((UIImage?) -> Void)?
    
    private var imagesID = [String]()
    
    func getImage(_ viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {
        imageSelectAction = completion
        checkAuth(viewController)
    }
    
    func checkAuth(_ viewController: UIViewController) {
        let auth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch auth {
        case .notDetermined:
            print("notDetermined")
            requestAuth(viewController)
        case .restricted:
            print("restricted")
            showGoToSettingAlert(viewController)
        case .denied:
            print("denied")
            showGoToSettingAlert(viewController)
        case .authorized:
            print("authorized")
            showImagePicker(viewController)
        case .limited:
            print("limited")
            requestAuth(viewController)
        @unknown default:
            fatalError("PhotoLibAuth need update")
        }
    }

    func requestAuth(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .notDetermined, .restricted, .denied:
                    break
                case .authorized:
                    print("authorized")
                    self?.showImagePicker(viewController)
                case .limited:
                    break
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func showImagePicker(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            var configuration = PHPickerConfiguration(photoLibrary: .shared())
            
            configuration.preselectedAssetIdentifiers = self.imagesID
            
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            viewController.present(picker, animated: true)
        }
    }
    
    func showGoToSettingAlert(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "현재 앨범에 대한 접근 권한이 없습니다.",
                message: "설정 > 작심삼일 > 사진 탭에서 앨범 접근을 활성화 할 수 있습니다.",
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction(title: "취소",
                                            style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            
            let goToSetting = UIAlertAction(title: "설정",
                                                 style: .default) { _ in
                guard let settingURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingURL) else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
            
            alert.addAction(cancel)
            alert.addAction(goToSetting)
            
            viewController.present(alert, animated: true)
        }
    }
}

extension ImagePickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) { // 3
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in // 4
                if let _image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.imageSelectAction?(_image)
                    }
                }
            }
        } else {
            // TODO: Handle empty results or item provider not being able load UIImage
        }
    }

}
