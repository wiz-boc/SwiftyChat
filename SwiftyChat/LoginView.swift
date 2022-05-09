//
//  LoginView.swift
//  SwiftyChat
//
//  Created by wizz on 5/7/22.
//

import SwiftUI
import Firebase
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    static let shared = FirebaseManager()
    override init(){
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        super.init()
    }
}

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    @State private var showShowImagePicker = false
    
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 16){
                    Picker(selection: $isLoginMode) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                        
                    } label: {
                        Text("Picker here")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            showShowImagePicker.toggle()
                        } label: {
                            VStack{
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 120, height: 120)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                }else {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color(.label))
                                        .font(.system(size: 64))
                                        .padding()
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(.black, lineWidth: 3))
                                
                        }
                    }
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                        
                    }
                    .autocapitalization(.none)
                    .padding(12)
                    .background(.white)
                    
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            
                        }
                        .background(Color.blue)
                    }
                    
                    Text(loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" :"Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showShowImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    private func handleAction(){
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password){ result, error in
            if let err = error {
                print("Failed to login user: \(err)")
                loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Succesfully logged in user: \(result?.user.uid ?? "")")
            loginStatusMessage = "Succesfully logged in user: \(result?.user.uid ?? "")"
        }
    }
    
    private func createNewAccount(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password){ result, error in
            if let err = error {
                print("Failed to create user: \(err)")
                loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Succesfully created user: \(result?.user.uid ?? "")")
            loginStatusMessage = "Succesfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()
        }
    }
    private func persistImageToStorage(){
        
        //let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to psuh image to Storage: \(err)"
                
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "failed to retrieved downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
