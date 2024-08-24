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

import CoreLocation
import Alamofire

enum SDKConstants {

  //#error("Register for API Key and insert here. Then delete this line.")
  static let apiKey = "111AIzaSyCYEjZVnDQWY01I6XMdQq5pj8FXsvu2V28"
}

extension CLLocationCoordinate2D {
  static let sydney = CLLocationCoordinate2D(latitude: -33.8683, longitude: 151.2086)
  // Victoria, Australia
  static let victoria = CLLocationCoordinate2D(latitude: -37.81969, longitude: 144.966085)
  static let newYork = CLLocationCoordinate2D(latitude: 40.761388, longitude: -73.978133)
  static let mountainSceneLocation = CLLocationCoordinate2D(
    latitude: -33.732022, longitude: 150.312114)
}

struct RouteTool{
  
  static func fetchRoute(from startLocation: CLLocationCoordinate2D, to endLocation: CLLocationCoordinate2D) {
    
    let head = Waypoint(location: Location(latLng: LatLng(latitude: startLocation.latitude, longitude: startLocation.longitude)))
    let end = Waypoint(location: Location(latLng: LatLng(latitude: endLocation.latitude, longitude: endLocation.longitude)))
    let params = Route(origin: head, destination: end)
    
    AF.request("https://routes.googleapis.com/directions/v2:computeRoutes",
                   method: .post,
                   parameters: params,
                   encoder: JSONParameterEncoder.default)
        .response { response in
            debugPrint(response)
    }
  }
  
  struct Login: Encodable {
      let email:String
      let password:String
  }
  struct Route:Encodable {
    let origin:Waypoint
    let destination:Waypoint
    let travelMode:Int8 = 3
  }
  
  struct Waypoint:Encodable{
//    let via:Bool=true
//    let vehicleStopover:Bool=true
//    let sideOfRoad:Bool = true
    let location:Location
  }
  struct Location:Encodable{
    let latLng:LatLng
  }
  struct LatLng:Encodable{
    let latitude:CLLocationDegrees
    let longitude:CLLocationDegrees
  }
}
