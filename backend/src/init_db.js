import fs from "node:fs";
import path from "node:path";
import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

function requiredEnv(name, fallback) {
  const v = process.env[name] ?? fallback;
  if (v === undefined || v === null || String(v).trim() === "") {
    throw new Error(`Missing env ${name}`);
  }
  return String(v);
}

async function main() {
  const host = requiredEnv("MYSQL_HOST", "localhost");
  const port = Number(process.env.MYSQL_PORT ?? "3306");
  const user = requiredEnv("MYSQL_USER", "root");
  const password = String(process.env.MYSQL_PASSWORD ?? "");
  const database = requiredEnv("MYSQL_DATABASE", "clinic_booking");

  const schemaPath = path.resolve(process.cwd(), "schema.sql");
  const sql = fs.readFileSync(schemaPath, "utf8");

  const conn = await mysql.createConnection({
    host,
    port,
    user,
    password,
    multipleStatements: true,
    charset: "utf8mb4",
  });

  try {
    await conn.query(
      `CREATE DATABASE IF NOT EXISTS \`${database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
    );
    await conn.query(`USE \`${database}\`;`);

    // chạy schema + seed (idempotent nhờ IF NOT EXISTS / INSERT IGNORE)
    await conn.query(sql);

    // eslint-disable-next-line no-console
    console.log("Init MySQL OK");
  } finally {
    await conn.end();
  }
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error("Init MySQL FAILED:", e?.message ?? e);
  process.exit(1);
});

