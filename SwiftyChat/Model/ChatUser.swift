//
//  ChatUser.swift
//  SwiftyChat
//
//  Created by wizz on 5/14/22.
//

import Foundation

struct ChatUser: Identifiable {
    
    var id: String { uid }
    let uid, email, profileImageURL: String
    init(data: [String: Any]) {
        uid = data["uid"] as? String ?? ""
        email = data["email"] as? String ?? ""
        profileImageURL = data["profileImageUrl"] as? String ?? ""
    }
}
