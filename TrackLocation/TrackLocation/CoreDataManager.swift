//
//  CoreDataManager.swift
//  TrackLocation
//
//  Created by Sharvan Kumawat on 06/09/17.
//  Copyright © 2017 Sharvan Kumawat. All rights reserved..
//

import Foundation
import UIKit

class CoreDataManager: NSObject {
    
     let appdelgate = (UIApplication.shared.delegate as! AppDelegate)
    
    func saveData(location: String, latitude: Double ,longitude: Double ,currentTime: Int ,nextTime: Int) {
       
        let context = appdelgate.persistentContainer.viewContext
        
        let locationDetails = Location(context: context)
        locationDetails.currentTimeInterval = Int64(currentTime)
        locationDetails.nextTimeInterval = Int64(nextTime)
        locationDetails.location = location
        locationDetails.longitude = longitude
        locationDetails.latitude = latitude
        locationDetails.time = Utility.getCuttentTime()
        
        appdelgate.saveContext()
    }
}
