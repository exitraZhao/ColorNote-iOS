//
//  BasicStringOperation.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/10/26.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import Alamofire
import SwiftyJSON





class LoginViewController: UIViewController {
    
    let url_login = "http://115.159.35.33:3000/login/app"
    let universalUser = AppUser.getInstance()
    
    
    //MARK: Outlets for UI Elements.
    @IBOutlet weak var usernameField:   UITextField!
    @IBOutlet weak var passwordField:   UITextField!
    @IBOutlet weak var loginButton:     UIButton!
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        requestForLogin()
//        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: View Controller LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Notifiying for Changes in the textFields
        usernameField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textFieldDidChange() {
    }
    
    func requestForLogin(){
        
            }
    
    @IBAction func backgroundPressed(sender: AnyObject) {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignUp" {
            if let dv = segue.destination as? SignUpViewController {
                dv.title = "Sign Up"
            }
        }
    }
}

class SignUpViewController: UIViewController {
    
    let url_signUp = "http://115.159.35.33:3000/signup/app"
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var rePasswordField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if checkPasswordEquivalent() {
            requestForSignUp()
        }else{
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.isEnabled = false
        
        passwordField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChanged), for: .editingChanged)
        rePasswordField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChanged), for: .editingChanged)
    }
    func checkPasswordEquivalent() -> Bool {
        
            if passwordField.text == rePasswordField.text {
                return true
            }else{
                self.present(UIAlertController.init(title: "Password Error", message: "Please check your password", preferredStyle: .alert), animated: true, completion: nil)
                return false
            }
        
    }
    func textFieldDidChanged(){
        print("changed!")
    }
    func requestForSignUp(){
        
        let dataPara:Dictionary<String,Any> = [
            "username" : "\(usernameField.text!)",
            "password" : "\(passwordField.text!)",
            "repassword" : "\(passwordField.text!)"
        ]
        
        
    }
}

public func showAlert(title:String,message:String, viewController:UIViewController){
    let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction.init(title: "ok", style: .default, handler: { (action) in
        alert.dismiss(animated: true, completion: {() -> Void in
            viewController.navigationController?.popViewController(animated: true)
        })
    }))
    
    DispatchQueue.main.async {
        viewController.present(alert, animated: true, completion: nil)
    }
}

class UserViewController: UIViewController {
    
    let universalUser = AppUser.getInstance()
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var SignUpBar: UIView!
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        signUp()
    }
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        signIn()
    }
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        SignOut()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignUpBar.layer.cornerRadius = self.SignUpBar.frame.width/2
        
        if universalUser.hasBeenLogin() {
            userName.text = universalUser.getUsername()
            signInButton.isHidden = true
        } else {
            userName.text = "PleaseSignIn"
            signOutButton.isHidden = true
        }
        
    }
    
    func signUp(){
        let alertSheet = UIAlertController(title: "Sign Up", message: nil, preferredStyle: .alert)
        alertSheet.addTextField { (textField) in
            textField.placeholder = "enter your name"
        }
        alertSheet.addTextField { (textField) in
            textField.placeholder = "enter your password"
        }
        alertSheet.addTextField { (textField) in
            textField.placeholder = "enter your password again"
        }
        
        alertSheet.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { (alertAction) in
            
            if alertSheet.textFields?[1].text == alertSheet.textFields?[2].text {
                // signup request
//                let user = "sXvWPWGXozgs0abUMsuL8143-gzGzoHsz"
//                let password = "5vRTX6YB4wD3c06N569NIsh9"
//                var headers: HTTPHeaders = [:]
//                
//                if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
//                    headers[authorizationHeader.key] = authorizationHeader.value
//                }
//              
                let headers = [
                    "X-LC-Id": "sXvWPWGXozgs0abUMsuL8143-gzGzoHsz",
                    "X-LC-Key": "5vRTX6YB4wD3c06N569NIsh9"
                ]
                let parameters: Parameters = [
                    "Password": "\(alertSheet.textFields![1].text!)",
                    "User_ID": "\(alertSheet.textFields![0].text!)"
                ]
                var alert: UIAlertView = UIAlertView(title: "analysing...", message: "", delegate: nil, cancelButtonTitle: "Cancel");
                alert.frame.size.width = 170
                
                
                var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
                loadingIndicator.center = self.view.center;
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                alert.setValue(loadingIndicator, forKey: "accessoryView")
                loadingIndicator.startAnimating()
                
                alert.show();
                
                Alamofire.request("https://api.leancloud.cn/1.1/classes/User_Data", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
                    
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print(json)
                        print(json["code"])
                        if json["code"] == nil  {
                            let alertSheet = UIAlertController(title: "SUCCESS", message: nil, preferredStyle: .alert)
                            alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                            self.present(alertSheet, animated: true, completion: nil)
                        }else{
                            let alertSheet = UIAlertController(title: "ERROR", message: "User name already existed", preferredStyle: .alert)
                            alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                            self.present(alertSheet, animated: true, completion: nil)
                        }

                    case .failure(let error):
                        print("!!!!!!!!!!")
                        let alertSheet = UIAlertController(title: "ERROR", message: nil, preferredStyle: .alert)
                        alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                        self.present(alertSheet, animated: true, completion: nil)
                    }
                }
                alert.dismiss(withClickedButtonIndex: 0, animated: true)
                self.dismiss(animated: true, completion: {
                })
            }else {
                let passwordDifferentAlert = UIAlertController(title: "pass word different", message: "please enter your password again.", preferredStyle: .alert)
                passwordDifferentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                    passwordDifferentAlert.dismiss(animated: true, completion: {
                        alertSheet.textFields?[0].text = ""
                        alertSheet.textFields?[1].text = ""
//                        self.dismiss(animated: true, completion: nil)
                        
                    })
                }))
                
                self.present(passwordDifferentAlert, animated: true, completion: nil)
            }
            
        }))
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            
        }))
        self.present(alertSheet, animated: true, completion: nil)
    }
    func signIn(){
        let alertSheet = UIAlertController(title: "Sign In", message: nil, preferredStyle: .alert)
        alertSheet.addTextField { (textField) in
            textField.placeholder = "enter your name"
        }
        alertSheet.addTextField { (textField) in
            textField.placeholder = "enter your password"
            textField.isSecureTextEntry = true
        }
        alertSheet.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { (alertAction) in
            
            // signin request
            let headers = [
                "X-LC-Id": "sXvWPWGXozgs0abUMsuL8143-gzGzoHsz",
                "X-LC-Key": "5vRTX6YB4wD3c06N569NIsh9"
            ]
            let parameters: Parameters = [
                "Password": "\(alertSheet.textFields![1].text!)",
                "User_ID": "\(alertSheet.textFields![0].text!)"
            ]
            
            var alert: UIAlertView = UIAlertView(title: "analysing...", message: "", delegate: nil, cancelButtonTitle: "Cancel");
            alert.frame.size.width = 170
            
            
            var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
            loadingIndicator.center = self.view.center;
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            alert.setValue(loadingIndicator, forKey: "accessoryView")
            loadingIndicator.startAnimating()
            
            alert.show();
            
            Alamofire.request("https://leancloud.cn/1.1/functions/Login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    print(json["result"])
                    
                    if json["result"] != nil  {
                        self.universalUser.login(userName: alertSheet.textFields![0].text!)
                        self.userName.text = self.universalUser.getUsername()
                        self.signInButton.isHidden = true
                        self.signOutButton.isHidden = false
                        let alertSheet = UIAlertController(title: "SUCCESS", message: nil, preferredStyle: .alert)
                        alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                        self.present(alertSheet, animated: true, completion: nil)
                    }else{
                        let alertSheet = UIAlertController(title: "ERROR", message: nil, preferredStyle: .alert)
                        alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                        self.present(alertSheet, animated: true, completion: nil)
                    }
                    
                case .failure(let error):
                    print("!!!!!!!!!!")
                    let alertSheet = UIAlertController(title: "ERROR", message: nil, preferredStyle: .alert)
                    alertSheet.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                    self.present(alertSheet, animated: true, completion: nil)
                }
            }
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
            self.viewDidLoad()
            self.dismiss(animated: true, completion: {
            })
            
        }))
        alertSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            
        }))
        self.present(alertSheet, animated: true, completion: nil)

    }
    func SignOut(){
        let alertSheet = UIAlertController(title: "Sign Out", message: "Really want to Sign Out?", preferredStyle: .alert)
        
        alertSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            
            self.universalUser.signOut()
            self.viewDidLoad()
            self.userName.text = "PleaseSignIn"
            self.signInButton.isHidden = false
            self.signOutButton.isHidden = true
            self.dismiss(animated: true, completion: {
            })
            
        }))
        alertSheet.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) in
            
        }))
        self.present(alertSheet, animated: true, completion: nil)
    }
}
