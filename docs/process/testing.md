# 테스트 작성 가이드

테스트는 **diff가 아니라 의도 문서(테크스펙)의 TC에서 도출한다.** AI가 코드를 쓰더라도 "무엇을 검증할지"는 사람이 TC 목록으로 먼저 승인하고, 코드는 그 다음이다.
프로세스 전체 그림은 `docs/process/tech-spec-process.md`, 아키텍처 규칙은 `docs/architecture/RULES.md`.

## 흐름

```
노션 테크스펙 TC-1..n
   │  /3dollars:test-cases  (브랜치명 → 티켓 키 → 지라 `테크스펙` 필드 → 노션)
   ▼
TC별 계층 배정 (유닛 / 자동화 / 수동)  ──▶ 사람 승인
   │              │                  │
   ▼              ▼                  ▼
유닛 테스트 코드   simulator-test     PR 본문 체크박스
   │              │                  │
   ▼              ▼                  ▼
CI 커버리지 표    스크린샷·영상 증거    작성자 체크
```

## 테스트의 세 계층

| 계층 | 무엇을 검증 | 실행 주체·시점 | 증거 |
|---|---|---|---|
| **1. 유닛 테스트 코드** | ViewModel Input→Output/Route, Service·Api 로직, 응답 디코딩 | `xcodebuild test` — CI가 PR마다 | CI 코멘트의 TC 커버리지 표 |
| **2. 자동화 테스트 TC** | 시뮬레이터를 에이전트가 조작해 화면을 실제로 거치는 E2E. 탭·스와이프·딥링크를 넣고 스크린샷·영상으로 판정 | `3dollars:simulator-test` — PR 올리기 전, 이번 티켓 TC만 | PR 본문 "증거" 섹션의 스크린샷·영상 |
| **3. 수동 테스트 TC** | 시뮬레이터로 상황 자체를 만들 수 없어 실기기·사람이 필요한 것 | 작성자 — PR 올리기 전 | PR 본문 체크박스 |

- 테크스펙 TC 하나는 **반드시 셋 중 하나 이상**에 배정된다. 어디에도 없는 TC가 있으면 PR을 열 수 없다.
- **위 계층을 먼저 쓴다.** 유닛으로 덮이면 유닛, 안 되면 자동화, 그것도 안 되면 수동. 계층을 내릴 때는 이유가 있어야 한다.
- 한 TC가 두 계층에 걸쳐도 된다 (로그 파라미터는 유닛, 화면 전환은 자동화).
- **2와 3의 경계는 "시뮬레이터로 그 상황을 만들 수 있는가" 하나다.** 판정이 사람 눈이어야 한다는 건 2번이지 3번이 아니다 — 조작은 에이전트가 하고 스크린샷·영상을 증거로 남긴다.

### 무엇이 어느 계층인가

| 대상 | 계층 | 이유 |
|---|---|---|
| Input → Output/Route, State 전이, 로그 전송 | 1 유닛 | ViewModel 경계에서 단언된다 |
| 서버 JSON 디코딩, API path·method·parameters | 1 유닛 | 순수 함수 |
| 화면 진입·전환, 버튼 탭 후 결과, 목록 갱신 | 2 자동화 | 실제 화면을 거쳐야 의미가 있다 |
| 애니메이션·제스처, 바텀시트(PanModal) 노출·닫힘 | 2 자동화 | 영상으로 판정 |
| 지도(네이버맵) 내 가게 위치·주변 가게 마커 | 2 자동화 | 스크린샷으로 판정 |
| OS 권한 팝업 (위치·카메라·사진·알림) | 2 자동화 | `simctl privacy reset` 후 재현 |
| 푸시 수신·딥링크 진입 | 2 자동화 | `simctl push` / `simctl openurl` (`dollars-manager-dev://`) |
| 로그인 뒤 화면 (가게 정보·리뷰·통계·쿠폰 등) | 2 자동화 | 목 Repository 하네스로 로그인 없이 화면을 띄운다 |
| 긴 텍스트·빈 데이터·오프라인 | 2 자동화 | 목 데이터·Proxyman으로 상태를 만든다 |
| 카카오·애플 로그인 자체 | 3 수동 | 시뮬레이터에 해당 앱·계정이 없다 |
| 영업 시작 후 백그라운드 위치 갱신, 실기기 푸시 | 3 수동 | 실제 이동·APNs가 필요하다 |

세부 항목과 화면 변경 PR 공통 체크는 `docs/process/e2e-and-manual-tests.md`.

## 1. 유닛 테스트 코드

### 종류

| 계층 | 검증 대상 | 위치 | 대표 예 |
|---|---|---|---|
| **ViewModel** (화면 로직) | Input → Output/Route 변환, State 전이, 로그 전송 | `Sources/ViewModelTests/` | `ReviewReportBottomSheetViewModelTests` |
| **Service** (서비스·Api) | 서비스·매니저 기능, `XxxApi`의 경로·메서드·파라미터 | `Sources/ServiceTests/` | `ReviewApiTests` |
| **Decoding** (응답 파싱) | 서버 JSON → Model 타입 디코딩, 미지의 값 처리 | `Sources/DecodingTests/` | `ApiErrorContainerTests` |
| 공용 | 목·픽스처 로더 | `Sources/Support/` | `MockLogManager`, `MockReviewRepository`, `FixtureLoader` |

화면 TC는 기본적으로 **ViewModel 테스트**로 쓴다. ViewController·View(SwiftUI 포함)는 테스트하지 않는다(R5 덕분에 ViewModel만으로 화면 로직이 검증된다). SwiftUI View의 모양은 `#Preview`로 작성 중에 보고, 동작은 2번 계층(자동화 TC)으로 확인한다.
ReactorKit 기반 레거시 화면(`XxxReactor`)은 테스트 대상이 아니다. 그 화면의 TC가 유닛으로 필요하면 먼저 Combine ViewModel로 옮기는 게 테스트의 일부다(R5).

### 파일 위치 · 네이밍

```
3dollar-in-my-pocket-managerTests/
├── Sources/
│   ├── ViewModelTests/{ViewModel이름}Tests.swift
│   ├── ServiceTests/{서비스·Api이름}Tests.swift
│   ├── DecodingTests/{응답타입}Tests.swift
│   └── Support/Mock{Protocol}.swift, FixtureLoader.swift, MockError.swift, XCTestCase+WaitUntil.swift
└── Resources/{픽스처}.json
```

- 테스트 메서드명: **`test_{티켓}_TC{n}_{조건}_{기대결과}()`** — 한글 허용. 티켓 키는 하이픈을 뺀다 (`TH-1384` → `TH1384`).
  - `test_TH1384_TC2_신고에성공하면_토스트와dismissRoute가발행된다()`
  - TC 하나를 여러 메서드로 나누면 전부 같은 접두: `test_TH1384_TC1_...` 2개
  - TC와 무관한 회귀 테스트는 `test_회귀_...` 접두 (예: 예전 버그 재발 방지)
- **TC 번호는 테크스펙(티켓) 안에서 유일하다. 노션 테크스펙의 `TC-n` 을 그대로 가져다 쓴다.**
  - 화면·서비스별로 파일이 갈라져도 번호는 스펙 순서 그대로다. **파일마다 1부터 다시 시작하지 않는다.**
  - 티켓 키가 네임스페이스라, 한 클래스에 여러 티켓의 테스트가 쌓여도 번호가 충돌하지 않는다.
  - 한 TC를 ViewModel·Decoding 등 여러 클래스에서 검증해도 번호는 하나다. 클래스는 커버리지 표에서 구분된다.
  - 테크스펙에 없는 케이스를 테스트로 만들고 싶으면 **테크스펙에 TC를 먼저 추가**하고 그 번호를 쓴다. 코드가 스펙보다 앞서가지 않는다.
  - 테크스펙이 없는 티켓(버그·태스크)은 티켓 안에서 1부터 순서대로 붙인다. 이때 번호의 원본은 PR 본문이다.
- `// MARK: {티켓} TC{n}` 으로 묶는다 (`// MARK: TH-1384 TC2`).
- Given / When / Then 주석 3개를 반드시 쓴다.

### 실행

```bash
# 전체 (테스트 액션은 -dev 스킴에 있다. 운영 스킴에는 없다)
xcodebuild test \
  -project 3dollar-in-my-pocket-manager.xcodeproj \
  -scheme 3dollar-in-my-pocket-manager-dev \
  -destination 'platform=iOS Simulator,id=<simctl로 확인한 UDID>'

# 특정 클래스만
  -only-testing:3dollar-in-my-pocket-managerTests/ReviewReportBottomSheetViewModelTests
```

시뮬레이터는 `xcrun simctl list devices available | grep iPhone`으로 고른다. `generic/platform=iOS Simulator`는 테스트 실행에 쓸 수 없다.
테스트 타깃 `3dollar-in-my-pocket-managerTests`는 폴더 동기화(Buildable Folder)라 테스트 파일·픽스처를 폴더에 추가하면 Xcode 프로젝트 수정 없이 바로 포함된다.
앱 모듈 이름은 타깃명이 숫자로 시작해 `_dollar_in_my_pocket_manager`다 → `@testable import _dollar_in_my_pocket_manager`.

### CI (PR 증거)

`.github/workflows/test.yml`이 PR마다 macOS 러너에서 전체 테스트를 돌리고:
- `scripts/test-summary.sh`로 결과를 마크다운(전체 결과 / 실패 목록 / **TC 커버리지 표** / 전체 목록)으로 만들어 **PR 코멘트(갱신형)** 와 Job Summary에 붙인다
- `tests.xcresult`를 아티팩트로 올린다(14일)
- 실패한 테스트가 있으면 체크가 빨간불

TC 커버리지 표는 메서드명 `test_{티켓}_TC{n}_` 접두로 뽑아 티켓별·스펙 번호순으로 정렬한다. 그래서 네이밍 규칙이 곧 증거 규칙이다. 스펙 TC 중 표에 없는 번호가 곧 미커버 TC다.
UI 회귀는 스냅샷 테스트를 쓰지 않는다. 2번 계층(자동화 테스트 TC)이 대신한다.

### ViewModel 테스트 작성법

```swift
import Combine
import XCTest

@testable import _dollar_in_my_pocket_manager   // Input/Output/Route/Dependency 가 internal 이라 @testable

final class ReviewReportBottomSheetViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: TH-1384 TC2

    func test_TH1384_TC2_신고에성공하면_토스트와dismissRoute가발행된다() async {
        // Given
        let repository = MockReviewRepository()
        repository.reportReviewResult = .success("OK")
        let viewModel = ReviewReportBottomSheetViewModel(
            config: .init(reviewId: "review-1"),
            dependency: .init(reviewRepository: repository)
        )
        let routeExpectation = expectation(description: "dismiss")
        viewModel.output.route
            .sink { route in
                if case .dismiss = route { routeExpectation.fulfill() }
            }
            .store(in: &cancellables)

        // When
        viewModel.input.inputText.send("열글자이상인신고사유입니다")
        viewModel.input.didTapReport.send(())

        // Then
        await fulfillment(of: [routeExpectation], timeout: 1)
        XCTAssertEqual(repository.reportReviewCalls.count, 1)
    }
}
```

- **Dependency는 목으로 주입**한다. Repository는 `Support/Mock{Repository}.swift`, 로그는 `MockLogManager`.
- **비동기 판단**: ViewModel에서 `Task { }`로 감싼 Input(보통 `firstLoad`, `didTapSave`류)은 `expectation` + `await fulfillment`. 동기 Input은 `send` 후 바로 단언.
- **Route 검증**: `if case .presentXxx = route { fulfill }` 패턴. SwiftUI 화면도 전환은 ViewModel의 `Route`로 나오므로(View가 받아 `NavigationStack` path에 넣음) 같은 방식으로 "어느 화면으로 가는지"를 검증한다. `NavigationStack`·`.sheet` 자체의 동작은 자동화 TC가 본다.
- **로그 검증**: `MockLogManager.sentEvents`/`pageViews`로 어떤 이벤트가 몇 번 갔는지 단언. 로그 파라미터 회귀는 여기서 잡는다. SwiftUI 화면은 VC가 없으므로 페이지뷰도 ViewModel이 `input.onAppear`에서 보낸다 → `pageViews`로 검증한다.
- **State 검증**: SwiftUI 화면 ViewModel(`@Observable`)은 `private(set) var state`를 직접 단언한다 — `load` 후 `viewModel.state.presets.count` 등. `@MainActor` 메서드로 state를 바꾸므로, 비동기 Input 뒤에는 state가 바뀔 때까지 기다린다(아래 예시). UIKit 레거시 ViewModel처럼 State가 private이면 Output으로 드러나는 결과로 검증하고, State를 노출하려고 접근 제어를 풀지 않는다.

  ```swift
  @MainActor
  func test_TH1234_TC1_로드하면_자주쓰는문구가_state에담긴다() async throws {
      // Given
      let repository = MockReviewRepository()
      repository.fetchCommentPresetsResult = .success(try FixtureLoader.decode(ContentListWithCursorAndCount<CommentPresetResponse>.self, from: "CommentPresets"))
      let viewModel = CommentPresetListViewModel(config: .init(storeId: "1"), dependency: .init(reviewRepository: repository))

      // When
      viewModel.input.onAppear.send(())

      // Then
      try await waitUntil { !viewModel.state.presets.isEmpty }
      XCTAssertEqual(viewModel.state.presets.count, 2)
  }
  ```
  `waitUntil`은 조건이 참이 될 때까지 짧게 폴링하는 헬퍼다 (`Support/XCTestCase+WaitUntil.swift`).
- `Preference.shared`처럼 protocol이 없는 의존을 테스트에서 바꿔야 하면, 먼저 protocol로 분리해 `Dependency`에 주입한다(R5).

### 목(Mock) 규칙

- 위치 `Sources/Support/Mock{Protocol}.swift`, 클래스명 `Mock{Protocol}` (`MockReviewRepository`, `MockLogManager`).
- 메서드마다 `var {메서드}Result: ApiResult<...> = .failure(MockError.notStubbed())` 프로퍼티. 스텁 안 한 메서드가 호출되면 `notStubbed(함수명)` 실패로 흘러 테스트 메시지에 드러난다. `fatalError` 금지.
- 호출 기록이 필요하면 `private(set) var xxxCalls: [XxxCall]` 배열로 스파이 (튜플 대신 작은 struct — `large_tuple` 린트).
- 테스트 파일 안에 `private class Mock...`을 만들지 않는다. 공용으로 빼야 다음 테스트가 재사용한다.

### 픽스처 규칙

- 가상 데이터를 손으로 만들지 말고 **실서버 응답**을 쓴다. Proxyman으로 잡아 `Resources/{화면}{상황}.json`으로 저장. `{ok, data}` 래퍼는 벗기고 `data`만 저장.
- 로드: `FixtureLoader.decode(StoreReviewResponse.self, from: "ReviewDetailWithComment")`.
- 서버가 안 내려주는 분기(알 수 없는 enum 값, 필드 누락)는 실데이터를 복사해 값만 바꾼 파일을 별도로 둔다.

### Service 테스트 작성법

- **순수 로직 서비스**(`DeepLinkHandler`의 URL 파싱, `GlobalEventService` 발행/구독): 입력을 주고 결과·부수효과를 단언. 외부 SDK(Firebase, Kakao)는 protocol 뒤에 숨겨져 있을 때만 테스트 가능 → 안 숨겨져 있으면 먼저 protocol로 분리하는 게 테스트의 일부다.
- **API 정의**(`XxxApi: ApiRequest`): `path`, `method`, `parameters`를 단언. 서버 계약이 바뀌었을 때 가장 싸게 잡히는 테스트.
  ```swift
  func test_TH1384_TC4_리뷰신고API는_리뷰report경로와POST를쓴다() {
      let api = ReviewApi.reportReview(storeId: "store-1", reviewId: "review-1", input: .init(reasonDetail: "사유"))
      XCTAssertEqual(api.path, "/v1/store/store-1/review/review-1/report")
      XCTAssertEqual(api.method, .post)
  }
  ```
- **RepositoryImpl**은 `asyncRequest()`를 그대로 부르는 얇은 래퍼라 보통 테스트하지 않는다. 응답 변환 로직이 있으면 그 부분만.

### Decoding 테스트 작성법

- 실서버 픽스처로 `Decodable` 타입을 디코딩하고, 필드 값·enum 매핑·기본값을 단언.
- 필수: **알 수 없는 enum 값이 와도 크래시 없이 `.unknown`/nil로 떨어지는지**. 서버가 값을 추가해도 구버전 앱이 죽지 않아야 한다.

## 2. 자동화 테스트 TC

시뮬레이터를 에이전트가 직접 조작해 TC 조건을 만들고, 스크린샷·영상으로 판정한다. 실행은 `3dollars:simulator-test`.

- **테스트 코드를 만들지 않는다.** XCTest UI 테스트도 쓰지 않는다. 산출물은 코드가 아니라 증거다.
- **로그인 뒤 화면**은 카카오·애플 로그인을 시뮬레이터에서 통과할 수 없으므로, ViewModel `Dependency`에 목 Repository(JSON 픽스처 반환)를 넣고 루트 화면을 바꾸는 **임시 하네스**로 띄운다. 하네스 코드는 커밋하지 않는다.
- **시나리오의 원본은 테크스펙 TC 한 줄이다.** Given/When/Then 을 그대로 스킬에 넘긴다. 재현 단계를 레포에 따로 파일로 두지 않는다 (스펙과 이중 관리가 되면 둘 다 썩는다).
- **언제**: PR 올리기 전, **이번 티켓의 자동화 TC만** 돌린다. 과거 TC 회귀는 기본으로 돌리지 않는다.
- **판정**: 스킬이 케이스마다 `PASS` / `FAIL` / `UNCLEAR` / `BLOCKED` 를 매긴다. **UNCLEAR·BLOCKED 는 통과가 아니다** — 재현 경로를 고치거나 수동 TC로 내린다.
- **증거**: 스크린샷·영상을 PR 본문 "증거" 섹션에 TC 번호와 함께 붙인다 (`/3dollars:pr-body` 가 레포의 `verification-assets` prerelease 에 올려 다운로드 URL 로 건다. git 브랜치에 커밋하지 않는다).

```
| TC | 시나리오 | 결과 | 증거 |
|---|---|---|---|
| TC-3 | 리뷰 상세에서 신고 → 사유 입력 → 신고 시 시트 닫힘 | ✅ PASS | before.png / after.png |
| TC-5 | 자주 쓰는 문구 시트 스와이프로 닫힘 | ✅ PASS | swipe.mp4 |
```

## 3. 수동 테스트 TC

시뮬레이터로 **상황 자체를 만들 수 없는 것만** 남는다 (카카오·애플 로그인 자체, 실기기 푸시, 실제 이동에 따른 위치 갱신).
목록과 화면 변경 PR 공통 체크 항목은 `docs/process/e2e-and-manual-tests.md`.
PR 본문에 체크박스로 넣고 **작성자가 올리기 전에 체크**한다. 리뷰어는 미체크 항목이 있으면 머지하지 않는다.

## PR에 남기는 것

`/3dollars:pr-body`가 PR 본문 `## TC` 섹션 맨 위에 **커버리지 표**를 넣는다. 사람은 이 표만 본다.
표는 세션 기억이 아니라 매번 **노션 스펙 TC 목록 + 레포의 `test_{티켓}_TC{n}_` 메서드 + `simulator-test` 판정**으로 다시 만든다. 그래서 `/3dollars:test-cases` 를 다른 세션에서 돌렸어도 빠지지 않는다.

```markdown
커버리지 3/4 · ⚠️ 미커버 TC-6

| TC | 내용 | 계층 | 테스트 / 증거 | 결과 |
|---|---|---|---|---|
| TC-1 | 신고 버튼 활성화 | 유닛 | `test_TH1384_TC1_신고사유가10자이상이면_…` | ✅ |
| TC-2 | 신고 성공 시 닫힘 | 유닛 | `test_TH1384_TC2_신고에성공하면_…` | ✅ |
| TC-6 | 중복 신고 안내 | — | — | ⚠️ 미커버 |
| TC-8 | 완료 토스트 → 닫힘 | 자동화 | report.mp4 | ✅ PASS |
```

- **미커버** = 유닛 테스트도, 자동화 PASS 증거도, 수동 배정도 없는 스펙 TC. 숨기지 않고 ⚠️ 로 보인다 — CI 코멘트의 커버리지 표는 테스트 메서드만 보므로 이걸 못 잡는다.
- 수동 TC 는 표에 `☐` 로 두고, 표 아래 체크리스트에서 작성자가 체크한다.
- CI 코멘트(`test.yml`)는 유닛 실행 결과의 원본이고, 본문 표는 **스펙 대비 커버 여부**의 원본이다.
