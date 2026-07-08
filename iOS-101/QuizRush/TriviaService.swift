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

    /// URLSession with a 15-second timeout so the app never hangs on the loading screen.
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 15
        return URLSession(configuration: config)
    }

    func fetchQuestions() async throws -> [QuizQuestion] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: endpoint)
        } catch {
            throw TriviaError.network(error)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TriviaError.badResponse
        }

        do {
            let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
            // OTD response_code 5 = rate limited, 1 = no results for query
            switch decoded.responseCode {
            case 5: throw TriviaError.rateLimited
            case 1: throw TriviaError.noResults
            default: break
            }
            guard !decoded.results.isEmpty else { throw TriviaError.noResults }
            return decoded.results.map(QuizQuestion.init)
        } catch let e as TriviaError {
            throw e
        } catch {
            throw TriviaError.decodingFailed
        }
    }
}