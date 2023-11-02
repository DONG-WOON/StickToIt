//
//  DayPlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import Foundation
import UIKit
import RxCocoa

final class DayPlanViewModel {
    // MARK: Properties
    private let updateDayPlanUseCase: any UpdateDayPlanUseCase<DayPlan, DayPlanEntity>
    
    var dayPlan: BehaviorRelay<DayPlan>
    var isValidated = BehaviorRelay(value: false)
    var isLoading = BehaviorRelay(value: false)
    
    init(
        dayPlan: DayPlan,
        updateDayPlanUseCase: some UpdateDayPlanUseCase<DayPlan, DayPlanEntity>
    ) {
        self.dayPlan = BehaviorRelay(value: dayPlan)
        self.updateDayPlanUseCase = updateDayPlanUseCase
    }
    
    func checkError(handler: (String, String) -> Void) {
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.isCertifyingError) {
            handler(UserDefaultsKey.isCertifyingError, StringKey.certifyingErrorMessage.localized())
        } else if UserDefaults.standard.bool(forKey: UserDefaultsKey.isSaveImageError) {
            handler(UserDefaultsKey.isSaveImageError, StringKey.saveImageErrorMessage.localized())
        }
    }
    
    func isLoading(_ isLoading: Bool) {
        self.isLoading.accept(isLoading)
    }
    
    func certifyButtonDidTapped(with image: UIImage?, success: @escaping () -> Void, failure: @escaping (String, String) -> Void) {
        isLoading(true)
        Task(priority: .background) { [weak self] in
            guard let _self = self else { return }
            do {
                try await _self.certify()
                let url = try await _self.save(with: image)
                try await _self.updateImageURL(with: url)
                
                DispatchQueue.main.async {
                   NotificationCenter.default.post(name: .reloadPlan, object: nil)
                   success()
                }
                
            } catch STIError.certifyingError {
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.isCertifyingError)
                DispatchQueue.main.async {
                    failure(StringKey.noti.localized(), StringKey.certifyingErrorMessage.localized())
                }
            } catch STIError.imageNotSave {
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.isSaveImageError)
                DispatchQueue.main.async {
                    failure(StringKey.noti.localized(), StringKey.saveImageErrorMessage.localized())
                }
            } catch STIError.imageURLNotSave {
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKey.isSaveImageError)
                DispatchQueue.main.async {
                    failure(StringKey.noti.localized(), StringKey.saveImageErrorMessage.localized())
                }
            }
        }
    }
    
    func certify() async throws {
        let result = await updateDayPlanUseCase.update(
            entity: DayPlanEntity.self,
            key: dayPlan.value.id,
            updateHandler: {
                $0?.isComplete = true
            }
        )
        
        switch result {
        case .success:
            return
        case .failure:
            throw STIError.certifyingError
        }
    }
    
    func save(with imageData: UIImage?) async throws -> String {
        let imageData = compressedImageData(
            imageData,
            limitSize: Const.Size.kb(10).value
        )
        let imageURL = await updateDayPlanUseCase.saveImageData(
            imageData,
            dayPlanID: dayPlan.value.id
        )
        
        if let imageURL {
            return imageURL
        } else {
            throw STIError.imageURLNotSave
        }
    }
    
    func updateImageURL(with imageURL: String) async throws {
        let result = await updateDayPlanUseCase.update(
            entity: DayPlanEntity.self,
            key: dayPlan.value.id
        ) { $0?.imageURL = imageURL }
        
        switch result {
        case .success:
            return
        case .failure:
            throw STIError.entityNotSave
        }
    }
    
    func loadImage(completion: @escaping (Data?) -> Void) {
        updateDayPlanUseCase.loadImage(dayPlanID: dayPlan.value.id) { data in
            completion(data)
        }
    }
    
    private func compressedImageData(_ image: UIImage?, limitSize limitOfImageDataSize: Int) -> Data? {
        guard let image = image else { return nil }
        let compressionQuality: CGFloat
        
        if let jpegImageData = image.jpegData(compressionQuality: 1.0) {
            let bytesOfImageData = jpegImageData.count
            
            if bytesOfImageData > limitOfImageDataSize {
                compressionQuality = CGFloat(limitOfImageDataSize) / CGFloat(bytesOfImageData)
            } else {
                compressionQuality = 1.0
            }
            
            let compressedData = image.jpegData(compressionQuality: compressionQuality)
            print("Image saved with compression quality: \(compressionQuality).\nDataSize:\(compressedData?.count ?? 0 / 1024)")
            
            return compressedData
        }
        
        return nil
    }
}
