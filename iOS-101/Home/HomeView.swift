import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🎮")
                .font(.system(size: 64))
            Text("Arcade")
                .font(.largeTitle.bold())
            Text("Choose a game mode")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            NavigationLink(destination: TapFrenzyView()) {
                GameModeButton(
                    title: "Tap Frenzy",
                    subtitle: "Tap fast. Beat traps. Build combos.",
                    color: .blue
                )
            }

            NavigationLink(destination: LightItUpView()) {
                GameModeButton(
                    title: "Light It Up",
                    subtitle: "Tap the lit card before it goes dark.",
                    color: .indigo
                )
            }
            NavigationLink(destination: QuizRushView()) {
                GameModeButton(
                    title: "Quiz Rush",
                    subtitle: "Live trivia. Beat the streak.",
                    color: .purple
                )
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarHidden(true)
    }
}

#Preview { HomeView() }