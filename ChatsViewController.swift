

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,RecentChatsTableViewCellDelegate,UISearchResultsUpdating {
  
    var recentChats : [NSDictionary]=[]
    var filteredChats : [NSDictionary]=[]
    var recentListener : ListenerRegistration!
       let searchController = UISearchController(searchResultsController: nil)


    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.delegate=self
        tableView.dataSource=self
        setTableViewHeader()
        
        navigationItem.searchController=searchController
        navigationItem.hidesSearchBarWhenScrolling=true
        searchController.searchResultsUpdater=self
        searchController.dimsBackgroundDuringPresentation=false
        definesPresentationContext=true

    }
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        tableView.tableFooterView=UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    

    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "UsersTableViewController") as! UsersTableViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return filteredChats.count
            
        }else{
            
               return recentChats.count
        }
     
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentChats", for: indexPath) as! RecentChatsTableViewCell
        var  recent :NSDictionary!
        cell.delegate=self
        if searchController.isActive && searchController.searchBar.text != ""{
            recent = filteredChats[indexPath.row]
             }else{
                  recent = recentChats[indexPath.row]
                    
             }
           
        cell.generateCell(recentChat: recent, indexpath: indexPath)
        return cell
    }
    
    //MAHMOUD:-tableViewDelegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
            
      var tempRecent :NSDictionary!
      if searchController.isActive && searchController.searchBar.text != ""{
          tempRecent=filteredChats[indexPath.row]
      }else{
          
          tempRecent=recentChats[indexPath.row]
      }
  
    
    let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
        view.backgroundColor=#colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        print(indexPath)
        self.recentChats.remove(at: indexPath.row)
        deleteRecentChat(recentChatDictionary: tempRecent)
        self.tableView.reloadData()
    }
    
    
    let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
        
       
    return swipeActions
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var tempRecent :NSDictionary!
        if searchController.isActive && searchController.searchBar.text != ""{
            tempRecent=filteredChats[indexPath.row]
        }else{
            
            tempRecent=recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempRecent[kMEMBERSTOPUSH]as![String]).contains(FUser.currentId()){
            muteTitle="Mute"
            mute=true
        }
        
        
        let contextItem2 = UIContextualAction(style: .destructive, title: muteTitle) {  (contextualAction, view, boolValue) in
            view.backgroundColor=#colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            print(indexPath)
        }
        
        
        let swipeActions2 = UISwipeActionsConfiguration(actions: [contextItem2])
            
           
        return swipeActions2
    }
    
    // didselect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent :NSDictionary!
        if searchController.isActive && searchController.searchBar.text != ""{
            recent=filteredChats[indexPath.row]
        }else{
            
            recent=recentChats[indexPath.row]
        }
        
        restartRecentChat(recent: recent)
        
        let chatVC=ChatViewController()
        chatVC.hidesBottomBarWhenPushed=true
        chatVC.titleName=(recent[kWITHUSERUSERID] as? String)!
        
        chatVC.memberToPush=(recent[kMEMBERSTOPUSH] as?[String])!
        chatVC.memberIds=(recent[kMEMBERS] as?[String])!
        chatVC.chatRoomId=(recent[kCHATROOMID] as? String)!
        
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    
    
   // load recent chats
    
    func loadRecentChats (){
        //Attaches a listener for QuerySnapshot events.
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let sanpshot = snapshot else {return}
            self.recentChats=[]
            if !sanpshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot!.documents)) as NSArray ).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE]  as! String != "" &&  recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                        
                    }
                    
                }
                self.tableView.reloadData()
            }

        })

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(120.0)
    }

    
    
    //MAHMOUD:-custom tableView
    
    func setTableViewHeader(){
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width
            , height: 45))
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
        
        let groupButton=UIButton(frame: CGRect(x: tableView.frame.width-110, y: 10, width: 100, height: 20))
        
        groupButton.addTarget(self, action:
            #selector(self.groupButtonPressed), for: .touchUpInside)
        
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height-1, width: tableView.frame.width, height: 1))
        lineView.backgroundColor=#colorLiteral(red: 0.8371338502, green: 0.8371338502, blue: 0.8371338502, alpha: 1)
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        tableView.tableHeaderView=headerView
        
        
        
    }
    
    
    @objc func groupButtonPressed(){
        
        
        
        
        
        
    }
    //MAHMOUD:-delegate func
    
    func didTapImageView(indexpath: IndexPath) {
        
        var  recentChat :NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != ""{
            recentChat = filteredChats[indexpath.row]
             }else{
                  recentChat = recentChats[indexpath.row]
                    
             }

        
        if recentChat[kTYPE]as!String == kPRIVATE{
            
            reference(.User).document(recentChat[kWITHUSERUSERID]as!String).getDocument { (snapshot, error) in
                
                
                guard let snapshot = snapshot else{return}
                if snapshot.exists{
                    
                    let userDictionary = snapshot.data()as!NSDictionary
                    let tempUser=FUser(_dictionary: userDictionary)
                    self.showUserProfile(user: tempUser)
                    
                    
                }
                
                
            }
            
            
        }
    }

    
    func showUserProfile(user:FUser){
        
        
        let profileVC=UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView")as!ProfileViewTableViewController
        profileVC.user=user
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    // search controller functions
    
    
    func filterContentForSearchText(searchText:String,scope:String="All"){
        
        filteredChats = recentChats.filter({ (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME]as!String).lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
