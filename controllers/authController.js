require('dotenv').config();
const pool = require('../utils/database');
const bcrypt = require('bcrypt');
const jwt = require("jsonwebtoken");

// Login controller
exports.login = (req, res) => { 
  const { userID ,password } = req.body;

  if (!userID || !password) {
    return res.status(400).json({ message: 'Both userID and password are required' });
  }
 
  const sql = 'SELECT * FROM tbl_login WHERE empcode = @userID';

  pool.request()
    .input('userID', userID)
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      if (results.recordset.length > 0) {
        const dbPasswordHash = results.recordset[0].pwd;
        const role = results.recordset[0].role; 
        bcrypt.compare(password, dbPasswordHash).then((isMatch) => {
          if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
          }
          const token = jwt.sign({ userID: userID.toString() }, process.env.TOKEN_SECRET, { expiresIn: "24h" });
          res.status(200).json({ token: token, userID: userID.toString(), role:role });
        }).catch((err) => {
          console.error('Error comparing passwords: ', err);
          return res.status(500).json({ message: 'Error comparing passwords' });
        });
      } else {
        return res.status(401).json({ message: 'Invalid credentials' });
      }
    });
};

exports.getUser = (req, res) => {
  const { empcode } = req.body;

  if (!empcode) {
    return res.status(400).json({ message: 'empcode is required' });
  }

  const sql = 'SELECT * FROM tbl_intranet_employee_jobDetails WHERE empcode = @empcode';

  pool.request()
    .input('empcode', empcode)
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      if (results.recordset.length > 0) {
        const empName = results.recordset[0].emp_fname;
        const official_email_id = results.recordset[0].official_email_id;
        const official_mob_no = results.recordset[0].official_mob_no;
        const emp_gender = results.recordset[0].emp_gender;
        return res.status(200).json({ empName: empName , email:official_email_id, mobile:official_mob_no, gender:emp_gender});
      } else {
        return res.status(404).json({ message: 'Employee not found' });
      }
    });
};

exports.editUser = (req, res) => {
  const {
    empcode,
    userName, 
    email,
    mobile,
    gender,
  } = req.body;

  const editSql = `
    UPDATE dbo.tbl_intranet_employee_jobDetails
    SET 
      emp_gender = @emp_gender,
      emp_fname = @emp_fname,
      official_email_id = @official_email_id,
      official_mob_no = @official_mob_no
    WHERE empcode = @empcode;
  `;

  pool.request()
    .input('empcode', empcode)
    .input('emp_gender', gender)
    .input('emp_fname', userName)
    .input('official_email_id', email)
    .input('official_mob_no', mobile)
    .query(editSql, (editErr, editResult) => {
      if (editErr) {
        console.error('Error updating user record:', editErr);
        return res.status(500).json({ message: 'Error editing user record' });
      }
      console.log('Rows affected:', editResult.rowsAffected); 
      res.status(200).json({ message: 'User record edited successfully' });
    });
};
