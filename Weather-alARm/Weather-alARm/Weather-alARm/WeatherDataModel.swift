//
//  WeatherDataModel.swift
//  Weather-alARm
//
//  Created by Wilson Zhang on 10/6/18.
//  Copyright © 2018 Wilson Zhang. All rights reserved.
//

import UIKit

class WeatherDataModel {
    var weatherType : Int = 0
    var currentTemp : Int = 0
    var maxTemp : Int = 0
    var minTemp : Int = 0
    var weatherTypeString : String = ""
    
    func updateWeatherType(weatherType: Int) -> String {
        switch weatherType {
        case 1..<5:
            return "sunny"
        case 5..<12:
            return "cloudy"
        case 12..<15:
            return "showers"
        case 15..<18:
            return "thunderStorm"
        case 18:
            return "rainy"
        default:
            return "cloudy"
        }
    }

}
