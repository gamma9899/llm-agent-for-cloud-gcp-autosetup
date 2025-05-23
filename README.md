✅ 사용 매뉴얼 요약
1. VM 인스턴스 생성 직후 한 방 설치
(bash) 
 <(curl -s https://raw.githubusercontent.com/gamma9899/llm-agent-for-cloud-gcp-autosetup/main/install.sh)

2. 설치 완료 후 RDP 접속
 윈도우 원격 데스크톱 연결 (mstsc) 이용
 접속 시 반드시 “드라이브 공유” 옵션 체크

3. GUI 터미널에서 FastAPI 서버 실행
(bash)
 cd ~/llm_agent_demo
 ~/.local/bin/uvicorn main:app --host 0.0.0.0 --port 7860

4. 브라우저에서 접속
(url)
 http://<외부 IP>:7860/docs

5. 스크린샷 엔드포인트 테스트
 /screenshot → 현재 GUI 전체 화면 캡처 이미지 반환

6. 문제 발생 시 점검 체크리스트
 - 방화벽 규칙 (포트 7860 허용 + 인스턴스에 태그 적용됨?)

 - FastAPI 정상 실행 여부 (uvicorn 명령어 뒤에 에러 없음?)

 - GUI 환경에서 실행 중인지 확인 (DISPLAY=:10.0 안 써도 되는 상태인지)

 - pyautogui + gnome-screenshot 설치 확인

 - 스크린샷 요청 시 500 오류라면 gnome-screenshot 설치 확인

