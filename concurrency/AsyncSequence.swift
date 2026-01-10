//
//  AsyncSequence.swift
//  LinkedInPosts
//
//  Created by Константин Клинов on 11/01/26.
//

import Foundation

// MARK: - Models
struct WeatherUpdate {
    let temperature: Double
    let value: Double
}

// MARK: - Services
class WeatherService {
    func subscribe(completion: @escaping (Result<WeatherUpdate, Error>) -> Void) {
        // Simulates callback-based API
    }
    
    func stream() -> AsyncStream<WeatherUpdate> {
        AsyncStream { continuation in
            // Simulates async stream
            continuation.yield(WeatherUpdate(temperature: 75, value: 75))
        }
    }
}

class NotificationService {
    func sendAlert(_ message: String) async {
        // Sends notification
    }
}

// MARK: - Example Usage

// ❌ BEFORE: Callback Hell - Nested, hard to follow
class ViewController {
    var temperature: Double = 0
    let weatherService = WeatherService()
    let notificationService = NotificationService()
    
    func fetchNextUpdate(completion: @escaping (Result<WeatherUpdate, Error>) -> Void) {
        // Simulates another async operation
    }
    
    func processData(_ data: WeatherUpdate, completion: @escaping (Bool) -> Void) {
        // Simulates data processing
    }
}

func testWays() {

    let vc = ViewController()
    // ❌ BEFORE: Callback Hell - Nested, hard to follow
    vc.weatherService.subscribe { result in
        switch result {
        case .success(let update):
            DispatchQueue.main.async {
                vc.temperature = update.value
                vc.fetchNextUpdate { nextResult in
                    switch nextResult {
                    case .success(let next):
                        vc.processData(next) { processed in
                            // Deep nesting continues...
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        case .failure(let error):
            print(error)
        }
    }

    // ✅ AFTER: Async/Await - Clean, sequential, readable
    Task {
        for await update in vc.weatherService.stream() {
            vc.temperature = update.value
        }
    }

    // ✅ BONUS: Complex logic stays readable
    Task {
        for await update in vc.weatherService.stream() {
            // Filter
            guard update.temperature > 0 else { continue }
            
            // Transform
            let fahrenheit = update.temperature * 9/5 + 32
            vc.temperature = fahrenheit
            
            // Conditional async operations - no nesting!
            if fahrenheit > 80 {
                await vc.notificationService.sendAlert("High temp: \(fahrenheit)°F")
            }
        }
    }
}
