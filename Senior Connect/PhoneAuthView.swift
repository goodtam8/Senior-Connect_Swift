import SwiftUICore
import SwiftUI
struct PhoneAuthView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var phoneNumber: String = ""
    
    var body: some View {
        VStack {
            TextField("Phone Number", text: $phoneNumber)
                .keyboardType(.phonePad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Verify Phone Number") {
                viewModel.verifyPhoneNumber(phoneNumber)
            }
            .padding()
            
            if viewModel.isShowingVerificationCode {
                TextField("Verification Code", text: $viewModel.verificationCode)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Submit Code") {
                    Task {
                        await viewModel.signInWithVerificationCode(verificationCode: viewModel.verificationCode)
                    }
                }
                .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}
#Preview {
    PhoneAuthView()
}
