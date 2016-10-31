//
//  Photos+CoreDataClass.swift
//  virtualWorld2
//
//  Created by Arjun Baru on 24/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import CoreData
import UIKit
@objc(Photos)

public class Photos: NSManagedObject {
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
     init(photoUrl:String,id: String,filePath: String, pin: Pin,context: NSManagedObjectContext){
        let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context)
        super.init(entity: ent!, insertInto: context)
        self.url = photoUrl
        self.pin = pin
        self.id = id
        self.filePath = filePath
    }
    
}
