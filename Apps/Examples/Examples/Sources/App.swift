
import SwiftUI

@main
struct ExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
