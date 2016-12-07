//
//  User.swift
//  TACLeaseApp
//
//  Created by 赵一达 on 2016/11/30.
//  Copyright © 2016年 lirui. All rights reserved.
//

import Foundation

class AppUser {
    
    private enum userTypes {
        case Normal
        case Admin
    }
    
    private static var userInstance:AppUser? = nil
    
    private var userName:String? = nil
    private var userType:userTypes = .Normal
    
    
    public static func getInstance() -> AppUser{
        if userInstance == nil {
            userInstance = AppUser()
        }
        return userInstance!
    }
    
    init() {}
    
    func login(userName:String){
        self.userName = userName
    }
    
    func signUp(userName:String,password:String,repassword:String,handle: ((_ alertString:String) -> Void)){
        let checker = signUPCheck(userName: userName, password: password, repassword: password)
        
        if checker != "400" {
            let string = "error"
            handle(string)
        }
        else{
            let string = ""
            handle(string)
        }
    }
    private func signUPCheck(userName:String,password:String,repassword:String) -> String {
        //
        return "400"
    }
    
    func signOut() {
        
    }
    
    func getUsername() -> String {
        return self.userName!
    }
    
    func hasBeenLogin() -> Bool {
        if self.userName == nil {
            return false
        }else{
            return true
        }
    }
}
