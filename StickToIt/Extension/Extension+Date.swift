//
//  Extension+Date.swift
//  StickToIt
//
//  Created by 서동운 on 11/1/23.
//

import Foundation

extension Date {
    func addDays(_ day: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: day, to: self)!
    }
}
