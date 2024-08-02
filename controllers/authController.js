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
          const token = jwt.sign({ userID: userID.toString() }, process.env.TOKEN_SECRET, { expiresIn:"168h"});
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

const baseUrl = 'http://192.168.1.5:3000/images/';
exports.getUser = (req, res) => {
  const { empcode } = req.body;

  if (!empcode) {
    return res.status(400).json({ message: 'empcode is required' });
  }

  const sql = `
    SELECT 
      ejd.empcode,
      ejd.emp_fname, 
      ejd.official_email_id, 
      ejd.official_mob_no, 
      ejd.emp_gender, 
      ejd.photo,
      des.designationname
    FROM tbl_intranet_employee_jobDetails ejd
    JOIN tbl_intranet_designation des ON ejd.degination_id = des.id
    WHERE ejd.empcode = @empcode
  `;

  pool.request()
    .input('empcode', empcode)
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      if (results.recordset.length > 0) {
        const empName = results.recordset[0].emp_fname;
        const empCode = results.recordset[0].empcode.trim();
        const official_email_id = results.recordset[0].official_email_id;
        const official_mob_no = results.recordset[0].official_mob_no;
        const emp_gender = results.recordset[0].emp_gender;
        const photo = results.recordset[0].photo ? baseUrl + results.recordset[0].photo : null;
        const designationname = results.recordset[0].designationname;
        return res.status(200).json({ empName, empCode, email: official_email_id, mobile: official_mob_no, gender: emp_gender, designation: designationname,photo});
      } else {
        return res.status(404).json({ message: 'Employee not found' });
      }
    });
};

exports.getAllUser = (req, res) => {
  const sql = `
    SELECT 
      ejd.emp_fname,
      ejd.empcode, 
      des.designationname,
      ejd.photo
    FROM tbl_intranet_employee_jobDetails ejd
    JOIN tbl_intranet_designation des ON ejd.degination_id = des.id
  `;

  pool.request()
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      return res.status(200).json(results.recordset);
    });
};

exports.getAllUserTask = (req, res) => {
  const sql = `
    SELECT 
      ejd.empcode,
      ejd.emp_fname, 
      des.designationname
    FROM tbl_intranet_employee_jobDetails ejd
    JOIN tbl_intranet_designation des ON ejd.degination_id = des.id
    ORDER BY ejd.empcode ASC, des.designationname ASC
    OFFSET 3 ROWS
  `;

  pool.request()
    .query(sql, (err, results) => {
      if (err) {
        console.error('Error executing query: ', err);
        return res.status(500).json({ message: 'Internal server error' });
      }
      console.log(results.recordset);
      return res.status(200).json(results.recordset);
      
    });
};

