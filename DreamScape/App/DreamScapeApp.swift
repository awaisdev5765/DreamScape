import SwiftUI
import SwiftData

@main
struct DreamScapeApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            UserProfile.self,
            SleepLog.self,
            Meditation.self
        ])
    }
}
