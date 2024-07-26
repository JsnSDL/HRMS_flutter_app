require('dotenv').config();
const pool = require('../utils/database');

exports.fetchNotification = (req, res) => {
  const { empcode } = req.body;

  const fetchSql = `
    SELECT jobDetails.emp_fname, personalDetails.dob, jobDetails.empcode
    FROM tbl_intranet_employee_personalDetails AS personalDetails
    JOIN tbl_intranet_employee_jobDetails AS jobDetails
    ON personalDetails.empcode = jobDetails.empcode
    WHERE 
      DATEPART(day, personalDetails.dob) = DATEPART(day, GETDATE())
      AND DATEPART(month, personalDetails.dob) = DATEPART(month, GETDATE())
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching dob records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching dob records' });
      }

      const dobRecords = fetchResult.recordset.map(record => ({
        name: record.emp_fname,
        dob: record.dob,
        empcode: record.empcode,
      }));

      res.status(200).json({ dobRecords });
    });
};


exports.insertBirthdayWish = (req, res) => {
    const { empcode, fName, createdDate, receiverEmpcode, receiverFName, receiverWish } = req.body;

    const insertSql = `
        INSERT INTO tbl_birthday_wishes (empcode, f_name, created_date, receiver_empcode, receiver_f_name, receiver_wish)
        VALUES (@empcode, @fName, @createdDate, @receiverEmpcode, @receiverFName, @receiverWish)
    `;

    pool.request()
        .input('empcode', empcode)
        .input('fName', fName)
        .input('createdDate', createdDate)
        .input('receiverEmpcode', receiverEmpcode)
        .input('receiverFName', receiverFName)
        .input('receiverWish', receiverWish)
        .query(insertSql, (insertErr, insertResult) => {
            if (insertErr) {
                console.error('Error inserting birthday wishes record: ', insertErr);
                return res.status(500).json({ message: 'Error inserting wishes record' });
            }
            res.status(200).json({ message: 'Wishes record inserted successfully' });
        });
};

exports.fetchWishNotification = (req, res) => {
  const { receiver_empcode } = req.body;

  const fetchSql = `
    SELECT *
    FROM tbl_birthday_wishes
    WHERE receiver_empcode = @receiver_empcode
    ORDER BY created_date DESC`;

  pool.request()
    .input('receiver_empcode', receiver_empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching birthday wishes: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching birthday wishes' });
      }

      const birthdayWishes = fetchResult.recordset.map(record => ({
        empcode: record.empcode,
        senderName: record.f_name,
        createdDate: record.created_date,
        receiverEmpcode: record.receiver_empcode,
        receiverName: record.receiver_f_name,
        receiverWish: record.receiver_wish,
      }));

      res.status(200).json({ birthdayWishes });
    });
};



exports.checkNotification = (req, res) => {
  const { receiver_empcode } = req.body;

  // Get today's date in YYYY-MM-DD format
  const todayDate = new Date().toISOString().split('T')[0];
  
  const fetchSql = `
    SELECT COUNT(*) AS notificationCount
    FROM tbl_birthday_wishes
    WHERE receiver_empcode = @receiver_empcode
    AND CONVERT(date, created_date) = @todayDate
    `;
  
  pool.request()
    .input('receiver_empcode', receiver_empcode)
    .input('todayDate', todayDate)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching notification count: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching notification count' });
      }
  
      const { notificationCount } = fetchResult.recordset[0]; // Assuming there's only one result
  
      res.status(200).json({ notificationCount });
    });
  
};


