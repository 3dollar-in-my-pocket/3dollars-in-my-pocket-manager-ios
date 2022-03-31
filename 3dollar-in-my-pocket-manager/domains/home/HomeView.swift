import UIKit

import NMapsMap

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 17
    }
    
    let marker = UIImageView().then {
        $0.image = UIImage(named: "ic_marker_active")
    }
    
    let addressView = AddressView()
    
    let showOtherButton = ShowOtherButton()
    
    let salesToggleView = SalesToggleView()
    
    let currentLocationButton = UIButton().then {
        $0.setImage(nil, for: .normal)
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.marker,
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
        
        self.marker.snp.makeConstraints { make in
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
    
    private func setupRangeOverlayView(latitude: Double, longitude: Double) {
        let rangeOverlayView = NMFCircleOverlay().then {
            $0.center = NMGLatLng(lat: latitude, lng: longitude)
            $0.radius = 100
            $0.fillColor = .pink.withAlphaComponent(0.2)
        }
        
        rangeOverlayView.mapView = self.mapView
    }
}
