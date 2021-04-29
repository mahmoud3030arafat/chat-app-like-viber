
import Foundation

func startPrivateChat(user1:FUser,user2:FUser)->String{
    
    let userId1=user1.objectId
    let userId2=user2.objectId
    var ChatRoomId=""
    let value = userId1.compare(userId2).rawValue
    
    if value < 0{
        
        ChatRoomId=userId1+userId2
        
    }else{
        
        ChatRoomId=userId2+userId1
        
        }
    
    let members=[userId1,userId1]
    createRecent(members: members, chatRoomId: ChatRoomId, withUserUserName: "", type: kPRIVATE, users: [user1,user2], avatarOfGroup: nil)
    
    
    return ChatRoomId
}



func createRecent(members:[String],chatRoomId:String,withUserUserName:String,type:String,users:[FUser]?,avatarOfGroup:String?){
      var tempMembers = members
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snaphot, error) in
        guard let snapshot = snaphot else{ return}
        
        if !snaphot!.isEmpty{
            for recent in snaphot!.documents{
                
                let   currentRecent = recent.data() as NSDictionary
                    
                    if let currentUserId = currentRecent[kUSERID]{
                        if tempMembers.contains(currentUserId as! String){
                            
                            tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                        }
                    }
                    
                }
                
            }
        for userId  in tempMembers{
            
            // create recent items
           
            createRecentItems(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserName: withUserUserName, type: type, users: users, avatarOfGroub: avatarOfGroup)
            
        }
    }
}



func createRecentItems(userId:String,chatRoomId:String,members:[String],withUserUserName:String,type:String,users:[FUser]?,avatarOfGroub:String?) {
  
    
    let localReference = reference(.Recent).document()
    let recentId = localReference.documentID

    let date = dateFormatter().string(from: Date())
    
    var   recent:[String:Any]!
    if type==kPRIVATE{
        //private
        
        var withUser:FUser?
        
        if users != nil && users!.count > 0{
            if userId == FUser.currentId(){
                //for current user
                withUser=users!.last!
            }else{
               withUser=users!.first!
            }
        }
        
        recent = [kRECENTID:recentId,kUSERID:userId,kCHATROOMID:chatRoomId,kMEMBERS:members,kMEMBERSTOPUSH:members,kWITHUSERFULLNAME:withUser!.fullname,kWITHUSERUSERID:withUser!.objectId,kLASTMESSAGE:"",kCOUNTER:0,kDATE:date,kTYPE:type,kAVATAR:withUser!.avatar] as [String:Any]
    }else {
        
        // group
        if avatarOfGroub != nil {
            recent = [kRECENTID:recentId,kUSERID:userId,kCHATROOMID:chatRoomId,kMEMBERS:members,kMEMBERSTOPUSH:members,kWITHUSERFULLNAME:withUserUserName,kLASTMESSAGE:"",kCOUNTER:0,kDATE:date,kTYPE:type ,kAVATAR : avatarOfGroub!] as [String:Any]
            
        }

    }
    localReference.setData(recent)
}
// restar chat

func restartRecentChat(recent:NSDictionary){
    if recent[kTYPE]as!String==kPRIVATE{
        
        createRecent(members: recent[kMEMBERSTOPUSH] as! [String], chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: FUser.currentUser()!.firstname, type: kPRIVATE, users: [FUser.currentUser()!], avatarOfGroup: nil)
       
        
    }
    
    if recent[kTYPE]as!String==kGROUP{
        
        createRecent(members:recent[kMEMBERSTOPUSH] as! [String] , chatRoomId: recent[kCHATROOMID] as! String, withUserUserName: recent[kWITHUSERUSERID] as! String, type: kGROUP, users: nil, avatarOfGroup: recent[kAVATAR] as? String)
        print("group")
        
    }
    
    
}

 
func deleteRecentChat(recentChatDictionary:NSDictionary){
    
    if let recentId=recentChatDictionary[kRECENTID]{
        
        reference(.Recent).document(recentId as! String).delete()
    }
    
}
