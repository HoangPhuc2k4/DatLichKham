# 📱 Hệ thống đặt lịch khám bệnh

**Flutter + Dart + MySQL (qua Backend REST API)** theo kiến trúc **MVC**.

- **Mobile (Android):** dành cho **Bệnh nhân (User)**
- **Web (Chrome):** ưu tiên cho **Quản trị viên (Admin)**

---

## 1) Công nghệ sử dụng

- **Flutter** (Material 3) + **Dart 3**
- **Backend**: Node.js + Express (REST API)
- **Database**: **MySQL**
- UI/tiện ích: `google_fonts`, `flutter_svg`, `file_picker`

---

## 2) Chức năng hệ thống

### 2.1. Bệnh nhân (User) — Mobile

- **Xác thực:** đăng ký, đăng nhập, đăng xuất
- **Bác sĩ:** xem danh sách, xem chi tiết (chuyên khoa, kinh nghiệm, mô tả, ảnh)
- **Lịch khám:** xem các **slot/ca** theo bác sĩ và ngày
- **Đặt lịch khám:** chọn bác sĩ → ngày → ca giờ, nhập triệu chứng
- **Lịch của tôi:** xem danh sách, theo dõi trạng thái, **hủy lịch**

### 2.2. Quản trị (Admin) — Web

- **Dashboard:** thống kê tổng quan (user/doctor/appointment), phân bổ trạng thái, xu hướng theo ngày, cảnh báo gợi ý
- **Quản lý bác sĩ:** thêm / sửa / xóa, quản lý ảnh đại diện
- **Quản lý lịch làm việc (slot):** tạo / sửa / xóa ca theo ngày & bác sĩ
- **Quản lý lịch hẹn:** xem toàn bộ, **xác nhận**, hủy/xóa (đồng bộ trạng thái slot)

---

## 3) Cấu trúc thư mục (MVC)

```plaintext
lib/
│
├── models/
│   ├── user.dart
│   ├── doctor.dart
│   ├── schedule.dart
│   └── appointment.dart
│   └── appointment_details.dart
│
├── views/
│   ├── auth/
│   ├── user/
│   ├── admin/
│   └── widgets/
│
├── controllers/
│   ├── auth_controller.dart
│   ├── session_controller.dart
│   ├── doctor_controller.dart
│   ├── schedule_controller.dart
│   └── appointment_controller.dart
│
├── api/
│   └── api_client.dart
│
├── config/
│   └── app_config.dart
│
└── main.dart

backend/
└── src/ (REST API)
```

---

## 4) Database (MySQL)

Các bảng chính (khai báo trong `backend/schema.sql`):

- **users**: `email` unique, `role` = `user` / `admin`
- **doctors**: thông tin bác sĩ; `specializations` lưu dạng chuỗi phân tách bởi `|`
- **schedules**: slot theo `doctor_id + date + start_time/end_time`, có cờ `is_booked`
- **appointments**: liên kết `user_id/doctor_id/schedule_id`, có `status` (`pending/confirmed/cancelled`) và `created_at`

Ghi chú: DB có **seed dữ liệu mẫu** (users/doctors/schedules/appointments) trong `backend/schema.sql`.

---

## 5) Luồng nghiệp vụ chính (tóm tắt)

- **Đặt lịch:** kiểm tra slot còn trống → tạo appointment → cập nhật `schedules.isBooked = true` (transaction)
- **Hủy lịch:** cập nhật `appointments.status = cancelled` → trả slot về trống `schedules.isBooked = false` (transaction)
- **Admin xác nhận lịch:** cập nhật `appointments.status = confirmed`

---

## 6) Hướng dẫn chạy dự án

Yêu cầu:

- Flutter SDK (khuyến nghị Flutter 3.x), Dart 3.x
- Chrome (chạy Web)
- MySQL Server (local)
- Node.js (chạy backend)

Cài dependencies:

```bash
flutter pub get
```

Backend:
- Cài packages:

```bash
cd backend
npm install
```

- Init MySQL (tạo DB + tạo bảng + seed dữ liệu mẫu):

```bash
cd backend
npm run init
```

- Chạy API:

```bash
cd backend
npm start
```

Chạy Web (Admin):

```bash
flutter run -d chrome
```

Chạy Android (User):

```bash
flutter run
```

Tài liệu chi tiết hơn xem `RUN.md`.

---

## 7) Tài khoản mẫu

Seed sẵn trong MySQL (sau khi chạy `npm run init`):

- **Admin**: `admin@gmail.com` / `123456`
- **User**: `user@gmail.com` / `123456`

Ngoài ra có thể **đăng ký** tài khoản User trực tiếp trong app.

---

## 8) Tài liệu liên quan

- `MO_TA_CHUC_NANG_USE_CASE.md`: mô tả chức năng theo UC tổng quát & phân rã
- `RUN.md`: hướng dẫn chạy (Web ưu tiên, có ghi chú Drift/WASM)
