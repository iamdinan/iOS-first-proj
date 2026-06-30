import SwiftUI

enum QuizState {
    case loading
    case loaded
    case failed(String)
}

@MainActor
class QuizRushViewModel: ObservableObject {

    // MARK: - Published State
    @Published var state: QuizState = .loading
    @Published var questions: [QuizQuestion] = []
    @Published var index = 0
    @Published var score = 0
    @Published var streak = 0
    @Published var lastAnswerWasCorrect: Bool? = nil
    @Published var isNewHighScore = false

    private let service: TriviaService
    let highScoreStore = HighScoreStore(key: "quizRushTopScores")

    private let basePoints = 10
    private let wrongPenalty = 3
    private let streakBonusPerLevel = 2

    init(service: TriviaService = TriviaService()) {
        self.service = service
    }

    var currentQuestion: QuizQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var isRoundComplete: Bool { index >= questions.count }

    var progressLabel: String { "\(min(index + 1, questions.count)) of \(questions.count)" }

    // MARK: - Fetch
    func load() async {
        state = .loading
        do {
            let fetched = try await service.fetchQuestions()
            guard !fetched.isEmpty else {
                state = .failed("No questions returned. Please try again.")
                return
            }
            questions = fetched
            index = 0
            score = 0
            streak = 0
            isNewHighScore = false
            state = .loaded
        } catch {
            state = .failed(Self.message(for: error))
        }
    }

    private static func message(for error: Error) -> String {
        switch error {
        case TriviaError.badResponse:
            return "The trivia server didn't respond properly. Please retry."
        case TriviaError.decodingFailed:
            return "Couldn't read the trivia data. Please retry."
        case TriviaError.network:
            return "No connection. Check your network and retry."
        default:
            return "Something went wrong. Please retry."
        }
    }

    // MARK: - Answering
    func selectAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        let isCorrect = answer == question.correctAnswer

        if isCorrect {
            streak += 1
            let bonus = (streak - 1) * streakBonusPerLevel
            score += basePoints + bonus
        } else {
            streak = 0
            score = max(0, score - wrongPenalty)
        }

        lastAnswerWasCorrect = isCorrect

        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            advance()
        }
    }

    private func advance() {
        lastAnswerWasCorrect = nil
        index += 1
        if isRoundComplete {
            isNewHighScore = score > highScoreStore.best
            highScoreStore.submit(score)
        }
    }

    // MARK: - Reset
    func playAgain() {
        state = .loading
        Task { await load() }
    }
}