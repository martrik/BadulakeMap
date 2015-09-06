//
//  ViewController.swift
//  BadulakeMap
//
//  Created by Martí Serra Vivancos on 01/06/15.
//  Copyright (c) 2015 Tomorrow Developers s.c.p. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON


class BMMainVC: UIViewController, CLLocationManagerDelegate {

    var mapView: GMSMapView!
    var locationManager: CLLocationManager!
    var firstTime: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google Map
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86,
            longitude: 151.20, zoom: 6)
        mapView = GMSMapView.mapWithFrame(CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-40), camera: camera)
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
     
        // Nav iamge depending on screen size
        var image = "nav45"
        if (self.view.bounds.size.width == 375) {
            image = "nav6"
        }
        var navImage = UIImageView(image: UIImage(named: image))
        navImage.frame = CGRectMake(0, 0, navImage.frame.size.width, navImage.frame.size.height)
        
        var addButton = UIButton(frame: CGRectMake(self.view.frame.size.width - 40, 25, 30, 30))
        addButton.setImage(UIImage(named: "add"), forState: .Normal)
        addButton.addTarget(self, action: "addBadulakeVC:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(mapView)
        self.view.addSubview(navImage)
        self.view.addSubview(addButton)
    }
    
    // Add and remove observer to location
    override func viewWillAppear(animated: Bool) {
        mapView.addObserver(self, forKeyPath: "myLocation", options: nil, context: nil)
        firstTime = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        mapView.removeObserver(mapView, forKeyPath: "myLocation")
    }
    
    // Gets called when location changes
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "myLocation") {
            
            if (firstTime == true) {
                var sydney = GMSCameraPosition.cameraWithLatitude(mapView.myLocation.coordinate.latitude,
                    longitude: mapView.myLocation.coordinate.longitude, zoom: 16)
                mapView.camera = sydney
                
                println(mapView.myLocation)
                
                feedMap()
                firstTime = false
            }
        }
        
    }
    
    // Feed map with badulakes
    func feedMap () {
        Alamofire.request(.GET, "http://badulakemap.herokuapp.com/badulake", parameters: ["longitude": mapView.myLocation.coordinate.longitude, "latitude" :  mapView.myLocation.coordinate.latitude])
            .responseJSON { (request, response, data, error) in
                
                // Parse response into Swifty JS
                let json = JSON(data!)
                
                let date = NSDate()
                let calendar = NSCalendar.currentCalendar()
                let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
                let hour = components.hour

                
                 // Create marker for each badulake received
                for (index: String, subJson: JSON) in json {
                    var position = CLLocationCoordinate2DMake(subJson["latitude"].double!, subJson["longitude"].double!)
                    var marker = GMSMarker(position: position)
                    marker.title = subJson["name"].string
                    
                    // Change appereance
                    if (subJson["alwaysopened"].bool == true) {
                        marker.snippet = "Opened 24h."
                        marker.icon = UIImage(named: "badu24")
                    } else {
                        marker.icon = UIImage(named: "badu")
                        
                        // Check if time is between 12 and 8
                        if (hour < 8) {
                            marker.opacity = 0.5
                            marker.snippet = "Proably closed"

                        } else {
                            marker.snippet = "Regular schedule"
                        }
                    }
                    
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = self.mapView
                        
                }
                
                if ((error) != nil) {
                    println(error)
                }
        }        
    }
    
    // Add badulake view
    func addBadulakeVC(sender: UIButton!) {
        println("H3llo")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

