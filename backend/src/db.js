import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

export function getPool() {
  const host = process.env.MYSQL_HOST ?? "localhost";
  const port = Number(process.env.MYSQL_PORT ?? "3306");
  const user = process.env.MYSQL_USER ?? "root";
  const password = process.env.MYSQL_PASSWORD ?? "";
  const database = process.env.MYSQL_DATABASE ?? "clinic_booking";

  return mysql.createPool({
    host,
    port,
    user,
    password,
    database,
    connectionLimit: 10,
    charset: "utf8mb4",
  });
}

