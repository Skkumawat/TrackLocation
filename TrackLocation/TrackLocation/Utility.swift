//
//  Utility.swift
//  TrackLocation
//
//  Created by Sharvan Kumawat on 05/09/17.
//  Copyright © 2017 Sharvan Kumawat. All rights reserved.
//

import Foundation
import UIKit

class Utility: NSObject {
    
    static let locationDenied  = "TrackLocation was not granted access to your device's Location so you cannot use this feature. To change this, open the Settings application on your iOS, touch Privacy, then Location Services, then turn the switch on for TrackLocation"
   
    
    
    //static let sharedInstance = Utility()
    
    class func showAlert(title: String, message: String, view: UIViewController){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        
        view.present(alertController, animated: true, completion: nil)
    }
    
   class func getCuttentTime() -> String{
    
    let dateFormatter = DateFormatter()
     dateFormatter.locale = NSLocale.current
     dateFormatter.dateFormat = "dd/MM/yy-HH:mm:ss:sss"
    return dateFormatter.string(from: Date())
        
    }
    
}

