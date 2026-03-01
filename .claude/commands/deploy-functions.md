Firebase Functions를 빌드하고 배포한다. 아래 순서를 따른다.

1. `functions/` 디렉토리에서 빌드 및 배포를 실행한다:
   ```bash
   cd functions && npm run build && cd .. && firebase deploy --only functions
   ```

2. 배포 성공 시 결과를 요약해서 보여준다:
   - 업데이트된 함수 목록
   - 새로 생성된 함수 목록
   - Function URL (있는 경우)

3. 배포 실패 시 오류 메시지를 분석하고 원인과 해결 방법을 안내한다.
