

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    
    var chatRoomId : String?
    var memberIds : [String]!
    var memberToPush : [String]!
    var titleName : String!
    
    let legitTypes = [kVIDEO,kAUDIO,kTEXT,kLOCATION,kPICTURE]
     var maxMessagesNumber = 0
    var minMessagesNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    var messages : [JSQMessage] = []
    var objectMessages : [NSDictionary]=[]
    var loadedMessages : [NSDictionary]=[]
    var allPictureMessages:[String]=[]
    var intialLoadCompelte = false
    
    
    var typingListener : ListenerRegistration?
    var updatedChatListener : ListenerRegistration?
    var newChatListener : ListenerRegistration?



    
    
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    // jsq_updateCollectionViewInsets
   
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems=[UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        collectionView.collectionViewLayout.incomingAvatarViewSize=CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize=CGSize.zero
        
         
        loadMessages()
        
        // The string identifier that uniquely identifies the current user sending messages.
        
        self.senderId=FUser.currentId()
        // The display name of the current user who is sending messages.
        self.senderDisplayName=FUser.currentUser()!.firstname
        // toolbarBottomLayoutGuide
          
        
        let constrain =  perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constrain.priority=UILayoutPriority(rawValue: 1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive=true
        
        print(Selector(("toolbarBottomLayoutGuide")))
       // custom send button 
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
   
        
        

    }
    
    //MAHMOUD:-data source functions
    

    
    //MAHMOUD:-jsqmessages delegate function
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        // set color
        if data.senderId==FUser.currentId(){
            cell.textView?.textColor = .white
        }else{
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data=messages[indexPath.row]
        if data.senderId==FUser.currentId(){
            return outgoingBubble
        }else{
            return incomingBubble
        }
    }
    // time
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            return JSQMessagesTimestampFormatter().attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = objectMessages[indexPath.row]
        let status : NSAttributedString!
        let  attributedStringColor = [NSAttributedString.Key.foregroundColor:UIColor.darkGray]
        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status=NSAttributedString(string: kDELIVERED)
        case kREAD:
            let ststusText = "Read"+" "+readTimeFrom(dataString: message[kREADDATE]as!String)
            status=NSAttributedString(string: ststusText, attributes: attributedStringColor)
       
        default:
            status=NSAttributedString(string: "*")
        }
        if indexPath.row == messages.count-1{
            print("yes00000000")
            return status
        }else{
         return NSAttributedString(string: "")
        }

    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        let data = messages[indexPath.row]
             
        if data.senderId==FUser.currentId(){
           return kJSQMessagesCollectionViewCellLabelHeightDefault
        }else{
        return 0.0
        }
    }
    
    
    
    // delegtes func
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
             print("Camera")
         }
         let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                   print("Photo Library")
               }
         
        
         let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
                   print("Video Library")
               }
         
               let shareLocation = UIAlertAction(title: "Location Library", style: .default) { (action) in
                         print("Share Location")
                     }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
             
         }
         takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
         sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
         shareVideo.setValue(UIImage(named: "video"), forKey: "image")
         shareLocation.setValue(UIImage(named: "location"), forKey: "image")
         optionMenu.addAction(takePhotoOrVideo)
         optionMenu.addAction(sharePhoto)
         optionMenu.addAction(shareVideo)
         optionMenu.addAction(shareLocation)
         optionMenu.addAction(cancelAction)

         self.present(optionMenu, animated: true, completion: nil)

    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
       if text != "" {
        sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
           
            updateSendButton(isSend: false)
       }else{
           
       }

    }
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.loadMoreMessages(maxNmber: maxMessagesNumber, minNumber: minMessagesNumber)
        self.collectionView.reloadData()
    }
    
    //MAHMOUD:-send messages
     func sendMessage(text:String?,date:Date,picture:UIImage?,location:String?,video:NSURL?,audio:String?){
        
        
        var outgoingMessage : OutgoingMessage?
        let currentUser = FUser.currentUser()!
        // text message
        if let text = text {
            
            
            
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
            
        }
        
        // cleaning searching 
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        
        outgoingMessage!.sendMessage(chatRoomId: chatRoomId!, messageDictionary: (outgoingMessage?.messagesDictionary)!, memberIds: memberIds, membersToPush: memberToPush)
         
         
     }
    
    //MAHMOUD:-load messages
    
    func loadMessages(){
        // get last 11 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomId!).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot=snapshot else{
                // intial loading is done
                self.intialLoadCompelte=true
                // listen for new chats
                return
            }
            
            let sorted=((dictionaryFromSnapshots(snapshots: snapshot.documents))as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            self.loadedMessages =       self.removeBadMessages(allMessages: sorted)
            // insert messages
            self.insertMessage()
            self.finishReceivingMessage(animated: true)
            self.intialLoadCompelte=true
            print( self.messages.count)
            // get picture messages
            // get old messages in background
            // start listsing for new chats
            self.getOldMessagesInBackground()
            self.listenForNewChats()
        
    }
    }
    
    
    //
    
    
    
    func listenForNewChats(){
        
        
        var lastMessageDate = "0"
        if loadedMessages.count>0{
            lastMessageDate=loadedMessages.last![kDATE]as!String
        }
        newChatListener=reference(.Message).document(FUser.currentId()).collection(chatRoomId!).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty{
                
                for diff in snapshot.documentChanges{
                    if (diff.type == .added){
                        let item = diff.document.data() as! NSDictionary
                        if let type = item[kTYPE]{
                            if self.legitTypes.contains(type as! String){
                                
                                /// this picture add
                                if type as! String == kPICTURE{
                                    
                                }
                                
                                if self.insertIntialLoadMessage(messageDictionary: item){
                                    
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                }
                                self.finishReceivingMessage()
                                
                                
                            }
                            
                        }
                    }
                }
            }
            
            
        })
        
    }

    func getOldMessagesInBackground(){
        
        if loadedMessages.count>10{
            let firstMessageData = loadedMessages.first![kDATE]as!String
            reference(.Message).document(FUser.currentId()).collection(chatRoomId!).whereField(kDATE, isLessThan: firstMessageData).getDocuments { (snapshot, error) in
                guard let sanpshot  = snapshot else{return}
                let sorted=((dictionaryFromSnapshots(snapshots: snapshot!.documents))as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
               // self.removeBadMessages(allMessages: sorted)
                self.loadedMessages=self.removeBadMessages(allMessages: sorted)+self.loadedMessages
                // get picture
                self.maxMessagesNumber=self.loadedMessages.count-self.loadedMessagesCount-1
                self.minMessagesNumber=self.maxMessagesNumber-kNUMBEROFMESSAGES
            }
            
        }
    }
    
    
    //MAHMOUD:-insert message
    
    func insertMessage(){
        maxMessagesNumber=loadedMessages.count-loadedMessagesCount
        minMessagesNumber=maxMessagesNumber-kNUMBEROFMESSAGES
        if minMessagesNumber<0{
            minMessagesNumber=0
            
        }
        
        for i in  minMessagesNumber..<maxMessagesNumber{
            
            let messageDictionary = loadedMessages[i]
            // insert message
            insertIntialLoadMessage(messageDictionary: messageDictionary)
            loadedMessagesCount+=1
            
        }
        self.showLoadEarlierMessagesHeader=(loadedMessagesCount != loadedMessages.count)
        
        
    }
  
    
       func insertIntialLoadMessage(messageDictionary:NSDictionary) -> Bool {
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            // update message status
        }
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId!)
        if message != nil{
            objectMessages.append(messageDictionary)
            messages.append(message!)
        }
        return isIncoming(messageDictionary: messageDictionary)
    }

        
            
            // remove bad messages
            
            func removeBadMessages(allMessages:[NSDictionary])->[NSDictionary]{
                
                var tempMessages=allMessages
                for message in tempMessages{
                    if message [kTYPE] != nil{
                    if !self.legitTypes.contains(message[kTYPE]as!String){
                        // remove
                        tempMessages.remove(at: tempMessages.firstIndex(of:message)!)
                        print("remove1")
                    }
                    
                    }else{
                        tempMessages.remove(at: tempMessages.firstIndex(of:message)!)
                        print("remove 2")
                    }
                }
                print(tempMessages)
                return tempMessages
                
            }
            
            
    //MAHMOUD:- load more
    func loadMoreMessages(maxNmber:Int,minNumber:Int){
        
        if loadOld{
            
            maxMessagesNumber=minNumber-1
            minMessagesNumber=maxMessagesNumber-kNUMBEROFMESSAGES
            
        }
        if minMessagesNumber<0{
            minMessagesNumber=0
        }
        for i in (minMessagesNumber...maxMessagesNumber).reversed(){
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount+=1
        }
        loadOld=true
        self.showLoadEarlierMessagesHeader=(loadedMessagesCount != loadedMessages.count)
        
        
    }
    
    
    func insertNewMessage(messageDictionary:NSDictionary){
        let incomingMessage=IncomingMessage(collectionView_: self.collectionView!)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId!)
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }

    
    
    
    
    
    //MAHMOUD:- IBAction

    @objc func backAction(){
        
        self.navigationController?.popViewController(animated: true)
        // mahmoud 
        
    }
    
    override func textViewDidChange(_ textView: UITextView) {
           if textView.text != "" {
               updateSendButton(isSend: true)
           }else{
               updateSendButton(isSend: false)
           }
       }
       
       func updateSendButton(isSend:Bool){
           if isSend {
               self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
           }else{
               self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
           }
       }
    
    
    //MAHMOUD:-helper func
    
    func  isIncoming(messageDictionary:NSDictionary)->Bool{
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        }else{
            return true
       
        }
        
        
       
        
    }
    
    func readTimeFrom(dataString:String)->String{
               
        let date = dateFormatter().date(from: dataString)
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat="HH:mm"
        return currentDateFormat.string(from:date!)
        
               
               
           }
   

}
