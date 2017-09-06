//
//  LocationManager.swift
//  TrackLocation
//
//  Created by Sharvan Kumawat on 05/09/17.
//  Copyright © 2017 Sharvan Kumawat. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    var locationManagerClosures: [((_ userLocation: CLLocation?) -> ())] = []
    var locationAuthrizationClosures: [((_ isAuthorization: Bool) -> ())] = []
    
    
    
    lazy var manager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .automotiveNavigation
        _locationManager.distanceFilter = 10.0  // Movement threshold for new events
        _locationManager.allowsBackgroundLocationUpdates = true // allow in background
        
        return _locationManager
    }()

    func locationAuthorization(isAuthorizationClosure: (@escaping ((_ isAuthorization: Bool) -> ()))) {
         self.locationAuthrizationClosures.append(isAuthorizationClosure)
        if CLLocationManager.locationServicesEnabled() {
            //Then check whether the user has granted you permission to get his location
            if CLLocationManager.authorizationStatus() == .notDetermined {
                //Request permission
                manager.requestWhenInUseAuthorization()
                
            } else if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                callAuthorizationClosure(Authorization: false)
                
            } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways{
                // This will trigger the locationManager:didUpdateLocation delegate method to get called when the next available location of the user is available
               callAuthorizationClosure(Authorization: true)
             
            }
        }
    }
    
    func callAuthorizationClosure(Authorization: Bool) {
        for closure in self.locationAuthrizationClosures {
            closure(Authorization)
            break
        }
        self.locationAuthrizationClosures = []
    }
    //This is the main method for getting the users location and will pass back the usersLocation and isAuthorized status when it is available
    func getlocationForUser(userLocationClosure: @escaping ((_ userLocation: CLLocation?) -> ())) {
        
        self.locationManagerClosures.append(userLocationClosure)
        
         manager.startUpdatingLocation()
        
        //First need to check if the apple device has location services availabel.
        
        
    }
    func stoplocationForUser() {
         manager.stopUpdatingLocation()
    }
    
    func getPlacemark(forLocation location: CLLocation, completionHandler: @escaping (CLPlacemark?, String?) -> ()) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {
            placemarks, error in
            
            if let err = error {
                completionHandler(nil, err.localizedDescription)
            } else if let placemarkArray = placemarks {
                if let placemark = placemarkArray.first {
                    completionHandler(placemark, nil)
                } else {
                    completionHandler(nil, "Placemark was nil")
                }
            } else {
                completionHandler(nil, "Unknown error")
            }
        })
        
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            callAuthorizationClosure(Authorization: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //These userLocation closures will have been stored in the locationManagerClosures array so now that we have the users location we can pass the users location into all of them and then reset the array.
        let tempClosures = self.locationManagerClosures
        for closure in tempClosures {
            closure(locations.first)
        }
        self.locationManagerClosures = []
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
}
