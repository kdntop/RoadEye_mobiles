# RoadEye_mobiles

## 레포 구성
- `index.html`, `company.html`, `product.html`, `mobile.html`: 단일 파일로 번들된 정적 페이지(각 4~5MB). 소스 빌드 체계는 없음.
- 파일이 크므로 통째로 Read하지 말고 `grep`/`sed -n`/`head -c`로 필요한 부분만 확인한다.
- 수정 후에는 Chromium(Playwright)으로 페이지를 열어 렌더링을 확인한다.

## REA (Reverse Engineer Anything) 연동
- `.mcp.json`에 REA MCP 서버(`rea-agents@6.5.0`)가 프로젝트 범위로 등록되어 있다. 첫 실행 시 승인 필요.
- 워크플로 지침은 `.claude/skills/reverse-engineer-anything/` 스킬에 있다.
- 번들된 페이지·앱·바이너리처럼 소스가 없는 대상을 분석할 때 REA를 쓴다. 일반 소스 분석에는 쓰지 않는다.
- JS 정적 분석은 별도 엔진 없이 동작한다. 네이티브 분석(Ghidra/Hopper/IDA)은 해당 엔진 설치가 필요하다.
- 버전 업데이트 시 `.mcp.json`의 버전과 스킬 폴더(npm 패키지의 `skills/`)를 함께 맞춘다.
