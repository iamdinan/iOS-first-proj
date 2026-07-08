import Foundation

enum TriviaError: Error {
    case badResponse
    case decodingFailed
    case network(Error)
    case rateLimited
    case noResults
}

struct TriviaService {

    private let endpoint = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        return URLSession(configuration: config)   // ← use this, not .shared
    }()

    func fetchQuestions() async throws -> [QuizQuestion] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: endpoint)   // ← session, not .shared
        } catch {
            throw TriviaError.network(error)
        }

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw TriviaError.badResponse
        }

        return try await Task.detached(priority: .userInitiated) {
            let decoded: TriviaResponse
            do {
                decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            } catch {
                throw TriviaError.decodingFailed
            }

            // Check Open Trivia DB's own response code
            // 0 = success, 5 = rate limited, anything else = no results available
            switch decoded.responseCode {
            case 0: break
            case 5: throw TriviaError.rateLimited
            default: throw TriviaError.noResults
            }

            guard !decoded.results.isEmpty else { throw TriviaError.noResults }
            return decoded.results.map(QuizQuestion.init)
        }.value
    }
}