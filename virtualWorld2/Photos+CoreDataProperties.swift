//
//  Photos+CoreDataProperties.swift
//  virtualWorld2
//
//  Created by Arjun Baru on 24/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var filePath: String?
    @NSManaged public var pin: Pin?
    @NSManaged public var image: NSData?

}
