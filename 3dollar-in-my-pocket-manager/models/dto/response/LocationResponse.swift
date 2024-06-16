struct LocationResponse: Decodable {
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude  = latitude
        self.longitude = longitude
    }
}
