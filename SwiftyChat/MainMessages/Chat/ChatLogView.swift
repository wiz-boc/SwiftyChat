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
                DispatchQueue.main.async {
                    self.count += 1
                }
                
                
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
            
            self.persistRecentMessage()
            self.chatText = ""
            self.count += 1
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
    
    private func persistRecentMessage(){
        guard let chatUser = chatUser else { return }

        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text:self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageURL,
            FirebaseConstants.email: chatUser.email
            
        ] as [String: Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent messages: \(error)"
                print(self.errorMessage)
                return
            }
        }
    }
    
    @Published var count = 0
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
    static let emptyScrollToString = "Empty"
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                
                VStack {
                    ForEach(vm.chatMessages){ message in
                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
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


struct MessageView: View {
    let message: ChatMessage
    var body: some View {
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
    }
    
}
struct ChatLogView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: ChatUser(data: ["uid":"aUKtlAEPH9VYn8YkucKtF60Qkqd2","email":"test10@email.con","profileImageUrl":"https://firebasestorage.googleapis.com:443/v0/b/swifty-chat-b2522.appspot.com/o/aUKtlAEPH9VYn8YkucKtF60Qkqd2?alt=media&token=d3fb135b-73b7-41cd-b212-cd1fcae4cc80"]))
        }
    }
}
