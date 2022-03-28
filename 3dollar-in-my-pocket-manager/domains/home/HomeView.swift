import UIKit

import NMapsMap

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    let addressView = AddressView()
    
    let salesToggleView = SalesToggleView()
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.addressView,
            self.salesToggleView
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(self.safeAreaLayoutGuide)
        }
        
        self.salesToggleView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
