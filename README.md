#ColorNote

A mashup-based app based on integrating Web APIs. Integrate information of colors from different providers and enable the user to make individual color scheme.

##Introduction
As a designer and developer, somtimes I will be confused if I can't decide what color to use on a product. To deal with this situation, I developed this application on iOS.
ColorNote enables the users to browse color palettes and color patterns from the Internet(mainly from [COLOURLover.com](http://www.colourlovers.com)) and get detail information about them, and even made color palettes by themselves.

##Mainly Used Third-party Services
###1. Public APIs
* [COLOURlovers](http://www.colourlovers.com/api)
* [The Color](http://www.thecolorapi.com)
* [IMAGE COLOR SUMMARIZER](http://mkweb.bcgsc.ca/color-summarizer/?api)
* [imagga](https://imagga.com)

###2. Open Source Libraries
* [Alamofire](https://github.com/Alamofire/Alamofire) : Swift based HTTP networking library.
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) : Swift based JSON handling library.
* [SWXMLHash](https://github.com/drmohundro/SWXMLHash) : Swift based XML handling library.
* [ImageLoader](https://github.com/hirohisa/ImageLoaderSwift) : Swift based web image loader library.

##Configuration and Deployment Description
###Development environment:
1. Xcode 8.1
2. Swift 3.03. iOS Simulator 10.0 
4. Cocoapods 1.0.1 
5. Git 2.8.4

###Configurations:
1. download from zip / git clone
											
`$ git clone https://github.com/exitraZhao/ColorNote/tree/master-Imageloader`

2. install cocoapod libraries

`$ pod install`

3. open `ColorNote.xcworkspace` 

##Design and Implementation
###Data Structure
* Fetching data from APIs by Alamofire

```swift
Alamofire.request(url, method: .get ).validate().responseJSON { response in
            
            switch response.result {
            case .success(let value):
                self.json = JSON(value)
            case .failure(let error):
                print(error)
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
            self.palettesTableView.reloadData()
        }


```
* Using SwiftyJSON to prase json data

```
Alamofire.request(analysis, method: .get, headers: headers).responseJSON {response in
            
            switch response.result {
            case .success(let value):
                var json = JSON(value)

                print(json["results"][0]["info"]["image_colors"].arrayValue.count)
                for i in 0..<json["results"][0]["info"]["image_colors"].arrayValue.count {
                    self.colorArray.append(changeHexToThreeValue(string: String(describing: json["results"][0]["info"]["image_colors"][i]["html_code"])))
                    
                }
            case .failure(let error):
                print(error)
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
            self.colorTableView.reloadData()
        }
```
* Using SWXMLHash to prase xml data

```
 Alamofire.request(url, method: .get ).validate().responseData { response in
            
            switch response.result {
            case .success(let value):
                self.xml = SWXMLHash.parse(String.init(data: value, encoding: String.Encoding.utf8)!) 
                self.patternsTableView.reloadData()
            case .failure(let error):
                print(error)
            }
            loadingIndicator.stopAnimating()
            alert.dismiss(withClickedButtonIndex: 0, animated: true)
        }

```
* Using ImageLoader to load image and store them into cache temporarily

Because it is hard for me to implement the sychronously loading for images, so that i use this library to implement it.

```
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
                                var alert: UIAlertView = UIAlertView(title: "Networking goes error ", message: "Please check your Network.", delegate: nil, cancelButtonTitle: "OK")
                                alert.show()
                            }
                        }
                    }
        

```

###Data Storage

* Using Core Data to store data

```
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
```

###User Interfaces
Since I am already have a decision to build a iOS app all by my self, I also spend times on designing the UI for my `ColorNote` thoughtfully.

* **home page**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_280.PNG)

* **PalettesTableView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2801.PNG)

* **PalettesDetailView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2802.PNG)

* **ColorDetailView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2803.PNG)

* **CollectionView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2804.PNG)

* **PalettesTableView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2805.PNG)

* **PalettesDetailView**

![General preferences pane](/Users/zhaoyida/Downloads/IMG_2806.PNG)


##Pros and Cons

This is my first time to develop a app all by myself, feels exhausted but actually learned a lot.

* Cons

	I'm not practise on managing a framework of a whole application, so these codes coded by me is not elegant,
	I will refactor them.
	
* Pros

	I'm keen on enhancing the user experience, so i spend a lot time to design a easy-to-use user interface, althought the app is still not completed, but i gives the users a good experience.
	