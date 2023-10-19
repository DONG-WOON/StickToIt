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
    func isLoading(_ isLoading: Bool) {
        self.isLoading.accept(isLoading)
    }
    
    func save(with imageData: UIImage?) async -> Result<Bool, Error> {
        let imageData = compressedImageData(imageData, limitSize: Const.Size.kb(10).value)
        let imageURL = await useCase.save(dayPlanID: dayPlan._id, imageData: imageData)
        dayPlan.imageURL = imageURL
        dayPlan.isComplete = true
        let result = await useCase.save(entity: DayPlanEntity.self, matchingWith: dayPlan)
        return result
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
