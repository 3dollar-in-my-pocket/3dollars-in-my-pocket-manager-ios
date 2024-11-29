// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  /// 사진을 첨부하기 위해 권한이 필요합니다.
  /// 설정에서 해당 권한을 허용해주세요.
  internal static let authorizationDeniedDescription = Strings.tr("Localizations", "authorization_denied_description", fallback: "사진을 첨부하기 위해 권한이 필요합니다.\n설정에서 해당 권한을 허용해주세요.")
  /// 권한 거절
  internal static let authorizationDeniedTitle = Strings.tr("Localizations", "authorization_denied_title", fallback: "권한 거절")
  /// 설정
  internal static let authorizationSetting = Strings.tr("Localizations", "authorization_setting", fallback: "설정")
  /// 확인
  internal static let commonOk = Strings.tr("Localizations", "common_ok", fallback: "확인")
  /// 메뉴 추가하기
  internal static let editMenuAdd = Strings.tr("Localizations", "edit_menu_add", fallback: "메뉴 추가하기")
  /// 삭제
  internal static let editMenuDelete = Strings.tr("Localizations", "edit_menu_delete", fallback: "삭제")
  /// 전체 삭제
  internal static let editMenuDeleteAll = Strings.tr("Localizations", "edit_menu_delete_all", fallback: "전체 삭제")
  /// 전체 메뉴를 삭제하시겠습니까?
  internal static let editMenuDeleteAllMessage = Strings.tr("Localizations", "edit_menu_delete_all_message", fallback: "전체 메뉴를 삭제하시겠습니까?")
  /// 삭제 완료
  internal static let editMenuFinishDelete = Strings.tr("Localizations", "edit_menu_finish_delete", fallback: "삭제 완료")
  /// 메뉴를 입력해주세요.
  internal static let editMenuNamePlaceholder = Strings.tr("Localizations", "edit_menu_name_placeholder", fallback: "메뉴를 입력해주세요.")
  /// 가격을 입력해 주세요.
  internal static let editMenuPricePlaceholder = Strings.tr("Localizations", "edit_menu_price_placeholder", fallback: "가격을 입력해 주세요.")
  /// 저장하기
  internal static let editMenuSave = Strings.tr("Localizations", "edit_menu_save", fallback: "저장하기")
  /// 수정된 내용을 저장하지 않고 나갈까요?
  internal static let editMenuSaveAlertMessage = Strings.tr("Localizations", "edit_menu_save_alert_message", fallback: "수정된 내용을 저장하지 않고 나갈까요?")
  /// 나가기
  internal static let editMenuSaveAlertOk = Strings.tr("Localizations", "edit_menu_save_alert_ok", fallback: "나가기")
  /// 메뉴 관리
  internal static let editMenuTitle = Strings.tr("Localizations", "edit_menu_title", fallback: "메뉴 관리")
  /// * 메뉴명, 가격, 사진을 모두 등록해주세요.
  internal static let editMenuWarning = Strings.tr("Localizations", "edit_menu_warning", fallback: "* 메뉴명, 가격, 사진을 모두 등록해주세요.")
  /// 출몰 지역
  internal static let editScheduleLocation = Strings.tr("Localizations", "edit_schedule_location", fallback: "출몰 지역")
  /// 영업 요일을 선택해주세요!
  internal static let editScheduleMainDescription = Strings.tr("Localizations", "edit_schedule_main_description", fallback: "영업 요일을 선택해주세요!")
  /// 저장하기
  internal static let editScheduleSave = Strings.tr("Localizations", "edit_schedule_save", fallback: "저장하기")
  /// 선택하지 않은 요일은 휴무로 표시됩니다.
  internal static let editScheduleSubDescription = Strings.tr("Localizations", "edit_schedule_sub_description", fallback: "선택하지 않은 요일은 휴무로 표시됩니다.")
  /// 일정 관리
  internal static let editScheduleTitle = Strings.tr("Localizations", "edit_schedule_title", fallback: "일정 관리")
  /// 영업 시간
  internal static let editScheduleWorkTime = Strings.tr("Localizations", "edit_schedule_work_time", fallback: "영업 시간")
  /// 알 수 없는 형태의 데이터입니다.
  internal static let errorFailDecode = Strings.tr("Localizations", "error_fail_decode", fallback: "알 수 없는 형태의 데이터입니다.")
  /// 값이 없습니다.
  internal static let errorNilValue = Strings.tr("Localizations", "error_nil_value", fallback: "값이 없습니다.")
  /// 알 수 없는 에러입니다.
  /// 잠시후 다시 시도해주세요.
  internal static let errorTimeOut = Strings.tr("Localizations", "error_time_out", fallback: "알 수 없는 에러입니다.\n잠시후 다시 시도해주세요.")
  /// 알 수 없는 에러입니다.
  internal static let errorUnknown = Strings.tr("Localizations", "error_unknown", fallback: "알 수 없는 에러입니다.")
  /// 어떤 점이 궁금하셨나요?
  internal static let faqDescription = Strings.tr("Localizations", "faq_description", fallback: "어떤 점이 궁금하셨나요?")
  /// FAQ
  internal static let faqTitle = Strings.tr("Localizations", "faq_title", fallback: "FAQ")
  /// 금요일
  internal static let fridayFull = Strings.tr("Localizations", "friday_full", fallback: "금요일")
  /// 닫기
  internal static let homeAutoAlertClose = Strings.tr("Localizations", "home_auto_alert_close", fallback: "닫기")
  /// 임의로 영업 상태를 변경하고 싶다면 영업 설정에서
  /// 상태 자동 변경을 꺼주세요.
  internal static let homeAutoAlertDescription = Strings.tr("Localizations", "home_auto_alert_description", fallback: "임의로 영업 상태를 변경하고 싶다면 영업 설정에서\n상태 자동 변경을 꺼주세요.")
  /// 영업 설정으로 이동하기
  internal static let homeAutoAlertGoPreference = Strings.tr("Localizations", "home_auto_alert_go_preference", fallback: "영업 설정으로 이동하기")
  /// 영업 상태 자동 변경이
  /// 설정되어 있습니다!
  internal static let homeAutoAlertTitle = Strings.tr("Localizations", "home_auto_alert_title", fallback: "영업 상태 자동 변경이\n설정되어 있습니다!")
  /// 빨간 원(현재 위치의 반경 100m 이내) 안에서 장사를 시작해주세요.
  internal static let homeInvalidPosition = Strings.tr("Localizations", "home_invalid_position", fallback: "빨간 원(현재 위치의 반경 100m 이내) 안에서 장사를 시작해주세요.")
  /// 영업을 시작하면 위치가 손님들에게 공개됩니다.
  internal static let homeOffDescription = Strings.tr("Localizations", "home_off_description", fallback: "영업을 시작하면 위치가 손님들에게 공개됩니다.")
  /// 지금 계신 위치에서 영업을 시작할까요?
  internal static let homeOffTitle = Strings.tr("Localizations", "home_off_title", fallback: "지금 계신 위치에서 영업을 시작할까요?")
  /// 오늘의 영업 시작하기
  internal static let homeOffToggle = Strings.tr("Localizations", "home_off_toggle", fallback: "오늘의 영업 시작하기")
  /// 동안 영업중이시네요! 오늘도 대박나세요!
  internal static let homeOnDescription = Strings.tr("Localizations", "home_on_description", fallback: "동안 영업중이시네요! 오늘도 대박나세요!")
  /// 오늘은
  internal static let homeOnTitle = Strings.tr("Localizations", "home_on_title", fallback: "오늘은")
  /// 셔텨 내리기
  internal static let homeOnToggle = Strings.tr("Localizations", "home_on_toggle", fallback: "셔텨 내리기")
  /// 다른 푸드트럭 보기
  internal static let homeShowOther = Strings.tr("Localizations", "home_show_other", fallback: "다른 푸드트럭 보기")
  /// 일시적인 오류가 발생했어요..ㅠㅠ
  /// 잠시 후 다시 시도해주세요!
  internal static let httpErrorBadGateway = Strings.tr("Localizations", "http_error_bad_gateway", fallback: "일시적인 오류가 발생했어요..ㅠㅠ\n잠시 후 다시 시도해주세요!")
  /// 요청에 오류가 있습니다.
  /// 다시 확인해주세요.
  internal static let httpErrorBadRequest = Strings.tr("Localizations", "http_error_bad_request", fallback: "요청에 오류가 있습니다.\n다시 확인해주세요.")
  /// 이미 존재하는 데이터입니다.
  internal static let httpErrorConflict = Strings.tr("Localizations", "http_error_conflict", fallback: "이미 존재하는 데이터입니다.")
  /// 권한이 없는 요청입니다.
  internal static let httpErrorForbidden = Strings.tr("Localizations", "http_error_forbidden", fallback: "권한이 없는 요청입니다.")
  /// 서버에서 오류가 발생했습니다.
  /// 잠시 후 다시 시도해주세요!
  internal static let httpErrorInternalServerError = Strings.tr("Localizations", "http_error_internal_server_error", fallback: "서버에서 오류가 발생했습니다.\n잠시 후 다시 시도해주세요!")
  /// 서버 점검중입니다.
  /// 잠시 후 다시 시도해주세요.
  internal static let httpErrorMaintenance = Strings.tr("Localizations", "http_error_maintenance", fallback: "서버 점검중입니다.\n잠시 후 다시 시도해주세요.")
  /// 없는 데이터입니다.
  internal static let httpErrorNotFound = Strings.tr("Localizations", "http_error_not_found", fallback: "없는 데이터입니다.")
  /// 일시적인 오류가 발생했어요..ㅠㅠ
  /// 잠시 후 다시 시도해주세요!
  internal static let httpErrorTimeout = Strings.tr("Localizations", "http_error_timeout", fallback: "일시적인 오류가 발생했어요..ㅠㅠ\n잠시 후 다시 시도해주세요!")
  /// 일시적으로 너무 많은 요청이 발생하였습니다. 잠시 후 다시 이용해주세요
  internal static let httpErrorTooManyRequests = Strings.tr("Localizations", "http_error_too_many_requests", fallback: "일시적으로 너무 많은 요청이 발생하였습니다. 잠시 후 다시 이용해주세요")
  /// 세션이 만료되었습니다.
  /// 다시 로그인해주세요.
  internal static let httpErrorUnauthorized = Strings.tr("Localizations", "http_error_unauthorized", fallback: "세션이 만료되었습니다.\n다시 로그인해주세요.")
  /// 주소를 알 수 없는 위치입니다.
  internal static let locationAddressUnknown = Strings.tr("Localizations", "location_address_unknown", fallback: "주소를 알 수 없는 위치입니다.")
  /// 현재 내 위치를 찾기 위해 위치 권한이 필요합니다.
  /// 설정에서 위치 권한을 허용시켜주세요.
  internal static let locationDenyDescription = Strings.tr("Localizations", "location_deny_description", fallback: "현재 내 위치를 찾기 위해 위치 권한이 필요합니다.\n설정에서 위치 권한을 허용시켜주세요.")
  /// 위치 서비스가 비활성화되어있습니다.
  /// 서비스를 활성화시켜주세요.
  internal static let locationDisableService = Strings.tr("Localizations", "location_disable_service", fallback: "위치 서비스가 비활성화되어있습니다.\n서비스를 활성화시켜주세요.")
  /// 현재 위치가 확인되지 않습니다.
  /// 잠시 후 다시 시도해주세요.
  internal static let locationUnknown = Strings.tr("Localizations", "location_unknown", fallback: "현재 위치가 확인되지 않습니다.\n잠시 후 다시 시도해주세요.")
  /// 월요일
  internal static let mondayFull = Strings.tr("Localizations", "monday_full", fallback: "월요일")
  /// 계좌정보를 등록해주세요!
  /// 손님들에게 바로 계좌번호를 알려줄 수 있습니다.
  internal static let myStoreInfoAccountEmptyPlaceholder = Strings.tr("Localizations", "my_store_info_account_empty_placeholder", fallback: "계좌정보를 등록해주세요!\n손님들에게 바로 계좌번호를 알려줄 수 있습니다.")
  /// 휴무일
  internal static let myStoreInfoAppearanceClosedDay = Strings.tr("Localizations", "my_store_info_appearance_closed_day", fallback: "휴무일")
  /// 계좌번호
  internal static let myStoreInfoHeaderAccount = Strings.tr("Localizations", "my_store_info_header_account", fallback: "계좌번호")
  /// 정보 수정
  internal static let myStoreInfoHeaderAccountButton = Strings.tr("Localizations", "my_store_info_header_account_button", fallback: "정보 수정")
  /// 영업 일정
  internal static let myStoreInfoHeaderAppearanceDay = Strings.tr("Localizations", "my_store_info_header_appearance_day", fallback: "영업 일정")
  /// 일정 관리
  internal static let myStoreInfoHeaderAppearanceDayButton = Strings.tr("Localizations", "my_store_info_header_appearance_day_button", fallback: "일정 관리")
  /// 사장님 한마디
  internal static let myStoreInfoHeaderIntroduction = Strings.tr("Localizations", "my_store_info_header_introduction", fallback: "사장님 한마디")
  /// 정보 수정
  internal static let myStoreInfoHeaderIntroductionButton = Strings.tr("Localizations", "my_store_info_header_introduction_button", fallback: "정보 수정")
  /// 메뉴 정보
  internal static let myStoreInfoHeaderMenus = Strings.tr("Localizations", "my_store_info_header_menus", fallback: "메뉴 정보")
  /// 메뉴 수정
  internal static let myStoreInfoHeaderMenusButton = Strings.tr("Localizations", "my_store_info_header_menus_button", fallback: "메뉴 수정")
  /// 손님들에게 하고 싶은 말을 적어주세요!
  /// ex) 오전에 오시면 서비스가 있습니다!
  internal static let myStoreInfoIntroductionPlaceholder = Strings.tr("Localizations", "my_store_info_introduction_placeholder", fallback: "손님들에게 하고 싶은 말을 적어주세요!\nex) 오전에 오시면 서비스가 있습니다!")
  /// 가게의 메뉴를 등록해 주세요!
  internal static let myStoreInfoMenuEmpty = Strings.tr("Localizations", "my_store_info_menu_empty", fallback: "가게의 메뉴를 등록해 주세요!")
  /// %d개의 메뉴가 더 있습니다.
  internal static func myStoreInfoMenuMoreFormat(_ p1: Int) -> String {
    return Strings.tr("Localizations", "my_store_info_menu_more_format", p1, fallback: "%d개의 메뉴가 더 있습니다.")
  }
  /// 토요일
  internal static let saturdayFull = Strings.tr("Localizations", "saturday_full", fallback: "토요일")
  /// 가슴속 삼천원팀에 연락하기
  internal static let settingContact = Strings.tr("Localizations", "setting_contact", fallback: "가슴속 삼천원팀에 연락하기")
  /// 토큰을 복사했습니다. 붙여넣기를 통해 사용하세요.
  internal static let settingCopyTokenDescription = Strings.tr("Localizations", "setting_copy_token_description", fallback: "토큰을 복사했습니다. 붙여넣기를 통해 사용하세요.")
  /// FCM 토큰
  internal static let settingCopyTokenTitle = Strings.tr("Localizations", "setting_copy_token_title", fallback: "FCM 토큰")
  /// FAQ
  internal static let settingFaq = Strings.tr("Localizations", "setting_faq", fallback: "FAQ")
  /// 로그아웃
  internal static let settingLogout = Strings.tr("Localizations", "setting_logout", fallback: "로그아웃")
  /// 로그아웃하시겠습니까?
  internal static let settingLogoutMessage = Strings.tr("Localizations", "setting_logout_message", fallback: "로그아웃하시겠습니까?")
  /// 오늘도 적게 일하고 많이 버세요!
  internal static let settingNameDescription = Strings.tr("Localizations", "setting_name_description", fallback: "오늘도 적게 일하고 많이 버세요!")
  /// 푸시알림
  internal static let settingNotification = Strings.tr("Localizations", "setting_notification", fallback: "푸시알림")
  /// 개인정보 처리방침
  internal static let settingPrivacy = Strings.tr("Localizations", "setting_privacy", fallback: "개인정보 처리방침")
  /// 사업자번호
  internal static let settingRegisterationNumber = Strings.tr("Localizations", "setting_registeration_number", fallback: "사업자번호")
  /// 회원탈퇴
  internal static let settingSignout = Strings.tr("Localizations", "setting_signout", fallback: "회원탈퇴")
  /// 탈퇴
  internal static let settingSignoutButton = Strings.tr("Localizations", "setting_signout_button", fallback: "탈퇴")
  /// 회원 탈퇴 시, 그동안의 데이터가 모두 삭제됩니다.
  /// 회원탈퇴하시겠습니까?
  internal static let settingSignoutTitle = Strings.tr("Localizations", "setting_signout_title", fallback: "회원 탈퇴 시, 그동안의 데이터가 모두 삭제됩니다.\n회원탈퇴하시겠습니까?")
  /// 설정
  internal static let settingTitle = Strings.tr("Localizations", "setting_title", fallback: "설정")
  /// 가입 신청하기
  internal static let signupButton = Strings.tr("Localizations", "signup_button", fallback: "가입 신청하기")
  /// 최대 3개
  internal static let signupCategoryDescription = Strings.tr("Localizations", "signup_category_description", fallback: "최대 3개")
  /// 카테고리 선택
  internal static let signupCategoryTitle = Strings.tr("Localizations", "signup_category_title", fallback: "카테고리 선택")
  /// 사장님, 가게 정보 등록하시고
  /// 부자 되세요~!
  internal static let signupDescription = Strings.tr("Localizations", "signup_description", fallback: "사장님, 가게 정보 등록하시고\n부자 되세요~!")
  /// 사장님 성함
  internal static let signupOwnerName = Strings.tr("Localizations", "signup_owner_name", fallback: "사장님 성함")
  /// 사장님 성함을 입력해주세요.
  internal static let signupOwnerNamePlaceholder = Strings.tr("Localizations", "signup_owner_name_placeholder", fallback: "사장님 성함을 입력해주세요.")
  /// 사진은 사장님 인증 용도로 사용됩니다.
  internal static let signupPhotoDescription = Strings.tr("Localizations", "signup_photo_description", fallback: "사진은 사장님 인증 용도로 사용됩니다.")
  /// 가게 인증 사진
  internal static let signupPhotoTitle = Strings.tr("Localizations", "signup_photo_title", fallback: "가게 인증 사진")
  /// “-”를 제외한 숫자만 입력
  internal static let signupRegisterationNumberDescription = Strings.tr("Localizations", "signup_registeration_number_description", fallback: "“-”를 제외한 숫자만 입력")
  /// 사업자 등록 번호를 입력해 주세요.
  internal static let signupRegisterationNumberPlaceholder = Strings.tr("Localizations", "signup_registeration_number_placeholder", fallback: "사업자 등록 번호를 입력해 주세요.")
  /// 사업자 등록 번호
  internal static let signupRegisterationNumberTitle = Strings.tr("Localizations", "signup_registeration_number_title", fallback: "사업자 등록 번호")
  /// 가게이름
  internal static let signupStoreName = Strings.tr("Localizations", "signup_store_name", fallback: "가게이름")
  /// 최대 20자
  internal static let signupStoreNameDescription = Strings.tr("Localizations", "signup_store_name_description", fallback: "최대 20자")
  /// 가게 이름을 입력해 주세요.
  internal static let signupStoreNamePlaceholder = Strings.tr("Localizations", "signup_store_name_placeholder", fallback: "가게 이름을 입력해 주세요.")
  /// 회원가입
  internal static let signupTitle = Strings.tr("Localizations", "signup_title", fallback: "회원가입")
  /// 이미지 업로드
  internal static let signupUploadPhoto = Strings.tr("Localizations", "signup_upload_photo", fallback: "이미지 업로드")
  /// 일별
  internal static let statisticsFilterDay = Strings.tr("Localizations", "statistics_filter_day", fallback: "일별")
  /// 전체
  internal static let statisticsFilterTotal = Strings.tr("Localizations", "statistics_filter_total", fallback: "전체")
  /// 리뷰가 사장님께 도착했어요 :)
  internal static let statisticsReviewCount = Strings.tr("Localizations", "statistics_review_count", fallback: "리뷰가 사장님께 도착했어요 :)")
  /// 일요일
  internal static let sundayFull = Strings.tr("Localizations", "sunday_full", fallback: "일요일")
  /// 목요일
  internal static let thursdayFull = Strings.tr("Localizations", "thursday_full", fallback: "목요일")
  /// 화요일
  internal static let tuesdayFull = Strings.tr("Localizations", "tuesday_full", fallback: "화요일")
  /// 사장님이 영업 시작 버튼을 누르면
  /// 근처 고객들에게 홍보 돼요!
  internal static let waitingBottomDescription1 = Strings.tr("Localizations", "waiting_bottom_description_1", fallback: "사장님이 영업 시작 버튼을 누르면\n근처 고객들에게 홍보 돼요!")
  /// 사장님! 소중한 정보를 입력해주셔서 감사합니다.
  /// 심사는 지원한 날로부터 주말을 제외한 평일 기준 약 2-5일 소요될 수 있어요. 최대한 빠르게 처리하여 사장님의 영업을 도와드릴 테니 조금만 기다려주세요 :)
  internal static let waitingDescription = Strings.tr("Localizations", "waiting_description", fallback: "사장님! 소중한 정보를 입력해주셔서 감사합니다.\n심사는 지원한 날로부터 주말을 제외한 평일 기준 약 2-5일 소요될 수 있어요. 최대한 빠르게 처리하여 사장님의 영업을 도와드릴 테니 조금만 기다려주세요 :)")
  /// 로그아웃
  internal static let waitingLogout = Strings.tr("Localizations", "waiting_logout", fallback: "로그아웃")
  /// 이메일로 문의하기
  internal static let waitingQuestionButton = Strings.tr("Localizations", "waiting_question_button", fallback: "이메일로 문의하기")
  /// 신청 완료!
  internal static let waitingTitle = Strings.tr("Localizations", "waiting_title", fallback: "신청 완료!")
  /// 수요일
  internal static let wednesdayFull = Strings.tr("Localizations", "wednesday_full", fallback: "수요일")
  internal enum Common {
    /// 앨범
    internal static let album = Strings.tr("Localizations", "common.album", fallback: "앨범")
    /// 카메라
    internal static let camera = Strings.tr("Localizations", "common.camera", fallback: "카메라")
    /// 취소
    internal static let cancel = Strings.tr("Localizations", "common.cancel", fallback: "취소")
    /// 이미지 불러오기
    internal static let loadImage = Strings.tr("Localizations", "common.load_image", fallback: "이미지 불러오기")
  }
  internal enum EditAccount {
    /// 계좌번호를 입력해주세요.
    internal static let accountNumberPlaceholder = Strings.tr("Localizations", "edit_account.account_number_placeholder", fallback: "계좌번호를 입력해주세요.")
    /// 계좌번호
    internal static let accountNumbuer = Strings.tr("Localizations", "edit_account.account_numbuer", fallback: "계좌번호")
    /// 은행
    internal static let bank = Strings.tr("Localizations", "edit_account.bank", fallback: "은행")
    /// 은행을 선택해주세요.
    internal static let bankPlaceholder = Strings.tr("Localizations", "edit_account.bank_placeholder", fallback: "은행을 선택해주세요.")
    /// 예금주
    internal static let name = Strings.tr("Localizations", "edit_account.name", fallback: "예금주")
    /// 저장하기
    internal static let save = Strings.tr("Localizations", "edit_account.save", fallback: "저장하기")
    /// 계좌번호 등록
    internal static let title = Strings.tr("Localizations", "edit_account.title", fallback: "계좌번호 등록")
    /// 예금주를 입력해주세요.
    internal static let titlePlaceholder = Strings.tr("Localizations", "edit_account.title_placeholder", fallback: "예금주를 입력해주세요.")
  }
  internal enum EditIntroduction {
    /// 손님들에게 하고 싶은 말을
    /// 적어주세요!
    internal static let mainDescription = Strings.tr("Localizations", "edit_introduction.main_description", fallback: "손님들에게 하고 싶은 말을\n적어주세요!")
    /// ex) 오전에 오시면 서비스가 있습니다 😋
    internal static let subDescription = Strings.tr("Localizations", "edit_introduction.sub_description", fallback: "ex) 오전에 오시면 서비스가 있습니다 😋")
    /// 사장님 한마디 수정
    internal static let title = Strings.tr("Localizations", "edit_introduction.title", fallback: "사장님 한마디 수정")
    internal enum MainDescription {
      /// 손님들에게 하고 싶은 말
      internal static let bold = Strings.tr("Localizations", "edit_introduction.main_description.bold", fallback: "손님들에게 하고 싶은 말")
    }
    internal enum Toast {
      /// 정보가 업데이트 되었습니다
      internal static let successUpdate = Strings.tr("Localizations", "edit_introduction.toast.success_update", fallback: "정보가 업데이트 되었습니다")
    }
  }
  internal enum EditIntrodution {
    /// 저장하기
    internal static let editButton = Strings.tr("Localizations", "edit_introdution.edit_button", fallback: "저장하기")
  }
  internal enum EditStoreInfo {
    /// 가게 사진
    internal static let photoTitle = Strings.tr("Localizations", "edit_store_info.photo_title", fallback: "가게 사진")
    /// 저장하기
    internal static let save = Strings.tr("Localizations", "edit_store_info.save", fallback: "저장하기")
    /// SNS
    internal static let sns = Strings.tr("Localizations", "edit_store_info.sns", fallback: "SNS")
    /// 대표 정보 수정
    internal static let title = Strings.tr("Localizations", "edit_store_info.title", fallback: "대표 정보 수정")
    internal enum Photo {
      /// 대표
      internal static let representative = Strings.tr("Localizations", "edit_store_info.photo.representative", fallback: "대표")
    }
    internal enum Sns {
      /// SNS주소를 적어주세요.
      internal static let placeholder = Strings.tr("Localizations", "edit_store_info.sns.placeholder", fallback: "SNS주소를 적어주세요.")
    }
    internal enum Toast {
      /// 사진은 최대 10장까지 등록 가능합니다
      internal static let maximumPhoto = Strings.tr("Localizations", "edit_store_info.toast.maximum_photo", fallback: "사진은 최대 10장까지 등록 가능합니다")
    }
  }
  internal enum Location {
    internal enum Deny {
      /// 내 위치를 찾기 위해 위치 권한이 필요합니다. 설정에서 위치 권한을 허용시켜주세요.
      internal static let description = Strings.tr("Localizations", "location.deny.description", fallback: "내 위치를 찾기 위해 위치 권한이 필요합니다. 설정에서 위치 권한을 허용시켜주세요.")
      /// 위치 권한 거절
      internal static let title = Strings.tr("Localizations", "location.deny.title", fallback: "위치 권한 거절")
    }
  }
  internal enum Main {
    /// 내 가게를 북마크한 고객님들께
    /// 메세지를 보낼 수 있어요
    internal static let messageTooltip = Strings.tr("Localizations", "main.message_tooltip", fallback: "내 가게를 북마크한 고객님들께\n메세지를 보낼 수 있어요")
  }
  internal enum Message {
    /// 메시지 전송
    internal static let sendMessage = Strings.tr("Localizations", "message.send_message", fallback: "메시지 전송")
    /// %@ 후 발송 가능
    internal static func sendMessageAfterTime(_ p1: Any) -> String {
      return Strings.tr("Localizations", "message.send_message_after_time", String(describing: p1), fallback: "%@ 후 발송 가능")
    }
    internal enum FirstTitle {
      internal enum Description {
        /// 단골 고객님들께
        internal static let first = Strings.tr("Localizations", "message.first_title.description.first", fallback: "단골 고객님들께")
        /// 북마크를 요청해 보세요!
        internal static let second = Strings.tr("Localizations", "message.first_title.description.second", fallback: "북마크를 요청해 보세요!")
        /// 하루에 한 번 메세지를
        /// 전송할 수 있어요.
        internal static let third = Strings.tr("Localizations", "message.first_title.description.third", fallback: "하루에 한 번 메세지를\n전송할 수 있어요.")
        internal enum Second {
          /// 북마크
          internal static let colord = Strings.tr("Localizations", "message.first_title.description.second.colord", fallback: "북마크")
        }
        internal enum Third {
          /// 하루에 한 번 메세지
          internal static let colored = Strings.tr("Localizations", "message.first_title.description.third.colored", fallback: "하루에 한 번 메세지")
        }
      }
    }
    internal enum Message {
      /// 이전 메세지 모두보기
      internal static let headerTitle = Strings.tr("Localizations", "message.message.header_title", fallback: "이전 메세지 모두보기")
    }
    internal enum Overview {
      /// 아직 메세지를 보낼 수 없어요
      internal static let disableToast = Strings.tr("Localizations", "message.overview.disable_toast", fallback: "아직 메세지를 보낼 수 없어요")
      /// %d명
      internal static func userCountFormat(_ p1: Int) -> String {
        return Strings.tr("Localizations", "message.overview.user_count_format", p1, fallback: "%d명")
      }
      internal enum Description {
        /// 가게를 즐겨찾기한 고객님들께 푸시 메세지가 전송돼요.
        internal static let first = Strings.tr("Localizations", "message.overview.description.first", fallback: "가게를 즐겨찾기한 고객님들께 푸시 메세지가 전송돼요.")
        /// 하루 1회 횟수 제한이 있으니 신중히 발송해 주세요.
        internal static let second = Strings.tr("Localizations", "message.overview.description.second", fallback: "하루 1회 횟수 제한이 있으니 신중히 발송해 주세요.")
        /// 전송 24시간 이후 다음 메세지를 발송할 수 있어요.
        internal static let third = Strings.tr("Localizations", "message.overview.description.third", fallback: "전송 24시간 이후 다음 메세지를 발송할 수 있어요.")
        internal enum Second {
          /// 하루 1회
          internal static let colored = Strings.tr("Localizations", "message.overview.description.second.colored", fallback: "하루 1회")
        }
        internal enum Third {
          /// 24시간 이후 다음 메세지를 발송
          internal static let colored = Strings.tr("Localizations", "message.overview.description.third.colored", fallback: "24시간 이후 다음 메세지를 발송")
        }
      }
      internal enum Title {
        /// 의 고객님에게
        internal static let first = Strings.tr("Localizations", "message.overview.title.first", fallback: "의 고객님에게")
        /// 오늘의 메시지 보내기
        internal static let second = Strings.tr("Localizations", "message.overview.title.second", fallback: "오늘의 메시지 보내기")
      }
    }
    internal enum Toast {
      /// 💌 고객님께 메세지를 전달드렸어요
      /// 다음 메세지는 24시간 후 전송할 수 있어요
      internal static let finish = Strings.tr("Localizations", "message.toast.finish", fallback: "💌 고객님께 메세지를 전달드렸어요\n다음 메세지는 24시간 후 전송할 수 있어요")
    }
  }
  internal enum MessageConfirm {
    /// 다시 쓰기
    internal static let rewrite = Strings.tr("Localizations", "message_confirm.rewrite", fallback: "다시 쓰기")
    /// 메세지 전송
    internal static let send = Strings.tr("Localizations", "message_confirm.send", fallback: "메세지 전송")
    /// 정말 아래의 메세지로 전송하시나요?
    /// 다시 한 번 확인해 주세요.
    internal static let title = Strings.tr("Localizations", "message_confirm.title", fallback: "정말 아래의 메세지로 전송하시나요?\n다시 한 번 확인해 주세요.")
    internal enum Content {
      /// 내가 즐겨 찾은 가게 %@의 메세지가 도착하였습니다.
      internal static func titleFormat(_ p1: Any) -> String {
        return Strings.tr("Localizations", "message_confirm.content.title_format", String(describing: p1), fallback: "내가 즐겨 찾은 가게 %@의 메세지가 도착하였습니다.")
      }
    }
  }
  internal enum MyPage {
    internal enum Message {
      /// 고객님들께 첫 인사를 보내보세요!
      internal static let toolTip = Strings.tr("Localizations", "my_page.message.tool_tip", fallback: "고객님들께 첫 인사를 보내보세요!")
    }
    internal enum SubTab {
      /// 메세지
      internal static let message = Strings.tr("Localizations", "my_page.sub_tab.message", fallback: "메세지")
      /// 가게소식
      internal static let notice = Strings.tr("Localizations", "my_page.sub_tab.notice", fallback: "가게소식")
      /// 리뷰통계
      internal static let statistics = Strings.tr("Localizations", "my_page.sub_tab.statistics", fallback: "리뷰통계")
      /// 가게정보
      internal static let storeInfo = Strings.tr("Localizations", "my_page.sub_tab.store_info", fallback: "가게정보")
    }
  }
  internal enum Preference {
    /// 영업 설정
    internal static let title = Strings.tr("Localizations", "preference.title", fallback: "영업 설정")
    internal enum AutoOpenCloseControl {
      /// 설정한 영업 일정에 따라 자동으로 영업 상태가 변경됩니다.
      internal static let description = Strings.tr("Localizations", "preference.auto_open_close_control.description", fallback: "설정한 영업 일정에 따라 자동으로 영업 상태가 변경됩니다.")
      /// 영업 상태 자동 변경
      internal static let title = Strings.tr("Localizations", "preference.auto_open_close_control.title", fallback: "영업 상태 자동 변경")
    }
    internal enum RemoveLocationOnClose {
      /// 엽업 종료 시에도 위치가 손님들에게 공개됩니다.
      internal static let description = Strings.tr("Localizations", "preference.remove_location_on_close.description", fallback: "엽업 종료 시에도 위치가 손님들에게 공개됩니다.")
      /// 영업 종료 시 위치 노출
      internal static let title = Strings.tr("Localizations", "preference.remove_location_on_close.title", fallback: "영업 종료 시 위치 노출")
    }
  }
  internal enum SendingMessage {
    /// 한 번 전송 후 취소가 불가능하니 신중하게 작성해 주세요!
    internal static let description = Strings.tr("Localizations", "sending_message.description", fallback: "한 번 전송 후 취소가 불가능하니 신중하게 작성해 주세요!")
    /// 오늘의 메세지 전송하기
    internal static let send = Strings.tr("Localizations", "sending_message.send", fallback: "오늘의 메세지 전송하기")
    /// 고객님께 전송할 메세지를
    /// 입력해 주세요.
    internal static let title = Strings.tr("Localizations", "sending_message.title", fallback: "고객님께 전송할 메세지를\n입력해 주세요.")
    /// *최소 10자에서 최대 100자 이내로 입력해 주세요.
    internal static let warning = Strings.tr("Localizations", "sending_message.warning", fallback: "*최소 10자에서 최대 100자 이내로 입력해 주세요.")
    internal enum Description {
      /// 취소가 불가능
      internal static let colored = Strings.tr("Localizations", "sending_message.description.colored", fallback: "취소가 불가능")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

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
