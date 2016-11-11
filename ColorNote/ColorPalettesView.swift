//
//  ColorPalettesView.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/10/27.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ColorBlock: UIView {
    var hexString:String = ""
    var blockWidth:String = ""
    
    convenience init(hexString:String,frame:CGRect){
        self.init()
        self.frame = frame
        self.hexString = hexString
//        print(hexToRGB(json: hexString))
        self.backgroundColor = hexToRGB(string: hexString)
        
        //set gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(ColorBlock.colorBlockTapped(_ :)))
        self.addGestureRecognizer(tap)


    }
    func colorBlockTapped(_ sender:UITapGestureRecognizer) {
        
        //  tap began
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
        self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 2, y: 2))
        }, completion:nil)
        switch sender.state {
        
        case .ended:
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
                self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1, y: 1))
                }, completion:nil)
        case .possible:
            print("???")
        case .changed:
            print("ccc")
        default:
            print("hhh")
            break
        }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
//            self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 2, y: 2))
//            }, completion:nil)
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
//            self.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1, y: 1))
//            }, completion:nil)
//    }
    
    
    
}

class ColorPaletteView: UIView {
    var colorArray = [String]()
    var widthArray = [String]()
    
    
    convenience init(frame: CGRect,colorArray:[String],widthArray:[String]) {
        self.init()
        self.frame = frame
        self.colorArray = colorArray
        self.widthArray = widthArray

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        print(self.frame)
        
        
    }
    
    func layColorBlock() {
        var frameLocator = frame
        frameLocator.origin = CGPoint.init(x: 0, y: 0)
        
        //init color block
        
        if colorArray.count == widthArray.count {
            
            print(widthArray)
            for i in 0 ..< colorArray.count {
                if i != widthArray.count-1 {
                    frameLocator.size.width = CGFloat(Float(String(describing:widthArray[i]))!) * frame.width
                    
                }
                else{
                    frameLocator.size.width = frame.width - (frameLocator.origin.x )
                    
                }
                let colorBlock = ColorBlock.init(hexString: colorArray[i], frame: frameLocator)
                frameLocator.origin.x += frameLocator.width
                self.addSubview(colorBlock)
            }
        }
        else{
            print("failed when getting data")
        }
        
        
        //add shadow
        let bottomShadow = UIView.init(frame: frame)
        let shadowHeight = 0.1
        bottomShadow.frame.origin.y = frame.size.height * CGFloat(1 - shadowHeight)
        bottomShadow.frame.origin.x = 0
        bottomShadow.frame.size.height = frame.size.height * CGFloat(shadowHeight)
        bottomShadow.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)
        
        self.addSubview(bottomShadow)

    }
  
}

class addButton: UIButton {
    var hasBeenAdd = false
    var heartView = UIImageView.init(image: #imageLiteral(resourceName: "heart"))
    
    override func awakeFromNib() {
//        layoutIfNeeded()
//        self.frame.origin.x = 331
//        self.frame.origin.y = 32
        heartView.frame = CGRect.init(x: 13, y: 31, width: 2, height: 2)
        self.addSubview(self.heartView)
    }
    func rotate(){
        if hasBeenAdd {
            UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: .allowUserInteraction, animations: {() -> Void in
                self.frame.origin.y -= 32
                self.heartView.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1, y: 1))
            }, completion: nil)
            hasBeenAdd = false
        }else{
            UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: .allowUserInteraction, animations: {() -> Void in
                self.layoutIfNeeded()
                self.frame.origin.y += 32
                self.heartView.layer.setAffineTransform(CGAffineTransform.init(scaleX: 8, y: 8))
            }, completion: nil)
            hasBeenAdd = true
        }
    }
}
