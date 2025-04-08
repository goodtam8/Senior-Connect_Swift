//
//  ContentView.swift
//  Senior Connect
//
//  Created by SUN TAM on 16/11/2024.
//

import SwiftUI
import SwiftData
import SwiftUI


    struct ContentView: View {
        @AppStorage("token") var token: String?
        @AppStorage("darkMode") var darkMode: Bool = false
        @AppStorage("seeded") var seeded: Bool = false
        @Environment(\.modelContext) private var modelContext
        @Query private var items: [Item]
        var body: some View {
            TabView{
                
            MainMessagesView().tabItem {
                                   Image(systemName: "message.fill")
                                   Text("Chat")
                               }
                           
                           

                Calen().tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                IOTEzView().tabItem{
                    Image(systemName: "waveform.circle.fill")
                    Text("Ez")
                }
                EventRecommendView().tabItem{
                    Image(systemName: "exclamationmark.bubble")
                    Text("recommend")
                }
                Profile(ID: "-WwkbDfDqCY").tabItem{ Image(systemName: "command")
                                    Text("Setting")
                                }
                //                Profile(videoURL: URL(string:"https://www.youtube.com/watch?v=-suHr4i3hv0")!).tabItem{ Image(systemName: "command")
                //                    Text("Setting")
                //                }
                
            }.onAppear(perform: seedData)
            .preferredColorScheme(darkMode ? .dark : .light)
          
         
                
            }

        }

    
extension ContentView {
    
    func seedData() {
        if seeded {
            return
        }
        
        for event in Event.events {
            modelContext.insert(event)
        }
        
        seeded = true
    }
}
extension Event {
    static let events: [Event] = [
        Event(
            title: "Community Potluck",
            category: "Social",
            date: Date(), // Current date
            time: "6:00 PM",
            location: "Community Center",
            des: "Join us for a fun evening of food and friends! Bring a dish to share.",
            rating: 5,
            saved: false
        ),
        Event(
            title: "Yoga in the Park",
            category: "Health & Wellness",
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, // One week from now
            time: "8:00 AM",
            location: "Central Park",
            des: "Start your day with a refreshing outdoor yoga session.",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Book Club Meeting",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 14, to: Date())!, // Two weeks from now
            time: "3:00 PM",
            location: "Local Library",
            des: "This month's book is 'The Great Gatsby'. Join us for a lively discussion!",
            rating: 5,
            saved: false
        ),
        Event(
            title: "Art Workshop",
            category: "Creative",
            date: Calendar.current.date(byAdding: .month, value: 1, to: Date())!, // One month from now
            time: "10:00 AM",
            location: "Art Studio",
            des: "Explore your creativity in this hands-on art workshop.",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Movie Night",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "7:00 PM",
            location: "Community Hall",
            des: "Enjoy a classic movie with popcorn and friends.",
            rating: 3,
            saved: false
        ),
        // new add
        Event(
            title: "All-Star Game",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "7:00 PM",
            location: "Community Hall",
            des: "Enjoy a classic movie with popcorn and friends.",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Player Awards Ceremony",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "7:00 PM",
            location: "Community Hall",
            des: "Enjoy a classic movie with popcorn and friends.",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Home Run Derby",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "7:00 PM",
            location: "Community Hall",
            des: "Enjoy a classic movie with popcorn and friends.",
            rating: 3,
            saved: false
        ),
        Event(
            title: "World Series Game",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "7:00 PM",
            location: "Community Hall",
            des: "Enjoy a classic movie with popcorn and friends.",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Player Awards Ceremony",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "9:42:00 PM",
            location: "Wayridge",
            des: "Bypass Cecum to Cutaneous with Nonaut Sub, Endo",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Summer BBQ Bash",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "Entertainment",
            location: "Fieldstone",
            des: "Drainage of R Trunk Bursa/Lig, Perc Endo Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Tech Conference 2022",
            category: "Creative",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "9:47:00 PM",
            location: "Dahle",
            des: "Occlusion of Right Cephalic Vein, Percutaneous Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Art Gala Fundraiser",
            category: "Social",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "9:17:00 PM",
            location: "Talmadge",
            des: "Drainage of Right Ankle Region, Perc Endo Approach, Diagn",
            rating: 5,
            saved: false
        ),
        Event(
            title: "Fitness Expo",
            category: "Health & Wellness",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "11:24:00 AM",
            location: "Maywood",
            des: "Occlusion L Fallopian Tube w Extralum Dev, Open",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Food Truck Festival",
            category: "Creative",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "1:13:00 AM",
            location: "Northfield",
            des: "Extirpate of Matter from Conduction Mechanism, Perc Approach",
            rating: 1,
            saved: false
        ),
        Event(
            title: "Music in the Park",
            category: "Creative",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "11:50:00 PM",
            location: "Memorial",
            des: "Drainage of Right Acetabulum, Perc Endo Approach, Diagn",
            rating: 1,
            saved: false
        ),
        Event(
            title: "Fashion Show Extravaganza",
            category: "Creative",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "10:47:00 AM",
            location: "Crescent Oaks",
            des: "Reposition Esophagus, Percutaneous Endoscopic Approach",
            rating: 2,
            saved: false
        ),
        Event(
            title: "Wellness Retreat Weekend",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "2:05:00 AM",
            location: "Pine View",
            des: "Release Upper Esophagus, Percutaneous Approach",
            rating: 2,
            saved: false
        ),
        Event(
            title: "Craft Beer Tasting",
            category: "Health & Wellness",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "4:22:00 PM",
            location: "Anderson",
            des: "Drainage of Thoracic Duct, Open Approach",
            rating: 1,
            saved: false
        ),
        Event(
            title: "Yoga and Wine Retreat",
            category: "Health & Wellness",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "10:17:00 AM",
            location: "Anderson",
            des: "Revision of Drainage Device in Diaphragm, Endo",
            rating: 3,
            saved: false
        ),
        Event(
            title: "Virtual Reality Experience",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "11:01:00 PM",
            location: "Fisk",
            des: "Dilation of L Ext Iliac Art, Bifurc, Perc Endo Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Cooking Class Series",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "4:10:00 AM",
            location: "Havey",
            des: "Division of Left Glenoid Cavity, Percutaneous Approach",
            rating: 1,
            saved: false
        ),
        Event(
            title: "Gaming Tournament",
            category: "Entertainment",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "6:33:00 PM",
            location: "Havey",
            des: "Reattachment of Lower Tooth, Single, Open Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Book Club Meetup",
            category: "Education",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "6:40:00 PM",
            location: "Kingsford",
            des: "Insertion of Radioactive Element into R Elbow, Open Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Dance Party Under the Stars",
            category: "Health & Wellness",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "4:23:00 AM",
            location: "Petterle",
            des: "Fusion of Right Tarsal Joint with Synth Sub, Perc Approach",
            rating: 4,
            saved: false
        ),
        Event(
            title: "Farmers Market Festival",
            category: "Social",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "12:51:00 PM",
            location: "Arizona",
            des: "Removal of Nonaut Sub from L Ulna, Perc Endo Approach",
            rating: 2,
            saved: false
        ),
        Event(
            title: "DIY Workshop",
            category: "Creative",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "10:07 PM",
            location: "Rutledge",
            des: "MRI of L Toe using Oth Contrast, Unenh, Enhance",
            rating: 5,
            saved: false
        ),
        Event(
            title: "Puppy Adoption Fair",
            category: "Social",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "10:19:00 PM",
            location: "Waubesa",
            des: "Introduction of Oth Anti-infect into Eye, Extern Approach",
            rating: 5,
            saved: false
        ),
        Event(
            title: "Puppy Adoption Fair",
            category: "Social",
            date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, // Three weeks from now
            time: "10:19:00 PM",
            location: "Waubesa",
            des: "Introduction of Oth Anti-infect into Eye, Extern Approach",
            rating: 5,
            saved: false
        ),
    ]
}
   

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
