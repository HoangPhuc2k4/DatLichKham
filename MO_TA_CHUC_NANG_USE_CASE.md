# Mô tả chức năng dự án — phục vụ vẽ Use Case

Tài liệu này tóm tắt chức năng của ứng dụng **Đặt lịch khám** (Flutter, SQLite/Drift), phân cấp để:

- **Cấp 1:** các **chức năng lớn** — dùng cho **sơ đồ Use Case tổng quát** (mức hệ thống / gói nghiệp vụ).
- **Cấp 2:** các **chức năng con** — dùng cho **Use Case phân rã** (mức chi tiết thao tác: thêm, sửa, xóa, xác nhận, …), ký hiệu **UCx_yy** (ví dụ `UC1_01`, `UC1_02`).

**Tác nhân gợi ý khi vẽ:** *Bệnh nhân (User)*, *Quản trị viên (Admin)*, *(tuỳ chọn) Hệ thống / Thời gian* cho các luồng tự động (seed DB, nhắc lịch — nếu mở rộng).

**Quy ước cột Điều kiện (cấp 1):** mô tả *tiền đề* thường gặp (đăng nhập, vai trò). Chi tiết từng thao tác xem bảng phân rã.

---

## Cấp 1 — Chức năng lớn (Use Case tổng quát)

| Mã | Chức năng lớn | Mô tả ngắn | Tác nhân chính | Điều kiện / tiền đề |
|----|----------------|------------|----------------|----------------------|
| UC1 | **Xác thực tài khoản** | Đăng nhập, đăng ký, duy trì phiên làm việc, đăng xuất | User, Admin | **Đăng nhập / Đăng ký:** không cần đã đăng nhập. **Đăng xuất:** phải đang có phiên đăng nhập. |
| UC2 | **Truy cập trang chủ & khám phá phòng khám** | Xem landing, điều hướng nhanh tới bác sĩ / lịch / đăng nhập | User (khách có thể xem một phần) | **Không bắt buộc** đăng nhập để xem nội dung chung. Một số nút (ví dụ “Lịch của tôi”) có thể yêu cầu đăng nhập khi vào. |
| UC3 | **Tra cứu & xem thông tin bác sĩ** | Danh sách bác sĩ, chi tiết, hình ảnh & chuyên môn | User | **Không bắt buộc** đăng nhập để xem danh sách/chi tiết (theo luồng app hiện tại). |
| UC4 | **Đặt lịch khám** | Chọn bác sĩ, ngày, khung giờ (ca), nhập triệu chứng, tạo lịch hẹn | User (bệnh nhân) | **Phải đăng nhập** với tài khoản **User** (không áp dụng khách). Slot còn trống, lịch tồn tại. |
| UC5 | **Quản lý lịch khám cá nhân** | Xem lịch đã đặt, theo dõi trạng thái, hủy lịch | User | **Phải đăng nhập** User. Chỉ thao tác trên lịch của chính người dùng. |
| UC6 | **Thống kê & tổng quan vận hành** | Dashboard: số liệu, xu hướng, cảnh báo gợi ý | Admin | **Phải đăng nhập** với tài khoản **Admin**. |
| UC7 | **Quản lý danh mục bác sĩ** | CRUD bác sĩ, chuyên khoa, chuyên môn, ảnh đại diện | Admin | **Phải đăng nhập** Admin. |
| UC8 | **Quản lý lịch làm việc (slot trống)** | Tạo/sửa/xóa ca khám theo ngày & bác sĩ | Admin | **Phải đăng nhập** Admin. Xóa/sửa phải thỏa ràng buộc nghiệp vụ (ví dụ slot đã đặt). |
| UC9 | **Quản lý lịch hẹn toàn hệ thống** | Xem toàn bộ lịch đặt; xác nhận; hủy/xóa | Admin | **Phải đăng nhập** Admin. |

> **Gợi ý vẽ UC tổng quát:** Có thể gom UC6–UC9 thành một ô **“Quản trị phòng khám”** nếu sơ đồ cần gọn; tách ra khi cần bài chi tiết.

---

## Cấp 2 — Chức năng con (Use Case phân rã)

### UC1 — Xác thực tài khoản

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC1_01 | Đăng nhập | Xác thực email + mật khẩu, tạo phiên người dùng |
| UC1_02 | Đăng ký | Tạo tài khoản bệnh nhân (họ tên, email, mật khẩu, xác nhận mật khẩu) |
| UC1_03 | Điều hướng sau đăng nhập | Phân luồng theo vai trò (User → trang chủ user; Admin → khu vực quản trị) |
| UC1_04 | Đăng xuất | Kết thúc phiên, chuyển về màn hình đăng nhập hoặc trang công khai |

---

### UC2 — Truy cập trang chủ & khám phá phòng khám

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC2_01 | Xem nội dung trang chủ | Giới thiệu, hero, gợi ý tìm bác sĩ |
| UC2_02 | Điều hướng nhanh | Link tới danh sách bác sĩ, lịch của tôi, đăng nhập |
| UC2_03 | Tìm kiếm / gợi ý bác sĩ (nếu có trên UI) | Mở danh sách bác sĩ kèm từ khóa hoặc bộ lọc |

---

### UC3 — Tra cứu & xem thông tin bác sĩ

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC3_01 | Xem danh sách bác sĩ | Hiển thị tên, chuyên khoa, kinh nghiệm, ảnh |
| UC3_02 | Xem chi tiết bác sĩ | Mô tả, danh sách chuyên môn khám, chuyển tới đặt lịch |
| UC3_03 | Điều hướng từ danh sách → chi tiết | Chọn một bác sĩ để xem đầy đủ |

---

### UC4 — Đặt lịch khám

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC4_01 | Chọn bác sĩ | Từ danh sách hoặc trang chi tiết |
| UC4_02 | Chọn ngày khám | Ngày trong phạm vi có lịch làm việc |
| UC4_03 | Chọn khung giờ (ca) | Slot còn trống (`chưa đặt`) |
| UC4_04 | Nhập triệu chứng / lý do khám | Văn bản mô tả |
| UC4_05 | Gửi yêu cầu đặt lịch | Tạo bản ghi lịch hẹn; khóa slot tương ứng |
| UC4_06 | Xử lý lỗi nghiệp vụ | Slot đã được đặt, không tồn tại, chưa đăng nhập |

---

### UC5 — Quản lý lịch khám cá nhân

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC5_01 | Xem danh sách lịch của tôi | Kèm thông tin bác sĩ, ngày giờ, trạng thái |
| UC5_02 | Phân nhóm / lọc theo trạng thái | Ví dụ: chờ xác nhận, đã xác nhận, đã hủy (theo giao diện hiện tại) |
| UC5_03 | Hủy lịch | Đổi trạng thái lịch hẹn; mở lại slot (nếu quy tắc cho phép) |
| UC5_04 | Đặt lại / điều hướng đặt mới | Chuyển sang luồng đặt lịch khác (từ màn lịch của tôi) |

---

### UC6 — Thống kê & tổng quan vận hành

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC6_01 | Xem số lượng tổng quan | Bệnh nhân, bác sĩ, lịch hẹn |
| UC6_02 | Xem phân bổ trạng thái lịch | Pending / confirmed / cancelled |
| UC6_03 | Xem chỉ số vận hành (theo thiết kế màn hình) | Ví dụ: tỷ lệ xác nhận, độ lấp đầy slot trong ngày, thời gian chờ trung bình (pending) |
| UC6_04 | Xem xu hướng theo khoảng ngày | Biểu đồ/trend theo `range` ngày |
| UC6_05 | Xem cảnh báo / gợi ý | Ví dụ: tồn đọng pending, occupancy cao |

---

### UC7 — Quản lý danh mục bác sĩ

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC7_01 | Xem danh sách bác sĩ | Bảng danh sách trong khu admin |
| UC7_02 | Thêm bác sĩ | Tên, chuyên khoa, chuyên môn (danh sách), kinh nghiệm, mô tả, ảnh |
| UC7_03 | Sửa bác sĩ | Cập nhật các trường trên |
| UC7_04 | Xóa bác sĩ | Xóa khỏi hệ thống (lưu ý ràng buộc với lịch/slot nếu có) |
| UC7_05 | Quản lý ảnh đại diện | Chọn file ảnh (upload qua file picker trên web), hoặc URL/path theo quy ước |

---

### UC8 — Quản lý lịch làm việc (slot)

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC8_01 | Xem lịch theo bác sĩ & ngày | Danh sách ca trong ngày |
| UC8_02 | Thêm ca / lịch làm việc | Ngày, giờ bắt đầu – kết thúc, gán bác sĩ |
| UC8_03 | Sửa ca | Đổi thời gian hoặc thuộc tính (theo màn hình admin) |
| UC8_04 | Xóa ca | Chỉ khi không xung đột nghiệp vụ (ví dụ chưa đặt hoặc đã xử lý) |
| UC8_05 | Theo dõi trạng thái slot | Đã đặt / còn trống |

---

### UC9 — Quản lý lịch hẹn toàn hệ thống

| Mã con | Chức năng con | Mô tả |
|--------|----------------|--------|
| UC9_01 | Xem tất cả lịch đặt | Kèm bệnh nhân, bác sĩ, ngày giờ, triệu chứng |
| UC9_02 | Xác nhận lịch | Đổi trạng thái sang confirmed |
| UC9_03 | Hủy lịch (admin) | Đổi trạng thái; cập nhật slot phù hợp |
| UC9_04 | Xóa lịch hẹn | Xóa bản ghi; trả slot về trống (theo logic ứng dụng) |
| UC9_05 | Lọc / sắp xếp | Theo thời gian tạo, trạng thái (theo UI) |

---

## Ghi chú khi vẽ sơ đồ

- **Include / Extend:** Ví dụ “Đặt lịch khám” *include* “Đăng nhập” nếu bắt buộc phiên; “Hủy lịch” có thể *extend* “Quản lý lịch” với điều kiện xác nhận dialog.
- **Ranh giới hệ thống:** Toàn bộ xử lý nằm trong app + SQLite; không có API server riêng trong phạm vi dự án hiện tại.
- **Admin vs User:** Web thường dùng cho admin, mobile cho user — có thể ghi chú trên sơ đồ triển khai (Android/Web) nhưng **cùng một codebase** và cùng các use case logic.

---

*Tài liệu căn cứ theo mã nguồn thư mục `lib/` và mô tả trong `readme.md`.*
