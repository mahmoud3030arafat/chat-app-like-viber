
import UIKit

class ProfileViewTableViewController: UITableViewController {
    
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var phoneNumperLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var callButtonOutlet: UIButton!
    
    @IBOutlet weak var chatButtonOutlet: UIButton!
    var user : FUser?
    
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
   setUp()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
        
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
   
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    //
    func setUp(){
        
        
        if user != nil{
            
            fullNameLabel.text=user?.fullname
            phoneNumperLabel.text=user?.phoneNumber
            updateBlockstatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil{
                    
                    avatarImageView.image=avatarImage?.circleMasked
                }
            }
            
        }
        
        
    }
    
    //MAHMOUD:-IBAction
    

    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId){
            
            currentBlockedIds.remove(at: currentBlockedIds.index(of:user!.objectId)!)
            
        }else{
            
            currentBlockedIds.append(user!.objectId)
            
            
            
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:currentBlockedIds]) { (error) in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            self.updateBlockstatus()
        }
        
        
    }

    //MAHMOUD:-helper function
    func updateBlockstatus(){
        
        if user!.objectId != FUser.currentId(){
            blockButtonOutlet.isHidden = false
             callButtonOutlet.isHidden = false
             chatButtonOutlet.isHidden = false
        
            
        }else{
            blockButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
            chatButtonOutlet.isHidden = true
            
        }
        
        
        if (FUser.currentUser()?.blockedUsers.contains(user!.objectId))!{
            
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
            
        }else{
            
            blockButtonOutlet.setTitle("Block User", for: .normal)
            
        }
        
    }


}
