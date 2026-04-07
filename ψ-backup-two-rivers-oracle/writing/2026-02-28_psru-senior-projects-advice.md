# PSRU Senior Projects — คำแนะนำจากพี่นัท

> 15 โปรเจคจบ สาขาวิศวกรรมคอมพิวเตอร์ ม.ราชภัฏพิบูลสงคราม
> วันที่ให้คำปรึกษา: 28 ก.พ. 2569

---

## 1. SmartPenTest
**สิ่งที่ทำ**: เว็บทดสอบ OWASP โดยใช้ AI อธิบายและวิเคราะห์ช่องโหว่

**AI Feature**: LLM วิเคราะห์ผล vulnerability scan → อธิบายเป็นภาษาคน + จัดลำดับความรุนแรง

**Tech แนะนำ**: OWASP ZAP API → ส่งผลให้ Claude/GPT → สรุปเป็นรายงาน

**คำแนะนำพี่นัท**: ใช้ Oracle pattern ได้เลย — สร้าง AI agent ที่เชี่ยวชาญ security วิเคราะห์ได้ทันที ไม่ต้องสร้างโมเดลเอง

**จุดเด่นตอน defense**: Live demo scan เว็บจริง → AI อธิบายทันทีว่าช่องโหว่คืออะไร อันตรายแค่ไหน แก้ยังไง

---

## 2. Smart Bin (วัดปริมาณ)
**สิ่งที่ทำ**: วัดปริมาณขยะและแจ้งเตือน

**AI Feature**: แนะนำเพิ่ม — ML predict เวลาขยะเต็ม จาก pattern การทิ้ง (time-series)

**Tech แนะนำ**: Radar sensor (แม่นกว่า ultrasonic, ไม่กลัวฝุ่น/ความชื้น), ESP32, LINE Notify

**คำแนะนำพี่นัท**: ใช้ radar sensor แทน ultrasonic — เพิ่ม dashboard 3D แสดงระดับขยะแต่ละถัง real-time

**จุดเด่นตอน defense**: ถ้ามี prediction "ถังจะเต็มใน 3 ชม." จะเด่นกว่าแค่ "ถังเต็มแล้ว"

---

## 3. Data Analysis — ยืมหนังสือ PSRU
**สิ่งที่ทำ**: วิเคราะห์การยืมหนังสือห้องสมุด PSRU ผ่าน Web Application

**AI Feature**: แนะนำ — AI สรุป trend ("เดือนนี้นศ.ยืมหนังสือ IT เพิ่ม 40%") + recommendation แนะนำหนังสือ

**Tech แนะนำ**: Python/Pandas, Web app (React/Vue), Chart.js หรือ D3.js

**คำแนะนำพี่นัท**: ข้อมูลห้องสมุดคือ gold mine — ทำ heatmap ช่วงเวลายืม, clustering นักศึกษาตาม reading pattern, collaborative filtering แนะนำหนังสือ

**จุดเด่นตอน defense**: ใช้ข้อมูลจริงของ PSRU — กรรมการเห็น insight ของมหาวิทยาลัยตัวเองจะประทับใจ

---

## 4. AI Smart Bin — Recognize Recycle Waste
**สิ่งที่ทำ**: ตรวจจับฝา ฉลาก และน้ำผ่านกล้อง + แจ้งเตือนด้วยเสียงให้แยกขยะ

**AI Feature**: Computer Vision จำแนกประเภทขยะ → TTS บอกให้แยกก่อนทิ้ง

**Tech แนะนำ**: YOLOv8-nano (edge device), ESP32-CAM / Raspberry Pi, edge-tts ภาษาไทย

**คำแนะนำพี่นัท**: Train custom dataset ขยะไทย (ขวด Est, ฝา Singha, ฉลากมาม่า) — dataset ไทยจะเป็นจุดเด่น. เสียงพูดไทย "กรุณาแยกฝาออกก่อนทิ้งค่ะ"

**จุดเด่นตอน defense**: Live demo ทิ้งขวดน้ำ → ระบบพูด "แยกฝาออก แยกฉลากออก แล้วทิ้งในถังรีไซเคิลค่ะ"

---

## 5. PSRU Blockchain Digital Wallet — Carbon Credit
**สิ่งที่ทำ**: แอปสะสมคะแนน carbon credit บน blockchain (JIB Chain)

**AI Feature**: แนะนำ — AI ตรวจสอบหลักฐานกิจกรรม (ถ่ายรูป → verify ว่าปั่นจักรยานจริง) ก่อน mint credit

**Tech แนะนำ**: JIB Chain, Solidity, NFT ERC-721, Web3.js — ✅ มี contract deploy แล้ว

**คำแนะนำพี่นัท**: Smart contract + NFT บน JIB Chain deploy แล้ว = ดีมาก เพราะพิสูจน์ได้ว่าทำงานจริง. เพิ่ม AI verify กิจกรรม (vision model ตรวจรูป) จะทำให้ระบบน่าเชื่อถือ

**จุดเด่นตอน defense**: เปิด block explorer ให้กรรมการดู transaction จริงบน chain

---

## 6. Virtual Tour (VR & AR)
**สิ่งที่ทำ**: VR/AR แสดงโมเดล 3D + หลักการทำงานของชุดฝึก ด้วย Unity + WASM

**AI Feature**: แนะนำ — AI tour guide อธิบายแต่ละจุดด้วยเสียง, ตอบคำถาม voice input

**Tech แนะนำ**: Unity, AR Foundation, WebGL/WASM build

**คำแนะนำพี่นัท**: WASM build = รันบนเว็บได้ไม่ต้องลง app — จุดแข็งมาก. เพิ่ม AI narrator อธิบายชิ้นส่วนเมื่อ user จ้องมอง (gaze trigger) จะยกระดับจาก "ดูสวย" เป็น "ใช้งานได้จริง"

**จุดเด่นตอน defense**: ให้กรรมการเปิดเว็บดูได้ทันทีบนมือถือ ไม่ต้องลงแอป

---

## 7. Box Assembly Robot
**สิ่งที่ทำ**: หุ่นยนต์ UR3 พับกล่องอัตโนมัติ + AI ตรวจจับฝั่งถูก/ผิด + อ่านสัญลักษณ์บนกล่อง

**AI Feature**: Vision ตรวจ orientation กล่อง (ถูกฝั่งไหม) + อ่าน text/symbol + defect detection (รอยขาด/บุบ)

**Tech แนะนำ**: UR3 robot, OpenCV/YOLOv8, OCR (Tesseract/PaddleOCR)

**คำแนะนำพี่นัท**: Defect detection เป็น real industry use case ที่โรงงานต้องการจริง. ใช้ anomaly detection — train แค่กล่องปกติ แล้วหา anomaly. เพิ่ม dashboard แสดง pass/fail rate

**จุดเด่นตอน defense**: วิดีโอ UR3 ทำงานจริง + สถิติ accuracy / defect rate

---

## 8. Automation Delivery Robot
**สิ่งที่ทำ**: หุ่นยนต์ส่งของอัตโนมัติ + ตรวจสอบพัสดุ + หลบสิ่งกีดขวาง

**AI Feature**: Object detection (ตรวจพัสดุ), obstacle avoidance, path planning

**Tech แนะนำ**: ESP-32, LAFVIN Uno R3, Camera, Mobile App

**คำแนะนำพี่นัท**: เพิ่ม MQTT real-time tracking บน web map (เหมือนติดตาม Grab/LINE MAN). AI เช็คว่าพัสดุถูกชิ้นไหม (QR/barcode verify) ก่อนออกเดินทาง

**จุดเด่นตอน defense**: Live demo — สั่งผ่าน app → หุ่นยนต์หยิบของ → หลบสิ่งกีดขวาง → ส่งถึง

---

## 9. ตรวจสอบ Phishing แบบ Realtime
**สิ่งที่ทำ**: เว็บ + browser extension ตรวจ phishing URL แบบ real-time

**AI Feature**: ML วิเคราะห์ URL features + LLM อธิบายว่า "URL นี้น่าสงสัยเพราะ..."

**Tech แนะนำ**: Chrome Extension, ML classifier (URL features), PhishTank API สำหรับ dataset

**คำแนะนำพี่นัท**: Feature engineering จาก URL เป็นหัวใจ — domain age, SSL cert, Levenshtein distance จาก known brands, จำนวน subdomain. เพิ่ม LLM อธิบายเป็นภาษาคนว่าทำไมถึงอันตราย

**จุดเด่นตอน defense**: ลง extension → เข้าเว็บ phishing ตัวอย่าง → แจ้งเตือนทันที + อธิบายเหตุผล

---

## 10. ระบบสหกิจศึกษา + AI Matching
**สิ่งที่ทำ**: ระบบยื่นเอกสาร + AI จับคู่นักศึกษากับสถานประกอบการ + ตรวจเอกสาร

**AI Feature**: Matching algorithm (skill similarity) + document verification

**Tech แนะนำ**: Web app, cosine similarity / embedding-based matching, LLM สรุปเหตุผล

**คำแนะนำพี่นัท**: AI Matching คือ core value — ใช้ embedding ของ skill + ความสนใจ → cosine similarity กับ requirement ของบริษัท. เพิ่ม LLM อธิบาย "จับคู่เพราะ..." จะน่าเชื่อถือ

**จุดเด่นตอน defense**: ใส่ข้อมูลนักศึกษาจริง → ระบบแนะนำบริษัท + อธิบายว่าทำไม match

---

## 11. PSRU Smart EV Bus Routing + People Count
**สิ่งที่ทำ**: ตรวจจับจำนวนคนบนรถ + แสดงตำแหน่งรถ real-time + จัดการเส้นทาง

**AI Feature**: YOLOv8 people counting + tracking (นับขึ้น-ลง ไม่ซ้ำ) + route optimization

**Tech แนะนำ**: YOLOv8 + ByteTrack, GPS, MQTT real-time, Web map dashboard

**คำแนะนำพี่นัท**: รวม 2 งานเป็นระบบเดียว — ข้อมูลคนบนรถ → ปรับเส้นทาง dynamic. ใช้ MQTT pub/sub สำหรับ live tracking บน map (bus icon + จำนวนคน). AI predict "อีก 10 นาที รถจะเต็ม สายนี้ควรเพิ่มรอบ"

**จุดเด่นตอน defense**: เปิด dashboard → เห็นรถวิ่งบน map real-time + จำนวนคนเปลี่ยนแบบ live

---

## 12. VR Driving License Test
**สิ่งที่ทำ**: เกมขับรถ VR + hardware controller (MCU) สำหรับฝึกขับ

**AI Feature**: แนะนำ — AI driving instructor วิเคราะห์พฤติกรรมขับ → feedback เสียง

**Tech แนะนำ**: Unity VR, Microcontroller (Arduino/ESP32), Serial communication

**คำแนะนำพี่นัท**: Hardware-software integration = จุดแข็ง. เพิ่ม AI scoring — วิเคราะห์ความเร็ว เลี้ยว เบรก แล้วให้คะแนน + feedback "คุณเบรกกะทันหันบ่อย ลองเบรกเนิ่นกว่านี้". บันทึก session data → สถิติพัฒนาการ

**จุดเด่นตอน defense**: ให้กรรมการลองขับ → ได้คะแนน + คำแนะนำจาก AI

---

## 13. Smart Box — แขนกลแยกขนาด
**สิ่งที่ทำ**: แขนกล Hornet565 แยกขนาดวัตถุ

**AI Feature**: แนะนำ — Vision-based classification จำแนกขนาด+ประเภท จากกล้อง (ไม่พึ่ง sensor อย่างเดียว)

**Tech แนะนำ**: Hornet565, Camera, OpenCV (contour analysis) หรือ YOLOv8

**คำแนะนำพี่นัท**: เพิ่ม vision measurement — กล้อง + reference object คำนวณขนาดจริง (cm). จะทำให้ไม่ต้องเปลี่ยน sensor ทุกครั้งที่เจอวัตถุใหม่. เพิ่ม sorting statistics dashboard

**จุดเด่นตอน defense**: วางวัตถุหลายขนาด → แขนกลหยิบแยกถูกถัง + แสดง accuracy rate

---

## 14. ระบบเช็คชื่ออัตโนมัติ — Face + RFID
**สิ่งที่ทำ**: เช็คชื่อด้วย QR code + สแกนใบหน้า ด้วย DeepFace (FaceNet, VGG-Face)

**AI Feature**: Face recognition multi-model (FaceNet + VGG-Face) + multi-factor auth (QR + face)

**Tech แนะนำ**: DeepFace library (Python), OpenCV, RFID/QR scanner

**คำแนะนำพี่นัท**: Multi-factor (QR + face) = จุดเด่นด้าน security. เพิ่ม liveness detection (anti-spoofing) ป้องกันใช้รูปหลอก — ใช้ blink detection หรือ depth estimation. เปรียบเทียบ accuracy ระหว่าง FaceNet vs VGG-Face บน dataset ของนักศึกษาจริง

**จุดเด่นตอน defense**: Demo live เช็คชื่อ → ลองใช้รูปหลอก → ระบบ reject → กรรมการประทับใจ

---

## ภาพรวม 15 โปรเจค

| หมวด | โปรเจค | จำนวน |
|------|--------|-------|
| AI + Computer Vision | AI Smart Bin, Box Assembly, People Count, Face Check, Delivery | 5 |
| Web + AI | SmartPenTest, Phishing, สหกิจ Matching, Data Analysis | 4 |
| IoT + Hardware | Smart Bin (radar), EV Bus, Smart Box แขนกล | 3 |
| VR/AR + Hardware | Virtual Tour, VR Driving | 2 |
| Blockchain | Carbon Credit Wallet | 1 |

### โปรเจคที่ collaborate กันได้
- **EV Bus Routing + People Count** → ข้อมูลจำนวนคน feed เข้า route optimization
- **Smart Bin (radar) + AI Smart Bin (vision)** → radar วัดปริมาณ + camera แยกประเภท
- **Box Assembly Robot + Smart Box แขนกล** → share ความรู้ robot arm + vision

### เคล็ดลับสำหรับทุกโปรเจค
1. **มี dashboard** — กรรมการชอบเห็นข้อมูล visualize สวยๆ
2. **มี accuracy/performance metric** — ตัวเลขพิสูจน์ว่าทำงานได้จริง
3. **Live demo ได้** — ทำงานจริงหน้ากรรมการ ดีกว่า slide 100 แผ่น
4. **อธิบาย AI ได้** — ไม่ใช่แค่ "ใช้ AI" แต่อธิบายได้ว่า model อะไร train ยังไง accuracy เท่าไหร่
