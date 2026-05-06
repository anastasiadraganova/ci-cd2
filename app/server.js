const express = require("express");
const { Pool } = require("pg");

const app = express();
app.use(express.json());

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT || 5432),
  database: process.env.DB_NAME || "lab6_db",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres"
});

pool
  .query("SELECT 1")
  .then(() => console.log("DB connection successful"))
  .catch((err) => console.error("DB connection failed:", err.message));

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

app.get("/api/items", async (_req, res) => {
  try {
    const { rows } = await pool.query(
      "SELECT id, name, created_at FROM items ORDER BY id ASC"
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch items", detail: err.message });
  }
});

app.post("/api/items", async (req, res) => {
  const { name } = req.body || {};
  if (!name || typeof name !== "string") {
    return res.status(400).json({ error: "name is required" });
  }
  try {
    const { rows } = await pool.query(
      "INSERT INTO items (name) VALUES ($1) RETURNING id, name, created_at",
      [name]
    );
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: "Failed to create item", detail: err.message });
  }
});

const port = Number(process.env.PORT || 3000);
// ✅ ВАЖНО: '0.0.0.0' чтобы слушать все интерфейсы внутри Docker
app.listen(port, '0.0.0.0', () => console.log(`Server listening on port ${port}`));