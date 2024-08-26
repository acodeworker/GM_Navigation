## 项目运行
请执行`pod install`。
## 项目功能总结

- 启动时定位到当前位置
- 点击地图选择目的地。
- 点击开始会绘制路线图
- 移动时绘制走过的路径
- 实时监测GPS信号强度。
- 用户偏离路径会提示重新规划路径
- 到达目的地自动结束。 

## 实现步骤
根据google maps官网上的链接，下载demo文件，查看相应的接口文档。借助vpn下载对应的依赖库，运行项目。

- MyLocationViewController 导航页面
- TripSummaryController 路程总结页面
- SDKConstants 路线请求
- RideNavigationManager 核心类，导航的所有业务逻辑。

## 关键问题思路

### 如何定位当前位置？
```
observation = mapView.observe(\.myLocation, options: [.new]) {
  [weak self] mapView, _ in
  guard let strongSelf = self,let curLocation = mapView.myLocation else{ return}
  let result = strongSelf.getGPSStrength(curLocation)
  strongSelf.rideManager?.updateUserFootprint(gpsIsWeak: result)
}
```

### 点击地图选择地点
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

### 点击开始会绘制路线图
根据google[文档链接](https://developers.google.com/maps/documentation/routes/compute_route_directions?hl=zh-cn)，请求数据逻辑`fetchRoute`方法。

### 返回路径数据解析逻辑
```
guard let encodedPolyline = routeResponse.routes.first?.polyline.encodedPolyline,let path = GMSPath(fromEncodedPath:encodedPolyline) else{
          return }
```

### 路径绘制
```
let polyline = GMSPolyline(path:path)
polyline.strokeWidth = 6
polyline.strokeColor = UIColor.purple
polyline.map = mapview
```
### 走过的路径绘制
根据位置更新函数，不断获取当前点，拼接到我的路径上，并更新。
### 用户偏离监测
借助GMSPath的如下分类方法
```
 func isOnPolyline(coordinate: CLLocationCoordinate2D, tolerance: Double = GMSPath.defaultToleranceInMeters) -> Bool {}
```
### 行程总结
位置更新时，计算当前点与上个点的距离。然后累加得出总路程。开始骑行时记录一个时间，结束时算差值得到时间。结束时，把导航路线移除，然后调整mapview尺寸，利用sdk的截屏方法生成一张图片，跳转到下一个页面展示。详情见`endNavigation`方法 。
### 到达目的地检查
计算当前点和目的地的距离，小于10认为到达。





