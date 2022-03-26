import UIKit

import NMapsMap

final class HomeView: BaseView {
    let mapView = NMFMapView().then {
        $0.positionMode = .direction
        $0.zoomLevel = 15
    }
    
    override func setup() {
        self.addSubViews([
            self.mapView
        ])
    }
    
    override func bindConstraints() {
        self.mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
