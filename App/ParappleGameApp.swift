import SwiftUI

@main
struct ParappleGameApp : App {
    @StateObject var appModel = AppModel()
   
    var body: some Scene {
        WindowGroup {
            GameSelectionView()
                .environmentObject(appModel)
        }
    }
}

