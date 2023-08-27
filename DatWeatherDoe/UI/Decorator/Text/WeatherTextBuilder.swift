//
//  WeatherTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import OSLog

protocol WeatherTextBuilderType {
    func build() -> String
}

final class WeatherTextBuilder: WeatherTextBuilderType {
    
    struct Options {
        let isWeatherConditionAsTextEnabled: Bool
        let valueSeparator: String
        let temperatureOptions: TemperatureTextBuilder.Options
        let isShowingHumidity: Bool
    }
    
    private let response: WeatherAPIResponse
    private let options: Options
    private let logger: Logger
    
    init(
        response: WeatherAPIResponse,
        options: Options,
        logger: Logger
    ) {
        self.response = response
        self.options = options
        self.logger = logger
    }
    
    func build() -> String {
        let finalString = buildWeatherConditionAsText() |>
        appendTemperatureAsText |>
        appendHumidityText
        
        return finalString
    }
    
    private func buildWeatherConditionAsText() -> String? {
        guard options.isWeatherConditionAsTextEnabled else { return nil }
        
        let weatherCondition = WeatherConditionBuilder(response: response).build()
        return WeatherConditionTextMapper().map(weatherCondition)
    }
    
    private func appendTemperatureAsText(initial: String?) -> String {
        TemperatureTextBuilder(
            initial: initial,
            response: response,
            options: options.temperatureOptions,
            temperatureCreator: TemperatureWithDegreesCreator()
        ).build()
    }
    
    private func appendHumidityText(initial: String) -> String {
        guard options.isShowingHumidity else { return initial }
        
        return HumidityTextBuilder(
            initial: initial,
            valueSeparator: options.valueSeparator,
            humidity: response.humidity,
            logger: logger
        ).build()
    }
}

precedencegroup ForwardPipe {
    associativity: left
}

infix operator |>: ForwardPipe

private func |> <T, U>(value: T, function: (T) -> U) -> U {
    function(value)
}
