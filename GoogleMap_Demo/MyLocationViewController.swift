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

  private let cameraZoom: Float = 12

  lazy var mapView: GMSMapView = {
    let camera = GMSCameraPosition(
    latitude: cameraLatitude, longitude: cameraLongitude, zoom: cameraZoom)
    let mapView = GMSMapView(frame: .zero, camera: camera)
    mapView.isMyLocationEnabled = true
    mapView.padding = UIEdgeInsets(
      top: 0, left: 0, bottom: MyLocationViewController.overlayHeight, right: 0)
    return mapView
  }()
  
  private lazy var overlay: UIView = {
    let overlay = UIView(frame: .zero)
    overlay.backgroundColor = UIColor(hue: 0, saturation: 1, brightness: 1, alpha: 0.5)
    
    let btn = UIButton(type: .custom)
    btn.setTitle("Start", for:.normal)
    btn.setTitleColor(.red, for:.normal)
    btn.addTarget(self, action: #selector(startAction), for: .touchUpInside)
    overlay.addSubview(btn)
    btn.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      btn.centerXAnchor.constraint(equalTo:overlay.centerXAnchor),
      btn.centerYAnchor.constraint(equalTo:overlay.centerYAnchor),
    ])
    return overlay
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

  var isStarted:Bool = false

  override func loadView() {
    view = mapView
//    navigationItem.rightBarButtonItem = flyInButton

    let overlayFrame = CGRect(
      x: 0, y: -MyLocationViewController.overlayHeight, width: 0,
      height: MyLocationViewController.overlayHeight)
    overlay.frame = overlayFrame
    overlay.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
    view.addSubview(overlay)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

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
      //debugPrint("current position \(mapView.myLocation?.coordinate)")
      strongSelf.location = curLocation
      strongSelf.runedPath.add(curLocation.coordinate)
      strongSelf.runedLine.path = strongSelf.runedPath
    }
    
    let startButton = UIBarButtonItem(
      barButtonSystemItem: .add, target: self, action: #selector(startAction))
//    startButton.accessibilityLabel = "Start"
    navigationItem.rightBarButtonItem = startButton

  }

  @objc func startAction() {
    // 获取路径并绘制
    guard let start = location,let end = destation else {
      return
    }
    isStarted = true
    runedPath.add(start.coordinate)
    
    fetchRoute(from: start.coordinate, to: end.position) { line in
      line?.map = self.mapView
      
    }
  }
   

  deinit {
    observation?.invalidate()
  }
}

extension MyLocationViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
//    let alert = UIAlertController(
//      title: "Location Tapped",
//      message: "Current location: <\(location.latitude), \(location.longitude)>",
//      preferredStyle: .alert)
//    alert.addAction(UIAlertAction(title: "OK", style: .default))
//    present(alert, animated: true)
  }
  
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
