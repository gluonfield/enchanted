//
//  OpenAIService.swift
//  Enchanted
//
//  Created for OpenAI-compatible gateway support (LiteLLM, etc.)
//

import Foundation
import Combine

// MARK: - OpenAI API Request/Response Models

struct OpenAIChatMessage: Codable {
    let role: String
    let content: OpenAIMessageContent

    enum CodingKeys: String, CodingKey {
        case role, content
    }

    init(role: String, content: String, imageBase64: String? = nil) {
        self.role = role
        if let image = imageBase64 {
            self.content = .array([
                .init(type: "text", text: content, imageUrl: nil),
                .init(type: "image_url", text: nil, imageUrl: .init(url: "data:image/jpeg;base64,\(image)"))
            ])
        } else {
            self.content = .string(content)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(String.self, forKey: .role)

        if let stringContent = try? container.decode(String.self, forKey: .content) {
            content = .string(stringContent)
        } else {
            content = try container.decode(OpenAIMessageContent.self, forKey: .content)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
    }
}

enum OpenAIMessageContent: Codable {
    case string(String)
    case array([OpenAIContentPart])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let parts):
            try container.encode(parts)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else {
            self = .array(try container.decode([OpenAIContentPart].self))
        }
    }
}

struct OpenAIContentPart: Codable {
    let type: String
    let text: String?
    let imageUrl: OpenAIImageUrl?

    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

struct OpenAIImageUrl: Codable {
    let url: String
}

struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIChatMessage]
    let stream: Bool
    let temperature: Double?

    init(model: String, messages: [OpenAIChatMessage], stream: Bool = true, temperature: Double? = nil) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.temperature = temperature
    }
}

struct OpenAIChatResponseChunk: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [OpenAIChoice]?
}

struct OpenAIChoice: Codable {
    let index: Int?
    let delta: OpenAIDelta?
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index, delta
        case finishReason = "finish_reason"
    }
}

struct OpenAIDelta: Codable {
    let role: String?
    let content: String?
}

struct OpenAIModelResponse: Codable {
    let object: String
    let data: [OpenAIModel]
}

struct OpenAIModel: Codable {
    let id: String
    let object: String?
    let created: Int?
    let ownedBy: String?

    enum CodingKeys: String, CodingKey {
        case id, object, created
        case ownedBy = "owned_by"
    }
}

// MARK: - OpenAI Chat Response (for streaming)

struct OpenAIChatResponse {
    let content: String?
    let done: Bool
}

// MARK: - OpenAI Service

class OpenAIService: @unchecked Sendable {
    static let shared = OpenAIService()

    private var baseURL: URL
    private var apiKey: String
    private var session: URLSession

    init() {
        self.baseURL = URL(string: "http://localhost:4000/v1")!
        self.apiKey = ""
        self.session = URLSession.shared
        initEndpoint()
    }

    func initEndpoint(url: String? = nil, apiKey: String? = nil) {
        let defaultUrl = "http://localhost:4000/v1"
        let localStorageUrl = UserDefaults.standard.string(forKey: "openAIUri")
        let storedApiKey = UserDefaults.standard.string(forKey: "openAIApiKey") ?? ""

        if var openAIUrl = [localStorageUrl, defaultUrl].compactMap({$0}).filter({$0.count > 0}).first {
            if !openAIUrl.contains("http") {
                openAIUrl = "http://" + openAIUrl
            }

            // Ensure URL ends with /v1
            if !openAIUrl.hasSuffix("/v1") && !openAIUrl.hasSuffix("/v1/") {
                openAIUrl = openAIUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/v1"
            }

            if let url = URL(string: openAIUrl) {
                self.baseURL = url
            }
        }

        self.apiKey = apiKey ?? storedApiKey
    }

    func getModels() async throws -> [LanguageModel] {
        let url = baseURL.appendingPathComponent("models")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OpenAIError.invalidResponse
        }

        let modelResponse = try JSONDecoder().decode(OpenAIModelResponse.self, from: data)

        return modelResponse.data.map { model in
            // Detect image support based on model name patterns
            let supportsImages = model.id.lowercased().contains("vision") ||
                                 model.id.lowercased().contains("gpt-4o") ||
                                 model.id.lowercased().contains("gpt-4-turbo") ||
                                 model.id.lowercased().contains("claude-3") ||
                                 model.id.lowercased().contains("llava")

            return LanguageModel(
                name: model.id,
                provider: .openAI,
                imageSupport: supportsImages
            )
        }
    }

    func reachable() async -> Bool {
        let url = baseURL.appendingPathComponent("models")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }

    func chat(model: String, messages: [OpenAIChatMessage], temperature: Double? = nil) -> AnyPublisher<OpenAIChatResponse, Error> {
        let subject = PassthroughSubject<OpenAIChatResponse, Error>()

        Task {
            do {
                let url = baseURL.appendingPathComponent("chat/completions")
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                if !apiKey.isEmpty {
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                }

                let chatRequest = OpenAIChatRequest(
                    model: model,
                    messages: messages,
                    stream: true,
                    temperature: temperature
                )

                request.httpBody = try JSONEncoder().encode(chatRequest)

                let (asyncBytes, response) = try await session.bytes(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    subject.send(completion: .failure(OpenAIError.invalidResponse))
                    return
                }

                if httpResponse.statusCode != 200 {
                    subject.send(completion: .failure(OpenAIError.httpError(statusCode: httpResponse.statusCode)))
                    return
                }

                for try await line in asyncBytes.lines {
                    if line.hasPrefix("data: ") {
                        let jsonString = String(line.dropFirst(6))

                        if jsonString == "[DONE]" {
                            subject.send(OpenAIChatResponse(content: nil, done: true))
                            subject.send(completion: .finished)
                            return
                        }

                        if let jsonData = jsonString.data(using: .utf8) {
                            do {
                                let chunk = try JSONDecoder().decode(OpenAIChatResponseChunk.self, from: jsonData)
                                if let content = chunk.choices?.first?.delta?.content {
                                    subject.send(OpenAIChatResponse(content: content, done: false))
                                }
                                if chunk.choices?.first?.finishReason != nil {
                                    subject.send(OpenAIChatResponse(content: nil, done: true))
                                }
                            } catch {
                                // Skip malformed chunks
                                print("Failed to decode chunk: \(error)")
                            }
                        }
                    }
                }

                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }

        return subject.eraseToAnyPublisher()
    }
}

// MARK: - Errors

enum OpenAIError: Error, LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
