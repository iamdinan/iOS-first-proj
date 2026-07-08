//
//  QuizRushVM.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import SwiftUI
internal import Combine

enum QuizViewState { case loading, loaded, failed(String) }

@MainActor
final class QuizRushVM: ObservableObject {
    

    @Published var state:                QuizViewState = .loading
    @Published var questions:            [QuizQuestion] = []
    @Published var index                 = 0
    @Published var score                 = 0
    @Published var streak                = 0
    @Published var lastAnswerWasCorrect: Bool?   = nil
    @Published var revealedCorrectAnswer: String? = nil
    @Published var isNewBest             = false

    var onSessionEnd: ((Int) -> Void)? = nil

    private let api              = TriviaAPI()
    private let basePoints       = 10
    private let wrongPenalty     = 3
    private let streakBonus      = 2
    let highScoreStore           = HighScoreStore(key: "quizRushTopScores")

    var currentQuestion: QuizQuestion? {
        index < questions.count ? questions[index] : nil
    }
    var isRoundComplete: Bool  { index >= questions.count && !questions.isEmpty }
    var progressLabel:   String { "\(min(index + 1, questions.count)) of \(questions.count)" }

    func load() async {
        state = .loading
        do {
            let fetched = try await api.fetchQuestions()
            questions = fetched; index = 0; score = 0; streak = 0; isNewBest = false
            state = .loaded
        } catch {
            state = .failed(Self.message(for: error))
        }
    }

    func selectAnswer(_ answer: String) {
        guard let q = currentQuestion else { return }
        let correct = answer == q.correctAnswer
        if correct {
            streak += 1
            score  += basePoints + (streak - 1) * streakBonus
        } else {
            streak  = 0
            score   = max(0, score - wrongPenalty)
            revealedCorrectAnswer = q.correctAnswer
        }
        lastAnswerWasCorrect = correct
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            revealedCorrectAnswer = nil
            lastAnswerWasCorrect  = nil
            index += 1
            if isRoundComplete {
                isNewBest = score > highScoreStore.best
                highScoreStore.submit(score)
                onSessionEnd?(score)
            }
        }
    }

    func playAgain() { Task { await load() } }

    private static func message(for error: Error) -> String {
        switch error {
        case TriviaError.badResponse:    return "Server error. Please retry."
        case TriviaError.decodingFailed: return "Couldn't read the data. Please retry."
        case TriviaError.rateLimited:    return "Too many requests. Wait a moment and retry."
        case TriviaError.noResults:      return "No questions available. Please retry."
        case TriviaError.network:        return "No connection. Check your network and retry."
        default:                         return "Something went wrong. Please retry."
        }
    }
}
