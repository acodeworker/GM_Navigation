## Project running
Please execute `pod install`.

## Project function summary

- Navigate to current location on startup
- Click on the map to select your destination.
- Click Start to draw a route map
- Draw the path taken while moving
- Monitor GPS signal strength in real time.
- If the user deviates from the path, the user will be prompted to re-plan the path.
- Ends automatically when reaching destination. 

## Implementation steps
According to the link on the official website of Google Maps, download the demo file and view the corresponding interface document. Use VPN to download the corresponding dependent libraries and run the project.

- MyLocationViewController.swift navigation page
- TripSummaryController.swift trip summary page
- SDKConstants.swift route request
- RideNavigationManager.swift core class, all business logic of navigation.

## Key question ideas

### How to locate the current location?
```
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
```

### Click on the map to select a location
```
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
```

### Click Start to draw a road map
According to google[documentation link](https://developers.google.com/maps/documentation/routes/compute_route_directions?hl=zh-cn), request data logic `fetchRoute` method.

### Return path data parsing logic

```
guard let encodedPolyline = routeResponse.routes.first?.polyline.encodedPolyline,let path = GMSPath(fromEncodedPath:encodedPolyline) else{
          return }
```

### Path drawing

```
let polyline = GMSPolyline(path:path)
polyline.strokeWidth = 6
polyline.strokeColor = UIColor.purple
polyline.map = mapview
```
### Drawing the path traveled
According to the position update function, the current point is continuously obtained, spliced ​​to my path, and updated.
### User deviation monitoring
Using the following classification method of GMSPath

```
 func isOnPolyline(coordinate: CLLocationCoordinate2D, tolerance: Double = GMSPath.defaultToleranceInMeters) -> Bool {}
```
### Trip summary
When the position is updated, the distance between the current point and the previous point is calculated. Then add up to get the total distance. Record a time when you start riding, and calculate the difference at the end to get the time. At the end, remove the navigation route, then adjust the mapview size, use the SDK's screenshot method to generate a picture, and jump to the next page for display. 

See the `endNavigation` method for details.

### Check at destination
Calculate the distance between the current point and the destination. If it is less than 10 meters, it is considered reached.


## To Do！！！！

During the test, it was found that the location located was inconsistent with the actual location. The same was true when using the demo in Google Maps. The reason was not found yet.
