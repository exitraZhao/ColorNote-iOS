//
//  LoginViewController.swift
//  TACLeaseApp
//
//  Created by 赵一达 on 2016/11/30.
//  Copyright © 2016年 lirui. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore





class LoginViewController: UIViewController {
    
    let url_login = "http://115.159.35.33:3000/login/app"
    let requestInstance = Request.getInstance()
    let universalUser = AppUser.getInstance()
    
    var fieldCheck = Checker()
    
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
        
        loginButton.isEnabled = false
        let observerInstance = Observer.init(ifTrue: {() -> Void in
            self.loginButton.isEnabled = true
        }, ifFalse: {() -> Void in
            self.loginButton.isEnabled = false
        })
        fieldCheck.observer = observerInstance
        
        // Notifiying for Changes in the textFields
        usernameField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange), for: UIControlEvents.editingChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textFieldDidChange() {
       fieldCheck.hasBeenTyped(password: usernameField, repassword: passwordField)
    }
    
    func requestForLogin(){
        
        let dataPara:Dictionary<String,Any> = [
            "username" : "\(usernameField.text!)",
            "password" : "\(passwordField.text!)"
        ]
        
        print(dataPara)
        
        requestInstance.post(url: url_login, dataPara: dataPara, completion: {(data) -> Void in
            var dictArray = NSDictionary()
            
            do {
                dictArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
              
            } catch let error as NSError {
                print(error)
            }
            if dictArray["success"] == nil {
                showAlert(title: "ERROR", message: (dictArray["error"] as? String)!, viewController: self)
            }else{
                
                showAlert(title: "SUCCESS", message: (dictArray["success"] as? String)!, viewController: self)
                self.universalUser.login(userName: self.usernameField.text!)
                
            }
        })
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
    let requestInstance = Request.getInstance()

    var fieldCheck = Checker()
    
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
        let observerInstance = Observer.init(ifTrue: {() -> Void in
            self.signUpButton.isEnabled = true
        }, ifFalse: {() -> Void in
            self.signUpButton.isEnabled = false
        })
        fieldCheck.observer = observerInstance
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
        fieldCheck.hasBeenTyped(password: passwordField, repassword: rePasswordField)
    }
    func requestForSignUp(){
        
        let dataPara:Dictionary<String,Any> = [
            "username" : "\(usernameField.text!)",
            "password" : "\(passwordField.text!)",
            "repassword" : "\(passwordField.text!)"
        ]
        
        requestInstance.post(url: url_signUp, dataPara: dataPara, completion: {(data) -> Void in
            var dictArray = NSDictionary()
            do {
                dictArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                print(dictArray)
                print(dictArray["success"])
                
            } catch let error as NSError {
                print(error)
            }
            if dictArray["success"] == nil {
                showAlert(title: "ERROR", message: (dictArray["error"] as? String)!, viewController: self)
            }else{
                showAlert(title: "SUCCESS", message: (dictArray["success"] as? String)!, viewController: self)
            }
            
        })
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
