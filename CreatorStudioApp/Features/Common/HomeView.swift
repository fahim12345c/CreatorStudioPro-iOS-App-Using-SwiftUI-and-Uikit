import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Quick Actions
                    quickActionsSection

                    // Features Grid
                    featuresSection

                    // Recent Activity
                    recentSection
                }
                .padding(.bottom, 20)
            }
            .background(Color.appBackground)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 0.498, blue: 1.0),
                                Color(red: 0.4, green: 0.65, blue: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .appPrimary.opacity(0.3), radius: 12, x: 0, y: 6)

                Image(systemName: "camera.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            Text("CreatorStudio")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Your creative media toolkit")
                .font(.subheadline)
                .foregroundColor(.appSecondaryText)
        }
        .padding(.top, 20)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    QuickActionButton(
                        icon: "camera.fill",
                        title: "Camera",
                        color: .appPrimary
                    ) {
                        coordinator.selectedTab = .camera
                    }

                    QuickActionButton(
                        icon: "mic.fill",
                        title: "Record",
                        color: .red
                    ) {
                        coordinator.selectedTab = .tools
                    }

                    QuickActionButton(
                        icon: "text.viewfinder",
                        title: "OCR",
                        color: .orange
                    ) {
                        coordinator.selectedTab = .tools
                    }

                    QuickActionButton(
                        icon: "qrcode.viewfinder",
                        title: "Scanner",
                        color: .green
                    ) {
                        coordinator.selectedTab = .tools
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Features Grid

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                FeatureCard(
                    icon: "photo.on.rectangle",
                    title: "Media Library",
                    subtitle: "Browse photos, videos & audio",
                    color: .purple
                ) {
                    coordinator.selectedTab = .media
                }

                FeatureCard(
                    icon: "waveform",
                    title: "Speech",
                    subtitle: "Transcribe & text-to-speech",
                    color: .teal
                ) {
                    coordinator.selectedTab = .speech
                }

                FeatureCard(
                    icon: "faceid",
                    title: "Face Detection",
                    subtitle: "Detect faces with gender",
                    color: .indigo
                ) {
                    coordinator.selectedTab = .vision
                }

                FeatureCard(
                    icon: "antenna.radiowaves.left.and.right",
                    title: "Streaming",
                    subtitle: "Live RTMP streaming",
                    color: .pink
                ) {
                    coordinator.selectedTab = .tools
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Recent Section

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Tools")
                .font(.headline)
                .padding(.horizontal)

            VStack(spacing: 8) {
                ToolRow(icon: "mic.circle.fill", title: "Voice Recorder", color: .red) {
                    coordinator.selectedTab = .tools
                }
                ToolRow(icon: "waveform.circle.fill", title: "Audio Analysis", color: .orange) {
                    coordinator.selectedTab = .tools
                }
                ToolRow(icon: "speaker.wave.2.circle.fill", title: "Text to Speech", color: .blue) {
                    coordinator.selectedTab = .tools
                }
                ToolRow(icon: "text.viewfinder", title: "OCR Scanner", color: .green) {
                    coordinator.selectedTab = .tools
                }
                ToolRow(icon: "qrcode.viewfinder", title: "QR & Barcode", color: .purple) {
                    coordinator.selectedTab = .tools
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Components

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.appSecondaryText)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(16)
        }
    }
}

struct ToolRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 32)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.appSecondaryText)
            }
            .padding()
            .background(Color.appSecondaryBackground)
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
}
