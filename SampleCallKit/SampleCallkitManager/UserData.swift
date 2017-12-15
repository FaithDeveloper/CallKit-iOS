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
    
    //json으로 받은 데이터를 저장합니다.
    //json["key"] 로 했을 경우 가져오게됩니다.
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


