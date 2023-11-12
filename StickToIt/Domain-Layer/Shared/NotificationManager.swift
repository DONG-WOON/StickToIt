//
//  NotificationManager.swift
//  StickToIt
//
//  Created by 서동운 on 11/12/23.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() { }
    
    func requestAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .badge, .sound)

        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
    
    func setUpLocalNotification(
        time: Date
    ) {
        let content = UNMutableNotificationContent()
        content.title = StringKey.localNotificationTitle.localized()
        content.body = StringKey.localNotificationSubTitle.localized()
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: dateComponents.hour, minute: dateComponents.minute), repeats: true)
        
        let request = UNNotificationRequest(identifier: "\(Date.now)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(error)
            } else {
                print("success")
            }
        }
    }
    
    func deleteLocalNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
