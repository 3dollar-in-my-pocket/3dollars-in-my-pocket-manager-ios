import UIKit

import NMapsMap

final class HomeView: BaseView {
    enum Constant {
        /// 강남역 좌표
        static let defaultLocation = CLLocation(latitude: 127.027681, longitude: 37.497970)
    }
    
    let mapView: NMFMapView = {
        let mapView = NMFMapView()
        mapView.positionMode = .direction
        mapView.zoomLevel = 17
        return mapView
    }()
    
    let centerMarker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_marker_active")
        return imageView
    }()
    
    let addressView = AddressView()
    
    let operationSettingButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "ic_setting")?
            .resizeImage(scaledTo: 30)
            .withRenderingMode(.alwaysTemplate)
        config.contentInsets = .init(top: 13, leading: 13, bottom: 13, trailing: 13)
        let button = UIButton(configuration: config)
        button.tintColor = .gray90
        button.backgroundColor = .white
        button.layer.cornerRadius = 13
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.08
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        return button
    }()
    
    let showOtherButton = ShowOtherButton()
    
    let salesToggleView = SalesToggleView()
    
    let currentLocationButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "ic_location")
        config.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let button = UIButton(configuration: config)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray20.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.15
        return button
    }()
    
    private let rangeOverlayView: NMFCircleOverlay = {
        let overlayView = NMFCircleOverlay()
        overlayView.radius = 100
        overlayView.fillColor = .pink.withAlphaComponent(0.2)
        return overlayView
    }()
    
    private let marker: NMFMarker = {
        let marker = NMFMarker()
        marker.iconImage = NMFOverlayImage(name: "ic_marker_active")
        marker.width = 30
        marker.height = 40
        return marker
    }()
    
    private var otherStoreMarkers: [NMFMarker] = []
    
    override func setup() {
        backgroundColor = .white
        addSubViews([
            mapView,
            centerMarker,
            addressView,
            operationSettingButton,
            showOtherButton,
            salesToggleView,
            currentLocationButton
        ])
    }
    
    override func bindConstraints() {
        mapView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(salesToggleView.snp.top).offset(20)
        }
        
        centerMarker.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mapView.snp.centerY)
            make.width.equalTo(30)
            make.height.equalTo(40)
        }
        
        addressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(operationSettingButton.snp.leading).offset(-8)
            make.top.equalTo(safeAreaLayoutGuide)
        }
        
        operationSettingButton.snp.makeConstraints { make in
            make.centerY.equalTo(addressView)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(56)
        }
        
        showOtherButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalTo(salesToggleView.snp.top).offset(-32)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.trailing.equalToSuperview().offset(-32)
            make.centerY.equalTo(showOtherButton)
        }
        
        salesToggleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func moveCameraPosition(location: CLLocation) {
        let cameraPosition = NMFCameraPosition(
            NMGLatLng(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude
            ),
            zoom: mapView.zoomLevel
        )
        let cameraUpdate = NMFCameraUpdate(position: cameraPosition)
        
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
    
    func bind(store: Store) {
        marker.mapView = nil
        centerMarker.isHidden = store.isOpen
        if store.isOpen {
            if let location = store.location {
                let position = NMGLatLng(
                    lat: location.coordinate.latitude,
                    lng: location.coordinate.longitude
                )
                
                marker.position = position
                marker.mapView = mapView
            }
        }
    }
    
    func bindStore(_ store: BossStoreResponse) {
        marker.mapView = nil
        let isOpen = store.openStatus.status == .open
        centerMarker.isHidden = isOpen
        
        guard isOpen else { return }
        if store.location != nil {
            let position = NMGLatLng(
                lat: store.location?.latitude ?? Constant.defaultLocation.coordinate.latitude,
                lng: store.location?.longitude ?? Constant.defaultLocation.coordinate.longitude
            )
            
            marker.position = position
            marker.mapView = mapView
        }
    }
    
    func setupAvailableArea(location: CLLocation) {
        rangeOverlayView.mapView = nil
        setupRangeOverlayView(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func bindAddress(_ address: String) {
        addressView.bind(address)
    }
    
    func bindShowOtherStores(_ showOtherStores: Bool) {
        showOtherButton.bind(showOtherStores)
    }
    
    func bindOtherStores(_ stores: [BossStoreSimpleResponse]) {
        clearOtherStoreMarkers()
        for store in stores {
            if let location = store.location {
                let marker = NMFMarker()
                marker.iconImage = NMFOverlayImage(name: "ic_store")
                marker.width = 24
                marker.height = 24
                marker.position = NMGLatLng(lat: location.latitude, lng: location.longitude)
                marker.mapView = mapView
                otherStoreMarkers.append(marker)
            }
        }
    }
    
    private func clearOtherStoreMarkers() {
        for marker in otherStoreMarkers {
            marker.mapView = nil
        }
        otherStoreMarkers.removeAll()
    }
    
    private func setupRangeOverlayView(latitude: Double, longitude: Double) {
        rangeOverlayView.center = NMGLatLng(lat: latitude, lng: longitude)
        rangeOverlayView.mapView = mapView
    }
}
