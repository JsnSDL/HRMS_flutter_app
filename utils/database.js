
require('dotenv').config();
const sql = require('mssql/msnodesqlv8');

// Read environment variables
const dbName = process.env.DB_NAME;
const dbHost = process.env.DB_HOST;

// Construct the connection string using the environment variables
const connectionString = `Driver={SQL Server};Server=${dbHost};Database=${dbName};Trusted_Connection=Yes;`;

const dbSettings = {
  connectionString: connectionString,
};

// Create a SQL Server pool
const pool = new sql.ConnectionPool(dbSettings);

// Connect to SQL Server
pool.connect(err => {
  if (err) {
    console.error('Error connecting to database:', err.message);
    console.error('Connection settings:', dbSettings);
    return;
  }
  console.log('Connected to SQL Server database');
});

pool.on('error', err => {
  console.error('SQL Pool Error:', err.message);
});

module.exports = pool;
