import Foundation

// MARK: - API Response Shape
struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable {
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

// MARK: - View-Ready Question
struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let correctAnswer: String
    let answers: [String]

    init(from raw: TriviaQuestion) {
        self.text = raw.question.htmlDecoded
        self.correctAnswer = raw.correctAnswer.htmlDecoded
        let allAnswers = (raw.incorrectAnswers + [raw.correctAnswer])
            .map { $0.htmlDecoded }
        self.answers = allAnswers.shuffled()
    }
}

// MARK: - HTML Entity Decoding
private extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        return attributed.string
    }
}