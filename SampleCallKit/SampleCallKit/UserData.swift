//
//  UserData.swift
//  SampleCallKit
//
//  Created by MAC on 2017. 12. 10..
//  Copyright © 2017년 MAC. All rights reserved.
//


import Foundation

class UserData : Codable{
    var phoneNumber: String = ""
    var name: String = ""
    
    init(phoneNumber: String, name : String){
        self.phoneNumber = phoneNumber
        self.name = name
    }
    
    public static func dataFormJSONObject(json: [String: AnyObject]) -> UserData? {
        guard
            let phoneNumber = json["phoneNumber"] as? String,
            let name = json["name"] as? String
            else {
                return nil
        }
        let data = UserData(phoneNumber: phoneNumber, name: name)
        
        return data
    }
}

