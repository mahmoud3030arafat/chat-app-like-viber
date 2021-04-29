//
//  FinishRegisterationViewController.swift
//  CHAT
//
//  Created by Mahmoud on 4/4/21.
//  Copyright © 2021 mahmoud. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
class FinishRegisterationViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var countryTextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    @IBOutlet weak var avaterImageView: UIImageView!
    
    
    
    
    var email:String!
    var password : String!
    var avaterImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
   print(password!)
        print(email!)
        
    }
    
    
    //MAHMOUD:-IBAction

    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        dismissKeyboard()
        cleanTextFields()
        
    }
    

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Register...")
        if nameTextField.text != "" && surnameTextField.text != ""&&countryTextField.text != ""&&cityTextField.text != ""&&phoneTextField.text != ""{
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil{
                ProgressHUD.dismiss()
              ProgressHUD.showError(error?.localizedDescription)
                print(error?.localizedDescription)
                return
            }
                
                self.registerUser()
                
             }
            
            
            
            
        }else{
            
            ProgressHUD.showError("All fields are required")
        }
        
    }
    //MAHMOUD:-Helper Function
    
    
    func registerUser(){
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        var tempDictionary:Dictionary = [
            kFIRSTNAME:nameTextField.text!,kLASTNAME:surnameTextField.text!,kFULLNAME:fullName,kCOUNTRY:countryTextField.text!,kCITY:cityTextField.text!,kPHONE:phoneTextField.text!
        ] as [String:Any]
        
        if avaterImage == nil{
            
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                tempDictionary[kAVATAR]=avatar
                
                     // finsh registering
                
                self.finishRegisteration(withValues: tempDictionary)
               
            }
            
        }else{
            
            let avatarData = avaterImage?.jpegData(compressionQuality: 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            tempDictionary[kAVATAR] = avatar
            // finsh registering
            

            finishRegisteration(withValues: tempDictionary)
   
        }
        
        
    }
    
    
    func finishRegisteration(withValues:[String:Any] ){
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil{
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                return
              }
            
            // go to app
            self.goToApp()
        }
    }
    
    
    func goToApp(){
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        
        let mainVC=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainApplication") as! UITabBarController
        
        self.present(mainVC, animated: true, completion: nil)
        
        
    }
    func  dismissKeyboard(){
         
     self.view.endEditing(false)
         
     }
     
     func cleanTextFields(){
         
         nameTextField.text=""
         surnameTextField.text=""
         countryTextField.text=""
         cityTextField.text=""
         phoneTextField.text=""
        
         
     }
    
    
    

}
