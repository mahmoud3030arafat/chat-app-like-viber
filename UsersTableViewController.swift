//
//  UsersTableViewController.swift
//  CHAT
//
//  Created by Mahmoud on 4/5/21.
//  Copyright © 2021 mahmoud. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
class UsersTableViewController: UITableViewController ,UISearchResultsUpdating,UserTableViewCellDelegate{
  
    
    

    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allUsers : [FUser]=[]
    var filtedUsers : [FUser]=[]
    var allUsersGroupped = NSDictionary()as! [String:[FUser]]
    var sectionTitleList : [String ] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // loadUsers(filter: kCITY)
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController=searchController
        searchController.searchResultsUpdater=self
        searchController.obscuresBackgroundDuringPresentation=false
        definesPresentationContext=true

        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return 1
        }else{
         
        return allUsersGroupped.count
        }
    }

    
    
    //
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != ""{
            return filtedUsers.count
        }else{
            
            let sectionTitle = self.sectionTitleList[section]
            let users = self.allUsersGroupped[sectionTitle]
  
            return users!.count
            
            
        }
    }
    //
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
       
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != ""{
            
            user = filtedUsers[indexPath.row]
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.section]
            let users = self.allUsersGroupped[sectionTitle]
        
           
            user=users![indexPath.row]
            
     
        }
   
         cell.generateWith(fuser: user, indexpathh: indexPath)
        cell.delegate=self
        return cell
    }
    
    //MAHMOUD:-table view delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return ""
        }else{
            
           return sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != ""{
            
            return nil
        }else{
            
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return  index
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // didselect func
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user : FUser
           
           if searchController.isActive && searchController.searchBar.text != ""{
               
               user = filtedUsers[indexPath.row]
           }else{
               let sectionTitle = self.sectionTitleList[indexPath.section]
               let users = self.allUsersGroupped[sectionTitle]
              
                 user=users![indexPath.row]
               
        
           }
        
        
        
        startPrivateChat(user1: FUser.currentUser()!, user2: user)
        
    }
    
    
    func loadUsers(filter:String){
        ProgressHUD.show()
        var query :Query!
        switch filter {
        case kCITY:
            query=reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query=reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
            
        default:
            query=reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers=[]
            self.sectionTitleList=[]
            self.allUsersGroupped=[:]
            if error != nil{
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = snapshot else {
                
                ProgressHUD.dismiss()
                return
            }
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents{
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fuser = FUser(_dictionary: userDictionary)
                    if fuser.objectId != FUser.currentId(){
                        self.allUsers.append(fuser)
                    }
                }
                
                
               self.splitDataIntoSection()
                self.tableView.reloadData()
               
                
                
            }
         
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
        
        
    }
    
    
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
            case 1:
            loadUsers(filter: kCOUNTRY)
            case 2:
            loadUsers(filter: "")
        default:
            return
        }
        
    }
    
    // search controller functions
    
    
    func filterContentForSearchText(searchText:String,scope:String="All"){
        
        filtedUsers = allUsers.filter({ (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    //MAHMOUD:- helper function
    fileprivate func splitDataIntoSection(){
        
        var sectionTitle : String = ""
        for i in 0..<self.allUsers.count{
        let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCharString = "\(firstChar)"
            
            if firstCharString != sectionTitle {
                
                sectionTitle=firstCharString
                self.allUsersGroupped[sectionTitle]=[]
                self.sectionTitleList.append(sectionTitle)

            }
             self.allUsersGroupped[firstCharString]?.append(currentUser)
            
            
        }
    
    }
   
    
    // delegate
    func didTapImageView(indexpath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "profileView") as! ProfileViewTableViewController
        var user : FUser
              
              if searchController.isActive && searchController.searchBar.text != ""{
                  
                user = filtedUsers[indexpath.row]
              }else{
                  let sectionTitle = self.sectionTitleList[indexpath.section]
                  let users = self.allUsersGroupped[sectionTitle]
                
                 
                  user=users![indexpath.row]
                  
                 
              }
        
        vc.user=user
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
      
    
    
    
}
