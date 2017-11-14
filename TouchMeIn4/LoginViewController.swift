/*
* Copyright (c) 2017 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import CoreData
import LocalAuthentication

// Keychain Configuration
struct KeychainConfiguration {
  static let serviceName = "TouchMeIn"
  static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {
  
  var managedObjectContext: NSManagedObjectContext? = nil
  var passwordItems = [KeychainPasswordItem]()
  let createLoginButtonTag = 0
  let loginButtonTag = 1
  var context = LAContext()
  let touchMe = TouchIDAuth()
  
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var createInfoLabel: UILabel!  
  @IBOutlet var touchIDButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
    
    if hasLogin {
      loginButton.setTitle("Login", for: UIControlState.normal)
      loginButton.tag = loginButtonTag
      createInfoLabel.isHidden = true
    } else {
      loginButton.setTitle("Create", for: UIControlState.normal)
      loginButton.tag = createLoginButtonTag
      createInfoLabel.isHidden = false
    }
    
    if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
      usernameTextField.text = storedUsername as String
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let touchBool = touchMe.canEvaluatePolicy()
    if touchBool {
      self.touchIDButtonAction()
    }
  }
  
  // MARK: - Action for checking username/password
  @IBAction func loginAction(sender: AnyObject) {
    
    // Check that text has been entered into both the account and password fields.
    guard let newAccountName = usernameTextField.text,
      let newPassword = passwordTextField.text,
      !newAccountName.isEmpty &&
      !newPassword.isEmpty else { return }
    
    usernameTextField.resignFirstResponder()
    passwordTextField.resignFirstResponder()
    
    if sender.tag == createLoginButtonTag {
      
      let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
      if hasLoginKey == false {
        UserDefaults.standard.setValue(self.usernameTextField.text, forKey: "username")
      }
      
      
      do {
        
        // This is a new account, create a new keychain item with the account name.
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
        
        // Save the password for the new item.
        try passwordItem.savePassword(newPassword)
      }
        catch {
          fatalError("Error updating keychain - \(error)")
      }
      
      UserDefaults.standard.set(true, forKey: "hasLoginKey")
      UserDefaults.standard.synchronize()
      loginButton.tag = loginButtonTag
      
      performSegue(withIdentifier: "dismissLogin", sender: self)
    } else if sender.tag == loginButtonTag {

      if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
        performSegue(withIdentifier: "dismissLogin", sender: self)
      } else {
        let alertView = UIAlertController(title: "Login Problem",
                                          message: "Wrong username or password." as String, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Foiled Again!", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
      }
    }
  }
    
  @IBAction func touchIDButtonAction() {
    
    let touchMe = TouchIDAuth()
    
    touchMe.authenticateUser() { (message: String?) in
      
      if let message = message {
        // if the completion is not nil show an alert
        let alertView = UIAlertController(title: "Error",
                                          message: message as String, preferredStyle:.alert)
        let okAction = UIAlertAction(title: "Darn!", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)

      } else {
      
      self.performSegue(withIdentifier: "dismissLogin", sender: self)
      }
    }

  }
  
  @objc func dismissLogin() {
    let faceID = TouchIDAuth()
    faceID.authenticateUser() {_ in
      self.performSegue(withIdentifier: "dismissLogin", sender: nil)
    }
  }
  
  func checkLogin(username: String, password: String ) -> Bool {
    if username == UserDefaults.standard.value(forKey: "username") as? String {
      do {
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: username, accessGroup: KeychainConfiguration.accessGroup)
        let KeychainPassword = try passwordItem.readPassword()
        if password == KeychainPassword{
          return true
        } else {
          return false
        }

      }
      catch {
        fatalError("Error reading password from keychain - \(error)")
      }
    }
    return false
  }
  
}
