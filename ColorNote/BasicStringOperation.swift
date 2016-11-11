//
//  BasicStringOperation.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/10/26.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

//remove the '#' in some data format
public func changeHexToThreeValue(string:String) -> (String){
    var string = string
    let index0 = string.startIndex
    string.remove(at: index0)
    return string
    
}

public func changeToInt(num:String) -> Int {
    let str = num.uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
        if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
            sum -= 7
        }
    }
    return sum
}

public func hexToRGB(string:String) ->(UIColor){
    
    var tryString = string
    
    if tryString.distance(from: tryString.startIndex, to: tryString.endIndex) != 6 {
        tryString = changeHexToThreeValue(string: tryString)
    }
    
    
    let hexColor = changeToInt(num:tryString)
    let red = Float((hexColor & 0xFF0000) >> 16)/255.0
    let green = Float((hexColor & 0xFF00) >> 8)/255.0
    let blue = Float(hexColor & 0xFF)/255.0
    let color = UIColor.init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    return color
    
}
public func transJSONToString(json:[JSON]) -> [String] {
    
    var string = [String]()
    
    for j in json{
        string.append(j.stringValue)
    }
    
    print("string is !!!!!!!!!!!!!!")
    print(string)
    
    return string
}

public func requestColorExtractWith(url:String) -> [String]{
    
    let analysis = "https://api.imagga.com/v1/colors?url=" + url
    let user = "acc_b3fc2e9be6f9027"
    let password = "855b8379bcf5b3030ac3e19fc6acc0b8"
    
    var json:JSON = []
    var colorArray = [String]()
    var headers: HTTPHeaders = [:]
    
    if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
        headers[authorizationHeader.key] = authorizationHeader.value
    }
    
    Alamofire.request(analysis, method: .get, headers: headers).responseJSON {response in
        
        switch response.result {
        case .success(let value):
            json = JSON(value)
            print(json)
            print(json["results"][0]["info"]["image_colors"].arrayValue.count)
            for i in 0..<json["results"][0]["info"]["image_colors"].arrayValue.count {
                colorArray.append(String(describing: json["results"][0]["info"]["image_colors"][i]["html_code"]))
            }
        case .failure(let error):
            print("!!!!!!!!!!")
            print(error)
            
            
        }
    }
    
    for i in 0..<colorArray.count {
        colorArray[i] = changeHexToThreeValue(string: colorArray[i])
    }
    
    return colorArray
    
}


