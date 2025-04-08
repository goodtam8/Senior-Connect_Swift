import SwiftUI
import SwiftData

struct DatePicker: View {
    @State var currentMonth: Int = 0
    @Binding var currentDate: Date
    @Query private var events: [Event]

    var body: some View {
        VStack(spacing: 35) {
            let days: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                Spacer(minLength: 0)
                Button {
                    withAnimation {
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                Button {
                    withAnimation {
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
            }.padding(.horizontal)
            
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(extractdate()) { value in
                    CardView(value: value)
                        .onTapGesture {
                            currentDate = value.date
                        }
                }
            }
            
            VStack(spacing: 20) {
                Text("Events")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)
                
                if let task = events.first(where: { task in return isSameDay(date1: task.date, date2: currentDate) }) {
                    ForEach(events) { task in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(task.time)
                            Text(task.title)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.pink.opacity(0.5).clipShape(Capsule()))
                        .contextMenu {
                            // Check only the user has logged in so they can join the event
                            Button("Add to itinerary") {
                                let eventData = [FirebaseConstants.eventTitle: task.title, FirebaseConstants.eventCategory: task.category, FirebaseConstants.eventDate: task.date, FirebaseConstants.eventTime: task.time, FirebaseConstants.eventLocation: task.location, FirebaseConstants.eventDes: task.des, FirebaseConstants.eventRating: task.rating]
                                FirebaseManager.shared.firestore.collection(FirebaseConstants.events)
                                    .document((FirebaseManager.shared.auth.currentUser?.uid)!).collection(FirebaseConstants.events).document(task.title).setData(eventData) { err in
                                        if let err = err {
                                            print(err)
                                            return
                                        }
                                        
                                        print("Success")
                                    }
                            }
                        }
                        .font(.title2.bold())
                    }
                } else {
                    Text("No Event found")
                }
            }.padding()
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
    
    func extractdate() -> [DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(date: date, day: day)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(date: Date(), day: -1), at: 0)
        }
        
        return days
    }
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        let date = formatter.string(from: currentDate)
        return date.components(separatedBy: " ")
    }
    
    func isCurrentMonth(date: Date) -> Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: getCurrentMonth())
        let currentYear = calendar.component(.year, from: getCurrentMonth())
        
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return month == currentMonth && year == currentYear
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack {
            if value.day != -1 {
                if let event = events.first(where: { event in
                    return isSameDay(date1: event.date, date2: value.date)
                }) {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                    Spacer()
                    Circle()
                        .fill(isSameDay(date1: event.date, date2: value.date) ? .white : .pink)
                        .frame(width: 8, height: 8)
                } else {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .padding(.vertical, 9)
        .frame(height: 60, alignment: .top)
        .background(
            Capsule()
                .fill(isCurrentMonth(date: value.date) && isSameDay(date1: value.date, date2: currentDate) ? .pink : .clear)
                .padding(.horizontal, 8)
        )
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self)) else {
            return []
        }
        
        guard let range = calendar.range(of: .day, in: .month, for: self) else {
            return []
        }
        
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}



#Preview {
    Calen()
}
