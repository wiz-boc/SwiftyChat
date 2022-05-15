//
//  ChatLogView.swift
//  SwiftyChat
//
//  Created by wizz on 5/14/22.
//

import SwiftUI


struct ChatLogView: View {
    
    let chatUser: ChatUser?
    @State var chatText = ""
    
    var body: some View {
        ZStack{
            messagesView
            VStack{
                Spacer()
                chatBottomBar
                    .background(Color.white)
            }
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
        .padding(.bottom, 65)
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16){
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            TextField("Description", text: $chatText)
            Button{
                
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
