# PR 프로세스 (한 장 요약)

AI가 코드를 많이 쓰는 환경에서 사람 리뷰어는 **diff 전체가 아니라 의도(TC) · 경계 · 검증 증거**만 본다.
나머지(스타일, 구조 규칙, 회귀)는 린트·테스트·AI가 맡는다. 이 문서는 전체 흐름과 도구 매핑, 그리고 PR 위험도별 요구 수준을 정한다.
유저앱 iOS·AOS 레포와 같은 프로세스이며, 이 레포는 단일 타깃이라 모듈 경계 검사만 빠진다.

## 흐름과 도구

| 단계 | 하는 일 | 도구 | 산출물이 가는 곳 |
|---|---|---|---|
| 1. 의도 정의 | 지라 티켓에서 테크스펙 생성, 요약·요구사항·TC 작성 | 지라 Actions "테크스펙 생성" → 노션 | 지라 `테크스펙` 필드 (단일 진실 소스) |
| 2. 코드 작성 | 규칙(R4~R10) 안에서 구현 | `docs/architecture/RULES.md`, 루트 `CLAUDE.md`, `make lint`(SwiftLint custom_rules) | 로컬 + `lint.yml` |
| 3. 테스트 | TC를 세 계층(유닛/자동화/수동)에 배정 → 승인 → 유닛만 코드 | `/3dollars:test-cases`, `docs/process/testing.md` | `3dollar-in-my-pocket-managerTests/Sources/{ViewModel,Service,Decoding}Tests/`, 메서드명 `test_{티켓}_TC{n}_` |
| 4. 동작 증거 | 스펙 TC 커버리지 표(미커버 ⚠️) / 유닛 실행 결과 / 자동화 TC 스크린샷·영상 | `/3dollars:pr-body`(표), `test.yml` + `scripts/test-summary.sh`, `3dollars:simulator-test` | 본문 "TC" 표, PR 코멘트(자동), 본문 "증거" |
| 5. 스코프 드리프트 | 요구사항 ↔ diff 대조, 스펙 밖 변경 목록 | `/3dollars:drift` | 본문 "스펙 밖 변경" |
| 6. 자동화·수동 범위 | 유닛으로 안 덮이는 TC 를 자동화(에이전트·시뮬레이터)와 수동(사람·실기기)으로 가르고 UI 변경 공통 체크 추가 | `docs/process/e2e-and-manual-tests.md` (pr-body가 자동 삽입) | 본문 "TC" 체크리스트 |
| 7. 검증 장치 변경 | 린트·CI·규칙·프로젝트 파일을 건드린 PR 표시 | `.github/labeler.yml` + `labeler.yml`, `docs/process/verification-change.md` | 라벨 + 파일 목록 코멘트 |
| 8. 설명 못 하는 부분 | 비자명한 결정 3개를 작성자에게 질문 | `/3dollars:ask-author` | 본문 "설명이 필요한 결정" |
| 9. 반복 지적 → 규칙 | 리뷰 코멘트 집계, 3회↑ 승격 제안 | `/3dollars:review-digest` | RULES.md·`.swiftlint.yml` 변경 PR |
| PR 생성 | 위 결과를 템플릿에 채워 생성/갱신 | `/3dollars:pr-body` (`.github/PULL_REQUEST_TEMPLATE.md`) | GitHub PR |
| 리뷰 | 의도·경계·증거 기준 리뷰 | `/3dollars:pr-code-review` + 사람 | PR 코멘트 |

작성자 기준 순서: **테크스펙 → 구현 → `/3dollars:test-cases` → `make lint` → (UI면) `simulator-test` → `/3dollars:pr-body`** (pr-body가 커버리지 표·drift·ask-author·체크리스트를 안에서 만든다).

티켓 하나를 처음부터 PR까지 한 번에 돌리려면 `/3dollars:feature-implementer`(피처) 또는 `/3dollars:bug-fix`(버그)로 시작한다. 두 스킬은 안에서 위 순서(test-cases → simulator-test → pr-body)를 그대로 호출한다.

`/3dollars:review-digest` 는 자동 트리거가 없다. 필요할 때 수동으로 실행한다.

## 위험도: 경량 / 풀코스

PR 본문 첫 줄 `위험도:`에 적는다. `/3dollars:pr-body`가 아래 기준으로 판정하고, 작성자가 바꿀 수 있다(바꾸면 사유 한 줄).

| | 경량 | 풀코스 |
|---|---|---|
| **조건** | 아래 전부: 문서/테스트/CI만 바뀜 **또는** 한 화면(`domains/` 하위 한 폴더) 안의 UI·로직 변경, `domains/base`·`Network`·`managers`·`AppDelegate`/`SceneDelegate` 미변경, 패키지·빌드 설정 미변경, 베이스라인 미변경, 로그인·영업(위치)·딥링크·푸시 흐름 미변경 | 하나라도: `baseline-change` 라벨, `domains/base`·`Network`·`managers`·`AppDelegate`/`SceneDelegate` 변경, 패키지 추가·제거·빌드 설정 변경, 새 API·Repository, 로그인·영업(위치)·딥링크·푸시·권한 흐름, 3개 이상 화면 폴더 동시 변경 |
| **자동 검증** | `lint.yml`, `test.yml` | 동일 |
| **본문 필수** | 의도 링크, 변경 불릿, TC 커버리지 표 + 수동·공통 체크(해당 시) | + `drift` 요구사항 표 **전체**(스펙 밖 변경만이 아니라), `ask-author` Q/A, UI 변경이면 `simulator-test` Before/After 증거 |
| **사람 리뷰** | 본문만 보고 승인 가능. 스펙 밖 변경이 "없음"이면 diff를 열 필요 없음 | 라벨이 가리키는 파일(검증 장치·베이스라인)과 Base 클래스·빌드 설정 변경을 **먼저** 읽고, 그다음 drift 표의 "부분/없음" 항목 |
| **머지 조건** | CI 초록 + 커버리지 표에 ⚠️·FAIL 없음(자동화 PASS는 증거 링크 포함) + 체크리스트 전부 체크 | + 리뷰 승인 1명 |

`project.pbxproj`는 파일을 추가할 때마다 바뀌므로(폴더 동기화가 일부 폴더에만 적용됨) **그 자체로는 위험도 기준이 아니다.** 그 안의 패키지 참조·빌드 설정이 바뀌었을 때만 풀코스다.

라벨은 표시일 뿐이며 워크플로를 조건 실행하지 않는다. 풀코스 요구사항은 작성자와 리뷰어가 본문으로 확인한다. (라벨 조건 실행이 필요해지면 `test.yml`에 `if: contains(labels, ...)` 잡을 추가한다.)

## 예외

- **핫픽스**(`hotfix/`): 테크스펙 생략 가능. 대신 본문 "의도"에 장애 내용 1줄 + 재현 경로, 풀코스 취급.
- **릴리즈 브랜치**(`release/`): 버전·빌드 번호 변경만이면 경량 (`project.pbxproj`의 `MARKETING_VERSION`만 바뀐 경우 포함).
- **의존성 업데이트**: `Package.resolved`만 바뀌면(버전 업) 경량, 패키지 추가·제거면 풀코스.

## 규칙을 바꾸고 싶을 때

이 문서, `RULES.md`, `.swiftlint.yml`, 루트 `CLAUDE.md`는 **함께** 바뀐다. 입구는 `/3dollars:review-digest`(반복 지적) 또는 `verification-change` 라벨이 붙는 PR이며, 린트·CI 변경은 적용 전에 확인받는다.
