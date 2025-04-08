//
//  Profile.swift
//  Senior Connect
//
//  Created by SUN TAM on 16/11/2024.
//

import SwiftUI
import AVKit
import WebKit

struct Profile: View {
//    let videoURL: URL
    @AppStorage("darkMode") var darkMode: Bool = false
    @State private var userEvents: [Event] = []
    let ID:String
    var body: some View {
        VStack {
//            VideoPlayer(player: AVPlayer(url: videoURL)).frame(height: 300)
            
            //            Link("Some label", destination: URL(string: "https://www.youtube.com/watch?v=uhNsQOU9PqI")!)
            
            Text("tutorial video")
                            .font(.title3)
                            .fontWeight(.bold)


                        Video(videoID: ID).frame(width: 360, height:220 ).cornerRadius(12).padding(.horizontal, 24)
            Section(header: Text("Settings")) {
                Toggle("Dark Mode", isOn: $darkMode)
                
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(userEvents) { event in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(event.time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(event.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.pink.opacity(0.5).clipShape(Capsule()))
                        .accessibilityElement(children: .combine)
                        .contextMenu {
                                       Button("Remove from itinerary") {
                                           removeEvent(event)
                                       }
                                   }// Combine elements for accessibility
                    }
                }
                .padding(.vertical)
            }
        }
        .safeAreaInset(edge: .bottom){
            HStack{
                Button{
                    
                }label: {
                    
                }
            }
        }
        .onAppear(perform: loadUserEvents)
        
    }
    
    
    
    
    private func loadUserEvents() {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Fail to get user id")
            return
        }
        
        let ref = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.events)
            .document(userId)
            .collection(FirebaseConstants.events)
        
        userEvents.removeAll()
        
        ref.getDocuments { (snapshot, err) in
            
            let documents = snapshot?.documents
            
            userEvents.removeAll()
            
            for document in documents! {
                let data = document.data()
                print((data[FirebaseConstants.eventDate]) as? Date ?? "Test")
                if let title = data[FirebaseConstants.eventTitle] as? String,
                   let category = data[FirebaseConstants.eventCategory] as? String,
                   let date = Calendar.current.date(from: DateComponents()),
                   let time = data[FirebaseConstants.eventTime] as? String,
                   let location = data[FirebaseConstants.eventLocation] as? String,
                   let des = data[FirebaseConstants.eventDes] as? String,
                   let rating = data[FirebaseConstants.eventRating] as? Int {
                    print("success")
                    userEvents.append(Event(title: title, category: category, date: date, time: time, location: location, des: des, rating: rating))
                }
            }
        }
        
        //        { (snapshot, error) in
        //            if let error = error {
        //                return
        //            }
        //
        //            if let documents = snapshot?.documents {
        //                userEvents = documents.map { document -> Event? in
        //                    Event(title: document.title, location: document.location)
        //                }
        //            }
        //        }
    }
    private func removeEvent(_ event: Event) {
        guard let userId = FirebaseManager.shared.auth.currentUser?.uid else {
            print("Fail to get user id")
            return
        }

        let ref = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.events)
            .document(userId)
            .collection(FirebaseConstants.events)
            .document(event.title)

        ref.delete { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
                loadUserEvents() // Refresh the events list
            }
        }
    }

    
    
}


//extension Profile {
//    private func fetchUserEvents() -> some View{
//        let ref = FirebaseManager.shared.firestore.collection(FirebaseConstants.events).document((FirebaseManager.shared.auth.currentUser?.uid)!).collection(FirebaseConstants.events)
//
//        return body {
//
//            ref.getDocuments { snapshot, err in
//                for document in (snapshot?.documents)! {
//
//                }
//            }
//        }
//
//    }
//}




#Preview {
//    if let path = Bundle.main.path(forResource: "sample-5s", ofType: "mp4") {
//                let videoURL = URL(fileURLWithPath: path)
//        Profile(ID: "3uEbkUmS29A")
//            } else {
//                Text("Video not found")
//            }
    Profile(ID: "3uEbkUmS29A")
}
struct Video: UIViewRepresentable{
    let videoID: String
    func makeUIView(context: Context) -> some WKWebView {
        return WKWebView()
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let YouTubeURL = URL(string:"https://www.youtube.com/embed/\(videoID)")
        else {
            return
        }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: YouTubeURL))
    }
}
