import SwiftUI

struct RootView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            ForEach(AppRouter.Tab.allCases) { tab in
                NavigationStack(path: $coordinator.navigationPath) {
                    tab.destination
                        .navigationDestination(for: AppRouter.Destination.self) { destination in
                            destination.view
                        }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.icon)
                }
                .tag(tab)
            }
        }
        .accentColor(.appPrimary)
        .sheet(item: $coordinator.activeSheet) { sheet in
            sheet.view
        }
        .fullScreenCover(isPresented: $coordinator.showPermissions) {
            PermissionSetupView()
        }
    }
}

struct PermissionSetupView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60))
                .foregroundColor(.appPrimary)

            Text("Permissions Required")
                .font(.title.bold())

            Text("CreatorStudioPro needs camera and microphone access to function.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.appSecondaryText)

            Button(action: {
                Task {
                    await coordinator.requestPermissions()
                }
            }) {
                Text("Grant Permissions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.appPrimary)
                    .cornerRadius(AppConstants.UI.cornerRadius)
            }
        }
        .padding()
    }
}
