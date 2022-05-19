//
//  RecentMessage.swift
//  SwiftyChat
//
//  Created by wizz on 5/20/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


struct RecentMessages: Codable, Identifiable {
    @DocumentID var id: String?
    //let documentId: String
    let text, fromId, toId,email,profileImageUrl: String
    let timestamp: Date
    
//    init(documentId: String, data: [String: Any]){
//        self.documentId = documentId
//        self.text = data[FirebaseConstants.text] as? String ?? ""
//        //self.timestamp = data[FirebaseConstants.timestamp] as? Timestamp  ?? Timestamp(date: Date())
//        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
//        self.toId = data[FirebaseConstants.toId] as? String ?? ""
//        self.email = data[FirebaseConstants.email] as? String ?? ""
//        self.profileImageURL = data[FirebaseConstants.profileImageUrl] as? String ?? ""
//    }
}
