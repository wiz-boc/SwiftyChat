//
//  ChatLogView.swift
//  SwiftyChat
//
//  Created by wizz on 5/14/22.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    let chatUser: ChatUser?
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId":fromId,"toId": toId,"text":self.chatText, "timestamp":Timestamp()] as [String : Any]
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore \(error)"
                print(self.errorMessage)
            }
            self.chatText = ""
        }
        
        
        let recipientDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore \(error)"
                print(self.errorMessage)
            }
            print("Recipient send message")
        }
    }
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        vm = ChatLogViewModel(chatUser: chatUser)
    }
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        ZStack{
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack{
                    Spacer()
                    HStack{
                        Text("Fake chat message")
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                HStack { Spacer() }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("Description", text: $vm.chatText)
            Button{
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical,8)
            .background(Color.blue)
            .cornerRadius(4)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ChatLogView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: ChatUser(data: ["uid":"aUKtlAEPH9VYn8YkucKtF60Qkqd2","email":"test10@email.con","profileImageUrl":"https://firebasestorage.googleapis.com:443/v0/b/swifty-chat-b2522.appspot.com/o/aUKtlAEPH9VYn8YkucKtF60Qkqd2?alt=media&token=d3fb135b-73b7-41cd-b212-cd1fcae4cc80"]))
        }
    }
}
