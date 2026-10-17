lint:
	swiftlint lint --quiet

lint-fix:
	swiftlint --fix --quiet

# baseline: 키가 가리키는 파일이 없으면 SwiftLint가 먼저 실패하므로 키를 뺀 임시 설정으로 생성한다
lint-baseline:
	sed '/^baseline:/d' .swiftlint.yml > .swiftlint.tmp.yml
	swiftlint lint --quiet --config .swiftlint.tmp.yml --write-baseline .swiftlint-baseline.json || true
	rm -f .swiftlint.tmp.yml
