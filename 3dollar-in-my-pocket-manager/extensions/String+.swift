import Foundation

extension String {
    var localized: String {
      return NSLocalizedString(self, tableName: "Localizations", value: self, comment: "")
    }
    
    var localizable: String {
        return NSLocalizedString(self, tableName: "Localizable", comment: "")
    }
    
    /**
     - 1분 미만인 경우 -> 방금 전
     - 60분 미만인 경우 -> n분 전
     - 24시간 미만인 경우 -> n시간 전
     - 48시간 미만인 경우 -> n일 전
     - 나머지 -> yyyy년MM월dd일 포맷
     */
    var createdAtFormatted: String {
        let date = DateUtils.toDate(dateString: self)
        let timeDiff = abs(date.timeIntervalSinceNow)
        let second = Int(timeDiff)
        
        let minuteInSeconds = 60
        let hourInSeconds = 60 * minuteInSeconds
        let dayInSeconds = hourInSeconds * 24
        let twoDayInSeconds = dayInSeconds * 2
        
        
        switch second {
        case 0...minuteInSeconds:
            return "방금 전"
        case minuteInSeconds...hourInSeconds:
            let minutes = second / 60
            return "\(minutes)분 전"
        case hourInSeconds...dayInSeconds:
            let hour = second / hourInSeconds
            return "\(hour)시간 전"
        case dayInSeconds...twoDayInSeconds:
            let days = second / dayInSeconds
            return "\(days)일 전"
        default:
            let formattedDate = DateUtils.toString(date: date, format: "yyyy년MM월dd일")
            
            return formattedDate
            
        }
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var camelCase: String {
        // Step 1: Snake case를 단어 배열로 나누기
        let components = self.split(separator: "_")
        
        // Step 2: 첫 단어는 소문자로 유지하고, 나머지 단어는 첫 글자를 대문자로 변환
        let camelCase = components.enumerated().map { index, word in
            if index == 0 {
                return word.lowercased() // 첫 단어는 소문자
            } else {
                return word.capitalized // 나머지는 첫 글자 대문자
            }
        }.joined()
        
        return camelCase
    }
}
