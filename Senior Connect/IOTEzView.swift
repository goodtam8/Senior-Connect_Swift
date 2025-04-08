//
//  IOTEzView.swift
//  Senior Connect
//
//  Created by f1225834 on 25/11/2024.
//

import SwiftUI
import Charts
struct Message: Codable {
    let role: String
    let content: String
}

struct ChatCompletionRequest: Codable {
    let messages: [Message]
    let temperature: Double
}

struct ChatCompletionResponse: Codable {
    let id: String?
    let object: String
    let created: Int
    let model: String
    let systemFingerprint: String?
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Codable {
        let index: Int
        let message: Message
        let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
    
    struct IOTEzView: View {
        @State private var userInput: String = "Here is my heart rate for the latest 20 records.Please only tell me my heart rate is normal? Answer it concisely for around 10 words"
        @State private var response: String = ""
        @State var apiKey: String = "???"
        
        func fetchChatCompletion(messages: [Message], temperature: Double, completion: @escaping (String?) -> Void) {
            guard let url = URL(string: "https://genai.hkbu.edu.hk/general/rest/deployments/gpt-4-turbo/chat/completions?api-version=2024-02-01")else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "api-key")
            
            let body = ChatCompletionRequest(messages: messages, temperature: temperature)
            request.httpBody = try? JSONEncoder().encode(body)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let data = data {
                    do {
                        // Print the raw JSON response for debugging
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("Raw JSON response: \(jsonString)")
                        }
                        
                        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
                        completion(response.choices.first?.message.content)
                    } catch {
                        print("Decoding error: \(error)")
                        completion(nil)
                    }
                }
            }
            
            task.resume()
        }
        
        
        @State var marks = [MarkEz]()
        let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
        
        
        var body: some View {
            VStack{
                Chart(marks) {
                    LineMark(
                        x: .value("Time", $0.id),
                        y: .value("Count", $0.value)
                    )
                }.padding()
                    .onAppear(perform: startLoad)
                    .onReceive(timer) { _ in
                        startLoad()
                    }
                Button("Send") {
                    let latestMarks = marks.suffix(20)
                    let marksString = latestMarks.map { "\($0.id): \($0.value)" }.joined(separator: ", ")
                    let query = "\(userInput) Latest marks: \(marksString)"
                    
                    let messages = [
                        Message(role: "user", content: query)
                    ]
                    
                    fetchChatCompletion(messages: messages, temperature: 0) { result in
                        DispatchQueue.main.async {
                            response = result ?? "Error fetching response."
                        }
                    }
                }
                .padding()
                
                Text("Response:")
                    .font(.headline)
                Text(response)
                    .padding()
                
            }
        }
    }

#Preview {
    IOTEzView()
}

struct MarkEz: Identifiable {
    let id: Date
    let value: Float
}

struct EzData: Decodable {
    let dataToken: String
    let dataType: String
    let name: String
    let value: Float
    var createTime: String
    var updateTime: String
}

struct EzResponse: Decodable {
    let code: Int
    let msg: String
    let data: EzData
}

extension IOTEzView {
    func handleClientError(_: Error) {
        return
    }
    
    func handleServerError(_: URLResponse?) {
        return
    }
}

extension IOTEzView {
    
    
    func startLoad() {
        
        let url = URL(string: "https://ezdata2.m5stack.com/api/v2/32dad31beb014e31942ad17da4fc9137/data")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                self.handleClientError(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response)
                return
            }
            
            if let data = data, let ezResponse = try? JSONDecoder().decode(EzResponse.self, from: data) {
                
                let mark = MarkEz(id: Date.now, value: ezResponse.data.value)

                if (self.marks.count == 20) {
                    self.marks.removeFirst()
                }

                self.marks.append(mark)
            }
        }
        task.resume()
    }
}

