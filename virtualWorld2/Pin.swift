//
//  Pin+CoreDataClass.swift
//  virtualWorld2
//
//  Created by Arjun Baru on 24/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Pin: NSManagedObject {
    
    
   convenience init(lat: Double, long: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.lat = lat
        self.long = long
        self.pageNumber = 0
    
    }
    
}
