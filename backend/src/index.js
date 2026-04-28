import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { getPool } from "./db.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const pool = getPool();

function toInt(v, fallback = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? Math.trunc(n) : fallback;
}

function ok(res, data) {
  res.json({ ok: true, data });
}

function fail(res, status, code, message) {
  res.status(status).json({ ok: false, error: { code, message } });
}

// Health check
app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    ok(res, { status: "up" });
  } catch (e) {
    fail(res, 500, "DB_DOWN", String(e?.message ?? e));
  }
});

// Auth
app.post("/auth/login", async (req, res) => {
  const email = String(req.body?.email ?? "").trim();
  const password = String(req.body?.password ?? "").trim();
  if (!email || !password) return fail(res, 400, "BAD_REQUEST", "Thiếu email/password");

  const [rows] = await pool.query(
    "SELECT id, name, email, password, phone, role FROM users WHERE email = ? AND password = ? LIMIT 1",
    [email, password]
  );
  const user = rows?.[0];
  if (!user) return fail(res, 401, "INVALID_CREDENTIALS", "Sai email hoặc mật khẩu");
  ok(res, user);
});

app.post("/auth/register", async (req, res) => {
  const name = String(req.body?.name ?? "").trim();
  const email = String(req.body?.email ?? "").trim();
  const password = String(req.body?.password ?? "").trim();
  const phone = String(req.body?.phone ?? "").trim();
  const role = String(req.body?.role ?? "user").trim() || "user";
  if (!name || !email || !password) return fail(res, 400, "BAD_REQUEST", "Thiếu name/email/password");

  const [exist] = await pool.query("SELECT id FROM users WHERE email = ? LIMIT 1", [email]);
  if (exist?.[0]) return fail(res, 409, "EMAIL_EXISTS", "Email đã tồn tại");

  const [result] = await pool.query(
    "INSERT INTO users (name, email, password, phone, role) VALUES (?, ?, ?, ?, ?)",
    [name, email, password, phone, role]
  );
  ok(res, { id: result.insertId, name, email, password, phone, role });
});

// Doctors
app.get("/doctors", async (_req, res) => {
  const [rows] = await pool.query(
    "SELECT id, name, specialty, specializations, experience, description, image FROM doctors ORDER BY id DESC"
  );
  ok(res, rows);
});

app.post("/doctors", async (req, res) => {
  const name = String(req.body?.name ?? "").trim();
  const specialty = String(req.body?.specialty ?? "").trim();
  const specializations = String(req.body?.specializations ?? "").trim();
  const experience = toInt(req.body?.experience ?? 0, 0);
  const description = String(req.body?.description ?? "").trim();
  const image = String(req.body?.image ?? "").trim();
  if (!name || !specialty) return fail(res, 400, "BAD_REQUEST", "Thiếu name/specialty");

  const [result] = await pool.query(
    "INSERT INTO doctors (name, specialty, specializations, experience, description, image) VALUES (?, ?, ?, ?, ?, ?)",
    [name, specialty, specializations, experience, description, image]
  );
  ok(res, { id: result.insertId });
});

app.put("/doctors/:id", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");
  const name = String(req.body?.name ?? "").trim();
  const specialty = String(req.body?.specialty ?? "").trim();
  const specializations = String(req.body?.specializations ?? "").trim();
  const experience = toInt(req.body?.experience ?? 0, 0);
  const description = String(req.body?.description ?? "").trim();
  const image = String(req.body?.image ?? "").trim();

  await pool.query(
    "UPDATE doctors SET name=?, specialty=?, specializations=?, experience=?, description=?, image=? WHERE id=?",
    [name, specialty, specializations, experience, description, image, id]
  );
  ok(res, { id });
});

app.delete("/doctors/:id", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");
  await pool.query("DELETE FROM doctors WHERE id = ?", [id]);
  ok(res, { id });
});

// Schedules
app.get("/schedules", async (req, res) => {
  const doctorId = toInt(req.query.doctorId, 0);
  const date = String(req.query.date ?? "").trim();
  if (!doctorId || !date) return fail(res, 400, "BAD_REQUEST", "Thiếu doctorId/date");
  const [rows] = await pool.query(
    "SELECT id, doctor_id, date, start_time, end_time, is_booked FROM schedules WHERE doctor_id=? AND date=? ORDER BY start_time ASC",
    [doctorId, date]
  );
  ok(res, rows);
});

app.post("/schedules", async (req, res) => {
  const doctorId = toInt(req.body?.doctor_id, 0);
  const date = String(req.body?.date ?? "").trim();
  const startTime = String(req.body?.start_time ?? "").trim();
  const endTime = String(req.body?.end_time ?? "").trim();
  const isBooked = toInt(req.body?.is_booked ?? 0, 0) ? 1 : 0;
  if (!doctorId || !date || !startTime || !endTime) return fail(res, 400, "BAD_REQUEST", "Thiếu dữ liệu schedule");

  const [result] = await pool.query(
    "INSERT INTO schedules (doctor_id, date, start_time, end_time, is_booked) VALUES (?, ?, ?, ?, ?)",
    [doctorId, date, startTime, endTime, isBooked]
  );
  ok(res, { id: result.insertId });
});

app.put("/schedules/:id", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");
  const doctorId = toInt(req.body?.doctor_id, 0);
  const date = String(req.body?.date ?? "").trim();
  const startTime = String(req.body?.start_time ?? "").trim();
  const endTime = String(req.body?.end_time ?? "").trim();
  const isBooked = toInt(req.body?.is_booked ?? 0, 0) ? 1 : 0;
  await pool.query(
    "UPDATE schedules SET doctor_id=?, date=?, start_time=?, end_time=?, is_booked=? WHERE id=?",
    [doctorId, date, startTime, endTime, isBooked, id]
  );
  ok(res, { id });
});

app.delete("/schedules/:id", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");
  await pool.query("DELETE FROM schedules WHERE id = ?", [id]);
  ok(res, { id });
});

// Appointments
app.get("/appointments", async (req, res) => {
  const userId = toInt(req.query.userId, 0);
  const sql = userId
    ? "SELECT id, user_id, doctor_id, schedule_id, symptom, status, created_at FROM appointments WHERE user_id=? ORDER BY created_at DESC"
    : "SELECT id, user_id, doctor_id, schedule_id, symptom, status, created_at FROM appointments ORDER BY created_at DESC";
  const params = userId ? [userId] : [];
  const [rows] = await pool.query(sql, params);
  ok(res, rows);
});

app.get("/appointments/details", async (req, res) => {
  const userId = toInt(req.query.userId, 0);
  const where = userId ? "WHERE a.user_id=?" : "";
  const params = userId ? [userId] : [];
  const [rows] = await pool.query(
    `
    SELECT 
      a.id, a.user_id, a.doctor_id, a.schedule_id, a.symptom, a.status, a.created_at,
      u.name AS userName,
      d.name AS doctorName,
      d.specialty AS specialty,
      s.date AS date,
      s.start_time AS startTime,
      s.end_time AS endTime
    FROM appointments a
    JOIN users u ON u.id = a.user_id
    JOIN doctors d ON d.id = a.doctor_id
    JOIN schedules s ON s.id = a.schedule_id
    ${where}
    ORDER BY a.created_at DESC
    `,
    params
  );

  const mapped = rows.map((r) => ({
    appointment: {
      id: r.id,
      user_id: r.user_id,
      doctor_id: r.doctor_id,
      schedule_id: r.schedule_id,
      symptom: r.symptom,
      status: r.status,
      created_at: r.created_at,
    },
    userName: r.userName,
    doctorName: r.doctorName,
    specialty: r.specialty,
    date: r.date,
    startTime: r.startTime,
    endTime: r.endTime,
  }));
  ok(res, mapped);
});

app.post("/appointments", async (req, res) => {
  const userId = toInt(req.body?.user_id, 0);
  const doctorId = toInt(req.body?.doctor_id, 0);
  const scheduleId = toInt(req.body?.schedule_id, 0);
  const symptom = String(req.body?.symptom ?? "").trim();
  const status = String(req.body?.status ?? "pending").trim() || "pending";
  const createdAt = String(req.body?.created_at ?? "").trim();
  if (!userId || !doctorId || !scheduleId || !createdAt) return fail(res, 400, "BAD_REQUEST", "Thiếu dữ liệu appointment");

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [srows] = await conn.query("SELECT id, is_booked FROM schedules WHERE id=? FOR UPDATE", [scheduleId]);
    const s = srows?.[0];
    if (!s) {
      await conn.rollback();
      return fail(res, 404, "SCHEDULE_NOT_FOUND", "Schedule không tồn tại");
    }
    if (Number(s.is_booked) === 1) {
      await conn.rollback();
      return fail(res, 409, "SCHEDULE_BOOKED", "Lịch đã được đặt");
    }

    const [result] = await conn.query(
      "INSERT INTO appointments (user_id, doctor_id, schedule_id, symptom, status, created_at) VALUES (?, ?, ?, ?, ?, ?)",
      [userId, doctorId, scheduleId, symptom, status, createdAt]
    );
    await conn.query("UPDATE schedules SET is_booked=1 WHERE id=?", [scheduleId]);
    await conn.commit();
    ok(res, { id: result.insertId });
  } catch (e) {
    await conn.rollback();
    fail(res, 500, "SERVER_ERROR", String(e?.message ?? e));
  } finally {
    conn.release();
  }
});

app.post("/appointments/:id/cancel", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [arows] = await conn.query("SELECT id, schedule_id FROM appointments WHERE id=? FOR UPDATE", [id]);
    const a = arows?.[0];
    if (!a) {
      await conn.rollback();
      return ok(res, { id, noop: true });
    }
    await conn.query("UPDATE appointments SET status='cancelled' WHERE id=?", [id]);
    await conn.query("UPDATE schedules SET is_booked=0 WHERE id=?", [a.schedule_id]);
    await conn.commit();
    ok(res, { id });
  } catch (e) {
    await conn.rollback();
    fail(res, 500, "SERVER_ERROR", String(e?.message ?? e));
  } finally {
    conn.release();
  }
});

app.post("/appointments/:id/confirm", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");
  await pool.query("UPDATE appointments SET status='confirmed' WHERE id=?", [id]);
  ok(res, { id });
});

app.delete("/appointments/:id", async (req, res) => {
  const id = toInt(req.params.id, 0);
  if (!id) return fail(res, 400, "BAD_REQUEST", "Invalid id");

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [arows] = await conn.query("SELECT id, schedule_id FROM appointments WHERE id=? FOR UPDATE", [id]);
    const a = arows?.[0];
    if (!a) {
      await conn.rollback();
      return ok(res, { id, noop: true });
    }
    await conn.query("UPDATE schedules SET is_booked=0 WHERE id=?", [a.schedule_id]);
    await conn.query("DELETE FROM appointments WHERE id=?", [id]);
    await conn.commit();
    ok(res, { id });
  } catch (e) {
    await conn.rollback();
    fail(res, 500, "SERVER_ERROR", String(e?.message ?? e));
  } finally {
    conn.release();
  }
});

// Admin helpers
app.get("/admin/counts", async (_req, res) => {
  const [[u]] = await pool.query("SELECT COUNT(*) AS c FROM users");
  const [[d]] = await pool.query("SELECT COUNT(*) AS c FROM doctors");
  const [[a]] = await pool.query("SELECT COUNT(*) AS c FROM appointments");
  ok(res, { users: Number(u.c), doctors: Number(d.c), appointments: Number(a.c) });
});

app.get("/admin/dashboard", async (req, res) => {
  const rangeDays = Math.max(1, Math.min(90, toInt(req.query.rangeDays, 7)));
  const now = new Date();
  const end = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const start = new Date(end);
  start.setDate(end.getDate() - (rangeDays - 1));

  const [patientsRows] = await pool.query("SELECT COUNT(*) AS c FROM users WHERE role='user'");
  const [doctorRows] = await pool.query("SELECT COUNT(*) AS c FROM doctors");
  const [apptRows] = await pool.query("SELECT status, COUNT(*) AS c FROM appointments GROUP BY status");
  const statusMap = Object.fromEntries(apptRows.map((r) => [r.status, Number(r.c)]));

  const pending = statusMap.pending ?? 0;
  const confirmed = statusMap.confirmed ?? 0;
  const cancelled = statusMap.cancelled ?? 0;
  const scheduledVisits = pending + confirmed + cancelled + (statusMap.other ?? 0);
  const efficiencyRating = (confirmed + cancelled) === 0 ? 0 : (confirmed / (confirmed + cancelled)) * 100;

  const yyyy = (d) => String(d.getFullYear()).padStart(4, "0");
  const mm = (d) => String(d.getMonth() + 1).padStart(2, "0");
  const dd = (d) => String(d.getDate()).padStart(2, "0");
  const key = (d) => `${yyyy(d)}-${mm(d)}-${dd(d)}`;

  const todayKey = key(end);
  const [[slotTotal]] = await pool.query("SELECT COUNT(*) AS c FROM schedules WHERE date=?", [todayKey]);
  const [[slotBooked]] = await pool.query("SELECT COUNT(*) AS c FROM schedules WHERE date=? AND is_booked=1", [todayKey]);
  const occupancyPercent = Number(slotTotal.c) === 0 ? 0 : (Number(slotBooked.c) / Number(slotTotal.c)) * 100;

  const [seriesRows] = await pool.query(
    `
    SELECT SUBSTRING(created_at, 1, 10) AS d, COUNT(*) AS c
    FROM appointments
    WHERE SUBSTRING(created_at, 1, 10) BETWEEN ? AND ?
    GROUP BY SUBSTRING(created_at, 1, 10)
    ORDER BY d ASC
    `,
    [key(start), key(end)]
  );
  const buckets = new Map();
  for (let i = 0; i < rangeDays; i++) {
    const d = new Date(start);
    d.setDate(start.getDate() + i);
    buckets.set(key(d), 0);
  }
  for (const r of seriesRows) buckets.set(String(r.d), Number(r.c));
  const series = Array.from(buckets.entries()).map(([d, c]) => ({ date: d, value: c }));

  // avg wait minutes (pending)
  const [pendingRows] = await pool.query("SELECT created_at FROM appointments WHERE status='pending'");
  let avgWaitMinutes = 0;
  if (pendingRows.length) {
    const nowMs = now.getTime();
    let sum = 0;
    let n = 0;
    for (const r of pendingRows) {
      const t = Date.parse(String(r.created_at));
      if (!Number.isFinite(t)) continue;
      const minutes = Math.max(0, Math.min(600, Math.floor((nowMs - t) / 60000)));
      sum += minutes;
      n++;
    }
    avgWaitMinutes = n ? (sum / n) : 0;
  }

  ok(res, {
    totalPatients: Number(patientsRows[0].c),
    clinicalStaff: Number(doctorRows[0].c),
    scheduledVisits,
    pendingTriage: pending,
    efficiencyRating,
    occupancyPercent,
    avgWaitMinutes,
    series,
    lastSync: new Date().toISOString(),
  });
});

// Schedules helpers for admin UI
app.post("/admin/schedules/grid", async (req, res) => {
  const doctorIds = Array.isArray(req.body?.doctorIds) ? req.body.doctorIds.map((x) => toInt(x, 0)).filter(Boolean) : [];
  const dates = Array.isArray(req.body?.dates) ? req.body.dates.map((x) => String(x ?? "").trim()).filter(Boolean) : [];
  if (!doctorIds.length || !dates.length) return fail(res, 400, "BAD_REQUEST", "Thiếu doctorIds/dates");

  const qs1 = doctorIds.map(() => "?").join(",");
  const qs2 = dates.map(() => "?").join(",");
  const sql =
    `SELECT id, doctor_id, date, start_time, end_time, is_booked FROM schedules ` +
    `WHERE doctor_id IN (${qs1}) AND date IN (${qs2})`;
  const [rows] = await pool.query(sql, [...doctorIds, ...dates]);
  ok(res, rows);
});

app.get("/admin/schedules/month-counts", async (req, res) => {
  const doctorId = toInt(req.query.doctorId, 0);
  const year = toInt(req.query.year, 0);
  const month = toInt(req.query.month, 0); // 1..12
  if (!doctorId || !year || month < 1 || month > 12) return fail(res, 400, "BAD_REQUEST", "Thiếu doctorId/year/month");

  const pad2 = (n) => String(n).padStart(2, "0");
  const first = `${String(year).padStart(4, "0")}-${pad2(month)}-01`;
  const nextMonth = month === 12 ? `${String(year + 1).padStart(4, "0")}-01-01` : `${String(year).padStart(4, "0")}-${pad2(month + 1)}-01`;
  const [rows] = await pool.query(
    `
    SELECT date,
           COUNT(*) AS total,
           SUM(CASE WHEN is_booked=1 THEN 1 ELSE 0 END) AS booked
    FROM schedules
    WHERE doctor_id=? AND date >= ? AND date < ?
    GROUP BY date
    `,
    [doctorId, first, nextMonth]
  );
  ok(res, rows.map((r) => ({ date: r.date, total: Number(r.total), booked: Number(r.booked) })));
});

app.post("/admin/schedules/bulk-set", async (req, res) => {
  const doctorId = toInt(req.body?.doctor_id, 0);
  const date = String(req.body?.date ?? "").trim();
  const shifts = Array.isArray(req.body?.shifts) ? req.body.shifts : [];
  if (!doctorId || !date) return fail(res, 400, "BAD_REQUEST", "Thiếu doctor_id/date");

  const desired = new Set(
    shifts
      .map((s) => ({
        start: String(s?.start_time ?? "").trim(),
        end: String(s?.end_time ?? "").trim(),
      }))
      .filter((s) => s.start && s.end)
      .map((s) => `${s.start}-${s.end}`)
  );

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const [existing] = await conn.query(
      "SELECT id, start_time, end_time, is_booked FROM schedules WHERE doctor_id=? AND date=? FOR UPDATE",
      [doctorId, date]
    );
    const existingByKey = new Map(existing.map((r) => [`${r.start_time}-${r.end_time}`, r]));

    // insert missing
    for (const k of desired) {
      if (existingByKey.has(k)) continue;
      const [start_time, end_time] = k.split("-");
      await conn.query(
        "INSERT INTO schedules (doctor_id, date, start_time, end_time, is_booked) VALUES (?, ?, ?, ?, 0)",
        [doctorId, date, start_time, end_time]
      );
    }

    // delete removed (only if not booked)
    for (const [k, r] of existingByKey.entries()) {
      if (desired.has(k)) continue;
      if (Number(r.is_booked) === 1) continue;
      await conn.query("DELETE FROM schedules WHERE id=?", [r.id]);
    }

    await conn.commit();
    ok(res, { ok: true });
  } catch (e) {
    await conn.rollback();
    fail(res, 500, "SERVER_ERROR", String(e?.message ?? e));
  } finally {
    conn.release();
  }
});

const port = Number(process.env.PORT ?? "3000");
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`API listening on :${port}`);
});

