//
//  Message.swift
//  InstagramCopy
//
//  Created by Stephan Dowless on 3/28/18.
//  Copyright © 2018 Stephan Dowless. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var videoUrl: String?
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let imageHeight = dictionary["imageHeight"] as? NSNumber {
            self.imageHeight = imageHeight
        }
        
        if let imageWidth = dictionary["imageWidth"] as? NSNumber {
            self.imageWidth = imageWidth
        }
        
        if let videoUrl = dictionary["videoUrl"] as? String {
            self.videoUrl = videoUrl
        }
    }
    
    func getChatPartnerId() -> String {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return ""}
        
        if fromId == currentUid {
            return toId
        } else {
            return fromId
        }
    }
}
