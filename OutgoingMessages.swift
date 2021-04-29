//
//  OutgoingMessages.swift
//  CHAT
//
//  Created by Mahmoud on 4/25/21.
//  Copyright © 2021 mahmoud. All rights reserved.
//

import Foundation
class OutgoingMessage {
    
    let messagesDictionary : NSMutableDictionary?
    // init()
    init(message:String,senderId:String,senderName:String,date:Date,status:String,type:String) {
        
        messagesDictionary=NSMutableDictionary(objects: [message,senderId,senderName,dateFormatter().string(from: date),status,type], forKeys: [kMESSAGE as NSCopying,kSENDERID as NSCopying,kSENDERNAME as NSCopying,kDATE as NSCopying,kSTATUS as NSCopying ,kTYPE as NSCopying])
        
        
        
    }
    
    
    //MAHMOUD:-sending messages
    func sendMessage(chatRoomId : String,messageDictionary:NSMutableDictionary,memberIds:[String],membersToPush:[String] ){
        
        
        let  messageId=UUID().uuidString
        messageDictionary[kMESSAGEID]=messageId
        for memberId in memberIds{
            
            reference(.Message).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary as! [String:Any])
            
        }
        
        // update recent chat
        
        // send push notification
    }
    
    

    
}
