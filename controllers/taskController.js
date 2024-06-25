require('dotenv').config();
const pool = require('../utils/database');

exports.insertTask = (req, res) => {
  const { 
 project, task_name, dept, create_date, end_date, descr , created_by, status, empcode
  } = req.body;
  
  const insertSql = `
  INSERT INTO tbl_timesheet_task_master (
     project, task_name, dept, create_date, end_date, descr, created_by, status, empcode
  ) 
  VALUES (
     @project, @task_name, @dept, CONVERT(date, @create_date, 23), @end_date, @descr, @created_by, @status, @empcode
  )
  `;

  pool.request()
    .input('project', project)
    .input('task_name', task_name)
    .input('create_date', create_date)
    .input('dept', dept)
    .input('end_date', end_date)
    .input('descr', descr)
    .input('created_by', created_by)
    .input('status', status)
    .input('empcode', empcode)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting task record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting task record' });
      }
      res.status(200).json({ message: 'Task record inserted successfully' });
    });
};
