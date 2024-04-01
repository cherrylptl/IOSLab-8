import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    
    var Locationlatitude : Double = 0.0
    var Locationlongitude : Double = 0.0
    let apiKeyID = "d324702e67d2d8f98ceb69c10631e313"
    
    let locationManager : CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
        Locationlatitude = location.coordinate.latitude
        Locationlongitude = location.coordinate.longitude
        getWeather(latitude: Locationlatitude, longitude: Locationlongitude)
      }
    }

    //Get Weather Data
    func getWeather(latitude: Double, longitude: Double) {
        
      guard
        let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKeyID)&units=metric")
      else {
        return
      }

      let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
          print("Error:", error)
          return
        }

        guard let data = data else {
          print("No data Found")
          return
        }

        do {
          let jsonDecoder = JSONDecoder()
          let weatherData = try jsonDecoder.decode(Temperatures.self, from: data)

          //Update UI
          DispatchQueue.main.async {
              
            //Set city name
            self.city.text = weatherData.name
              
            //Set Weather
            self.weather.text = weatherData.weather.last?.main
            if let url = URL(
              string: "https://openweathermap.org/img/wn/\(weatherData.weather.last?.icon ?? "").png"
            ) {
                
            //Set Weather Image
              self.getWeatherIcon(from: url)
            }
              
            //Set Temperature
            self.temperature.text = "\(weatherData.main.temp) °C"
              
            //Set Humidity
            self.humidity.text = "Humdity : \(weatherData.main.humidity) %"
              
            //Set Wind Speed
              self.windSpeed.text = "Wind : \(weatherData.wind.speed!*3.6) km/h"
              
          }

        } catch {
          print("Error decoding JSON:", error)
        }
      }
      task.resume()
    }

    func getWeatherIcon(from url: URL) {
      URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data else { return }

        if let error = error {
          print("Error downloading image: \(error.localizedDescription)")
          return
        }

        guard let image = UIImage(data: data) else {
          print("Failed to create image from data")
          return
        }

        DispatchQueue.main.async {
            
        //Set Weather Image
          self.weatherIcon.image = image
        }
      }.resume()
    }
}

