//
//  singleColorDetailViewController.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/11/7.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ColorDetailViewController: UIViewController {
    var midX = CGFloat()
    var midY = CGFloat()
    @IBOutlet weak var colorName: UILabel!
    @IBOutlet weak var colorBar: UIView!
    @IBOutlet weak var tagField: UIView!
    @IBOutlet weak var errorAlert: UILabel!
    var name = String()
    var url = String()
    var tagsJSON:[JSON] = []
    var hexString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        midX = colorBar.frame.midX
        midY = colorBar.frame.midY
        colorBar.layer.cornerRadius.add(colorBar.frame.width/2)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
            self.colorBar.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1.2, y: 1.2))
            self.colorBar.backgroundColor = hexToRGB(string: self.hexString)
            self.colorName.text = self.name
        }, completion:nil)
        
        Alamofire.request(url, method: .get ).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.tagsJSON = json["colors"][0]["tags"].arrayValue
                
                if self.tagsJSON.count != 0 {
                    let tagField = TagField.init(json: self.tagsJSON, frame: self.errorAlert.frame, color:hexToRGB(string: self.hexString))
                    self.view.addSubview(tagField)
                }else{
                    self.errorAlert.text = "No Tag Has Been Added"
                }
            case .failure(let error):
                print(error)
            }
            
        }
        

    }
}

class Tag: UIButton {
    var name = String()
    
    convenience init(tagName:String,frame: CGRect,color:UIColor) {
        self.init()
        self.frame = frame
        name = tagName
        self.tintColor = UIColor.white
        self.titleLabel?.font = UIFont.init(name: "American-Typewrite-Regular", size: 12)
        self.setTitle(name, for: .normal)
        self.layer.cornerRadius = 3
        self.backgroundColor = color
        
    }
    
}
class TagField: UIView {
    var tagsJSON:[JSON] = []
    
    convenience init(json:[JSON],frame: CGRect,color:UIColor) {
        self.init()
        self.frame = frame
        self.tagsJSON = json
        var indicatorFrame = self.frame
        indicatorFrame.origin.y = 0
        indicatorFrame.origin.x = 0
        indicatorFrame.size.height = 30
        
        
        for i in 0..<tagsJSON.count{
            let nameString = String(describing:json[i]["name"])
            let width = Float(nameString.characters.count) * 6.5 + 28.0
            if indicatorFrame.origin.x + CGFloat(width) > 359 {
                indicatorFrame.origin.y += 40
                indicatorFrame.origin.x = 0
            }
           
            
            indicatorFrame.size.width = CGFloat(width)
            let tag = Tag.init(tagName:nameString, frame: indicatorFrame, color:color)
            addSubview(tag)
            indicatorFrame.origin.x += tag.frame.width + 10
            
        }
        
    }
}

