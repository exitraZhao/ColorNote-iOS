//
//  CollectionViewController.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/11/8.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SwiftyJSON

class collectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak internal var palettesTableView: UITableView!
    
    var thing = [NSManagedObject]()
    
    override func viewDidLoad() {
        palettesTableView.delegate = self
        palettesTableView.dataSource = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        // 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Collection")
        
        // 3
        do {
            let results = try managedContext.fetch(fetchRequest)
            thing = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        palettesTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thing.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let json = JSON(self.thing[indexPath.row].value(forKey: "json") as! String)
        let str = self.thing[indexPath.row].value(forKey: "json") as! String
        let data = str.data(using: String.Encoding.utf8)
        let json = JSON.init(data: data!)
        print(json)
        if let cell = tableView.dequeueReusableCell(withIdentifier: "paletteCell", for: indexPath) as? PalettesTableViewCell {
            
            print(json)
            print(json["title"])
            print("??????")
            cell.palettesLabel.text = String(describing: json["title"])
            
            cell.layoutIfNeeded()
            cell.palettesView.subviews.map{$0.removeFromSuperview()}
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // 数据传递
            cell.palettesView.colorArray = transJSONToString(json: json["colors"].arrayValue)
            cell.palettesView.widthArray = transJSONToString(json: json["colorWidths"].arrayValue)
            cell.json = json
            cell.palettesView.layColorBlock()
            
            cell.contentView.frame.origin.x += 100
            
            //            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
            //                cell.contentView.frame.origin.x -= 200
            //            }, completion:nil)
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
                cell.contentView.frame.origin.x -= 100
            }, completion:nil)
            return cell
        }
        
        return UITableViewCell()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            if let destinationView = segue.destination as? PalettesDetailViewController {
                let str = self.thing[(palettesTableView.indexPathForSelectedRow?.row)!].value(forKey: "json") as! String
                let data = str.data(using: String.Encoding.utf8)
                let json = JSON.init(data: data!)
                
                destinationView.paletteColorArray = transJSONToString(json:json["colors"].arrayValue)
                destinationView.paletteWidthsArray = transJSONToString(json:json["colorWidths"].arrayValue)
                destinationView.title = String(describing:json["title"])
                destinationView.json = json
            }
        }
        
    }
}
