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
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var WeatLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var getWeatherDataButton: UIButton!
    @IBOutlet weak var overrideTF: UITextField!
    
    // Instance Variables.
    let locationManager = CLLocationManager()
    var lat = 0.0
    var lon = 0.0
    var cityName = ""
    var key = 0
    var weatherArray = [WeatherDataModel]()
    let weatherDataModel = WeatherDataModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        // Show debugging points.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        
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
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
            
            configuration.detectionImages = imageToTrack
            
            configuration.maximumNumberOfTrackedImages = 1
            
            print("Images Successfully Added")
            
            
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func ARObjManipulation () {
        print(weatherDataModel.weatherTypeString)
        let sceneName = "art.scnassets/" + weatherDataModel.weatherTypeString + ".scn"
        let scene = SCNScene(named: sceneName)!
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        let cloudScene = SCNScene(named: sceneName)!
        if let cloudNode = cloudScene.rootNode.childNode(withName: "Cloud", recursively: true) {
            cloudNode.position = SCNVector3(x: -1, y: 0, z: 2)
            sceneView.scene.rootNode.addChildNode(cloudNode)
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
            // print(response)
            let cityJSON : JSON = JSON(response.result.value!)
            self.cityName = cityJSON["EnglishName"].stringValue
            self.key = cityJSON["Key"].intValue
            
            print("\(self.cityName) || \(self.key)")
            self.getWeather(id: self.key)
        }
    }
    
    func getWeather(id: Int) {
        let weatherURL = "http://dataservice.accuweather.com/forecasts/v1/daily/1day/" + String(id) + "?apikey=HackPSU2018"
        Alamofire.request(weatherURL, method: .get).responseJSON {
            response in
            let weatherJSON : JSON = JSON(response.result.value!)
            print(weatherJSON)
            let maxTemp = weatherJSON["DailyForecasts"][0]["Temperature"]["Maximum"]["Value"].intValue
            print(maxTemp)
            let minTemp = weatherJSON["DailyForecasts"][0]["Temperature"]["Minimum"]["Value"].intValue
            let weaType = weatherJSON["DailyForecasts"][0]["Day"]["Icon"].intValue
            let date = weatherJSON["DailyForecasts"][0]["Date"].stringValue
            self.updateWeatherData(maxTemp: maxTemp, minTemp: minTemp, weaType: weaType, date: date)
        }
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
    
    func updateWeatherData (maxTemp: Int, minTemp: Int, weaType: Int, date: String) {
        weatherDataModel.maxTemp = maxTemp
        weatherDataModel.minTemp = minTemp
        weatherDataModel.weatherType = weaType
        weatherDataModel.weatherTypeString = weatherDataModel.updateWeatherType(weatherType: weatherDataModel.weatherType)
        weatherDataModel.currentDate = date
    }
    
    func updateUI() {
        CityLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        CityLabel.text = cityName
        CityLabel.sizeToFit()
        TempLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        TempLabel.text = String(weatherDataModel.minTemp) + " to " + String(weatherDataModel.maxTemp) + " F"
        TempLabel.sizeToFit()
        WeatLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        WeatLabel.text = weatherDataModel.weatherTypeString
        WeatLabel.sizeToFit()
        DateLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
        DateLabel.text = weatherDataModel.currentDate
        print("Current City: \(cityName)")
        print("Current Temp: \(weatherDataModel.minTemp) to \(weatherDataModel.maxTemp)")
        print("Current Weather: \(weatherDataModel.weatherTypeString)")
    }
    
    @IBAction func getWeatherDataBtPressed(_ sender: Any) {
        getCity(lat: lat, lon: lon)
        updateUI()
    }
    @IBAction func GenerateBtPressed(_ sender: Any) {
        ARObjManipulation()
    }
    @IBAction func OverrideBtPressed(_ sender: Any) {
        if overrideTF.text == nil {
            print("Empty String inside the TextField")
            return
        } else {
            let sceneName = "art.scnassets/" + overrideTF.text! + ".scn"
            if let scene = SCNScene(named: sceneName) {
                sceneView.scene = scene
                sceneView.autoenablesDefaultLighting = true
                let cloudScene = SCNScene(named: sceneName)!
                if let cloudNode = cloudScene.rootNode.childNode(withName: "Cloud", recursively: true) {
                    cloudNode.position = SCNVector3(x: -1, y: 0, z: 2)
                    sceneView.scene.rootNode.addChildNode(cloudNode)
                }
                
            }
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
        }

        return node
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "trackingSegue" {
            let VC = segue.destination as! TrackingViewController
            VC.currentWeather = weatherDataModel.weatherTypeString
        }
    }
}
