//
//  CreateNewMessageView.swift
//  SwiftyChat
//
//  Created by wizz on 5/14/22.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init() {
        fetchAllUsers()
    }
    
    func fetchAllUsers(){
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch users: \(error)"
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let user = ChatUser(data: snapshot.data())
                if user.uid !=  FirebaseManager.shared.auth.currentUser?.uid {
                    self.users.append(user)
                }
            })
            self.errorMessage = "Fetch users successfully"
        }
    }
}

struct CreateNewMessageView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationView{
            ScrollView{
                Text(vm.errorMessage)
                ForEach(vm.users){ user in
                    HStack{
                        WebImage(url: URL(string: user.profileImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50, alignment: .center)
                            .clipped()
                            .cornerRadius(50)
                            .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label),lineWidth: 1))
                    Text(user.email)
                        Spacer()
                    }
                    .padding(.horizontal)
                    Divider()
                        .padding(.vertical,8)
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button{
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView()
    }
}
