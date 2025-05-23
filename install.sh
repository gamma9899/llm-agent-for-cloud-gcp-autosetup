#!/bin/bash

set -e

# 사용자 변수
USERNAME=$(whoami)

# 1. 패키지 업데이트 및 필수 패키지 설치
read -p "⚠️ 시스템 패키지를 업데이트하고 업그레이드합니다. 계속하시겠습니까? (Y/n): " confirm
if [[ "$confirm" =~ ^[Yy]$ || -z "$confirm" ]]; then
  sudo apt update && sudo apt upgrade -y
else
  echo "⛔ 업데이트를 건너뜁니다."
fi

sudo apt install -y xfce4 xfce4-goodies xrdp x11vnc python3-pip git curl net-tools python3-tk python-dev

# 2. XRDP 설정 및 사용자 등록
sudo systemctl enable xrdp
sudo adduser xrdp ssl-cert

# 3. .xsession 설정
echo "startxfce4" > /home/$USERNAME/.xsession
chmod +x /home/$USERNAME/.xsession

# 4. XRDP 기본 세션 설정
sudo bash -c 'echo xfce4-session > /etc/skel/.xsession'
sudo sed -i "s/^test -x/#&/" /etc/xrdp/startwm.sh
sudo sed -i "s/^exec/#&/" /etc/xrdp/startwm.sh
sudo bash -c 'echo "exec startxfce4" >> /etc/xrdp/startwm.sh'

# 5. RDP 드라이브 마운트를 위한 polkit 설정
echo "[Allow RDP drive mount]
Identity=unix-user:$USERNAME
Action=org.freedesktop.udisks2.filesystem-mount
ResultActive=yes" | sudo tee /etc/polkit-1/localauthority/50-local.d/45-allow-mount.pkla

# 6. x11vnc 설정 (비밀번호는 사용자 입력)
echo "🔐 x11vnc 접속용 비밀번호를 입력하세요:"
x11vnc -storepasswd ~/.vnc/passwd

# 7. FastAPI 서버 설치 및 구성
pip3 install --user fastapi uvicorn pyautogui python3-xlib pillow

mkdir -p ~/llm_agent_demo
cat <<EOF > ~/llm_agent_demo/main.py
from fastapi import FastAPI
from fastapi.responses import FileResponse
import pyautogui
import datetime

app = FastAPI()

@app.get("/screenshot")
def screenshot():
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    path = f"/tmp/screenshot_{timestamp}.png"
    image = pyautogui.screenshot()
    image.save(path)
    return FileResponse(path)
EOF

# 8. FastAPI 실행 명령 안내
echo -e "\n✅ 설치 완료! 다음 명령어로 FastAPI 서버를 실행하세요:\n"
echo "cd ~/llm_agent_demo && ~/.local/bin/uvicorn main:app --host 0.0.0.0 --port 7860"
echo -e "\n💡 RDP 연결 시 드라이브 공유 옵션을 꼭 체크하세요. C: 드라이브는 /home/$USERNAME/thinclient_drives 경로에 나타납니다."

sudo systemctl restart xrdp
