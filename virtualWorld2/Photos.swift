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
    
   
  convenience  init(photoUrl:String,id: String, pin: Pin,context: NSManagedObjectContext){
        let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context)
        self.init(entity: ent!, insertInto: context)
        self.url = photoUrl
        self.pin = pin
        self.id = id
        self.image = nil
    }
    
}
