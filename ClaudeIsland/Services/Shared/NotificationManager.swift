import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func notifyStop(cwd: String, lastQuery: String? = nil) {
        let projectName = URL(fileURLWithPath: cwd).lastPathComponent
        let content = UNMutableNotificationContent()
        content.title = projectName
        content.body = lastQuery ?? "Waiting for your input"
        content.sound = .default

        let id = "stop-\(cwd.hashValue)-\(Int(Date().timeIntervalSince1970))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
