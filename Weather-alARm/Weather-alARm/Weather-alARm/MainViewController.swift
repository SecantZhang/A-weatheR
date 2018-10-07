//
//  MainViewController.swift
//  Weather-alARm
//
//  Created by Zhiling Wang on 10/6/18.
//  Copyright © 2018 Wilson Zhang. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON

class MainViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayDataModel.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let imageString = arrayDataModel[indexPath.item + 1].weatherTypeString + "-100"
        cell.ImageView.image = UIImage(named: imageString)
        cell.weatherLabel.text = arrayDataModel[indexPath.item + 1].weatherTypeString
        cell.tempLabel.text = String(arrayDataModel[indexPath.item + 1].currentTemp)
        cell.hourIndicatorLabel.text = String(indexPath.item + 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 221, height: 228)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    

    @IBOutlet weak var weatherIconIV: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var CView: UICollectionView!
    
    var lat = 0.0
    var lon = 0.0
    var cityName = ""
    var key = 0
    
    let locationManager = CLLocationManager()
    let dataModel = WeatherDataModel()
    var arrayDataModel = [WeatherDataModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getCurrentData()
        
    }
    
    func getCurrentData () {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
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
        let weatherURL = "http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/" + String(id) + "?apikey=HackPSU2018"
        Alamofire.request(weatherURL, method: .get).responseJSON {
            response in
            let weatherJSON : JSON = JSON(response.result.value!)
            for i in 0..<6 {
                print(weatherJSON[i]["Temperature"]["Value"].intValue)
                print(weatherJSON[i]["WeatherIcon"].intValue)
                self.arrayDataModel.append(
                    self.updateWeatherData(temp: weatherJSON[i]["Temperature"]["Value"].intValue,
                                           icon: weatherJSON[i]["WeatherIcon"].intValue))
            }
        }
        print(arrayDataModel)
    }
    @IBAction func getDataBtPressed(_ sender: Any) {
        getCity(lat: lat, lon: lon)
        // updateUIs()
    }
    
    func updateWeatherData (temp: Int, icon: Int) -> WeatherDataModel {
        let weatherDataModel = WeatherDataModel()
        weatherDataModel.currentTemp = temp
        weatherDataModel.weatherTypeString = weatherDataModel.updateWeatherType(weatherType: icon)
        return weatherDataModel
    }
    
    func updateUIs () {
        CView.reloadData()
        let imageString = "cloudy-100"
        weatherIconIV.image = UIImage(named: imageString)
        // tempLabel.text = String(arrayDataModel[1].currentTemp)
        
    }
}
