//
//  ContentView.swift
//  SwfitUIFirebaseChat
//
//  Created by RJ Hrabowskie on 5/1/23.
//
import FBSDKLoginKit
import FBSDKCoreKit
import SwiftUI
import Foundation
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import _AuthenticationServices_SwiftUI
import FirebaseFirestore
struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Picker here", selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color(.label), lineWidth: 3))
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemBackground))
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .frame(width: 350, height: 44) // Set fixed width and height
                        .background(Color.blue)
                        .cornerRadius(5) // Rounded corners
                    }
                    
                    if isLoginMode {
                        GoogleSignInButton {
                            Task {
                                await signInWithGoogle()
                            }
                        }
                        .frame(width: 350)
                        
                        SignInWithAppleButton(.signIn) { request in
                        } onCompletion: { result in
                        }
                        .frame(width: 350)
                        
                        Button(action: {
                            Task {
                                await loginWithFacebook()
                            }
                        }) {
                            HStack {
                                Image("facebooklogo") // Ensure you have a Facebook logo image in your assets
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjust size as needed
                                
                                Text("Sign in")
                                    .font(.headline)
                                    .foregroundColor(.white) // Text color
                                    .padding(.leading) // Adjust padding as needed
                            }
                            .frame(width: 350, height: 44) // Match the size of other buttons
                            .background(Color.blue) // Facebook's primary color
                            .cornerRadius(5) // Rounded corners
                        }
                        .padding()
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
                .ignoresSafeArea()
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        }
    }
    private func loginWithFacebook() async {
        let manager = LoginManager()
        manager.logOut()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        do {
            let result: LoginManagerLoginResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LoginManagerLoginResult, Error>) in
                manager.logIn(permissions: ["public_profile", "email"], from: rootViewController) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let result = result, !result.isCancelled else {
                        continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login cancelled"]))
                        return
                    }
                    
                    continuation.resume(returning: result)
                }
            }
            
            guard let accessToken = AccessToken.current else {
                print("Access token missing")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            try await FirebaseManager.shared.auth.signIn(with: credential) { result, err in
                if let err = err {
                    print("Failed to login user:", err)
                    self.loginStatusMessage = "Failed to login user: \(err)"
                    return
                }
                
                Firestore.firestore().collection(FirebaseConstants.users).document((result?.user.uid)!).getDocument { (document, error) in
                    if let document = document {
                        if !document.exists {
                            if let photoURL = result?.user.photoURL,
                               let email = result?.user.email {
                                storeUserInformation(imageProfileUrl: photoURL, email: email)
                            }
                        }
                    }
                }
                
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
                self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
                self.didCompleteLoginProcess()
            }
            
        } catch {
            print("Failed to login:", error)
            self.loginStatusMessage = "Failed to login: \(error)"
            return
        }
    }
    //    func fetchFacebookProfileImage() {
    //        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
    //        graphRequest.start { _, result, error in
    //            if let error = error {
    //                DispatchQueue.main.async {
    //                }
    //                return
    //            }
    //
    //            if let result = result as? [String: Any],
    //               let picture = result["picture"] as? [String: Any],
    //               let data = picture["data"] as? [String: Any],
    //               let url = data["url"] as? String {
    //                DispatchQueue.main.async {
    //                    self.profileImageURL = URL(string: url)
    //                }
    //            }
    //        }
    //    }
    
    
    private func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("There is no root view controller!")
            return
        }
        
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                print("ID token missing")
                return
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)
            
            try await FirebaseManager.shared.auth.signIn(with: credential) { result, err in
                if let err = err {
                    print("Failed to login user:", err)
                    self.loginStatusMessage = "Failed to login user: \(err)"
                    return
                }
                
                Firestore.firestore().collection(FirebaseConstants.users).document((result?.user.uid)!).getDocument { (document, error) in
                    if let document = document {
                        if !document.exists{
                            storeUserInformation(imageProfileUrl: (result?.user.photoURL)!, email: (result?.user.displayName)!+"@gmail.com")
                        }
                    }
                }
                
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
                
                self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
                
                self.didCompleteLoginProcess()
            }
        } catch {
            print("Fail to login")
            return
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString ?? "")
                
                guard let url = url else { return }
                storeUserInformation(imageProfileUrl: url, email: self.email)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL, email: String) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.email: email, FirebaseConstants.uid: uid, FirebaseConstants.profileImageUrl: imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success")
                
                self.didCompleteLoginProcess()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView {
            
        }
    }
}
