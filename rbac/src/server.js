require('dotenv').config();
const app = require('./app');
const { pool } = require('./lib/db');

const port = Number(process.env.PORT || 3000);

async function start() {
  try {
    await pool.query('SELECT 1');
    app.listen(port, () => {
      // eslint-disable-next-line no-console
      console.log(`RBAC API listening on port ${port}`);
    });
  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('Failed to connect to database:', err.message);
    process.exit(1);
  }
}

start();
