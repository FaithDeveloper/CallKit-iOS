//
//  ViewController.swift
//  SampleCallKit
//
//  Created by MAC on 2017. 12. 10..
//  Copyright © 2017년 MAC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var progressbar: UIActivityIndicatorView!
    @IBOutlet weak var viewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressbar.startAnimating()
        
        self.viewLabel.isHidden = true
        self.saveUserData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Group의 UserDefaults에 DB 데이터를 저장합니다.
    func saveUserData(){
        let userDefaults = UserDefaults(suiteName: "group.com.kcs.samepleCallkit")
        let userData = loadJsonFile()
        
        try? userDefaults?.set(PropertyListEncoder().encode(userData), forKey: "dbData")
        
        progressbar.stopAnimating()
        viewLabel.isHidden = false
    }
    
    // DB Data load Json File
    func loadJsonFile() -> Array<UserData>{
        var dbData: Array<UserData> = Array<UserData>()
        
        do {
            if let file  = Bundle.main.url(forResource: "DBData", withExtension: "json"){
                let data  = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                
                if let objects = json as? [Any]{
                    for object in objects {
                        dbData.append(UserData.dataFormJSONObject(json: object as! [String : AnyObject])!)
                    }
                } else{
                    print("JSON is invalid")
                }
            }else{
                print("no file")
            }
        }  catch {
            print(error.localizedDescription)
        }
        
        return dbData
    }
}

