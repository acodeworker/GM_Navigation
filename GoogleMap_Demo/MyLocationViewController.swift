// Copyright 2020 Google LLC. All rights reserved.
//
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License. You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.

import GoogleMaps
import GoogleMapsUtils
import GoogleMapsBase
import UIKit

class MyLocationViewController: UIViewController {

  private let cameraLatitude: CLLocationDegrees = -33.868

  private let cameraLongitude: CLLocationDegrees = 151.2086

  private var cameraZoom: Float = 12

//  var observation: NSKeyValueObservation?
  
  var rideManager:RideNavigationManager? = nil

  var locationManager: CLLocationManager!

  override func loadView() {
    view = mapView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    // Opt the MapView into automatic dark mode switching.
    
    rideManager = RideNavigationManager(map: mapView, vc: self)
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    locationManager.distanceFilter = SDKConstants.filterDistance
    locationManager.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    locationManager.startUpdatingLocation()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    locationManager.stopUpdatingLocation()
  }
  
 private func initUI(){
    view.addSubview(actionBtn)
    view.addSubview(gpsLabel)
    NSLayoutConstraint.activate([
      actionBtn.centerXAnchor.constraint(equalTo:view.centerXAnchor),
      actionBtn.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant: -40),
    ])
    NSLayoutConstraint.activate([
      gpsLabel.leftAnchor.constraint(equalTo:view.leftAnchor,constant: 2),
      gpsLabel.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant: -60),
    ])
  }

 
  
  @objc func startAction()  {
    rideManager?.startAction()
  }
  
  func getGPSStrength(_ location:CLLocation)->Bool{
    let horizontalAccuracy = location.horizontalAccuracy
    var strengthWeak:Bool = false
    if 0 > horizontalAccuracy || horizontalAccuracy > 100{
      strengthWeak = true
      self.gpsLabel.text = "GPS:weak"
    }else if horizontalAccuracy <= 20 {
      self.gpsLabel.text = "GPS:strong"
    } else if horizontalAccuracy <= 100 {
      self.gpsLabel.text = "GPS:medium"
    }
    debugPrint("gps:\(horizontalAccuracy)")
    return strengthWeak
  }

  deinit {
//    observation?.invalidate()
  }
  
  lazy var mapView: GMSMapView = {
    let camera = GMSCameraPosition(
    latitude: cameraLatitude, longitude: cameraLongitude, zoom: cameraZoom)
    let options = GMSMapViewOptions()
    options.camera = camera
    let mapView = GMSMapView.init(options: options)
    mapView.overrideUserInterfaceStyle = .unspecified
    mapView.settings.compassButton = true
    mapView.settings.myLocationButton = true
    mapView.isMyLocationEnabled = true
    return mapView
  }()
  
  
  lazy var gpsLabel: UILabel = {
    let gpsLabel = UILabel()
    gpsLabel.textColor = .white
    gpsLabel.backgroundColor = .red
    gpsLabel.translatesAutoresizingMaskIntoConstraints = false
    return gpsLabel
  }()

  private lazy var actionBtn: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setTitle("Start", for:.normal)
    btn.setTitleColor(.white, for:.normal)
    btn.backgroundColor = .red
    btn.addTarget(self, action: #selector(startAction), for: .touchUpInside)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
}


extension MyLocationViewController: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let curLocation = locations.last else{ return}
    let location: CLLocation = locations.last!
    print("Location: \(location)")
    let result = self.getGPSStrength(curLocation)
    self.rideManager?.updateUserFootprint(gpsIsWeak: result)
  }
  

  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    // Check accuracy authorization
    let accuracy = manager.accuracyAuthorization
    switch accuracy {
    case .fullAccuracy:
        print("Location accuracy is precise.")
      locationManager.startUpdatingLocation()

    case .reducedAccuracy:
        print("Location accuracy is not precise.")
    @unknown default:
      fatalError()
    }
    
    // Handle authorization status
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
      // Display the map using the default location.
      mapView.isHidden = false
    case .notDetermined:
      print("Location status not determined.")
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse:
      print("Location status is OK.")
    @unknown default:
      fatalError()
    }
  }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}
