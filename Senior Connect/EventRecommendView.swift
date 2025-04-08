//
//  EventRecommendView.swift
//  Senior Connect
//
//  Created by f1225834 on 29/11/2024.
//

import SwiftUI
import CoreML
import FirebaseFirestore



struct EventRecommendView: View {
    @ObservedObject var recommender = Recommender()
    @State private var eventName: String = ""
    @State private var num: String = ""
    @State private var itemId: Double = 0.0
    
    
    var body: some View {
        VStack {
            Text("Get Recommendations")
                .font(.headline)
                .padding()
            
            TextField("Enter event name", text: $eventName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter total number of recommend event ", text: $num)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                Task {
                    // Call the method directly on recommender
                    
                    do{
                        try await recommender.getRecommendations(genre: eventName, rating: Double(num) ?? 0.0)
                    } catch {
                        print("Error fetching recommendations: \(error)")
                        
                    }
                }
            }) {
                Text("Get Recommendations")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                
            }
            
            // find same name event
            List {
                ForEach(recommender.recommendedItems, id: \.self) { item in
                    if let event = Event.events.first(where: { $0.title == item }) {
                        Text(event.title) .contextMenu {
                            Button("Add to itinerary") {
                                let eventData = [FirebaseConstants.eventTitle: event.title, FirebaseConstants.eventCategory: event.category, FirebaseConstants.eventDate: event.date, FirebaseConstants.eventTime: event.time, FirebaseConstants.eventLocation: event.location, FirebaseConstants.eventDes: event.des, FirebaseConstants.eventRating: event.rating]
                                FirebaseManager.shared.firestore.collection(FirebaseConstants.events)
                                    .document((FirebaseManager.shared.auth.currentUser?.uid)!).collection(FirebaseConstants.events).document(event.title).setData(eventData) { err in
                                        if let err = err {
                                            print(err)
                                            return
                                        }
                                        
                                        print("Success")
                                    }
                            }
                        }
                    }
                }
            }}
        
        
        
    }
}

class Recommender: ObservableObject {
    
    
    @Published var recommendedItems: [String] = []
    
    
    
    func getRecommendations(genre: String, rating: Double) async throws {
        
        do {
            // Load your CoreML model
            let model = try EventRecommender(configuration: MLModelConfiguration())
            
            let store: [String: Double] = [
                genre:rating
            ]
            // Create input for the model, input name and number
            let input = EventRecommenderInput(items: store , k: Int64(rating))
            
            // Get prediction
            let prediction = try await model.prediction(input: input)
            print(prediction.recommendations)
            print(input.items)
            recommendedItems = prediction.recommendations
            // Update the UI on the main thread
            
        } catch {
            print("Error getting recommendations: \(error)")
        }
    }
}

#Preview {
    EventRecommendView()
}
