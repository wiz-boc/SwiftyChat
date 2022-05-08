//
//  LoginView.swift
//  SwiftyChat
//
//  Created by wizz on 5/7/22.
//

import SwiftUI

struct LoginView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
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
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
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
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" :"Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
    }
    
    private func handleAction(){
        if isLoginMode {
            print("Should log into Firebase with existing credentials")
        } else {
            print("Should create new account in Firebase ")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
