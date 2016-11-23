//
//  ImageColorExtracter.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/11/20.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import UIKit

class UIImageColorRefiner:UIImageView{
    
    
    func getPixelColor(pos:CGPoint)->(alpha: CGFloat, red: CGFloat, green: CGFloat,blue:CGFloat){
        let pixelData = self.image!.cgImage!.dataProvider!.data
        let data:UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(self.image!.size.width) * Int(pos.y) * 2) + Int(pos.x) * 2) * 4
//        let pixelInfo: Int = ((Int(self.image!.cgImage!.width) * Int(pos.y)) + Int(pos.x)) * 4
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return (a,r,g,b)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("info about pixel")
        print(self.image?.size)
        print(self.image!.cgImage?.width)
        print(self.image!.cgImage?.height)
        print(touches.first?.location(in: self))
        print(getPixelColor(pos: (touches.first?.location(in: self))!))
    }
    
}
