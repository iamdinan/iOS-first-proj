import Foundation

// MARK: - API Response Shape
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
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
        var s = self
        let entities: [(String, String)] = [
            ("&amp;",   "&"),
            ("&lt;",    "<"),
            ("&gt;",    ">"),
            ("&quot;",  "\""),
            ("&#039;",  "'"),
            ("&apos;",  "'"),
            ("&ndash;", "–"),
            ("&mdash;", "—"),
            ("&laquo;", "«"),
            ("&raquo;", "»"),
            ("&ldquo;", "\u{201C}"),
            ("&rdquo;", "\u{201D}"),
            ("&lsquo;", "\u{2018}"),
            ("&rsquo;", "\u{2019}"),
        ]
        for (entity, char) in entities { s = s.replacingOccurrences(of: entity, with: char) }
        return s
    }
}