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
        $0.setImage(UIImage(named: "ic_location"), for: .normal)
        $0.contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray20.cgColor
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
        $0.layer.shadowOpacity = 0.15
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
    
    private var otherStoreMarkers: [NMFMarker] = []
    
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
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.mapView.snp.centerY)
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
            }
        }
    }
    
    fileprivate func bindInitialPosition(location: CLLocation) {
        self.rangeOverlayView.mapView = nil
        self.setupRangeOverlayView(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    fileprivate func setOtherStores(stores: [Store]) {
        // 지도에 마커 추가
        self.clearOtherStoreMarkers()
        for store in stores {
            if let location = store.location {
                let marker = NMFMarker().then {
                    $0.iconImage = NMFOverlayImage(name: "ic_store")
                    $0.width = 24
                    $0.height = 24
                }
                let position = NMGLatLng(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude
                )
                marker.position = position
                marker.mapView = self.mapView
                self.otherStoreMarkers.append(marker)
            }
        }
    }
    
    private func clearOtherStoreMarkers() {
        for marker in self.otherStoreMarkers {
            marker.mapView = nil
        }
        otherStoreMarkers.removeAll()
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
    
    var otherStores: Binder<[Store]> {
        return Binder(self.base) { view, stores in
            view.setOtherStores(stores: stores)
        }
    }
    
    var initialPosition: Binder<CLLocation> {
        return Binder(self.base) { view, position in
            view.moveCameraPosition(position: position)
            view.bindInitialPosition(location: position)
        }
    }
}
