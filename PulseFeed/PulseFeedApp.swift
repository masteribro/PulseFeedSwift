import SwiftUI

@main
struct PulseFeedApp: App {
    @StateObject private var homeViewModel = HomeViewModel()
    
    init() {
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(homeViewModel)
                .preferredColorScheme(.light)
        }
    }
    
    private func configureAppearance() {
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }
}
