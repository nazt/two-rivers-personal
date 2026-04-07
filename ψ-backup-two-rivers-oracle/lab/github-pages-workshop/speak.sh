#!/bin/bash
# Two Rivers — GitHub Pages Workshop TTS
# Voice: th-TH-PremwadeeNeural (female, ค่ะ)
# Usage: ./speak.sh [step]
#   ./speak.sh greet     — Opening greeting
#   ./speak.sh step1     — GitHub Account
#   ./speak.sh step2     — Create Repo
#   ./speak.sh step3     — Upload HTML
#   ./speak.sh step4     — Visit Site
#   ./speak.sh celebrate — Sites are live!
#   ./speak.sh all       — Play all steps in sequence

VOICE="th-TH-PremwadeeNeural"
EDGE_TTS="${HOME}/.local/bin/edge-tts"
OUT_DIR="$(dirname "$0")/audio"
mkdir -p "$OUT_DIR"

speak() {
  local name="$1"
  local text="$2"
  local mp3="$OUT_DIR/${name}.mp3"

  if [ ! -f "$mp3" ]; then
    echo "Generating: $name"
    "$EDGE_TTS" --voice "$VOICE" --text "$text" --write-media "$mp3" 2>/dev/null
  fi

  echo "Playing: $name"
  afplay "$mp3"
}

# --- TTS Scripts ---

greet() {
  speak "greet" "สวัสดีค่ะ ยินดีต้อนรับทุกคนค่ะ ตอนเช้านี้เราทำ portfolio HTML เสร็จแล้ว ตอนนี้ เราจะเอาขึ้นเว็บไซต์จริงกันค่ะ ใช้ GitHub Pages ซึ่งฟรี ไม่ต้องจ่ายเงิน แค่ 4 ขั้นตอน ทุกคนจะมีเว็บไซต์ portfolio ของตัวเองค่ะ"
}

step1() {
  speak "step1" "ขั้นตอนที่ 1 ค่ะ สร้างบัญชี GitHub ใครที่มีแล้ว log in ได้เลยค่ะ ใครยังไม่มี ไปที่ github.com แล้วกด sign up ค่ะ ใช้อีเมลของตัวเอง ตั้ง username ให้จำง่าย เพราะ username นี้จะเป็นชื่อเว็บไซต์ของเราด้วยค่ะ"
}

step2() {
  speak "step2" "ขั้นตอนที่ 2 ค่ะ สร้าง repository ใหม่ กดปุ่มบวกที่มุมขวาบน แล้วเลือก New repository ชื่อ repo ต้องเป็น username จุด github จุด io ค่ะ ตัวอย่างเช่น ถ้า username คือ somchai ก็ตั้งชื่อว่า somchai จุด github จุด io ค่ะ เลือกเป็น public นะคะ ไม่ต้องติ๊ก README แล้วกด create ได้เลยค่ะ"
}

step3() {
  speak "step3" "ขั้นตอนที่ 3 ค่ะ อัปโหลดไฟล์ HTML ในหน้า repo ว่าง จะมีลิงก์ uploading an existing file กดตรงนั้นค่ะ แล้วลากไฟล์ portfolio HTML ของเราเข้าไป สำคัญมากค่ะ ต้องเปลี่ยนชื่อไฟล์เป็น index จุด html นะคะ แล้วกด commit changes ได้เลยค่ะ"
}

step4() {
  speak "step4" "ขั้นตอนที่ 4 ค่ะ เปิดเว็บไซต์ของเรา รอประมาณ 1 ถึง 2 นาทีค่ะ แล้วเปิด browser พิมพ์ username จุด github จุด io ค่ะ ถ้าเห็นหน้า portfolio ของเรา ก็แสดงว่าสำเร็จแล้วค่ะ"
}

celebrate() {
  speak "celebrate" "เย้ สุดยอดค่ะ ทุกคนมีเว็บไซต์ portfolio ของตัวเองแล้ว ลิงก์นี้แชร์ให้ใครก็ได้ทั่วโลกค่ะ นี่คือผลงานจริงของทุกคน ภูมิใจมากค่ะ ถ้าอยากแก้ไข สามารถกดไอคอนดินสอใน GitHub แล้วแก้ได้เลยค่ะ"
}

troubleshoot_rename() {
  speak "troubleshoot_rename" "สำหรับคนที่ลืมตั้งชื่อไฟล์เป็น index จุด html ไม่ต้องห่วงค่ะ กดที่ชื่อไฟล์ใน GitHub แล้วกดไอคอนดินสอ แล้วแก้ชื่อไฟล์ที่ด้านบนให้เป็น index จุด html แล้ว commit ค่ะ"
}

troubleshoot_404() {
  speak "troubleshoot_404" "ถ้าเปิดเว็บแล้วเจอ 404 ไม่ต้องตกใจค่ะ อาจจะต้องรอ 2 ถึง 3 นาทีค่ะ ลอง refresh อีกทีนะคะ ถ้ายังไม่ขึ้น เช็คว่าชื่อ repo ถูกต้อง คือ username จุด github จุด io และมีไฟล์ index จุด html อยู่ค่ะ"
}

# --- Main ---

case "${1:-greet}" in
  greet)      greet ;;
  step1)      step1 ;;
  step2)      step2 ;;
  step3)      step3 ;;
  step4)      step4 ;;
  celebrate)  celebrate ;;
  rename)     troubleshoot_rename ;;
  404)        troubleshoot_404 ;;
  all)
    greet && sleep 2
    step1 && sleep 2
    step2 && sleep 2
    step3 && sleep 2
    step4 && sleep 2
    celebrate
    ;;
  prebuild)
    echo "Pre-generating all audio files..."
    greet; step1; step2; step3; step4; celebrate
    troubleshoot_rename; troubleshoot_404
    echo "Done! Audio files in: $OUT_DIR"
    ;;
  *)
    echo "Usage: $0 {greet|step1|step2|step3|step4|celebrate|rename|404|all|prebuild}"
    exit 1
    ;;
esac
