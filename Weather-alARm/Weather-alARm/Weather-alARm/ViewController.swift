//
//  ViewController.swift
//  Weather-alARm
//
//  Created by Zhiling Wang on 10/6/18.
//  Copyright © 2018 Wilson Zhang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var CityLabel: UILabel!
    @IBOutlet weak var getWeatherDataButton: UIButton!
    
    // Instance Variables.
    let locationManager = CLLocationManager()
    var lat = 0.0
    var lon = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Show debugging points.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/Cloud.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        /*
         * AR Module below.
         */
        sceneView.autoenablesDefaultLighting = true
        let cloudScene = SCNScene(named: "art.scnassets/Cloud.scn")!
        
        if let cloudNode = cloudScene.rootNode.childNode(withName: "Cloud", recursively: true) {
            cloudNode.position = SCNVector3(x: 0, y: -2, z: -0.1)
            sceneView.scene.rootNode.addChildNode(cloudNode)
        }
        
        /*
         * Networking Module Below.
         */
        
        /*
         * Current Location module.
         */
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func getWeatherData (url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
            }
        }
    }
    
    /*
     * Function for applied the location value (latitude and longitude)
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lat = Double(locValue.latitude)
        lon = Double(locValue.longitude)
    }
    
    func getCity(lat: Double, lon: Double) {
        let CITY_URL = "http://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=HackPSU2018&q=" + String(lat) + "%2C" + String(lon)
        Alamofire.request(CITY_URL, method: .get).responseJSON {
            response in
            print(response)
        }
    }
    @IBAction func getWeatherDataBtPressed(_ sender: Any) {
        getCity(lat: lat, lon: lon)
    }
}
