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
import GoogleMaps


enum SDKConstants {

  //#error("Register for API Key and insert here. Then delete this line.")
  static let apiKey = //"AIzaSyCYEjZVnDQWY01I6XMdQq5pj8FXsvu2V28"
  "AIzaSyAyZ4S3bvIDOyrKYR3IGpjl9YmVPVZn_9M"
}

extension CLLocationCoordinate2D {
  static let sydney = CLLocationCoordinate2D(latitude: -33.8683, longitude: 151.2086)
  // Victoria, Australia
  static let victoria = CLLocationCoordinate2D(latitude: -37.81969, longitude: 144.966085)
  static let newYork = CLLocationCoordinate2D(latitude: 40.761388, longitude: -73.978133)
  static let mountainSceneLocation = CLLocationCoordinate2D(
    latitude: -33.732022, longitude: 150.312114)
}

  struct RouteHeader: Encodable {
      let Authorization:String
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



struct Coordinate: Decodable {
  let latitude: Double
  let longitude: Double
  let elevation: Double

  enum CodingKeys: String, CodingKey {
    case elevation
    case latitude = "lat"
    case longitude = "lng"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    latitude = try container.decode(Double.self, forKey: .latitude)
    longitude = try container.decode(Double.self, forKey: .longitude)
    elevation = try container.decode(Double.self, forKey: .elevation)
  }
}

struct RouteResponse: Codable {
    let routes: [SubRoute]
}

struct SubRoute: Codable {
    let polyline: Polyline
}

struct Polyline: Codable {
    let encodedPolyline: String
}

//private func addTrackToMap(_ encoderString:String)->GMSPolyline?{
//  guard let path = GMSPath(fromEncodedPath: encoderString)else{
//    return nil
//  }
//  let polyline = GMSPolyline(path:path)
//  polyline.strokeWidth = 6
//  polyline.strokeColor = UIColor.purple
//  return polyline
//}

/**
 
 {
   "routes": [
     {
       "polyline": {
         "encodedPolyline": "celhCoaivTCJE@aASCCFc@s@Om@lDU^mBtBgMwMcCeCQI{GgAgUcDaHaACPiAOE^k@Kc@AyAQWGFc@_IgAoEg@BSu@I}CS@m@OaBBOPg@@c@Ao@cAEE}BcDF?VoA?"
       }
     }
   ]
 }
 */
func fetchRoute(from startLocation: CLLocationCoordinate2D, to endLocation: CLLocationCoordinate2D, _ result: @escaping((GMSPolyline?)->Void)) {
  
  let head = Waypoint(location: Location(latLng: LatLng(latitude: startLocation.latitude, longitude: startLocation.longitude)))
  let end = Waypoint(location: Location(latLng: LatLng(latitude: endLocation.latitude, longitude: endLocation.longitude)))
  let params = Route(origin: head, destination: end)
  
  let header:HTTPHeaders = ["X-Goog-FieldMask":"routes.polyline.encodedPolyline","X-Goog-Api-Key": SDKConstants.apiKey,]
  AF.request("https://routes.googleapis.com/directions/v2:computeRoutes",
             method: .post,
             parameters: params,encoder: JSONParameterEncoder.default, headers: header)
  .responseDecodable(of: RouteResponse.self) { response in
      switch response.result {
      case .success(let routeResponse):
        debugPrint(routeResponse)
        guard let encodedPolyline = routeResponse.routes.first?.polyline.encodedPolyline,let path = GMSPath(fromEncodedPath:encodedPolyline) else{
          return
        }
        let polyline = GMSPolyline(path:path)
        polyline.strokeWidth = 6
        polyline.strokeColor = UIColor.purple
        result(polyline)
          
      case .failure(let error):
          print("Error: \(error)")
      }
  }
}


