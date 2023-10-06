//
//  CameraManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit
import AVFoundation

protocol CameraManageable: AnyObject {

    func requestAuth<T: UIViewController>(in viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    func openCamera<T: UIViewController>(in viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
}

final class CameraManager: CameraManageable {
    
    func requestAuth<T: UIViewController>(in viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            print(isAuthorized)
            
            guard isAuthorized else {
                self?.showGoToSettingAlert(viewController)
                return
            }
            
            self?.openCamera(in: viewController)
        }
    }
    
    func openCamera<T: UIViewController>(in viewController: T) where T: UIImagePickerControllerDelegate & UINavigationControllerDelegate
    {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            
            picker.sourceType = .camera
            picker.delegate = viewController
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear
            picker.allowsEditing = true
            
            viewController.present(picker, animated: true, completion: nil)
        }
    }
    
    func showGoToSettingAlert(_ viewController: UIViewController) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "현재 카메라에 대한 접근 권한이 없습니다.",
                message: "설정 > 작심삼일 > 카메라에서 접근을 활성화 할 수 있습니다.",
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
