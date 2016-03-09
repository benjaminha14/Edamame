//
//  MapViewController.swift
//  ActualWaterSensor
//
//  Created by Ben Ha on 1/16/16.
//  Copyright © 2016 Ben Ha. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Parse
class MapViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate{
    

    @IBOutlet weak var map: MKMapView!
     var manager:CLLocationManager!
     var someArray = [CLLocationDegrees]()
    var userLongitude: CLLocationDegrees = 0.0
    var userLattitude: CLLocationDegrees = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()

        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        


        
    }
    @IBAction func
        logTapp(sender: AnyObject) {
        let waterData = PFObject(className:"waterData")
        let point = PFGeoPoint(latitude:userLattitude, longitude:userLongitude)
            waterData["location"] = point
        
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        
        //userLocation - there is no need for casting, because we are now using CLLocation object
        
        let userLocation:CLLocation = locations[0]
        
        let latitude:CLLocationDegrees = userLocation.coordinate.latitude
        userLattitude = latitude
        
        let longitude:CLLocationDegrees = userLocation.coordinate.longitude
        userLongitude = longitude
        
        let latDelta:CLLocationDegrees = 0.05
        
        let lonDelta:CLLocationDegrees = 0.05
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: false)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
