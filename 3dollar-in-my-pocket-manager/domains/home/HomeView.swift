import UIKit

import NMapsMap

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    private let addressView = AddressView()
    
    override func setup() {
        self.addSubViews([
            self.mapView,
            self.addressView
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
    }
}
