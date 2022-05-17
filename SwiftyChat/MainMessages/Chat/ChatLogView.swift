//
//  ChatLogView.swift
//  SwiftyChat
//
//  Created by wizz on 5/14/22.
//

import SwiftUI
import Firebase


struct FirebaseConstants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
}

struct ChatMessage: Identifiable {
    var id: String { documentId }
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    let chatUser: ChatUser?
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        fetchMessages()
    }
    
    private func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapShot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen to for messages : \(error)"
                    print(error)
                    return
                }
                querySnapShot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        let docId = change.document.documentID
                        self.chatMessages.append(ChatMessage(documentId: docId,data: data))
                    }
                })
                
//                querySnapShot?.documents.forEach({ queryDocumentSnapshot in
//                    let data = queryDocumentSnapshot.data()
//                    let docId = queryDocumentSnapshot.documentID
//                    self.chatMessages.append(ChatMessage(documentId: docId,data: data))
//                })
            }
        
        
    }
    
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId:fromId,FirebaseConstants.toId: toId,FirebaseConstants.text:self.chatText, FirebaseConstants.timestamp:Timestamp()] as [String : Any]
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
            
            ForEach(vm.chatMessages){ message in
                VStack{
                    if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                        HStack{
                            Spacer()
                            HStack{
                                Text(message.text)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background( Color.blue)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }else {
                        HStack{
                            
                            HStack{
                                Text(message.text)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background( Color.white)
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                    
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
