

import UIKit
import ProgressHUD


class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    
   
    // Login
    @IBAction func loginButtonPressed(_ sender: Any) {
    dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
              loginUser()
        }else{
            
            ProgressHUD.showError("Email and password are missing !")
        }
    }
    
    
    
     // Register
     @IBAction func registerButtonPressed(_ sender: Any) {
         dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != ""&&repeatPasswordTextField.text != ""{
            
            if passwordTextField.text == repeatPasswordTextField.text {
                
               registerUser()
            }else{
                ProgressHUD.showError("Passwords do not  match")
            }
              
        }else{
            
            ProgressHUD.showError("All fields are required!")
        }
        
       }
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    
    //MAHMOUD:-Helper functions
    
    func loginUser(){
        ProgressHUD.show("Login...")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            self.goToApp()
        }
        
    }
    
    func registerUser(){
        performSegue(withIdentifier: "welcomeTofinshReg", sender: self)
        dismissKeyboard()
        cleanTextFields()
        
    }
    
   func  dismissKeyboard(){
        
    self.view.endEditing(false)
        
    }
    
    func cleanTextFields(){
        
        emailTextField.text=""
        passwordTextField.text=""
        repeatPasswordTextField.text=""
        
    }
    
    //MAHMOUD:-Gotoapp
    
    func goToApp(){
        ProgressHUD.dismiss()
        cleanTextFields()
        dismissKeyboard()
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        
        
         let mainVC=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "mainApplication") as! UITabBarController
                
                self.present(mainVC, animated: true, completion: nil)
        
        
    }
    
    
    
    //
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeTofinshReg"{
            
            let vc =  segue.destination as! FinishRegisterationViewController
            vc.email=emailTextField.text
            vc.password=passwordTextField.text
        }
    }


}

