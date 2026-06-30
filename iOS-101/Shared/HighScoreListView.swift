import SwiftUI

struct HighScoreListView: View {
    let title: String
    let accentColor: Color
    let scores: [ScoreEntry]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if scores.isEmpty {
                    Text("No scores yet — play a round!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(scores.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text("#\(index + 1)")
                                .font(.subheadline.bold())
                                .foregroundStyle(index == 0 ? accentColor : .secondary)
                                .frame(width: 36, alignment: .leading)

                            Text("\(entry.score)")
                                .font(.title3.bold())

                            Spacer()

                            Text(entry.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    HighScoreListView(
        title: "Tap Frenzy — Top 10",
        accentColor: .blue,
        scores: [ScoreEntry(score: 42), ScoreEntry(score: 30)]
    )
}