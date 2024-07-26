require('dotenv').config();
const pool = require('../utils/database');

exports.insertIntime = (req, res) => {
  const { companyID, empcode, exactdate, intime, location } = req.body;
  const insertSql = `
    INSERT INTO tbl_attendance_login_logout (companyid, empcode, exactdate, intime, outtime, location) 
    VALUES (@companyID, @empcode, @exactdate, @intime, NULL, @location)
  `;
  pool.request()
    .input('companyID', companyID)
    .input('empcode', empcode)
    .input('exactdate', exactdate)
    .input('intime', intime)
    .input('location', location)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting attendance record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting attendance record' });
      }
      res.status(200).json({ message: 'Attendance record inserted successfully' });
    });
};

exports.updateOuttime = (req, res) => {
  const { companyID, empcode, exactdate, outtime } = req.body;
  const updateSql = `
    UPDATE tbl_attendance_login_logout
    SET outtime = @outtime
    WHERE companyid = @companyID AND empcode = @empcode AND exactdate = @exactdate
  `;
  pool.request()
    .input('companyID', companyID)
    .input('empcode', empcode)
    .input('exactdate', exactdate)
    .input('outtime', outtime)
    .query(updateSql, (updateErr, updateResult) => {
      if (updateErr) {
        console.error('Error updating outtime: ', updateErr);
        return res.status(500).json({ message: 'Error updating outtime' });
      }
      res.status(200).json({ message: 'Outtime updated successfully' });
    });
};


exports.fetchAttendance = (req, res) => {
  const { empcode, startDate, endDate } = req.body;

  const fetchSql = `
    SELECT CONVERT(VARCHAR, exactdate, 23) AS date, intime, outtime, exactdate
    FROM tbl_attendance_login_logout
    WHERE empcode = @empcode
      AND exactdate BETWEEN @startDate AND @endDate
    ORDER BY exactdate ASC
  `;

  pool.request()
    .input('empcode', empcode)
    .input('startDate', startDate)
    .input('endDate', endDate)
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


exports.fetchAllAttendance = (req, res) => {
  const fetchSql = `
  DECLARE @Today DATE = CONVERT(DATE, GETDATE());

  SELECT e.emp_fname, a.intime, a.outtime, CONVERT(VARCHAR, a.exactdate, 23) AS date
  FROM tbl_intranet_employee_jobDetails e
  LEFT JOIN tbl_attendance_login_logout a ON e.empcode = a.empcode 
    AND CONVERT(DATE, a.exactdate) = @Today
  ORDER BY e.empcode ASC, a.exactdate ASC
  OFFSET 3 ROWS;
`;

  pool.request()
    .input('startDate',  req.body.startDate)
    .input('endDate',  req.body.endDate)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching attendance records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching attendance records' });
      }

      const attendanceRecords = fetchResult.recordset.map(record => ({
        name: record.emp_fname,
        date: record.date,
        intime: record.intime,
        outtime: record.outtime,
        status: record.intime ? 'Present' : 'Absent'
      }));

      res.status(200).json({ attendanceRecords });
    });
};


