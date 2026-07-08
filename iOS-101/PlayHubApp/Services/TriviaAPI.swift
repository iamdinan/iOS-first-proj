//
//  TriviaAPI.swift
//  iOS-101
//
//  Created by Student1 on 2026-07-08.
//

import Foundation

enum TriviaError: Error {
    case badResponse, decodingFailed, rateLimited, noResults, network(Error)
}

struct TriviaAPI {
    private let endpoint = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest  = 15
        cfg.timeoutIntervalForResource = 15
        return URLSession(configuration: cfg)
    }()

    func fetchQuestions() async throws -> [QuizQuestion] {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: endpoint)
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
