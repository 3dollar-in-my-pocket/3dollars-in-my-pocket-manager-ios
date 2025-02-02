// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Assets {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let icAddMenu = ImageAsset(name: "ic_add_menu")
  internal static let icAlert = ImageAsset(name: "ic_alert")
  internal static let icApple = ImageAsset(name: "ic_apple")
  internal static let icAppleLogo = ImageAsset(name: "ic_apple_logo")
  internal static let icArrowDown = ImageAsset(name: "ic_arrow_down")
  internal static let icArrowLeft = ImageAsset(name: "ic_arrow_left")
  internal static let icArrowRight = ImageAsset(name: "ic_arrow_right")
  internal static let icBack = ImageAsset(name: "ic_back")
  internal static let icBookmarkSolid = ImageAsset(name: "ic_bookmark_solid")
  internal static let icCamera = ImageAsset(name: "ic_camera")
  internal static let icCheck = ImageAsset(name: "ic_check")
  internal static let icCheckLine = ImageAsset(name: "ic_check_line")
  internal static let icCheckOff = ImageAsset(name: "ic_check_off")
  internal static let icClose = ImageAsset(name: "ic_close")
  internal static let icCloseCircle = ImageAsset(name: "ic_close_circle")
  internal static let icCommunitySolid = ImageAsset(name: "ic_community_solid")
  internal static let icDelete = ImageAsset(name: "ic_delete")
  internal static let icDeleteWithoutPadding = ImageAsset(name: "ic_delete_without_padding")
  internal static let icDeleteX = ImageAsset(name: "ic_delete_x")
  internal static let icHeartFill = ImageAsset(name: "ic_heart_fill")
  internal static let icHome = ImageAsset(name: "ic_home")
  internal static let icInformation = ImageAsset(name: "ic_information")
  internal static let icKakao = ImageAsset(name: "ic_kakao")
  internal static let icKakaoLogo = ImageAsset(name: "ic_kakao_logo")
  internal static let icLocation = ImageAsset(name: "ic_location")
  internal static let icMarkerActive = ImageAsset(name: "ic_marker_active")
  internal static let icMore = ImageAsset(name: "ic_more")
  internal static let icMy = ImageAsset(name: "ic_my")
  internal static let icNaver = ImageAsset(name: "ic_naver")
  internal static let icSetting = ImageAsset(name: "ic_setting")
  internal static let icStarSolid = ImageAsset(name: "ic_star_solid")
  internal static let icStore = ImageAsset(name: "ic_store")
  internal static let icTrash = ImageAsset(name: "ic_trash")
  internal static let icTruck = ImageAsset(name: "ic_truck")
  internal static let icWriteLine = ImageAsset(name: "ic_write_line")
  internal static let icWriteSolid = ImageAsset(name: "ic_write_solid")
  internal static let imgEmptyMenu = ImageAsset(name: "img_empty_menu")
  internal static let imgEmptyPost = ImageAsset(name: "img_empty_post")
  internal static let imgEmptyReview = ImageAsset(name: "img_empty_review")
  internal static let imgIntro = ImageAsset(name: "img_intro")
  internal static let imgMessageBookmark = ImageAsset(name: "img_message_bookmark")
  internal static let imgMessageIntroduction = ImageAsset(name: "img_message_introduction")
  internal static let imgNew = ImageAsset(name: "img_new")
  internal static let imgStoreDefault = ImageAsset(name: "img_store_default")
  internal static let imgWaitingBottom1 = ImageAsset(name: "img_waiting_bottom_1")
  internal static let imgWaitingBottom2 = ImageAsset(name: "img_waiting_bottom_2")
  internal static let imgWaitingBottom3 = ImageAsset(name: "img_waiting_bottom_3")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
