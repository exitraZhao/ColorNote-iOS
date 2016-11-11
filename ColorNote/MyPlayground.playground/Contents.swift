//: Playground - noun: a place where people can play

import UIKit
import Alamofire
import SWXMLHash
import SwiftyJSON

var str = "Hello, playground"
let url = "http://www.colourlovers.com/api/palettes?showPaletteWidths=1&format=xml&numResults=20&keywordExact=1&keywords=fish"

Alamofire.request(url, method: .get ).validate().responseJSON { response in
    
    switch response.result {
    case .success(let value):
//        let xml = SWXMLHash.parse(String(describing:value))
//        print(xml)
        print(JSON(value))
    case .failure(let error):
        print(error)
    }
    
}