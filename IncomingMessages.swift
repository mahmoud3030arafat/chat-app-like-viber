//
//
//import Foundation
//import JSQMessagesViewController
//
//class IncomingMessage {
//
//    var collectionView:JSQMessagesViewController
//
//    init(collectionView_:JSQMessagesViewController) {
//
//        collectionView=collectionView_
//    }
//
//    //MAHMOUD:-create message
//    func createMessage(messageDictionary:NSDictionary,chatRoomId:String)->JSQMessage?{
//
//        var message:JSQMessage?
//        let type=messageDictionary[kTYPE] as! String
//
//        switch type {
//        case kTEXT:
//         message =    createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
//        case kPICTURE:
//            print("picture message")
//        case kVIDEO:
//            print("video message")
//        case kAUDIO:
//            print("audio message")
//        case kLOCATION:
//            print("location message")
//        default:
//            print("unkown message type")
//        }
//
//        if message != nil{
//            return message
//        }
//        return nil
//
//
//    }
//    //MAHMOUD:-create text message
//
//          func createTextMessage(messageDictionary:NSDictionary,chatRoomId:String)->JSQMessage{
//              let name = messageDictionary[kSENDERNAME] as? String
//              let userId = messageDictionary[kSENDERID] as? String
//              var date:Date!
//              if let created=messageDictionary[kDATE]{
//                  if (created as! String).count != 14{
//                      date=Date()
//
//                  }else{
//
//                      date=dateFormatter().date(from: created as! String)
//                  }
//
//              }else{
//
//                  date=Date()
//
//              }
//              let text = messageDictionary[kMESSAGE] as! String
//
//
//              return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
//          }
//
//
//
//}

import Foundation
import JSQMessagesViewController


class IncomingMessage{
    var collectionView:JSQMessagesCollectionView
    init(collectionView_:JSQMessagesCollectionView) {
        collectionView=collectionView_

    }
    //MAHMOUD:-create message

    func createMessage(messageDictionary:NSDictionary,chatRoomId:String)->JSQMessage?{

        var message: JSQMessage?
        let type = messageDictionary[kTYPE] as! String

        switch type {
        case kTEXT:
         message=createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
          case kPICTURE:
            print("picture")
        case kVIDEO:
            print("video")
        case kAUDIO:
            print("audio")
        default:
            print("Unknown Message")
        }

        if message != nil{
            return message
        }else{
            return nil
        }

    }
    //MAHMOUD:-create message tupe
    func createTextMessage(messageDictionary:NSDictionary,chatRoomId:String)->JSQMessage{
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        let date:Date!
        if let created = messageDictionary[kDATE] as? String{

            if (created as! String).count != 14 {
                date=Date()
            }else{
                date=dateFormatter().date(from: created as! String)

            }
        }else{
            date=Date()
        }
        let text = messageDictionary[kMESSAGE] as! String

        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }




}

