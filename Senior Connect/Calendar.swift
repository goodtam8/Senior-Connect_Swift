//
//  Calendar.swift
//  Senior Connect
//
//  Created by SUN TAM on 19/11/2024.
//

import SwiftUI

struct Calen: View {
    @State var currentDate:Date=Date()
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            VStack(spacing:20){
                DatePicker(currentDate: $currentDate)
            }.padding(.vertical)
        }
        .safeAreaInset(edge: .bottom){
            HStack{
                Button{
                    
                }label: {
                
                }
            }
        }
    }
}

#Preview {
    Calen()
}
