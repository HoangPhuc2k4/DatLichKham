## Hướng dẫn chạy dự án (Web/Android) — MySQL qua Backend REST API

Dự án chạy theo mô hình:

- **Flutter (Web/Android)** gọi **Backend REST API**
- **Backend** kết nối **MySQL**

Bạn cần cài đặt trước:

- Flutter SDK (khuyến nghị Flutter 3.x)
- Chrome (để chạy debug web)
- (Tuỳ chọn) VS Code / Android Studio để debug
- Node.js (chạy backend)
- MySQL Server (local)

---

### 1. Cài đặt package

Mở terminal trong thư mục gốc dự án (`DatLichKham`) và chạy:

```bash
flutter pub get
```

---

### 2. Chạy Backend + Init MySQL (bắt buộc)

Backend nằm trong thư mục `backend/`.

```bash
cd backend
npm install
```

---

Init database (tạo DB, tạo bảng, seed dữ liệu mẫu):

```bash
cd backend
npm run init
```

Chạy API (mặc định port 3000):

```bash
cd backend
npm start
```

Kiểm tra nhanh backend đã lên:

```bash
curl http://localhost:3000/health
```

---

### 3. Chạy bản **Web (Chrome)**

Đảm bảo Chrome đã được Flutter nhận:

```bash
flutter devices
```

Chạy web:

```bash
flutter run -d chrome
```

---

### 4. Chạy bản **App Android (LDPlayer / giả lập Android)**

Bạn cần chuẩn bị:

- Cài **Android SDK** (Android Studio hoặc chỉ command-line tools).
- Bật toolchain Android cho Flutter:

```bash
flutter doctor
flutter doctor --android-licenses
```

#### 4.1 Kết nối LDPlayer để Flutter nhận thiết bị

LDPlayer thường hỗ trợ ADB. Mở LDPlayer trước, sau đó:

1) Kiểm tra ADB đang thấy thiết bị:

```bash
adb devices
```

2) Nếu chưa thấy, thử kết nối (cổng có thể khác tuỳ cấu hình LDPlayer):

```bash
adb connect 127.0.0.1:5555
adb devices
```

3) Khi đã thấy thiết bị Android, kiểm tra Flutter nhận:

```bash
flutter devices
```

#### 4.2 Chạy app lên LDPlayer

```bash
flutter run
```

Hoặc chỉ định device:

```bash
flutter run -d <device_id>
```

---

### 5. Fix lỗi LDPlayer không kết nối được Backend

Vấn đề thường gặp: **LDPlayer không truy cập được `localhost` của máy tính**.

Bạn có 2 cách:

#### Cách A (khuyến nghị): Dùng IP LAN của máy tính và `--dart-define`

1) Lấy IP LAN của máy tính (ví dụ `192.168.1.10`).
2) Đảm bảo LDPlayer và máy tính cùng mạng (thường là cùng Wi‑Fi/LAN).
3) Mở firewall cho port **3000** (Inbound) nếu bị chặn.
4) Chạy app với base URL trỏ về IP LAN:

```bash
flutter run -d <device_id> --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

Ghi chú: app đọc `API_BASE_URL` trong `lib/config/app_config.dart`.

#### Cách B: ADB reverse (tuỳ LDPlayer)

Nếu LDPlayer hỗ trợ reverse port:

```bash
adb -s <device_id> reverse tcp:3000 tcp:3000
```

Sau đó chạy app bình thường.

Nếu reverse không hoạt động, dùng lại **Cách A**.

---

### 6. Build web (release)

```bash
flutter build web --release
```

---

### 7. Tài khoản seed để test nhanh

Sau khi chạy `npm run init`, DB sẽ seed dữ liệu mẫu:

- **Admin**: `admin@gmail.com` / `123456`
- **User**: `user@gmail.com` / `123456`

---

### 8. Route nhanh (Web)

- User:
  - `/` (Login/Register)
  - `/#/user/home`
  - `/#/user/doctor`
  - `/#/user/appointments`
- Admin:
  - `/#/admin/dashboard`
  - `/#/admin/doctors`
  - `/#/admin/schedules`
  - `/#/admin/appointments`

