import Foundation

extension String {
    var localized: String {
      return NSLocalizedString(self, tableName: "Localizations", value: self, comment: "")
    }
}
