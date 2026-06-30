import Foundation

enum TriviaError: Error {
    case badResponse
    case decodingFailed
    case network(Error)
}

struct TriviaService {

    private let endpoint = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    func fetchQuestions() async throws -> [QuizQuestion] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(from: endpoint)
        } catch {
            throw TriviaError.network(error)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TriviaError.badResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            return decoded.results.map(QuizQuestion.init)
        } catch {
            throw TriviaError.decodingFailed
        }
    }
}