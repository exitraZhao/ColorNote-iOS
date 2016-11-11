//
//  ViewController.swift
//  ColorNote
//
//  Created by 赵一达 on 2016/10/21.
//  Copyright © 2016年 赵一达. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SWXMLHash
import SwiftyJSON
import ImageLoader

class ViewController: UIViewController , UITextFieldDelegate {
    var midX = CGFloat()
    var midY = CGFloat()
    @IBOutlet weak var colorSetterField: UITextField!
    @IBOutlet weak var colorName: UILabel!
    @IBOutlet weak var colorBar: UIView!
    @IBAction func hexSetter(_ sender: AnyObject) {
        let url = "http://thecolorapi.com/id?hex="+colorSetterField.text!+"&format=json"
        
        //animation when input ended
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
            self.colorBar.layer.setAffineTransform(CGAffineTransform.init(scaleX: 0.03, y: 0.03))
            
            }, completion:nil)
        
        //web request
        Alamofire.request(url, method: .get ).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \(json)")
                self.colorName.text = String(describing: json["name"]["value"])
                
                //animation when web request ended
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 15.0, options: .allowUserInteraction, animations: {() -> Void in
                    self.colorBar.layer.setAffineTransform(CGAffineTransform.init(scaleX: 1, y: 1))
                    self.colorBar.backgroundColor = hexToRGB(string:String(describing:json["name"]["closest_named_hex"]))
                    }, completion:nil)
                self.colorSetterField.text = changeHexToThreeValue(string: String(describing:json["name"]["closest_named_hex"]))
            case .failure(let error):
                print(error)
                showAlert()
            }
        }

    }
    //delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colorSetterField.delegate = self
        midX = colorBar.frame.midX
        midY = colorBar.frame.midY
        colorBar.layer.cornerRadius.add(colorBar.frame.width/2)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class testViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        
        let url = "http://www.colourlovers.com/api/palettes?keywordExact=1&keywords=fish&showPaletteWidths=1&format=json&numResults=1"
        
        Alamofire.request(url, method: .get ).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var frame = self.view.frame
                print(frame)
                print("!!!!!!")
                frame.origin.y = 300
                frame.size.height = 60
                
                self.addPaletteToViewFromJson(json: json, frame: frame)
            case .failure(let error):
                print(error)
                showAlert()
            }
            
        }
        

    }
    
    // may should add a parameter about frame
    func addPaletteToViewFromJson(json:JSON,frame:CGRect) {
        print(json)
        let colorArray = transJSONToString(json:json[0]["colors"].arrayValue)
        let widthArray = transJSONToString(json: json[0]["colorWidths"].arrayValue)
        
        print(self.view.frame.size)
        let colorPalette = ColorPaletteView.init(frame:frame, colorArray: colorArray, widthArray: widthArray)
        
        self.view.addSubview(colorPalette)
//        print(colorPalette.frame)
//        print("!!!!")
        

    }
    
}

// Classes in palettesTableViewController
class PalettesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var url = String()
    var json:JSON = []
    @IBOutlet weak internal var palettesTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        palettesTableView.delegate = self
        palettesTableView.dataSource = self
        self.view.layoutIfNeeded()
        
        var alert: UIAlertView = UIAlertView(title: "Loading...", message: "", delegate: nil, cancelButtonTitle: "Cancel");
        alert.frame.size.width = 170
        
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        Alamofire.request(url, method: .get ).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                self.json = JSON(value)
               
            case .failure(let error):
                showAlert()
                print(error)
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
            self.palettesTableView.reloadData()
        }
        
        
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("build tablecell")
        if let cell = tableView.dequeueReusableCell(withIdentifier: "paletteCell", for: indexPath) as? PalettesTableViewCell {
            
            cell.palettesLabel.text = String(describing:self.json[indexPath.row]["title"])
            cell.commentNumber.text = "\(self.json[indexPath.row]["numComments"])"
            cell.viewNumber.text = "\(self.json[indexPath.row]["numViews"])"
            cell.voteNumber.text = "\(self.json[indexPath.row]["numVotes"])"
            cell.layoutIfNeeded()
            cell.palettesView.subviews.map{$0.removeFromSuperview()}
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            
            // 数据传递
            cell.palettesView.colorArray = transJSONToString(json: self.json[indexPath.row]["colors"].arrayValue)
            cell.palettesView.widthArray = transJSONToString(json: self.json[indexPath.row]["colorWidths"].arrayValue)
            cell.json = json[indexPath.row]
            cell.palettesView.layColorBlock()
            
            cell.contentView.frame.origin.x += 100
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
                cell.contentView.frame.origin.x -= 100
            }, completion:nil)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.json.count
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
            if let destinationView = segue.destination as? PalettesDetailViewController {
                destinationView.paletteColorArray = transJSONToString(json:self.json[(palettesTableView.indexPathForSelectedRow?.row)!]["colors"].arrayValue)
                destinationView.paletteWidthsArray = transJSONToString(json:self.json[(palettesTableView.indexPathForSelectedRow?.row)!]["colorWidths"].arrayValue)
                destinationView.title = String(describing:json[(palettesTableView.indexPathForSelectedRow?.row)!]["title"])
                destinationView.json = json[(palettesTableView.indexPathForSelectedRow?.row)!]
                
            }
        }
}
    
    // may should add a parameter about frame
    func addPaletteToViewFromJson(json:JSON,frame:CGRect,view:UIView) {
        print(json)
        let colorArray = transJSONToString(json:json[0]["colors"].arrayValue)
        let widthArray = transJSONToString(json: json[0]["colorWidths"].arrayValue)
        
        print(self.view.frame.size)
        let colorPalette = ColorPaletteView.init(frame:frame, colorArray: colorArray, widthArray: widthArray)
        
        view.addSubview(colorPalette)
        //        print(colorPalette.frame)
        //        print("!!!!")
        
        
    }

    
}
class PalettesTableViewCell: UITableViewCell {
    @IBOutlet weak internal var palettesLabel: UILabel!
    @IBOutlet weak internal var palettesView: ColorPaletteView!
    var json:JSON = []
    
    @IBOutlet weak var voteNumber: UILabel!
    
    @IBOutlet weak var commentNumber: UILabel!
    
    @IBOutlet weak var viewNumber: UILabel!
    
    
}
//class for Patterns
class PatternsTableViewController:UIViewController,UITableViewDelegate,UITableViewDataSource{
    var json:JSON = []
    var xml = SWXMLHash.parse(" ")
    var url = String()
    @IBOutlet weak internal var patternsTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        patternsTableView.delegate = self
        patternsTableView.dataSource = self
        self.view.layoutIfNeeded()
        
        var alert: UIAlertView = UIAlertView(title: "Loading...", message: "", delegate: nil, cancelButtonTitle: "Cancel");
        alert.frame.size.width = 170
        
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();

        
        Alamofire.request(url, method: .get ).validate().responseData { response in
            
            switch response.result {
            case .success(let value):
                self.xml = SWXMLHash.parse(String.init(data: value, encoding: String.Encoding.utf8)!)
                
                self.patternsTableView.reloadData()
            case .failure(let error):
                print(error)
                showAlert()
                
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)

            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
//        return json.count
        return self.xml["patterns"]["pattern"].all.count
      
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "patternCell", for: indexPath) as? PatternsTableViewCell {
//            
//            cell.patternsLabel.text = String(describing:json[indexPath.row]["title"])
//            cell.json = json[indexPath.row]
//            
//            let url = String(describing:json[indexPath.row]["imageUrl"])
//            let placeholder = #imageLiteral(resourceName: "handler")
//            cell.patternsView.load(url, placeholder: placeholder) { url, image, error, cacheType in
//                print("url \(url)")
//                print("error \(error)")
//                print("image \(image?.size), render-image \(cell.patternsView.image?.size)")
//                print("cacheType \(cacheType.hashValue)")
//                if cacheType == CacheType.none {
//                    let transition = CATransition()
//                    transition.duration = 0.5
//                    transition.type = kCATransitionFade
//                    cell.patternsView.layer.add(transition, forKey: nil)
//                    cell.patternsView.image = image
//                }
//            }
//
//            
//            return cell
//        }
        
                if let cell = tableView.dequeueReusableCell(withIdentifier: "patternCell", for: indexPath) as? PatternsTableViewCell {
        
                    cell.patternsLabel.text = self.xml["patterns"]["pattern"][indexPath.row]["title"].element!.text!
                    cell.json = json[indexPath.row]
        
                    let url = self.xml["patterns"]["pattern"][indexPath.row]["imageUrl"].element!.text!
                    let placeholder = #imageLiteral(resourceName: "handler")
                    cell.patternsView.load(url, placeholder: placeholder) { url, image, error, cacheType in
                        print("url \(url)")
                        print("error \(error)")
                        print("image \(image?.size), render-image \(cell.patternsView.image?.size)")
                        print("cacheType \(cacheType.hashValue)")
                        if cacheType == CacheType.none {
                            let transition = CATransition()
                            transition.duration = 0.5
                            transition.type = kCATransitionFade
                            cell.patternsView.layer.add(transition, forKey: nil)
                            if image != nil {
                                cell.patternsView.image = image
                            }else{
                                showAlert()
                            }
                        }
                    }
        
                    cell.contentView.frame.origin.x += 100
                    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
                        cell.contentView.frame.origin.x -= 100
                    }, completion:nil)
                    return cell
                }
        
        
        return UITableViewCell()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dv = segue.destination as? PatternsDetailTableViewController {
            dv.image = ((patternsTableView.cellForRow(at: patternsTableView.indexPathForSelectedRow!) as? PatternsTableViewCell)?.patternsView.image)!
//            dv.url = String(describing:json[(patternsTableView.indexPathForSelectedRow?.row)!]["imageUrl"])
            dv.url = self.xml["patterns"]["pattern"][(patternsTableView.indexPathForSelectedRow?.row)!]["imageUrl"].element!.text!
            
        }
    }
    
}
class PatternsTableViewCell: UITableViewCell {
    @IBOutlet weak internal var patternsLabel: UILabel!
    @IBOutlet weak internal var patternsView: UIImageView!
    var json:JSON = []
    //b
}

class PatternsDetailTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var image = UIImage()
    
    var colorArray = [String]()
    var url = String()
    
    @IBOutlet weak internal var patternsView: UIImageView!
    @IBOutlet weak internal var colorTableView: UITableView!
    override func viewDidLoad() {
        colorTableView.dataSource = self
        colorTableView.delegate = self
        
        patternsView.image = image
        
        var alert: UIAlertView = UIAlertView(title: "analysing...", message: "", delegate: nil, cancelButtonTitle: "Cancel");
        alert.frame.size.width = 170
        
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect.init(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();

        
        let analysis = "https://api.imagga.com/v1/colors?url=" + url
        let user = "acc_b3fc2e9be6f9027"
        let password = "855b8379bcf5b3030ac3e19fc6acc0b8"
        
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: user, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(analysis, method: .get, headers: headers).responseJSON {response in
            
            switch response.result {
            case .success(let value):
                var json = JSON(value)

                print(json["results"][0]["info"]["image_colors"].arrayValue.count)
                for i in 0..<json["results"][0]["info"]["image_colors"].arrayValue.count {
                    self.colorArray.append(changeHexToThreeValue(string: String(describing: json["results"][0]["info"]["image_colors"][i]["html_code"])))
                    
                }
            case .failure(let error):
                print("!!!!!!!!!!")
                print(error)
                showAlert()
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
            self.colorTableView.reloadData()
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath) as? ColorTableViewCell {
            cell.colorBlock.backgroundColor = hexToRGB(string: colorArray[indexPath.row])
            cell.colorLabel.text = colorArray[indexPath.row]
            
            cell.contentView.frame.origin.x += 100
            UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
                cell.contentView.frame.origin.x -= 100
            }, completion:nil)
            
            return cell
        }
        return UITableViewCell()
    }
}
// lauch view the broswer model
class SearchViewController: UIViewController,UITextFieldDelegate {
    var urlForPalette = String()
    var urlForPattern = String()
    @IBOutlet weak internal var textField: UITextField!
    @IBAction func textfFieldTouchOutside(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    var colorArray = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        getUrl()
    }
    func getUrl() {
        urlForPalette = "http://www.colourlovers.com/api/palettes?showPaletteWidths=1&format=json&numResults=20&keywordExact=1&keywords="
        urlForPattern = "http://www.colourlovers.com/api/patterns?format=xml&numResults=20&keywordExact=1&keywords="
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPalettes"{
            if let destinationView = segue.destination as? PalettesTableViewController {
                destinationView.url = self.urlForPalette + textField.text!
            }
        }
        else if segue.identifier == "showPatterns"{
            if let destinationView = segue.destination as? PatternsTableViewController {
                destinationView.url = self.urlForPattern + textField.text!
            }
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textField.resignFirstResponder()
    }
}


//  Classes of detailView
class PalettesDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var flag = false
    var paletteColorArray = [String]()
    var paletteWidthsArray = [String]()
    var colorName = [String]()
    var thing = [NSManagedObject]()
    @IBOutlet weak internal var palettesView: ColorPaletteView!
    var json:JSON = []
    @IBOutlet weak internal var colorTableView: UITableView!
    @IBOutlet weak internal var addbutton: addButton!
    @IBOutlet weak internal var voteNumber: UILabel!
    
    @IBOutlet weak internal var commentNumber: UILabel!
    
    @IBOutlet weak internal var viewNumber: UILabel!
    
    @IBAction func addButton(_ sender: AnyObject) {
        
        if addbutton.hasBeenAdd {
            deleteData()
        }else{
            saveData()
        }
         addbutton.rotate()
        
    }
    func findId(){
        
        // 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Collection")
        
        // 3
        let id = String(describing:json["id"])
        
        // 4
        do {
            let results = try managedContext.fetch(fetchRequest)
            thing = results as! [NSManagedObject]
            
            for each in thing {
                if each.value(forKey: "id") as! String == id {
                   
                    addbutton.rotate()
                    flag = true
                    break
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        
    }
    
    func deleteData(){
        
        // 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Collection")

        // 3
        let id = String(describing:json["id"])
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            thing = results as! [NSManagedObject]
            
            for each in thing {
                if each.value(forKey: "id") as! String == id {
                    managedContext.delete(each)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        do {
            try managedContext.save()
            
        } catch let err as NSError {
            print(err)
        }
    }
    
    func saveData() {
        
        // 1
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Collection",in: managedContext)
        let person = NSManagedObject.init(entity: entity!, insertInto: managedContext)
        
        // 3
        person.setValue(String(describing:json["id"]), forKey: "id")
        person.setValue(String(describing:json),forKey: "json")
        
        // 4
        do {
            try managedContext.save()
            thing.append(person)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        colorTableView.delegate = self
        colorTableView.dataSource = self
        palettesView.colorArray = paletteColorArray
        palettesView.widthArray = paletteWidthsArray
        view.layoutIfNeeded()
        palettesView.layColorBlock()
        findId()
        self.commentNumber.text = "\(self.json["numComments"])"
        self.viewNumber.text = "\(self.json["numViews"])"
        self.voteNumber.text = "\(self.json["numVotes"])"
    
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if flag {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: .allowUserInteraction, animations: {() -> Void in
                self.addbutton.frame.origin.y += 32
            }, completion: nil)
            flag = false
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showColor" {
            let dv = segue.destination as! ColorDetailViewController
            if (colorTableView.cellForRow(at: colorTableView.indexPathForSelectedRow!) as! ColorTableViewCell).closestColor != " " {
                dv.url = "http://www.colr.org/json/color/" + (colorTableView.cellForRow(at: colorTableView.indexPathForSelectedRow!) as! ColorTableViewCell).closestColor
                
            }else{
                dv.url = "http://www.colr.org/json/color/" + paletteColorArray[(colorTableView.indexPathForSelectedRow?.row)!]
                
            }
            dv.hexString = self.paletteColorArray[(colorTableView.indexPathForSelectedRow?.row)!]
            dv.name = (colorTableView.cellForRow(at: colorTableView.indexPathForSelectedRow!) as! ColorTableViewCell).colorName.text!
           
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.palettesView.frame.origin.x += 200
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
            self.palettesView.frame.origin.x -= 200
        }, completion:nil)
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paletteColorArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "colorCell", for: indexPath) as? ColorTableViewCell {
            cell.colorBlock.backgroundColor = hexToRGB(string: paletteColorArray[indexPath.row])
            cell.colorLabel.text = paletteColorArray[indexPath.row]
            
            let url = "http://thecolorapi.com/id?&format=json&hex=" + paletteColorArray[indexPath.row]
            Alamofire.request(url, method: .get ).validate().responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    cell.colorName.text = String(describing:json["name"]["value"])
                    cell.closestColor = changeHexToThreeValue(string: String(describing:json["name"]["closest_named_hex"]))
                case .failure(let error):
                    print(error)
                    showAlert()
                }
                
            }
            
            cell.contentView.frame.origin.x += 100
            UIView.animate(withDuration: 0.6, delay: 0.1, usingSpringWithDamping: 0.75, initialSpringVelocity: 5.0, options: .allowUserInteraction, animations: {() -> Void in
                cell.contentView.frame.origin.x -= 100
            }, completion:nil)
            
            return cell
        }
        
        return UITableViewCell()
    }
}

class ColorTableViewCell: UITableViewCell {
    var closestColor = " "
    @IBOutlet weak internal var colorBlock: UIView!
    @IBOutlet weak internal var colorLabel: UILabel!
    @IBOutlet weak var colorName: UILabel!
    override func awakeFromNib() {
        colorBlock.layer.cornerRadius = colorBlock.frame.width/2
    }

}

public func showAlert(){
    let alert: UIAlertView = UIAlertView(title: "Networking goes error ", message: "Please check your Network.", delegate: nil, cancelButtonTitle: "OK")
    alert.show()
}




