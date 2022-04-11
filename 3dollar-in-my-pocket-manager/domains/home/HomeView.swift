import UIKit

import NMapsMap
import RxSwift
import RxCocoa

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 17
    }
    
    let centerMarker = UIImageView().then {
        $0.image = UIImage(named: "ic_marker_active")
    }
    
    let addressView = AddressView()
    
    let showOtherButton = ShowOtherButton()
    
    let salesToggleView = SalesToggleView()
    
    let currentLocationButton = UIButton().then {
        $0.setImage(nil, for: .normal)
    }
    
    private let rangeOverlayView = NMFCircleOverlay().then {
        $0.radius = 100
        $0.fillColor = .pink.withAlphaComponent(0.2)
    }
    
    private let marker = NMFMarker().then {
        $0.iconImage = NMFOverlayImage(name: "ic_marker_active")
        $0.width = 30
        $0.height = 40
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.centerMarker,
            self.addressView,
            self.showOtherButton,
            self.salesToggleView,
            self.currentLocationButton
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.salesToggleView.snp.top).offset(20)
        }
        
        self.centerMarker.snp.makeConstraints { make in
            make.center.equalTo(self.mapView)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        
        self.addressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.safeAreaLayoutGuide)
        }
        
        self.showOtherButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.bottom.equalTo(self.salesToggleView.snp.top).offset(-32)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.right.equalToSuperview().offset(-32)
            make.centerY.equalTo(self.showOtherButton)
        }
        
        self.salesToggleView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
    fileprivate func moveCameraPosition(position: CLLocation) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(
                lat: position.coordinate.latitude,
                lng: position.coordinate.longitude
            ),
            zoom: self.mapView.zoomLevel
        )
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        self.mapView.moveCamera(cameraUpdate)
    }
    
    fileprivate func bind(store: Store) {
        self.rangeOverlayView.mapView = nil
        self.marker.mapView = nil
        self.centerMarker.isHidden = store.isOpen
        if store.isOpen {
            if let location = store.location {
                let position = NMGLatLng(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude
                )
                
                self.marker.position = position
                self.marker.mapView = self.mapView
                self.setupRangeOverlayView(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
    }
    
    private func setupRangeOverlayView(latitude: Double, longitude: Double) {
        self.rangeOverlayView.center = NMGLatLng(lat: latitude, lng: longitude)
        self.rangeOverlayView.mapView = self.mapView
    }
}

extension Reactive where Base: HomeView {
    var cameraPosition: Binder<CLLocation> {
        return Binder(self.base) { view, position in
            view.moveCameraPosition(position: position)
        }
    }
    
    var myStore: Binder<Store> {
        return Binder(self.base) { view, store in
            view.bind(store: store)
        }
    }
}
