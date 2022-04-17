struct ReverseGeoLocation: Decodable {
    let name: String
    let region: Region
    let land: Land?
    
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case land
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.region = try values.decodeIfPresent(Region.self, forKey: .region) ?? Region()
        self.land = try values.decodeIfPresent(Land.self, forKey: .land)
    }
}
