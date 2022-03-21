//
//  ConfigureViewModel.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 3/20/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Combine
import Foundation

final class ConfigureViewModel: ObservableObject {
    
    @Published var temperateUnit: TemperatureUnit {
        didSet { configManager.temperatureUnit = temperateUnit.rawValue }
    }
    
    @Published var weatherSource: WeatherSource {
        didSet {
            configManager.weatherSource = weatherSource.rawValue
            updateWeatherSource()
        }
    }
    @Published private(set) var weatherSourceTextHint = ""
    @Published private(set) var weatherSourceTextFieldDisabled = false
    @Published private(set) var weatherSourcePlaceholder = ""
    @Published var weatherSourceText = "" {
        didSet { configManager.weatherSourceText = weatherSourceText }
    }
    
    @Published var refreshInterval: RefreshInterval {
        didSet { configManager.refreshInterval = refreshInterval.rawValue }
    }
    
    @Published var isShowingHumidity: Bool {
        didSet { configManager.isShowingHumidity = isShowingHumidity }
    }
    
    @Published var isRoundingOffData: Bool {
        didSet { configManager.isRoundingOffData = isRoundingOffData }
    }
    
    @Published var isWeatherConditionAsTextEnabled: Bool {
        didSet { configManager.isWeatherConditionAsTextEnabled = isWeatherConditionAsTextEnabled }
    }
    
    private let configManager: ConfigManagerType
    private weak var popoverManager: PopoverManager?
    
    init(configManager: ConfigManagerType, popoverManager: PopoverManager?) {
        self.configManager = configManager
        self.popoverManager = popoverManager
        
        temperateUnit = TemperatureUnit(rawValue: configManager.temperatureUnit)!
        weatherSource = WeatherSource(rawValue: configManager.weatherSource)!
       
        switch configManager.refreshInterval {
        case 300: refreshInterval = .fiveMinutes
        case 900: refreshInterval = .fifteenMinutes
        case 1800: refreshInterval = .thirtyMinutes
        case 3600: refreshInterval = .sixtyMinutes
        default: refreshInterval = .oneMinute
        }
        
        isShowingHumidity = configManager.isShowingHumidity
        isRoundingOffData = configManager.isRoundingOffData
        isWeatherConditionAsTextEnabled = configManager.isWeatherConditionAsTextEnabled
        
        updateWeatherSource()
    }
    
    func saveAndCloseConfig() {
        saveConfig(weatherSource: weatherSource, refreshInterval: refreshInterval)
        popoverManager?.togglePopover(nil)
    }
    
    private func updateWeatherSource() {
        weatherSourceTextHint = weatherSource.textHint
        weatherSourceTextFieldDisabled = weatherSource == .location
        if weatherSource == .location {
            weatherSourceText = ""
        }
        weatherSourcePlaceholder = weatherSource.placeholder
    }
    
    private func saveConfig(weatherSource: WeatherSource, refreshInterval: RefreshInterval) {
        let configCommitter = ConfigurationCommitter(configManager: configManager)
        configCommitter.setWeatherSource(weatherSource, sourceText: weatherSourceText)
        configCommitter.setOtherOptionsForConfig(
            refreshInterval: refreshInterval,
            isShowingHumidity: isShowingHumidity,
            isRoundingOffData: isRoundingOffData,
            isWeatherConditionAsTextEnabled: isWeatherConditionAsTextEnabled
        )
    }
}
