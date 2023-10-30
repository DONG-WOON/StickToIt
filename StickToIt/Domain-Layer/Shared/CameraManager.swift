//
//  CameraManager.swift
//  StickToIt
//
//  Created by 서동운 on 10/5/23.
//

import UIKit
import AVFoundation

final class CameraManager {
    
    typealias CameraManagerDelegate = UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate
    
    func requestAuthAndOpenCamera(in viewController: CameraManagerDelegate) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            
            guard isAuthorized else {
                self?.showGoToSettingAlert(viewController)
                return
            }
            
            self?.openCamera(in: viewController)
        }
    }
    
    private func openCamera(in viewController: CameraManagerDelegate) {
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
    
    private func showGoToSettingAlert(_ viewController: CameraManagerDelegate) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: StringKey.cameraSettingTitle.localized(),
                message: StringKey.cameraSettingMessage.localized(),
                preferredStyle: .alert
            )
            
            let cancel = UIAlertAction(title: StringKey.cancel.localized(),
                                       style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            
            let goToSetting = UIAlertAction(
                title: StringKey.setting.localized(),
                style: .default
            ) { _ in
                guard let settingURL = URL(
                    string: UIApplication.openSettingsURLString
                ), UIApplication.shared.canOpenURL(settingURL) else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
            
            alert.addAction(cancel)
            alert.addAction(goToSetting)
            
            viewController.present(alert, animated: true)
        }
    }
}
