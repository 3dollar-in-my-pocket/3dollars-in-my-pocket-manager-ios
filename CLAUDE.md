# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

**가슴속 3천원 사장님**은 푸드트럭·노점 사장님이 영업 위치를 공개하고 가게 정보·리뷰·쿠폰·소식을 관리하는 iOS 앱입니다. 유저앱(`3dollars-in-my-pocket-ios`)과 같은 서버(`/boss` API)를 씁니다.

유저앱과 달리 **Tuist 모듈 구조가 아니라 단일 앱 타깃**(`3dollar-in-my-pocket-manager.xcodeproj`)입니다. 유저앱 문서의 모듈·Interface·Demo 관련 내용은 이 레포에 해당하지 않습니다.

**신규 화면과 화면 전환은 SwiftUI로 만듭니다.** 새 화면 사이 전환은 `NavigationStack`·`.sheet`로 하고, ViewController는 새로 만들지 않고 조금씩 걷어냅니다. VC·UIKit 전환은 기존 UIKit 코드와 맞닿는 경계(기존 화면 → 새 플로우 진입 등)에서만 씁니다(R7, 린트로 강제). 기존 화면은 UIKit(SnapKit)·ReactorKit이 섞여 있습니다.

## 필수 명령어

### 빌드
```bash
# Debug (개발 서버) 빌드
xcodebuild build \
  -project 3dollar-in-my-pocket-manager.xcodeproj \
  -scheme 3dollar-in-my-pocket-manager-dev \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'

# Release (운영 서버) 빌드
xcodebuild build \
  -project 3dollar-in-my-pocket-manager.xcodeproj \
  -scheme 3dollar-in-my-pocket-manager \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

**주의사항**:
- 워크스페이스가 아니라 `-project 3dollar-in-my-pocket-manager.xcodeproj`로 빌드합니다
- `-destination`의 기기명은 **머신마다 다릅니다.** 설치된 기기를 먼저 확인하세요
  ```bash
  xcrun simctl list devices available | grep iPhone
  ```
- 빌드만 확인할 때는 `-destination 'generic/platform=iOS Simulator'`도 됩니다
- 문자열(`resources/strings/en.lproj/Localizations.strings`)·에셋(`resources/Assets.xcassets`)을 바꾸면 `swiftgen`으로 `Generated/Strings.swift`·`Generated/Assets.swift`를 재생성합니다 (`swiftgen.yml`)
- 새 화면 폴더를 추가하면 Xcode 프로젝트에 파일을 등록해야 할 수 있습니다. 일부 폴더(`ReviewDetail`, `ReviewList`, `AI`, `DeepLink`, `Service` 등)만 폴더 동기화(Buildable Folder)입니다

### 테스트
```bash
# 전체 테스트 (테스트 액션은 -dev 스킴에 있습니다)
xcodebuild test \
  -project 3dollar-in-my-pocket-manager.xcodeproj \
  -scheme 3dollar-in-my-pocket-manager-dev \
  -destination 'platform=iOS Simulator,id=<xcrun simctl list devices available 로 확인한 UDID>'

# 특정 테스트 클래스만
xcodebuild test \
  -project 3dollar-in-my-pocket-manager.xcodeproj \
  -scheme 3dollar-in-my-pocket-manager-dev \
  -destination 'platform=iOS Simulator,id=<UDID>' \
  -only-testing:3dollar-in-my-pocket-managerTests/{TestClassName}
```

**테스트 파일 위치**: `3dollar-in-my-pocket-managerTests/Sources/` 아래 `ViewModelTests/`(화면 로직) · `ServiceTests/`(서비스·Api) · `DecodingTests/`(응답 파싱) · `Support/`(공용 목·픽스처 로더), 픽스처는 `3dollar-in-my-pocket-managerTests/Resources/`. 테스트 타깃은 폴더 동기화라 파일만 추가하면 됩니다. 앱 모듈은 `@testable import _dollar_in_my_pocket_manager`(타깃명이 숫자로 시작해 앞에 `_`가 붙음).

**테스트는 세 계층입니다** — ① **유닛 테스트 코드**(ViewModel/Service/Decoding, XCTest, CI가 돌림) ② **자동화 테스트 TC**(`3dollars:simulator-test`가 시뮬레이터를 조작하는 E2E, PR 전 실행 후 스크린샷·영상 증거. 로그인 뒤 화면은 목 Repository 하네스로 띄움) ③ **수동 테스트 TC**(시뮬레이터로 상황을 만들 수 없어 실기기·사람이 필요한 것). 테크스펙 TC는 반드시 셋 중 하나 이상에 배정되고, 위 계층을 먼저 씁니다. 분류 기준은 [docs/process/e2e-and-manual-tests.md](docs/process/e2e-and-manual-tests.md).

**테스트는 diff가 아니라 테크스펙의 TC에서 도출합니다.** 메서드명은 `test_{티켓}_TC{n}_{조건}_{기대결과}()` (예: `test_TH1384_TC2_신고에성공하면_토스트와dismissRoute가발행된다`). **TC 번호는 노션 테크스펙의 `TC-n`을 그대로 쓰고 티켓 안에서 유일**합니다 — 파일이 갈라져도 1부터 다시 시작하지 않습니다. 스펙에 없는 케이스는 테크스펙에 TC를 먼저 추가하고 그 번호를 씁니다. 가이드: [docs/process/testing.md](docs/process/testing.md), 자동화: `/3dollars:test-cases`

### 린트 검증 (SwiftLint)
```bash
# 전체 검증
make lint

# SwiftLint 자동 수정
make lint-fix

# 베이스라인 재생성 (기존 위반 동결. 사유 없이 쓰지 않는다)
make lint-baseline
```

**주의사항**:
- SwiftLint는 Xcode 빌드 페이즈에 없습니다. 로컬은 `make lint`, PR은 GitHub Actions `lint.yml`(`--strict`)에서 검사합니다
- 기존 위반은 `.swiftlint-baseline.json`에 동결되어 있습니다. **새 위반만** 실패로 처리되며, 베이스라인에 항목을 추가하는 PR은 사유가 필요합니다
- 코드 작성 후 반드시 `make lint`를 실행합니다

## PR 프로세스

전체 흐름(테크스펙 → 규칙 → 테스트 → 증거 → PR)과 위험도(경량/풀코스) 기준은 **[docs/process/pr-process.md](docs/process/pr-process.md)** 한 장에 있습니다. PR은 `/3dollars:pr-body`로 만듭니다 (`.github/PULL_REQUEST_TEMPLATE.md`).

## 아키텍처 규칙

경계에 관한 규칙은 **[docs/architecture/RULES.md](docs/architecture/RULES.md)** 에 있습니다 (규칙 / 이유 / 예시 / 강제 수단 / 예외). 유저앱과 번호를 맞추며, 모듈 경계 규칙(R1~R3)은 이 레포에 없습니다.

- **R4** 서버 호출은 `repository/`의 `XxxApi`(enum + `ApiRequest`) → `XxxRepository`(protocol) → `XxxRepositoryImpl`로만. 네이밍은 서버 OpenAPI와 동일하게
- **R5** 신규 화면 ViewModel은 `BaseViewModel` 상속 + `@Observable`. **ReactorKit·RxSwift 신규 사용 금지.** `*ViewModel.swift`는 `import UIKit`·`import SwiftUI`·`UIApplication.shared` 금지(`import Observation`만), `Dependency` 프로퍼티는 protocol 타입. URL 열기·알럿·전환 같은 UI 동작은 `Route`로 View(레거시는 VC)에 넘긴다
- **R6** (기존 또는 R7 예외로 만드는) VC는 `BaseViewController`, UIKit Cell은 `BaseCollectionViewCell`/`BaseTableViewCell` 상속. `registerId` 같은 static 식별자 금지
- **R7** 새 화면·뷰는 **SwiftUI**, 새 화면 사이 전환은 **`NavigationStack`·`.sheet`·`.fullScreenCover`**. 새 VC·UIKit 뷰 클래스는 `// swiftlint:disable:next no_new_view_controller|no_new_uikit_view - {사유}`가 있을 때만. 기존 UIKit 화면에서 진입할 때는 `UIHostingController(rootView:)` 인스턴스로 충분(UIKit 컴포넌트는 `UIViewRepresentable`로 감싸기 우선). 색은 토큰(`Color.gray100`/`UIColor.gray100`), 폰트는 `Font.bold(size:)`/`UIFont.bold(size:)`, 이미지·문자열은 SwiftGen `Assets`/`Strings`. UIKit 코드는 SnapKit `leading/trailing`, `then` 금지
- **R8** 타입은 책임 하나. 타입 500줄·파일 800줄을 넘으면 분리하거나 `// swiftlint:disable:next type_body_length - {사유}`
- **R9** `print`·`as!`·`try!` 금지. 이벤트는 `LogManager`, 디버그 출력은 OSLog `Logger`
- **R10** ViewModel은 `Input / Output / Route / Config / Dependency / State` 구조. SwiftUI 화면은 `private(set) var state`를 View가 그리고, `Output`엔 route 같은 일회성 이벤트만 두어 View가 `.onReceive`로 전환. 레거시 UIKit 화면의 Route 처리는 VC의 `// MARK: Route` extension

규칙을 바꿀 때는 RULES.md·`.swiftlint.yml`·이 파일을 함께 수정합니다.

## 프로젝트 구조

```
3dollar-in-my-pocket-manager/
├── domains/          # 화면 단위 폴더 (Home, MyStore/*, AI, Preference, setting, membership, splash, main)
│   ├── base/         # BaseViewController, BaseViewModel, BaseCollectionViewCell, BaseTableViewCell, BaseView, (레거시) BaseReactor·BaseCoordinator
│   └── shared/       # 여러 화면이 쓰는 공용 뷰
├── repository/       # XxxApi + XxxRepository(Impl). 레거시 Rx XxxService 도 여기 있음 (신규 금지)
├── Network/          # ApiRequest 프로토콜(asyncRequest), ApiError
├── models/           # dto/request, dto/response, presentation, analytics
├── managers/         # log(LogManager), location, DeepLink, social-sign-in, Toast, loading
├── Service/          # GlobalEventService (화면 간 이벤트 버스)
├── extensions/       # UIColor/UIFont 토큰, UIKit·Combine 확장
├── resources/        # Assets.xcassets, strings, fonts, lottie, firebase
└── Generated/        # SwiftGen 산출물 (직접 수정 금지)
3dollar-in-my-pocket-managerTests/   # 유닛 테스트 타깃
```

화면 이름 ↔ 코드 위치를 찾을 때는 `domains/` 아래 폴더명을 먼저 봅니다 (예: 리뷰 상세 → `domains/MyStore/Statistics/ReviewDetail`).

## 주요 개발 패턴

### SwiftUI 화면 패턴 (신규 화면 기본)

새 기능은 **플로우** 단위로 만듭니다: **FlowView**(`NavigationStack` 소유, UIKit에서 들어오는 유일한 지점) → **화면 View**(`struct XxxView: View`) ↔ **ViewModel**(`@Observable`, 로직·상태).
새 화면 사이의 전환은 `NavigationStack` push, `.sheet`, `.fullScreenCover`로 합니다. **VC는 만들지 않습니다**(R7, 린트 `no_new_view_controller`). VC·UIKit 전환은 기존 UIKit 코드와 맞닿는 경계에서만 씁니다.

```swift
// XxxViewModel.swift — import Observation 만 (UIKit·SwiftUI 금지, R5)
import Combine
import Observation

extension CommentPresetListViewModel {
    struct Input {                       // View → ViewModel
        let onAppear = PassthroughSubject<Void, Never>()
        let didTapPreset = PassthroughSubject<CommentPresetResponse, Never>()
        let didTapClose = PassthroughSubject<Void, Never>()
    }

    struct Output {                      // 일회성 이벤트만 (화면 상태는 State)
        let screenName: ScreenName = .commentPresetList   // managers/log/ScreenName.swift 에 case 추가
        let route = PassthroughSubject<Route, Never>()
    }

    struct State {                       // View 가 그리는 값
        var presets: [CommentPresetResponse] = []
        var isLoading = false
    }

    enum Route {
        case pushEdit(CommentPresetEditViewModel)
        case close
        case showErrorAlert(Error)
    }

    struct Config {
        let storeId: String
    }

    struct Dependency {
        let reviewRepository: ReviewRepository
        let logManager: LogManagerProtocol

        init(
            reviewRepository: ReviewRepository = ReviewRepositoryImpl(),
            logManager: LogManagerProtocol = LogManager.shared
        ) {
            self.reviewRepository = reviewRepository
            self.logManager = logManager
        }
    }
}

@Observable
final class CommentPresetListViewModel: BaseViewModel {
    let input = Input()
    let output = Output()
    private(set) var state = State()
    private let config: Config
    private let dependency: Dependency

    init(config: Config, dependency: Dependency = Dependency()) {
        self.config = config
        self.dependency = dependency

        super.init()

        bind()
    }

    private func bind() {
        input.onAppear
            .withUnretained(self)
            .sink { (owner: CommentPresetListViewModel, _) in
                owner.dependency.logManager.sendPageView(screen: owner.output.screenName, type: CommentPresetListViewModel.self)
                Task { await owner.fetchPresets() }
            }
            .store(in: &cancellables)

        input.didTapPreset
            .withUnretained(self)
            .sink { (owner: CommentPresetListViewModel, preset: CommentPresetResponse) in
                let viewModel = CommentPresetEditViewModel(config: .init(preset: preset))
                owner.output.route.send(.pushEdit(viewModel))
            }
            .store(in: &cancellables)

        input.didTapClose
            .withUnretained(self)
            .sink { (owner: CommentPresetListViewModel, _) in
                owner.output.route.send(.close)
            }
            .store(in: &cancellables)
    }

    @MainActor   // state 는 View 가 관찰하므로 메인 스레드에서만 바꾼다
    private func fetchPresets() async {
        guard !state.isLoading else { return }
        state.isLoading = true

        let result = await dependency.reviewRepository.fetchCommentPresets(storeId: config.storeId)
        state.isLoading = false

        switch result {
        case .success(let response):
            state.presets = response.contents
        case .failure(let error):
            output.route.send(.showErrorAlert(error))
        }
    }
}
```

```swift
// 전환 대상 ViewModel 은 NavigationDestinationViewModel 을 따른다 (path·sheet 에 넣기 위해)
@Observable
final class CommentPresetEditViewModel: BaseViewModel, NavigationDestinationViewModel { ... }
```

```swift
// XxxFlowView.swift / XxxView.swift — 전환은 View 가 route 를 받아 path·sheet 로 한다
import SwiftUI

enum CommentPresetDestination: Hashable {
    case edit(CommentPresetEditViewModel)
}

/// 플로우 루트: NavigationStack 을 소유한다. UIKit 에서 진입하는 유일한 지점.
struct CommentPresetFlowView: View {
    @State private var path: [CommentPresetDestination] = []
    @State private var listViewModel: CommentPresetListViewModel
    /// UIKit 에 push 로 진입했을 때만 넘긴다 (루트에서 dismiss·스와이프가 동작하지 않으므로). present 진입이면 nil → dismiss()
    private let onClose: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    init(storeId: String, onClose: (() -> Void)? = nil) {
        _listViewModel = State(initialValue: CommentPresetListViewModel(config: .init(storeId: storeId)))
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack(path: $path) {
            CommentPresetListView(viewModel: listViewModel, path: $path, close: close)
                .navigationDestination(for: CommentPresetDestination.self) { destination in
                    switch destination {
                    case .edit(let viewModel):
                        CommentPresetEditView(viewModel: viewModel)
                    }
                }
        }
    }

    private func close() {
        if let onClose {
            onClose()
        } else {
            dismiss()
        }
    }
}

struct CommentPresetListView: View {
    let viewModel: CommentPresetListViewModel   // @Observable 은 프로퍼티로 받아도 추적된다
    @Binding var path: [CommentPresetDestination]
    let close: () -> Void
    @State private var error: Error?

    var body: some View {
        List(viewModel.state.presets, id: \.presetId) { preset in
            Button {
                viewModel.input.didTapPreset.send(preset)
            } label: {
                Text(preset.body)
                    .font(.medium(size: 14))
                    .foregroundStyle(Color.gray100)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Strings.ReviewDetail.comment)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.input.didTapClose.send(())
                } label: {
                    Assets.icBack.swiftUIImage
                }
            }
        }
        .onAppear { viewModel.input.onAppear.send(()) }
        .onReceive(viewModel.output.route) { route in
            switch route {
            case .pushEdit(let editViewModel):
                path.append(.edit(editViewModel))
            case .close:
                close()
            case .showErrorAlert(let error):
                self.error = error
            }
        }
        .errorAlert($error)
    }
}

struct CommentPresetEditView: View {
    let viewModel: CommentPresetEditViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Text(viewModel.state.body)
            .font(.regular(size: 14))
            .onReceive(viewModel.output.route) { route in
                switch route {
                case .back:
                    dismiss()   // NavigationStack 안에서는 pop, sheet 안에서는 닫기
                }
            }
    }
}

#Preview {
    CommentPresetFlowView(storeId: "preview")
}
```

**UIKit 경계 — 기존 UIKit 화면에서 새 플로우로 들어갈 때** (VC 서브클래스를 만들지 않고 인스턴스만 만든다)

```swift
// 권장: present. 루트에서 dismiss() 로 닫힌다
let hostingController = UIHostingController(rootView: CommentPresetFlowView(storeId: storeId))
hostingController.modalPresentationStyle = .fullScreen
present(hostingController, animated: true)

// push 로 넣어야 하면 onClose 필수 — 루트에서 dismiss()·가장자리 스와이프가 UIKit 으로 돌아가지 않는다 (시뮬레이터 실측)
let flow = CommentPresetFlowView(storeId: storeId, onClose: { [weak self] in
    self?.navigationController?.popViewController(animated: true)
})
navigationController?.pushViewController(UIHostingController(rootView: flow), animated: true)
```

- 새 플로우에서 **기존 UIKit 화면**으로 가야 하면, 그 화면을 SwiftUI로 옮기는 게 우선입니다. 당장 못 옮기면 FlowView가 브릿지 클로저(`onOpenLegacyXxx`)를 받아 UIKit 쪽에서 띄웁니다
- 바텀시트는 SwiftUI `.sheet` + `.presentationDetents`를 씁니다. PanModal은 기존 UIKit 화면에서만 씁니다
- 새 탭 루트가 필요하면 `UIHostingController(rootView: XxxFlowView())`를 `MainTabController`에 넣습니다 (`UINavigationController`로 감싸지 않음)

**구조 요소**:
- **Input**: View에서 보내는 이벤트 모음 (PassthroughSubject). 화면 진입은 `onAppear` → ViewModel이 페이지뷰 로그를 보냄(`BaseViewController`가 하던 일)
- **Output**: View가 처리하는 **일회성 이벤트**(route, 토스트). 화면에 계속 보이는 값은 넣지 않습니다
- **State**: View가 그리는 화면 상태. `private(set) var state`로 노출하고 ViewModel만 바꿉니다 (`@MainActor` 메서드에서)
- **Route**: 전환(`pushXxx(ViewModel)`, `presentXxx(ViewModel)`), 닫기, 에러 알럿. View가 `.onReceive(viewModel.output.route)`로 받아 `path.append`·sheet 상태·`dismiss()`로 처리
- **Relay**: 하위 ViewModel(시트 등)에서 올라오는 이벤트를 중계할 때만 (선택사항)
- **Dependency**: 외부 의존 (Repository, LogManager, GlobalEventService 등). protocol 타입, 기본값은 구현체
- **Config**: ViewModel 생성에 필요한 값 (선택사항)

**공용 부품** — 처음 SwiftUI 화면을 만드는 PR에서 `domains/base/SwiftUI/`에 추가하고 이후 재사용합니다 (위 코드는 이 부품이 있다는 전제로 빌드를 확인했습니다):
- `NavigationDestinationViewModel` — ViewModel을 path·sheet에 넣기 위한 identity 기반 `Hashable`/`Identifiable`. `BaseViewModel` 전체에 `Hashable`을 붙이면 기존 셀 ViewModel들의 `Hashable` 구현과 충돌하므로 전환 대상에만 붙입니다
  ```swift
import Foundation

/// NavigationStack path·sheet 에 ViewModel 을 그대로 넣기 위한 identity 기반 Hashable/Identifiable.
/// BaseViewModel 전체에 붙이면 기존 셀 ViewModel 들의 Hashable 구현과 충돌하므로, 전환 대상 ViewModel 에만 붙인다.
protocol NavigationDestinationViewModel: AnyObject, Hashable, Identifiable {}

extension NavigationDestinationViewModel {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
  ```
- `.errorAlert(_ error: Binding<Error?>)` — `BaseViewController.showErrorAlert(error:)`의 분기(401 → 로그인 화면, 점검 안내, `ApiError`·`ApiErrorContainer` 메시지)를 그대로 옮긴 SwiftUI modifier. 동작이 달라지면 안 되므로 옮긴 뒤 두 경로를 같이 확인합니다

**SwiftUI 규칙**:
- 새 화면·셀·컴포넌트는 SwiftUI로 만듭니다. 목록은 `UICollectionView` 대신 `List`/`LazyVStack`
- 네이버맵(`NMFMapView`), 크롭(`TOCropViewController`)처럼 SwiftUI에 없는 UIKit 컴포넌트는 `UIViewRepresentable`/`UIViewControllerRepresentable`로 감쌉니다
- 전환 상태(`path`, sheet 대상)는 View의 `@State`, 화면 데이터는 ViewModel의 `state`에 둡니다
- 색은 `Color.gray100`(`extensions/Color+.swift`), 폰트는 `.font(.bold(size: 16))`(`extensions/Font+.swift`), 이미지 `Assets.xxx.swiftUIImage`, 문자열 `Strings.Xxx.yyy`. `Color(red:)`·hex 리터럴 금지
- 뷰마다 `#Preview`를 둡니다. 서버 데이터가 필요하면 `PreviewMock`(JSON)이나 목 Repository를 `Dependency`로 주입합니다
- 반복 UI는 작은 `View` struct로 쪼갭니다 (R8 — `body`가 길어지면 하위 뷰로)

### UIKit 레거시 화면

기존 화면은 두 종류입니다. 고칠 때는 해당 방식을 그대로 따르고, 화면을 대부분 새로 만드는 수준이면 위 SwiftUI 패턴으로 옮깁니다.
- **UIKit + Combine ViewModel** (Statistics, ReviewDetail, Coupon, EditXxx 등): ViewModel이 `Output`의 Subject로 값을 흘리고 VC가 SnapKit 뷰에 바인딩. 예: `ReviewDetailViewModel` / `ReviewDetailViewController`
- **ReactorKit** (splash·signin·signup·waiting·setting·faq 등): `XxxReactor` + `XxxCoordinator`. 새 Reactor는 만들지 않습니다 (R5, 린트로 강제)

UIKit 코드를 고칠 때의 규칙:
- SnapKit은 left, right 대신 leading, trailing
- 색 `UIColor.gray100`, 폰트 `UIFont.bold(size:)`, `then` 대신 클로저 초기화
- UIKit 뷰 클래스를 새로 만들어야 하면 `// swiftlint:disable:next no_new_uikit_view - {사유}` (예: 기존 UIKit 컬렉션뷰에 셀 하나 추가)
- 기존 VC 안의 전환(`pushViewController`·`present`·PanModal)은 그대로 둬도 됩니다. 그 VC가 **새 SwiftUI 플로우**로 보낼 때는 위 "UIKit 경계" 방식을 씁니다

### Network/Repository/Model 규칙

- 모든 API는 enum + `ApiRequest` 프로토콜 확장으로 구현하고, `asyncRequest()`(async/await, `ApiResult<T>`)로 호출합니다
- Repository는 Protocol + Impl 구조로 분리합니다. 파일은 `repository/`에 둡니다
- API/Repository/Model 네이밍은 서버에서 정의한 네이밍과 동일하게 정의합니다. 요청 DTO는 `models/dto/request`, 응답은 `models/dto/response`
- 레거시 Rx `XxxService`는 새로 만들지 않습니다

```swift
// 1. API enum 정의
enum ReviewApi {
    case fetchReview(storeId: String, reviewId: String)
    case reportReview(storeId: String, reviewId: String, input: ReportCreateRequest)
}

// 2. ApiRequest 확장 (baseUrl 은 기본 Bundle.apiURL + "/boss")
extension ReviewApi: ApiRequest {
    var path: String {
        switch self {
        case .fetchReview(let storeId, let reviewId):
            return "/v1/store/\(storeId)/review/\(reviewId)"
        case .reportReview(let storeId, let reviewId, _):
            return "/v1/store/\(storeId)/review/\(reviewId)/report"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchReview:
            return .get
        case .reportReview:
            return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .fetchReview:
            return nil
        case .reportReview(_, _, let input):
            return input.toDictionary
        }
    }
}

// 3. Repository Protocol
protocol ReviewRepository {
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse>
}

// 4. Repository Impl
final class ReviewRepositoryImpl: ReviewRepository {
    func fetchReview(storeId: String, reviewId: String) async -> ApiResult<StoreReviewResponse> {
        return await ReviewApi.fetchReview(storeId: storeId, reviewId: reviewId).asyncRequest()
    }
}
```

### UICollectionViewCell 구현 규칙 (UIKit 예외일 때만)

- R7 예외로 새로 생성하는 UICollectionViewCell은 `BaseCollectionViewCell`(TableViewCell은 `BaseTableViewCell`)을 상속하고 `setup()`/`bindConstraints()`를 override합니다
- 셀 내부에 registerId(혹은 reuseIdentifier)와 같은 static 프로퍼티를 별도로 생성하지 않습니다. 등록은 `collectionView.register([XxxCell.self])`, 디큐는 `dequeueReusableCell(indexPath:)`

## 코드 스타일/네이밍/구조 규칙

- SwiftLint 규칙(.swiftlint.yml), 아키텍처 규칙(docs/architecture/RULES.md) 및 Swift 표준 컨벤션을 따릅니다
- Import 순서: 표준 → 서드파티. 각 분류 사이에는 한 줄 띄어서 사용합니다
- 클래스/구조체/enum: PascalCase, 변수/함수/상수: camelCase
- Combine 구독은 `cancellables`에 저장합니다
- 파일 이름: SwiftUI 플로우는 `XxxFlowView.swift`(NavigationStack) · `XxxView.swift`(화면) · `XxxViewModel.swift`. `XxxViewController.swift`는 새로 만들지 않음
- 주석은 "왜"에 집중(코드 네이밍이 길거나 코드가 어려운 경우에 주로 사용), 문서화 주석은 Swift 표준 사용
- Git-flow 브랜치 전략. 브랜치는 `feature/TH-xxxx-설명`, `fix/TH-xxxx-설명`, 커밋 메시지는 `TH-xxxx : 내용`

## 빌드 설정

| | Debug (`-dev` 스킴) | Release |
|---|---|---|
| Bundle ID | `com.macgongmon.-dollar-in-my-pocket-manager-dev` | `com.macgongmon.-dollar-in-my-pocket-manager` |
| API URL | `https://dev.threedollars.co.kr` | `https://threedollars.co.kr` |
| 딥링크 스킴 | `dollars-manager-dev` | `dollars-manager` |

- iOS 배포 타겟: **17.6+**, 세로 고정, iPhone 전용
- 메인 개발 브랜치: `develop`
- 배포: Xcode Cloud(`ci_scripts/`) + fastlane match

## 의존성 및 외부 라이브러리

- **SwiftUI / Observation**: 신규 UI (iOS 17.6+)
- **SnapKit**: Auto Layout (UIKit 레거시)
- **Combine / CombineCocoa**: 반응형 프로그래밍 (신규 코드)
- **RxSwift / ReactorKit / RxDataSources**: 레거시 화면 전용 (신규 사용 금지)
- **Alamofire**: 네트워킹 (`ApiRequest` 안에서만)
- **Kingfisher**: 이미지 로딩
- **Firebase**: Analytics, Crashlytics, Messaging, Remote Config
- **KakaoSDK**, Sign in with Apple: 소셜 로그인
- **Naver Maps**: 지도 (`Frameworks/`)
- **PanModal**: 바텀시트 (`Frameworks/PanModal`, 패치 적용 로컬 패키지). UIKit 레거시 전용 — 새 시트는 SwiftUI `.sheet`
- **Lottie**, **TOCropViewController**, **SPPermissions**, **Down**(마크다운)
- **netfox**, **LookinServer**: 디버그 도구

## Skills (자동화 도구)

- **3dollars 플러그인** (`~/.claude/skills/3dollars/`, 개인 환경): 유저앱과 같은 스킬을 이 레포에서도 씁니다. 호출 시 `3dollars:` 접두어가 필요합니다. 스킬 안의 유저앱 경로·스킴 대신 **이 파일의 명령어와 경로**를 씁니다
  - `/3dollars:feature-implementer` — 피처 티켓 → 구현 → 검증 → PR
  - `/3dollars:bug-fix` — 버그 티켓 → 원인 분석·수정 → 검증 → PR
  - `/3dollars:test-cases` — 테크스펙 TC → 계층 배정 → 테스트 코드·커버리지 표
  - `/3dollars:simulator-test` — 시뮬레이터 자동화 TC, Before/After 증거
  - `/3dollars:pr-body` — PR 생성/본문 갱신 (`.github/PULL_REQUEST_TEMPLATE.md`)
  - `/3dollars:drift` — 테크스펙 ↔ diff 대조, 스펙 밖 변경
  - `/3dollars:ask-author` — 설명이 필요한 결정 최대 3개 질문
  - `/3dollars:review-digest` — 반복 리뷰 지적 → 규칙 승격 제안
  - `/3dollars:pr-code-review`, `/3dollars:deploy-dev-build`
- 서버: 사장님 API는 `Bundle.apiURL + "/boss"` 기준입니다. 유저앱의 `server-schema` 스킬이 보는 `/api/v3/api-docs`에는 사장님 API가 없으니, 모델 필드는 기존 DTO와 실제 응답(Proxyman)으로 확인합니다
