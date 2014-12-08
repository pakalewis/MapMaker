//
//  Reminder.swift
//  MapMaker
//
//  Created by Parker Lewis on 11/4/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Reminder: NSManagedObject {
    
    @NSManaged var identifier: String
    @NSManaged var date: NSDate
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var radius: Double
    

    func makeCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
