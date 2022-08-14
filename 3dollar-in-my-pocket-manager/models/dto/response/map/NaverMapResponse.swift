struct NaverMapResponse: Decodable {
    let results: [ReverseGeoLocation]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.results = try values.decodeIfPresent(
            [ReverseGeoLocation].self,
            forKey: .results
        ) ?? []
    }
    
    func getAddress() -> String {
        if !results.isEmpty {
            var address = ""
            
            if results.count == 4 {
                address = "\(results[0].region.area1.name) \(results[0].region.area2.name)"
                if let name = results[3].land?.name {
                    address = "\(address) \(name)"
                }
                
                if let roadNumber1 = results[3].land?.number1 {
                    address = "\(address) \(roadNumber1)"
                    
                    if let roadNumber2 = results[3].land?.number2 {
                        if !roadNumber2.isEmpty {
                            address = "\(address)-\(roadNumber2)"
                        }
                    }
                }
            } else {
                address = "\(results[0].region.area1.name) \(results[0].region.area2.name) \(results[0].region.area3.name)"
                
                if results.count > 2 {
                    if let jibun1 = results[2].land?.number1 {
                        address = "\(address) \(jibun1)"
                        
                        if let jibun2 = results[2].land?.number2,
                           !jibun2.isEmpty {
                            address = "\(address)-\(jibun2)"
                        }
                    }
                }
            }
            
            return address
        } else {
            return "location_address_unknown".localized
        }
    }
}
