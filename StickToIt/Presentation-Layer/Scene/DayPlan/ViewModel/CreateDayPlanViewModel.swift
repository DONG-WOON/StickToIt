//
//  CreateDayPlanViewModel.swift
//  StickToIt
//
//  Created by 서동운 on 10/11/23.
//

import Foundation
import UIKit
import RxCocoa

final class CreateDayPlanViewModel<PlanUseCase: CreateDayPlanUseCase>
where PlanUseCase.Model == DayPlan, PlanUseCase.Entity == DayPlanEntity
{
    // MARK: Properties
    private let useCase: PlanUseCase
    private let mainQueue: DispatchQueue
    
    var dayPlan: DayPlan
    var isValidated = BehaviorRelay(value: false)
    var isLoading = BehaviorRelay(value: false)
    
    init(
        dayPlan: DayPlan,
        useCase: PlanUseCase,
        mainQueue: DispatchQueue = .main
    ) {
        self.dayPlan = dayPlan
        self.useCase = useCase
        self.mainQueue = mainQueue
    }
        
    func viewDidLoad() {
        
    }
    
    func checkError(handler: (String, String) -> Void) {
        if UserDefaults.standard.bool(forKey: Const.Key.isCertifyingError) {
            handler(Const.Key.isCertifyingError,"인증이 실패했어요. 오늘 다시 시도해주세요!")
        } else if UserDefaults.standard.bool(forKey: Const.Key.isSaveImageError) {
            handler(Const.Key.isSaveImageError, "사진이 제대로 저장되지않았어요 ㅠㅠ 인증사진만 다시 저장하시겠어요?")
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
                UserDefaults.standard.setValue(true, forKey: Const.Key.isCertifyingError)
                DispatchQueue.main.async { [weak self] in
                    failure("인증오류", "인증에 실패했습니다. 다시 시도하겠습니까?")
                }
            } catch STIError.imageNotSave {
                UserDefaults.standard.setValue(true, forKey: Const.Key.isSaveImageError)
                DispatchQueue.main.async { [weak self] in
                    failure("사진 저장 오류", "사진 저장에 실패했습니다. 다시 시도하겠습니까")
                }
            } catch STIError.imageURLNotSave {
                UserDefaults.standard.setValue(true, forKey: Const.Key.isSaveImageError)
                DispatchQueue.main.async { [weak self] in
                    failure("사진 저장 오류", "사진 저장에 실패했습니다. 다시 시도하겠습니까?")
                }
            }
        }
    }
    
    func certify() async throws {
        let result = await useCase.save(entity: DayPlanEntity.self, matchingWith: dayPlan, updateHandler: {
            $0.isComplete = true
        })
        
        switch result {
        case .success:
            return
        case .failure:
            throw STIError.certifyingError
        }
    }

    func save(with imageData: UIImage?) async throws -> String {
        let imageData = compressedImageData(imageData, limitSize: Const.Size.kb(10).value)
        let imageURL = await useCase.save(dayPlanID: dayPlan._id, imageData: imageData)
        
        if let imageURL {
            return imageURL
        } else {
            throw STIError.imageURLNotSave
        }
    }
    
    func updateImageURL(with imageURL: String) async throws {
        let result = await useCase.save(entity: DayPlanEntity.self, matchingWith: dayPlan) { $0.imageURL = imageURL }
        
        switch result {
        case .success:
            return
        case .failure:
            throw STIError.entityNotSave
        }
    }
    
    func loadImage(completion: @escaping (Data?) -> Void) {
        useCase.loadImage(dayPlanID: dayPlan._id) { data in
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
