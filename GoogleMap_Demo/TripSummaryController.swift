//
//  TripSummaryController.swift
//  GoogleMap_Demo
//
//  Created by jeremy on 2024/8/25.
//

import Foundation
import UIKit

struct TripSummary {
  let image:UIImage
  let distance:Double
  let time:Double
}

class TripSummaryController: UIViewController {
  
  lazy var tripImagView: UIImageView = {
    let imageview = UIImageView(image: trip.image)
    imageview.contentMode = .scaleAspectFit
    imageview.translatesAutoresizingMaskIntoConstraints = false
    return imageview
  }()

  lazy var timeLabel: UILabel = {
    let timeLabel = UILabel()
    timeLabel.text = "Ride time:\(trip.time/60) Minuntes"
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    return timeLabel
  }()
  
  lazy var distanceLabel: UILabel = {
    let distanceLabel = UILabel()
    distanceLabel.text = "Ride distance:\(trip.distance) meters"
    distanceLabel.translatesAutoresizingMaskIntoConstraints = false
    return distanceLabel
  }()
  
  var trip:TripSummary
  
  
  init(trip:TripSummary) {
    self.trip = trip
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initUI()
  }
  
  func initUI(){
    view.backgroundColor = .white
    view.addSubview(tripImagView)
    view.addSubview(distanceLabel)
    view.addSubview(timeLabel)
    NSLayoutConstraint.activate([
      tripImagView.leftAnchor.constraint(equalTo:self.view.leftAnchor),
      tripImagView.rightAnchor.constraint(equalTo:self.view.rightAnchor),
      tripImagView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor,constant: 0),
      tripImagView.topAnchor.constraint(equalTo:self.view.topAnchor,constant: 0),
    ])
    NSLayoutConstraint.activate([
      distanceLabel.leftAnchor.constraint(equalTo:self.view.leftAnchor,constant: 20),
      distanceLabel.rightAnchor.constraint(equalTo:self.view.rightAnchor,constant: -20),
      distanceLabel.topAnchor.constraint(equalTo:tripImagView.bottomAnchor, constant: -120)
    ])
    
    NSLayoutConstraint.activate([
      timeLabel.leftAnchor.constraint(equalTo:self.view.leftAnchor,constant: 20),
      timeLabel.rightAnchor.constraint(equalTo:self.view.rightAnchor,constant: -20),
      timeLabel.topAnchor.constraint(equalTo:distanceLabel.bottomAnchor, constant: 20)
    ])
  }
  
}
