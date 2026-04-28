-- MySQL schema + seed cho hệ thống đặt lịch khám
-- File này được chạy bởi `npm run init` (tự CREATE DATABASE/USE).

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL DEFAULT '',
  role VARCHAR(20) NOT NULL DEFAULT 'user'
);

CREATE TABLE IF NOT EXISTS doctors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  specialty VARCHAR(255) NOT NULL,
  specializations TEXT NOT NULL,
  experience INT NOT NULL DEFAULT 0,
  description TEXT NOT NULL,
  image TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  doctor_id INT NOT NULL,
  date VARCHAR(10) NOT NULL,        -- yyyy-MM-dd
  start_time VARCHAR(5) NOT NULL,   -- HH:mm
  end_time VARCHAR(5) NOT NULL,     -- HH:mm
  is_booked TINYINT(1) NOT NULL DEFAULT 0,
  CONSTRAINT fk_schedules_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  doctor_id INT NOT NULL,
  schedule_id INT NOT NULL,
  symptom TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending/confirmed/cancelled
  created_at VARCHAR(40) NOT NULL,               -- ISO8601
  CONSTRAINT fk_appointments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
  CONSTRAINT fk_appointments_schedule FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE
);

-- Seed tài khoản mẫu (giống readme.md)
INSERT IGNORE INTO users (id, name, email, password, phone, role)
VALUES
  (1, 'Admin', 'admin@gmail.com', '123456', '', 'admin'),
  (2, 'Demo User', 'user@gmail.com', '123456', '', 'user');

-- Seed doctors (tương tự seed Drift)
INSERT IGNORE INTO doctors (id, name, specialty, specializations, experience, description, image)
VALUES
  (1, 'Dr. Sarah Jenkins', 'Cardiology', 'Tim mạch tổng quát|Tăng huyết áp|Rối loạn nhịp tim|Tư vấn lối sống', 8, 'Lead Cardiologist with a patient-first approach.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuACxIl2BQtqmStUjBo1hH3_ZU3isctPoPOlKOtOI0Vmj1iIwbV7oYx2_ZLLVYo6VLVHcuqslIP1HIV6l46lyxMQpe1ebenVOh4q1CKXpFYjtYMPlA1ein57VpPeEShPP9T8apABS8pG2y1RuNKsECAXb90G3DhXViRCQgRopuJiooAjQPzAYCh_PBgtVBz7hFvxcjqNniBYko4-uO1wFPA5bVitNaRV4fVznlu05D_kTmw_wgnJfCcBPLOSubGjw4evVUCrpmBLEnc'),
  (2, 'Dr. Marcus Thorne', 'Neurology', 'Thần kinh|Đau đầu/migraine|Rối loạn giấc ngủ|Tư vấn phục hồi chức năng', 12, 'Neurology specialist focused on modern diagnostics.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAI3EhnM7K8H2AzHeJvtzCYy6yeXxtUcXaIXr54pRPmeWBN4OZya6Iuq4qduY7GQHg4HWm6JayE4Vg8hlfe2QZxe3W5N3lY2cte3M6Zs5x9lBV2XBtpGAVOsbgUgVim2AuomfXQXzubII7aS-LQhLeHLr4r2X-fFI82P1m5pCNgxEOo4eURzcDMzzY9IxhDUSrJNh-_c4hawTJBWAhRdk5e0slitcfZfu4RELeuyc7zDOh-lrnpZrJikP2XDMvlChhb0xWLCrg5lLc'),
  (3, 'Dr. Elena Rodriguez', 'Pediatrics', 'Nhi khoa|Tiêm chủng|Dinh dưỡng trẻ em|Theo dõi phát triển', 6, 'Pediatric wellness and preventive care.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAoYJVAa1lW6LB6w8uSaep9p3Dt_infnhy8lENKMdjX1h2tRwwPiHteodgBsI6-FysNuST7MGayhprCPZR-97UBABdu1dI7nCJL4kOvPQcbP_RVUnNeb3uy5MYaqjgLcfe99OO_YvzUXfGoQ6CvgSfZ_9ngNLB5Vz1rV0dZYSf4cI86Df6OcBdlAVxom_ocECUlnL0VhI1OhwPRHdflV3xkZl6WWRb9ZnCYbLDdxHQtWNt9K3muBKHFx676VEFjjEZNt_g27oXeEO8'),
  (4, 'Dr. An Nguyen', 'Dermatology', 'Da liễu|Mụn|Dị ứng da|Tư vấn chăm sóc da', 9, 'Chuyên gia da liễu, tập trung điều trị mụn và chăm sóc da an toàn.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuACxIl2BQtqmStUjBo1hH3_ZU3isctPoPOlKOtOI0Vmj1iIwbV7oYx2_ZLLVYo6VLVHcuqslIP1HIV6l46lyxMQpe1ebenVOh4q1CKXpFYjtYMPlA1ein57VpPeEShPP9T8apABS8pG2y1RuNKsECAXb90G3DhXViRCQgRopuJiooAjQPzAYCh_PBgtVBz7hFvxcjqNniBYko4-uO1wFPA5bVitNaRV4fVznlu05D_kTmw_wgnJfCcBPLOSubGjw4evVUCrpmBLEnc'),
  (5, 'Dr. Minh Tran', 'Internal Medicine', 'Nội tổng quát|Tiểu đường|Mỡ máu|Tư vấn sức khỏe định kỳ', 11, 'Bác sĩ nội tổng quát, theo dõi bệnh mạn tính và tư vấn lối sống.', 'https://lh3.googleusercontent.com/aida-public/AB6AXuAI3EhnM7K8H2AzHeJvtzCYy6yeXxtUcXaIXr54pRPmeWBN4OZya6Iuq4qduY7GQHg4HWm6JayE4Vg8hlfe2QZxe3W5N3lY2cte3M6Zs5x9lBV2XBtpGAVOsbgUgVim2AuomfXQXzubII7aS-LQhLeHLr4r2X-fFI82P1m5pCNgxEOo4eURzcDMzzY9IxhDUSrJNh-_c4hawTJBWAhRdk5e0slitcfZfu4RELeuyc7zDOh-lrnpZrJikP2XDMvlChhb0xWLCrg5lLc');

-- Seed schedules: 7 ngày tới, 4 ca/ngày cho 5 bác sĩ
INSERT IGNORE INTO schedules (doctor_id, date, start_time, end_time, is_booked)
SELECT d.id,
       DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL n.day DAY), '%Y-%m-%d') AS date_key,
       s.start_time,
       s.end_time,
       0 AS is_booked
FROM (SELECT 1 AS id UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) d
CROSS JOIN (
  SELECT 0 AS day UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
) n
CROSS JOIN (
  SELECT '08:00' AS start_time, '10:00' AS end_time UNION ALL
  SELECT '10:00', '12:00' UNION ALL
  SELECT '13:30', '15:30' UNION ALL
  SELECT '15:30', '17:30'
) s;

-- Seed 1 appointment pending cho user demo để admin thấy ngay
INSERT IGNORE INTO appointments (id, user_id, doctor_id, schedule_id, symptom, status, created_at)
SELECT 1, 2, 1, sc.id, 'Headache', 'pending', CONCAT(DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%s'), '.000Z')
FROM schedules sc
WHERE sc.doctor_id = 1 AND sc.date = DATE_FORMAT(CURDATE(), '%Y-%m-%d')
ORDER BY sc.start_time ASC
LIMIT 1;

UPDATE schedules sc
JOIN appointments a ON a.schedule_id = sc.id
SET sc.is_booked = 1
WHERE a.id = 1;

