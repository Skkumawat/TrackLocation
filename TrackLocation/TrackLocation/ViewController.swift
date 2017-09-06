//
//  ViewController.swift
//  TrackLocation
//
//  Created by Sharvan Kumawat on 05/09/17.
//  Copyright © 2017 Sharvan Kumawat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var locationTrack: UISwitch!
    let locationManager = LocationManager()
    let coreDataManager = CoreDataManager()
    var timer = Timer()
    var lastSpeed = 0.0
    var isSpeedDroppedSuddenly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Track Location"
        
        locationManager.locationAuthorization() { (isAuthorization) in
            if isAuthorization == true{
                self.setTimer(interval: 30)
            }
            else{
               Utility.showAlert(title: "", message: Utility.locationDenied, view: self)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /**
     Create function for Timer according to an interval.
     @param interval 30/60/120/300
     @return
     @exception
     */
    func setTimer(interval: Int) {
        self.invalidateTimer()
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(getUserCurrentLocation(timer:)), userInfo: interval, repeats: false)
    }
    /**
     Create function for stop the timer.
     @param
     @return
     @exception
     */
    func invalidateTimer() {
        timer.invalidate()
        
    }
    /**
     Create function for track user location on/off.
     @param
     @return
     @exception
     */
    @IBAction func traclLocation(){
        if locationTrack.isOn {
            self.setTimer(interval: 30)
        }
        else{
            stopUserCurrentLocation()
            
        }
    }
    /**
     Create function for get user current location.
     @param
     @return
     @exception
     */
    func getUserCurrentLocation(timer: Timer!){
        let currentTime = timer.userInfo as! Int
        
        if currentTime > 0
        {
            self.locationManager.getlocationForUser { userLocation -> () in
                guard let location = userLocation else {
                    print("Location Not Found")
                    return
                }
                print("**********************")
                print("Long \(location.coordinate.longitude)")
                print("Lati \(location.coordinate.latitude)")
                print("Sped \(location.speed)")
                print("**********************")
                
                self.locationManager.getPlacemark(forLocation: location, completionHandler: { (plackMark) in
                    var address = ""
                    var nextTime = 0
                    if let place = plackMark.0{
                        address = place.name! + ", " +  place.thoroughfare! + ", " + place.locality! + ", " +  place.administrativeArea! + ", " + place.country! + ", " +  place.postalCode!
                    }
                    
                    if self.isSpeedDroppedSuddenly == true {
                        
                        if self.lastSpeed > 60.0 {
                            
                            self.isSpeedDroppedSuddenly = true
                            
                            if self.lastSpeed >= 80.0 {
                                nextTime = 60
                                self.lastSpeed = 70.0
                                
                            } else if self.lastSpeed >= 60.0 {
                                nextTime = 120
                                self.lastSpeed = 20.0
                                
                            }
                            
                        } else {
                            self.lastSpeed = location.speed
                            nextTime = 300
                            self.isSpeedDroppedSuddenly = false
                        }
                        
                    } else {
                        
                        if self.lastSpeed >= 80
                        {
                            nextTime = 30
                        }
                        else if self.lastSpeed < 80  && self.lastSpeed >= 60
                        {
                            nextTime = 60
                        }
                        else if self.lastSpeed < 60  && self.lastSpeed >= 30
                        {
                            nextTime = 120
                        }
                        else if self.lastSpeed < 30
                        {
                            if self.lastSpeed > 30.0 {
                                
                                self.isSpeedDroppedSuddenly = true
                                
                                if self.lastSpeed >= 80.0 {
                                    nextTime = 60
                                    self.lastSpeed = 70.0
                                    
                                } else if self.lastSpeed >= 60.0 {
                                    nextTime = 120
                                    self.lastSpeed = 20.0
                                }
                                
                            } else {
                                nextTime = 300
                                
                            }
                            
                        }
                        
                    }
                    if self.isSpeedDroppedSuddenly == false {
                        self.lastSpeed = location.speed
                    }
                    
                    self.setTimer(interval: nextTime)
                    
                    self.coreDataManager.saveData(location: address, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, currentTime: currentTime, nextTime: nextTime)
                })
            }
        }
        
    }
    /**
     Create function for stop user current location.
     @param
     @return
     @exception
     */
    func stopUserCurrentLocation()
    {
        self.locationManager.stoplocationForUser()
        self.invalidateTimer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

