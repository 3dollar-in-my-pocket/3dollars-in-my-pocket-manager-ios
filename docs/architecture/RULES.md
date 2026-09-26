# 아키텍처 규칙 (RULES.md)

이 문서는 가슴속 3천원 **사장님앱 iOS** 레포의 아키텍처 규칙이다.
AI가 코드를 많이 쓰는 환경에서 사람은 diff 전체가 아니라 **의도(TC)·경계·검증 증거**만 본다.
그래서 경계에 관한 규칙은 엄격하게, 화면 내부 구현은 관대하게 둔다.

유저앱 iOS(`3dollars-in-my-pocket-ios`)와 **규칙 번호를 맞춘다.** 유저앱의 R1~R3은 Tuist 모듈 경계 규칙인데, 이 레포는 단일 앱 타깃이라 해당하지 않아 비워 둔다. 두 레포에서 같은 번호는 같은 뜻이다.

## 운영 원칙

- **기계로 판별 가능한 규칙은 문서가 아니라 린트로 강제한다.** 이 문서는 "왜"와 "예외"를 설명하는 곳이지, 위반을 잡는 곳이 아니다.
- **기존 위반은 베이스라인으로 동결하고 새 위반만 막는다.** 베이스라인에 있는 코드를 고칠 의무는 없지만, 그 파일을 크게 손댈 때 같이 고치는 걸 권장한다.
- 규칙은 10개를 넘기지 않는다. 새 규칙을 넣으려면 기존 규칙을 빼거나 합친다.
- 규칙 포맷: **규칙 한 문장 / 이유 / 좋은 예·나쁜 예 / 강제 수단 / 예외**.
- 강제 수단 우선순위: **린트(SwiftLint custom_rules) > 문서(이 파일 + 루트 CLAUDE.md)**. 문서로만 강제되는 규칙은 R10 하나다.

## 한눈에 보기

| # | 규칙 | 강제 수단 | 베이스라인 |
|---|---|---|---|
| R1~R3 | (유저앱의 모듈 경계 규칙 — 단일 타깃이라 해당 없음) | — | — |
| R4 | 서버 호출은 `repository/`의 Api + Repository에서만 | 린트 `no_network_outside_repository` | 2건 동결 |
| R5 | ViewModel은 Combine·Observation 기반으로 UI를 모르고, 의존은 주입받는다 | 린트 `viewmodel_*` 3개, `no_rx_reactorkit` | 79건 동결 |
| R6 | (예외로 만드는) ViewController/Cell은 Base 클래스를 상속 | 린트 `vc_inherits_base`, `cell_inherits_base`, `no_register_id` | 6건 동결 |
| R7 | 새 화면·전환은 SwiftUI(NavigationStack)로, 표현은 디자인 토큰으로 | 린트 `no_new_view_controller`, `no_new_uikit_view`, `uikit_disable_reason`, `no_uicolor_literal`, `snapkit_leading_trailing`, `no_then` | 425건 동결 |
| R8 | 타입은 책임 하나만 진다 (타입 500·파일 800줄 초과는 사유 필수) | 린트 기본 룰 `type_body_length`·`file_length` + `length_disable_reason` | 0건 |
| R9 | 로그는 LogManager·OSLog로, `print`·`as!`·`try!` 금지 | 린트 `no_print` + 기본 룰 error 승격 | 8건 동결 |
| R10 | ViewModel 구조·Route 분리·서버 네이밍 통일 | 문서 + AI 리뷰 | — |

---

## R4. 서버 호출은 `repository/`의 Api + Repository에서만 한다

**규칙** — HTTP 요청은 `3dollar-in-my-pocket-manager/repository/`의 `XxxApi`(enum + `ApiRequest`) + `XxxRepository`(protocol) + `XxxRepositoryImpl`로만 한다. `.asyncRequest()`, `AF.`, `HTTPUtils.defaultSession`을 `repository/`·`Network/` 밖에서 호출하지 않는다.

**이유** — 단일 책임(SRP). 네트워크를 목으로 바꿀 수 있는 지점이 Repository 하나여야 ViewModel 테스트가 서버 없이 돈다. 서버 스키마가 바뀌었을 때 고칠 곳도 한 곳으로 모인다.

**좋은 예**
```swift
// repository/ReviewRepository.swift
protocol ReviewRepository {
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse>
}

final class ReviewRepositoryImpl: ReviewRepository {
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse> {
        return await ReviewApi.fetchReview(storeId: storeId, reviewId: reviewId).asyncRequest()
    }
}
```

**나쁜 예**
```swift
// domains/.../XxxViewModel.swift
let result: ApiResult<StoreReviewResponse> = await ReviewApi.fetchReview(...).asyncRequest()   // ❌

// domains/.../XxxViewController.swift
AF.request(url).responseData { ... }   // ❌
```

**강제 수단** — SwiftLint custom_rule `no_network_outside_repository` (`repository/`, `Network/`, `utils/HTTPUtils.swift`, Alamofire 응답 확장 파일 제외).

**예외(베이스라인)** — `domains/Preference/PreferenceRepository.swift` 2건 동결(Api·Repository가 `domains/`에 있음 — `repository/`로 옮기면 해소). Rx 기반 레거시 `XxxService`(`StoreService`, `AuthService` 등)는 `repository/` 안에 있어 규칙 대상이 아니지만 **새로 만들지 않는다.** 신규 API는 `XxxApi` + `XxxRepository`(async/await)로 만든다.

---

## R5. ViewModel은 Combine·Observation 기반으로 UI를 모르고, 의존은 주입받는다

**규칙** — 신규 화면은 `BaseViewModel`을 상속한 ViewModel로 만든다(ReactorKit·RxSwift 금지). 입력·일회성 이벤트는 Combine, SwiftUI가 그리는 화면 상태는 `@Observable`(Observation)로 둔다. ViewModel은 `UIKit`·`SwiftUI`를 import하지 않으며, 외부 의존(Repository, LogManager 등)은 `Dependency`에 **protocol 타입**으로 주입받는다. `UIApplication.shared` 같은 싱글턴을 본문에서 직접 호출하지 않는다.

**이유** — 테스트 가능성과 패턴 통일. ViewModel이 UIKit이나 싱글턴을 직접 만지면 시뮬레이터 없이 테스트할 수 없다. "URL 열기" 같은 UI 동작은 `Route`로 뷰컨트롤러에 넘긴다. 이 레포는 ReactorKit(+RxSwift)에서 Combine MVVM으로 옮겨 가는 중이라, 새 코드가 옛 패턴을 늘리지 않게 막는다.

**좋은 예**
```swift
// ViewModel
enum Route {
    case openURL(URL)
}
input.didTapCall
    .sink { [weak self] in self?.output.route.send(.openURL(url)) }

// ViewController (extension)
case .openURL(let url):
    UIApplication.shared.open(url)
```

**나쁜 예**
```swift
import UIKit                              // ❌ ViewModel 에서 UIKit
import SwiftUI                            // ❌ ViewModel 에서 SwiftUI (Observation 만)
import ReactorKit                         // ❌ 신규 Reactor

UIApplication.shared.open(url)            // ❌ VM이 UI를 직접 조작

struct Dependency {
    let repository: ReviewRepositoryImpl  // ❌ 구현체 타입 → 목 교체 불가
}
```

**강제 수단** — SwiftLint custom_rules:
- `no_rx_reactorkit` — `import RxSwift/RxCocoa/RxRelay/RxDataSources/ReactorKit` 금지 (모든 파일)
- `viewmodel_no_uikit_import` — `*ViewModel.swift`에서 `import UIKit`·`import SwiftUI` 금지 (`@Observable`은 `import Observation`)
- `viewmodel_no_uiapplication` — `*ViewModel.swift`에서 `UIApplication.shared` 금지
- `viewmodel_inherits_base` — `class XxxViewModel` 선언이 `BaseViewModel`을 상속하지 않으면 실패

**예외(베이스라인)** — Rx/ReactorKit import 71건(Reactor 화면: splash·signin·signup·waiting·setting·faq 등), `import UIKit`·`SwiftUI` 5건, `BaseViewModel` 미상속 3건 동결. `Dependency`의 `init` 기본값 인자(`repository: ReviewRepository = ReviewRepositoryImpl()`)는 구현체 이름이 나와도 허용한다. 프로퍼티 타입이 protocol이면 된다. `Preference`처럼 아직 protocol이 없는 의존은 그대로 두되, 테스트에서 바꿔야 하면 그때 protocol로 분리한다.

---

## R6. (예외로 만드는) ViewController와 Cell은 Base 클래스를 상속한다

**규칙** — R7 예외로 만들거나 기존에 있는 ViewController는 `BaseViewController`, UIKit CollectionViewCell은 `BaseCollectionViewCell`, TableViewCell은 `BaseTableViewCell`을 상속한다. Cell 안에 `registerId`/`reuseIdentifier` 같은 static 식별자를 두지 않는다.

**이유** — `cancellables`·`disposeBag`·페이지뷰 로그·에러 알럿을 Base 한 곳에서 관리해야 메모리 누수와 바인딩·로그 누락을 구조적으로 막는다. Cell 등록/디큐는 확장(`register(_:)`, `dequeueReusableCell(indexPath:)`)이 타입 이름으로 처리하므로 별도 식별자는 중복이다.

**좋은 예**
```swift
final class ReviewDetailViewController: BaseViewController { ... }
final class ReviewListItemCell: BaseCollectionViewCell { ... }

collectionView.register([ReviewListItemCell.self])
let cell: ReviewListItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
```

**나쁜 예**
```swift
final class CouponCloseAlertViewController: UIViewController { ... }   // ❌

final class SettingTableViewCell: UITableViewCell {
    static let registerId = "\(SettingTableViewCell.self)"   // ❌
}
```

**강제 수단** — SwiftLint custom_rules `vc_inherits_base`, `cell_inherits_base`, `no_register_id` (`domains/base/` 제외).

**예외(베이스라인)** — VC 3건(쿠폰 알럿 2개, `DatePickerSheetViewController`), `registerId` 3건(설정·FAQ) 동결.

---

## R7. 새 화면과 화면 전환은 SwiftUI로 만들고, 표현은 디자인 토큰으로 통일한다

**규칙** — 새 화면·뷰는 **SwiftUI**(`struct XxxView: View`)로 만들고, 새 화면 사이의 전환은 **`NavigationStack`(push)·`.sheet`·`.fullScreenCover`** 로 한다. ViewController(VC)는 새로 만들지 않는다.
VC와 UIKit 전환(`pushViewController`·`present`·PanModal)은 **기존 UIKit 코드와 맞닿는 경계에서만** 쓴다.

| 경계 | 방법 |
|---|---|
| 기존 UIKit 화면 → 새 SwiftUI 플로우 | `UIHostingController(rootView: XxxFlowView(...))` **인스턴스**를 만들어 present(권장) 또는 push. VC 서브클래스를 만들지 않는다 |
| 새 SwiftUI 플로우 → 기존 UIKit 화면 | 그 화면을 SwiftUI로 옮기는 게 우선. 당장 못 옮기면 플로우가 받은 브릿지 클로저로 UIKit 쪽에서 띄운다 |
| 탭 루트·딥링크 핸들러·로그인 전환 등 UIKit 인프라 | 기존 코드 유지. 새 탭 루트는 `UIHostingController(rootView: NavigationStack { … })` |

UIKit은 SwiftUI로 할 수 없을 때만 쓰고, 그때는 사유를 단다.
색은 토큰(SwiftUI `Color.gray100` / UIKit `UIColor.gray100`), 폰트는 `Font.bold(size:)` / `UIFont.bold(size:)`, 이미지는 SwiftGen `Assets`, 문자열은 SwiftGen `Strings`만 쓴다. UIKit 코드에서는 SnapKit `leading/trailing`, 클로저 초기화를 쓰고 `then`은 쓰지 않는다.

**이유** — VC를 점진적으로 걷어내기 위해서다. 새 화면이 VC를 하나 만들 때마다 UIKit 네비게이션에 묶이는 화면이 늘어나 나중에 걷어낼 양이 커진다. 전환까지 SwiftUI로 하면 VC는 기존 코드와의 경계에만 남고, 경계는 시간이 지날수록 줄어든다.
선언형 UI는 상태 → 화면 매핑을 한 곳에 모아서, AI가 만든 화면도 사람이 빨리 읽고 `#Preview`로 바로 확인할 수 있다. 배포 타깃이 iOS 17.6이라 `@Observable`·`NavigationStack(path:)`·`navigationDestination`을 모두 쓸 수 있다.
디자인 토큰은 두 프레임워크가 같은 값을 쓰도록 `Color+.swift`가 `UIColorExtensions.swift`를 감싼다.

**경계에서 확인된 동작** (시뮬레이터 실측, 2026-09-26)
- SwiftUI 안의 push/pop, 스와이프 뒤로가기, `.sheet`의 `dismiss()`는 정상 동작한다.
- UIKit에서 **fullScreen present**로 띄운 플로우는 루트에서 `dismiss()`로 닫힌다.
- UIKit `UINavigationController`에 **push**한 플로우는 루트에서 `dismiss()`도, 가장자리 스와이프도 **동작하지 않는다.** 그래서 push로 진입하면 루트에 닫기(뒤로) 버튼을 두고, 브릿지가 넘긴 `onClose` 클로저로 UIKit pop을 해야 한다. 이 제약 때문에 UIKit → SwiftUI 진입은 **present를 권장**한다.

**좋은 예**
```swift
// 새 화면 사이 전환: NavigationStack
NavigationStack(path: $path) {
    ReviewListView(viewModel: listViewModel, path: $path)
        .navigationDestination(for: ReviewFlowDestination.self) { destination in
            switch destination {
            case .detail(let viewModel): ReviewDetailView(viewModel: viewModel, path: $path)
            }
        }
}

// 기존 UIKit 화면 → 새 SwiftUI 플로우: 인스턴스만 만든다
let hostingController = UIHostingController(rootView: ReviewFlowView())
hostingController.modalPresentationStyle = .fullScreen
present(hostingController, animated: true)

// SwiftUI 에 없는 UIKit 컴포넌트는 UIViewRepresentable 로 감싼다
struct NaverMapView: UIViewRepresentable { ... }

// 기존 코드 때문에 꼭 필요하면 사유를 단다
// swiftlint:disable:next no_new_view_controller - PanModalPresentable 이 UIViewController 를 요구
final class CouponGuideSheetViewController: BaseViewController { ... }
```

**나쁜 예**
```swift
final class CouponListViewController: BaseViewController { ... }   // ❌ 새 화면을 VC 로
navigationController?.pushViewController(detailViewController, animated: true)   // ❌ 새 화면 사이 전환을 UIKit 으로
final class CouponListCell: BaseCollectionViewCell { ... }         // ❌ 새 UIKit 셀 (SwiftUI List/LazyVStack 로)

private let titleLabel = UILabel().then {          // ❌ then
    $0.textColor = UIColor(r: 255, g: 0, b: 0)      // ❌ 색 리터럴
}
Text("제목").foregroundStyle(Color(red: 1, green: 0, blue: 0))   // ❌ SwiftUI 색 리터럴
```

**강제 수단** — SwiftLint custom_rules:
- `no_new_view_controller` — `UIViewController`/`BaseViewController`/`UIHostingController`/`UINavigationController` 등 VC 서브클래스 선언 금지 (`domains/base/` 제외)
- `no_new_uikit_view` — `UIView`/`BaseView`/Cell/`UIButton`/`UILabel`/`UIStackView` 등 UIKit 뷰 클래스 선언 금지
- `uikit_disable_reason` — 위 두 규칙을 사유 없이 disable 하면 실패. 예외는 `// swiftlint:disable:next {규칙} - {사유}`
- `no_uicolor_literal` — `UIColor`·`Color`의 hex 문자열 리터럴·RGB 직접 생성 금지. 서버가 내려준 색을 변수로 넘기는 `UIColor(hex: value)`는 허용, 토큰 정의 파일 `UIColorExtensions.swift`·`Color+.swift` 제외
- `snapkit_leading_trailing`(`$0.left.`/`.right.`/`make.left` 등), `no_then`(`.then {` 및 `import Then`)

새 화면 사이에서 `pushViewController`·`present`를 부르는지는 린트로 가르기 어려워(기존 화면 수정과 구분이 안 됨) AI 리뷰(`/3dollars:pr-code-review`)가 본다.

**예외(베이스라인)** — 기존 VC 41건, UIKit 뷰 클래스 120건, `UIColor(` 리터럴 35건, left/right 162건, `then` 67건 동결. 기존 UIKit 화면을 **고치는** 건 UIKit 그대로 해도 된다(기존 VC 안의 전환 포함). 화면 대부분을 다시 만드는 수준이면 SwiftUI로 옮기고, 그 화면으로 들어오던 UIKit 전환은 `UIHostingController` 진입으로 바꾼다. 토큰에 없는 새 색이 필요하면 `UIColorExtensions.swift`와 `Color+.swift`에 토큰을 먼저 추가한다.

---

## R8. 타입은 책임 하나만 진다

**규칙** — 클래스·구조체·enum은 책임 하나만 진다. 줄 수는 규칙이 아니라 **점검 신호**다. 타입 본문 500줄 또는 파일 800줄을 넘기면 린트가 멈추고, 그래도 책임이 하나라면 사유를 달아 예외로 둔다.

**이유** — 길이 자체가 문제가 아니라 **변경 하나가 건드리는 상태가 많아지는 것**이 문제다. 상태가 얽히면 TC 하나를 검증하려고 무관한 상태까지 세팅해야 하고, AI의 수정 범위도 넓어진다. AI는 기존 파일에 덧붙이지 먼저 쪼개자고 하지 않으므로, 사람이 diff를 안 보는 이 프로세스에선 기계적인 멈춤 지점이 하나는 있어야 한다. 반대로 코드 UI(SnapKit)는 책임이 하나여도 300줄을 쉽게 넘기므로, 낮은 임계값은 가짜 분리(같은 파일 `extension`으로 옮기기 — `type_body_length`는 extension을 세지 않는다)만 부른다.

**좋은 예** — 화면이 여러 기능을 가지면 섹션·기능 단위 하위 ViewModel(`XxxCellViewModel`)로 나누고 상위는 조합만 한다(`StatisticsViewModel` + `StatisticsFeedbackCountCellViewModel`). 셀 하나의 레이아웃이 길어 500줄을 넘으면 사유를 단다.

```swift
// swiftlint:disable:next type_body_length - 셀 하나의 레이아웃만 담당(서브뷰 선언·제약이 길 뿐 상태 없음)
final class XxxCell: BaseCollectionViewCell {
```

**나쁜 예** — 한 ViewModel이 가게 정보·메뉴·영업일·계좌를 전부 처리. 줄 수를 맞추려고 메서드를 같은 파일 `extension`으로 옮기기. 사유 없는 `disable`.

**강제 수단** — SwiftLint 기본 룰 `type_body_length: 500`, `file_length: 800`(둘 다 warning·error 같은 값. warning을 생략하면 기본값이 살아나고, CI는 `--strict`라 warning도 실패다) + 커스텀 룰 `length_disable_reason`(사유 없는 `disable` 금지).

**예외(베이스라인)** — 현재 0건.

---

## R9. 로그는 LogManager·OSLog로 남기고 `print`·`as!`·`try!`는 쓰지 않는다

**규칙** — 애널리틱스 이벤트·페이지뷰는 `LogManager`(`LogManagerProtocol`)로, 디버그 출력은 `OSLog`의 `Logger`로 남긴다. `print`, 강제 캐스팅 `as!`, 강제 시도 `try!`는 쓰지 않는다.

**이유** — `print`는 릴리즈에서 의미 없이 남고 Crashlytics·콘솔 필터에 걸리지 않는다. `as!`/`try!`는 서버 응답이 바뀌는 순간 크래시로 직결된다. 실패는 `Result`/옵셔널로 흘려 `Route.showErrorAlert`로 보낸다.

**좋은 예**
```swift
dependency.logManager.sendEvent(.init(screen: output.screenName, eventName: .tapReport))

private let logger = Logger(subsystem: Bundle.identifier, category: "Upload")
logger.error("upload failed: \(error.localizedDescription)")

guard let cell = cell as? ReviewListItemCell else { return }
```

**나쁜 예**
```swift
print("fetch failed \(error)")          // ❌
let value = userInfo[key] as! NSValue   // ❌
let data = try! JSONDecoder().decode(...)  // ❌
```

**강제 수단** — SwiftLint custom_rule `no_print` + 기본 룰 `force_cast`, `force_try`를 `error`로 승격.

**예외(베이스라인)** — `print` 4건(AppDelegate 3, ImageRequestable 1), `as!` 4건(키보드 프레임 2, Rx Observer 확장 2) 동결. `utils/NetworkActivityLogger.swift`는 네트워크 디버그 로거 자체라 규칙 대상에서 제외한다.

---

## R10. ViewModel 구조·Route 분리·서버 네이밍을 통일한다

**규칙** — 모든 ViewModel은 `Input / Output / Route / Config / Dependency / State`의 중첩 타입 구조를 따른다(화면 간 이벤트 중계가 필요하면 `Relay`). SwiftUI 화면의 ViewModel은 `@Observable`을 붙이고 `State`를 `private(set) var state`로 노출해 View가 그리게 한다 — 화면 상태를 `Output`의 Subject로 흘리지 않는다. `Output`에는 `route`·토스트 같은 **일회성 이벤트**만 남기고, View가 `.onReceive(viewModel.output.route)`로 받아 `NavigationStack` path·sheet로 전환한다. UIKit 레거시 화면의 `Route` 처리는 ViewController의 `extension`(`// MARK: Route`)의 `handleRoute(_:)`로 분리한다. API·Repository·Model 이름은 서버(OpenAPI)에서 정의한 이름과 동일하게 짓는다.

**이유** — 화면 40여 개가 같은 모양이어야 AI가 새 화면을 만들 때도, 사람이 리뷰할 때도 "어디를 보면 되는지"를 안다. 서버 네이밍을 그대로 쓰면 API 문서와 코드 사이 번역 비용이 사라진다.

**좋은 예** — 루트 `CLAUDE.md`의 "SwiftUI 화면 패턴" 템플릿. (UIKit 레거시 예: `ReviewDetailViewModel` / `ReviewDetailViewController`.)

**나쁜 예**
```swift
final class StoreViewModel: BaseViewModel {
    let didTapButton = PassthroughSubject<Void, Never>()   // ❌ Input 밖에 흩어진 입력
    var items: [Item] = []                                 // ❌ State 밖 상태
}

struct StoreDetail: Decodable { let storeName: String }   // ❌ 서버는 `name`
```

**강제 수단** — 이 문서 + 루트 `CLAUDE.md` + PR AI 리뷰. 기계 판별이 애매해 유일하게 문서로만 강제한다. 반복 지적이 쌓이면 부분 규칙(예: "`*ViewModel.swift`에 `struct Input`이 없으면 실패")을 린트로 승격한다.

**예외** — `Route`가 없는 단순 화면·셀 ViewModel은 `Route` 생략 가능. `Config`/`Dependency`/`State`는 필요할 때만.

---

## 베이스라인 운영

- SwiftLint: `.swiftlint-baseline.json`(`make lint-baseline`으로 생성). 베이스라인에 있는 위반은 보고되지 않는다. 파일을 옮기거나 크게 고쳐 베이스라인 매칭이 깨지면 그때 고친다.
- 베이스라인은 **줄어들기만** 해야 한다. 새 항목을 추가하는 PR은 리뷰어가 사유를 확인한다.

## 규칙을 바꾸는 방법

1. PR 리뷰에서 같은 지적이 **3번** 이상 나오면 규칙 후보가 된다 (`/3dollars:review-digest`).
2. 기계 판별 가능하면 린트(custom_rule) → 그래도 안 되면 이 문서. 문서로만 강제되는 규칙은 최소로 유지한다.
3. 10개를 넘기면 기존 규칙을 합치거나 뺀다. 규칙 변경 PR은 이 문서·`.swiftlint.yml`·루트 `CLAUDE.md`를 한 번에 바꾼다. 유저앱과 공통인 규칙이면 유저앱 레포도 같이 맞춘다.
