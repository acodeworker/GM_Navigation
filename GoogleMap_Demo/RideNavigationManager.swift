//
//  RideNavigationManager.swift
//  GoogleMap_Demo
//
//  Created by jeremy on 2024/8/26.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import GoogleMapsBase

class RideNavigationManager:NSObject,GMSMapViewDelegate{
  
  var destation:GMSMarker? = nil
  
  var originLocation:CLLocation? = nil
  
  var isStarted:Bool = false

  var startTime:Date? = nil

  var isRecalculate:Bool = false
  
  var mapView:GMSMapView
  
  weak var vc:UIViewController? = nil

  init(map:GMSMapView,vc:UIViewController) {
    self.mapView = map
    self.vc = vc
    super.init()
    mapView.delegate = self
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
    vc?.navigationController?.pushViewController(tripVc, animated: true)
   }
  
  
  func updateUserFootprint(gpsIsWeak:Bool){
    guard let curLocation = mapView.myLocation else{ return}

    let tempLastLocation = self.location
    self.location = curLocation
    
    guard let lastLocation = tempLastLocation,self.isStarted,let line = self.routeLine,let end = self.destation?.position else{
      return
    }
    
    //
    let runedDistance =  curLocation.distance(from:lastLocation)
    guard runedDistance > 1 else {//to avoid too many points.
      return
    }
    let timeInterval = curLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
    let speed = runedDistance / timeInterval
    
    print("User is moving, distance:\(runedDistance) speed: \(speed) m/s")
    
//    return
    //      if speed > speedThreshold {
    //         // 速度大于阈值，认为是有效移动
    //         // 处理有效的位置数据
    //     } else {
    //         // 速度低于阈值，可能是静止或GPS漂移
    //         print("Speed below threshold, ignoring this update.")
    //     }
    self.totalDistance += runedDistance
    
    //draw line
    self.runedPath.add(curLocation.coordinate)
    self.runedLine.path = self.runedPath
    
    //check is arrived or not.
    let distance = curLocation.distance(from:CLLocation(latitude: end.latitude, longitude: end.longitude))
    if distance<10 {//is arrived.
      self.endNavigation()
      return
    }
    
    if gpsIsWeak{
      return
    }
    //judge if you are riding outside the navigation path
    let inline =  line.isOnPolyline(coordinate: curLocation.coordinate, tolerance:10)
    if !inline,!self.isRecalculate{
      self.isRecalculate = true
      let alert = UIAlertController(
        title:"Alert",
        message: "You have deviated from your original planned route and need to re-plan your route",
        preferredStyle:.alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        self.replanRoute(curLocation.coordinate, to:end)
      }))
      vc?.navigationController?.present(alert,animated: true)
    }
  }
  
  func startAction() {
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
  
  func replanRoute(_ from:CLLocationCoordinate2D,to:CLLocationCoordinate2D){
    fetchRoute(from:from, to:to) {[weak self]line in
      guard let strongSelf = self,let unwrapLine = line else{return }
      strongSelf.routeLine = line
      strongSelf.isRecalculate = false
    }
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
  
  private var totalDistance:CLLocationDistance = 0
  
  private var routeLine:GMSPolyline? = nil{
    didSet{
      oldValue?.map = nil
      routeLine?.map = mapView
    }
  }

  var location: CLLocation? {
    didSet {
      guard oldValue == nil, let firstLocation = location else { return }
      mapView.camera = GMSCameraPosition(target: firstLocation.coordinate, zoom: 14)
    }
  }
  
  var runedPath: GMSMutablePath = GMSMutablePath()
  
  lazy var runedLine: GMSPolyline = {
    let polyline = GMSPolyline(path:GMSMutablePath())
    polyline.strokeWidth = 6
    polyline.strokeColor = UIColor.lightGray
    polyline.map = self.mapView
    return polyline
  }()
  
}
