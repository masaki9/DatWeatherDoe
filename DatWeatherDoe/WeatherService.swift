//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import SwiftHTTP
import CoreLocation

class WeatherService {

    let apiUrl = "http://api.openweathermap.org/data/2.5/weather"
    let appIdString = "appid"
    let appId: String

    init() {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist"),
            let plist = NSDictionary(contentsOfFile: filePath),
            let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
            fatalError()
        }
        self.appId = appId
    }

    // Zipcode-based weather
    func getWeather(zipCode: String, unit: String,
                    completion: @escaping (_ currentTempString: String, _ iconString: String) -> Void) {
        HTTP.GET(apiUrl, parameters: ["zip": zipCode, appIdString: appId]) { [weak self] response in
            if response.error != nil { return }
            self?.parseResponse(response, unit: unit, completion: completion)
        }
    }

    // Location-based weather
    func getWeather(location: CLLocationCoordinate2D, unit: String,
                    completion: @escaping (_ currentTempString: String,
                    _ iconString: String) -> Void) {
        HTTP.GET(apiUrl, parameters: ["lat": String(describing: location.latitude),
                                      "lon": String(describing: location.longitude),
                                      appIdString: appId]) { [weak self] response in
            if response.error != nil { return }
            self?.parseResponse(response, unit: unit, completion: completion)
        }
    }

    // Response
    func parseResponse(_ resp: Response, unit: String, completion:
        (_ currentTempString: String, _ iconString: String) -> Void) {
        guard let response = try? JSONDecoder().decode(
            WeatherResponse.self, from: resp.data) else { return }
        completion(response.temperatureString!, response.icon!)
    }
}
