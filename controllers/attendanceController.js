require('dotenv').config();
const pool = require('../utils/database');

exports.insertIntime = (req,res) => {
  const {companyID, empcode, exactdate, intime, outtime, location} = req.body;
  const insertSql = 'INSERT INTO tbl_attendance_login_logout (companyid, empcode, exactdate, intime,outtime, location) VALUES (@companyID, @empcode, @exactdate, @intime, @outtime, @location)';
  pool.request()
    .input('companyID', companyID)
    .input('empcode', empcode)
    .input('exactdate', exactdate)
    .input('intime', intime)
    .input('outtime', outtime)
    .input('location',location)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting attendance record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting attendance record' });
      }
      res.status(200).json({ message: 'Attendance record inserted successfully' });
    });
};

exports.fetchAttendance = (req, res) => {
  const { empcode } = req.body;

  const fetchSql = `
    SELECT CONVERT(VARCHAR, exactdate, 23) AS date, intime, outtime, exactdate
    FROM tbl_attendance_login_logout
    WHERE empcode = @empcode
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching attendance records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching attendance records' });
      }

      const attendanceRecords = fetchResult.recordset.map(record => ({
        date: record.date,
        intime: record.intime,
        outtime: record.outtime,
        exactdate: record.exactdate
      }));

      res.status(200).json({ attendanceRecords });
    });
};
