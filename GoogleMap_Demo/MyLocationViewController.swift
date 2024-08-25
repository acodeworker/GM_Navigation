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
import GoogleMapsBase
import UIKit

class MyLocationViewController: UIViewController {

  static let overlayHeight: CGFloat = 140

  private let cameraLatitude: CLLocationDegrees = -33.868

  private let cameraLongitude: CLLocationDegrees = 151.2086

  private var cameraZoom: Float = 12

  private var totalDistance:CLLocationDistance = 0
  
  private var routeLine:GMSPolyline? = nil
  
  lazy var mapView: GMSMapView = {
    let camera = GMSCameraPosition(
    latitude: cameraLatitude, longitude: cameraLongitude, zoom: cameraZoom)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    mapView.isMyLocationEnabled = true
    mapView.overrideUserInterfaceStyle = .unspecified
    mapView.padding = UIEdgeInsets(
      top: 0, left: 0, bottom: MyLocationViewController.overlayHeight, right: 0)
    return mapView
  }()
  
  private var distanceLabel:UILabel? = nil
  
  private var timeLabel:UILabel? = nil

  private lazy var actionBtn: UIButton = {
   
    let btn = UIButton(type: .custom)
    btn.setTitle("Start", for:.normal)
    btn.setTitleColor(.white, for:.normal)
    btn.backgroundColor = .red
    btn.addTarget(self, action: #selector(startAction), for: .touchUpInside)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()

  var observation: NSKeyValueObservation?
  var location: CLLocation? {
    didSet {
      guard oldValue == nil, let firstLocation = location else { return }
      mapView.camera = GMSCameraPosition(target: firstLocation.coordinate, zoom: 14)
    }
  }
//  var orginLocation:CLLocation? = nil
  
  lazy var runedPath: GMSMutablePath = {
    return GMSMutablePath()
  }()
  
  lazy var runedLine: GMSPolyline = {
    let polyline = GMSPolyline(path:GMSMutablePath())
    polyline.strokeWidth = 6
    polyline.strokeColor = UIColor.lightGray
    polyline.map = self.mapView
    return polyline
  }()
  
  var destation:GMSMarker? = nil
  
  var originLocation:CLLocation? = nil
  
  var isStarted:Bool = false

  var startTime:Date? = nil

  override func loadView() {
    view = mapView
//    navigationItem.rightBarButtonItem = flyInButton
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(actionBtn)
    NSLayoutConstraint.activate([
      actionBtn.centerXAnchor.constraint(equalTo:view.centerXAnchor),
      actionBtn.bottomAnchor.constraint(equalTo:view.bottomAnchor,constant: -40),
    ])
    
    // Opt the MapView into automatic dark mode switching.
    mapView.overrideUserInterfaceStyle = .unspecified

    mapView.delegate = self
    mapView.settings.compassButton = true
    mapView.settings.myLocationButton = true
    mapView.isMyLocationEnabled = true
    view = mapView

    // Listen to the myLocation property of GMSMapView.
    observation = mapView.observe(\.myLocation, options: [.new]) {
      [weak self] mapView, _ in
      guard let strongSelf = self,let curLocation = mapView.myLocation  else{return}

      if strongSelf.isStarted,let preLocation = strongSelf.location{
        
        let runedDistance =  curLocation.distance(from:preLocation)
        strongSelf.totalDistance += runedDistance
        if runedDistance > 1 {// to avoid too many points.
          strongSelf.runedPath.add(curLocation.coordinate)
          strongSelf.runedLine.path = strongSelf.runedPath
        }
      }
      //check is arrived or not.
      if strongSelf.isStarted,let end = strongSelf.destation{
        let distance = curLocation.distance(from:CLLocation(latitude: end.position.latitude, longitude: end.position.longitude))
        if distance<5 {//is arrived.
          strongSelf.endNavigation()
        }
      }
      
      strongSelf.location = curLocation
    }
    
    let startButton = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(startAction))
//    startButton.accessibilityLabel = "Start"
    navigationItem.rightBarButtonItem = startButton

  }


 private func endNavigation() {
    guard let startLocation = originLocation,let endLocation = location else { return}
    var bounds = GMSCoordinateBounds()
    let locations = [startLocation,endLocation]
    for location in locations {
      bounds = bounds.includingCoordinate(location.coordinate)
    }
    guard bounds.isValid else { return }
    mapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 50))
   
   routeLine?.map = nil
   routeLine = nil
   
   // Take a snapshot of the map.
   UIGraphicsBeginImageContextWithOptions(mapView.bounds.size, true, 0)
   mapView.drawHierarchy(in: mapView.bounds, afterScreenUpdates: true)
   let mapSnapshot = UIGraphicsGetImageFromCurrentImageContext()
   UIGraphicsEndImageContext()
   guard let snapshot = mapSnapshot,let startTime = startTime else {return}
   
   let timeInterval = Date().timeIntervalSince(startTime)
   let tripSummary = TripSummary(image: snapshot, distance:totalDistance, time: timeInterval)
   let tripVc = TripSummaryController(trip: tripSummary)
   self.navigationController?.pushViewController(tripVc, animated: true)
  }
  
  
  @objc func startAction() {
    // 获取路径并绘制
    guard let start = location,let end = destation else {
      return
    }
    if isStarted{
      self.endNavigation()
    }else{
      fetchRoute(from: start.coordinate,to:end.position){[weak self] line in
        guard let strongSelf = self,let line = line else{return}
        line.map = strongSelf.mapView
        strongSelf.routeLine = line
        strongSelf.isStarted = true
        strongSelf.startTime = Date()
        strongSelf.originLocation = start
        strongSelf.runedPath.add(start.coordinate)
      }
    }
  }
   
  

  deinit {
    observation?.invalidate()
  }
}


extension MyLocationViewController: GMSMapViewDelegate {
 
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
      // 用户选择目的地
    if isStarted {return }
    if nil == self.destation {
      destation = GMSMarker(position: coordinate)
    }else{
      destation?.position = coordinate
    }
    destation?.title = "destation!"
    destation?.map = mapView
  }
}
