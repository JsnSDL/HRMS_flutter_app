require('dotenv').config();
const pool = require('../utils/database');

exports.insertLeave = (req, res) => {
  const { 
    company_id, 
    empcode, 
    leaveid, 
    leavemode, 
    reason, 
    fromdate, 
    todate, 
    half, 
    no_of_days,
    leave_adjusted,
    approvel_status,
    leave_status,
    flag,
    status,
    createddate,
    createdby,
    modifieddate,
    modifiedby,
  } = req.body;

  console.log(fromdate,todate);
  
  const insertSql = `
  INSERT INTO tbl_leave_apply_leave (
    company_id, 
    empcode, 
    leaveid, 
    leavemode, 
    reason, 
    fromdate, 
    todate, 
    half, 
    no_of_days,
    leave_adjusted,
    approvel_status,
    leave_status,
    flag,
    status,
    createddate,
    createdby,
    modifieddate,
    modifiedby
  ) 
  VALUES (
    @company_id, 
    @empcode, 
    @leaveid, 
    @leavemode, 
    @reason, 
    @fromdate, 
    @todate, 
    @half, 
    @no_of_days,
    @leave_adjusted,
    @approvel_status,
    @leave_status,
    @flag,
    @status,
    @createddate,
    @createdby,
    @modifieddate,
    @modifiedby
  )
  
  `;

  pool.request()
    .input('company_id', company_id)
    .input('empcode', empcode)
    .input('leaveid', leaveid)
    .input('leavemode', leavemode)
    .input('reason', reason)
    .input('fromdate', fromdate)
    .input('todate', todate)
    .input('half', half)
    .input('no_of_days',no_of_days)
    .input('leave_adjusted', leave_adjusted)
    .input('approvel_status', approvel_status)
    .input('leave_status', leave_status)
    .input('flag', flag)
    .input('status', status)
    .input('createddate', createddate)
    .input('createdby', createdby)
    .input('modifieddate', modifieddate)
    .input('modifiedby', modifiedby)
    .query(insertSql, (insertErr, insertResult) => {
      if (insertErr) {
        console.error('Error inserting leave record: ', insertErr);
        return res.status(500).json({ message: 'Error inserting leave record' });
      }
      res.status(200).json({ message: 'Leave record inserted successfully' });
    });
};

exports.checkLeaveExists = (req, res) => {
  const { company_id, empcode, fromdate, createddate } = req.body;

  const checkSql = `
    SELECT * FROM tbl_leave_apply_leave
    WHERE company_id = @company_id AND empcode = @empcode AND (fromdate = @fromdate OR createddate = @createddate)
  `;

  pool.request()
    .input('company_id', company_id)
    .input('empcode', empcode)
    .input('fromdate', fromdate)
    .input('createddate', createddate)
    .query(checkSql, (checkErr, checkResult) => {
      if (checkErr) {
        console.error('Error checking leave record: ', checkErr);
        return res.status(500).json({ message: 'Error checking leave record' });
      }
      if (checkResult.recordset.length > 0 && checkResult.recordset[0].no_of_days != 18) {
        res.status(200).json({ exists: true });
      } else {
        res.status(200).json({ exists: false });
      }
    });
};

exports.checkRemainLeave = (req, res) => {
  const { company_id, empcode} = req.body;

  const checkSql = `
    SELECT * FROM tbl_leave_apply_leave
    WHERE company_id = @company_id AND empcode = @empcode 
  `;

  pool.request()
    .input('company_id', company_id)
    .input('empcode', empcode)
    .query(checkSql, (checkErr, checkResult) => {
      // console.log(checkResult);
      if (checkErr) {
        console.error('Error checking leave record: ', checkErr);
        return res.status(500).json({ message: 'Error checking leave record' });
      }
      if (checkResult.recordset.length > 0) {
        res.status(200).json({ days:checkResult.recordset[0].no_of_days});
      } else {
        res.status(200).json({ exists: false });
      }
    });
};

exports.fetchLeave = (req, res) => {
  const { empcode } = req.body; 

  const fetchSql = `
    SELECT id, leaveid, fromdate, todate, createddate, approvel_status, leave_status, reason
    FROM tbl_leave_apply_leave
    WHERE empcode = @empcode
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }
      const leaveRecords = fetchResult.recordset.map(record => ({
        id:record.id,
        leaveType: record.leaveid,
        fromdate: record.fromdate,
        todate: record.todate,
        createddate: record.createddate,
        reason: record.reason,
        approvel_status: record.approvel_status ? 'Approved' : 'Pending',
        leave_status: record.leave_status,
      }));
      res.status(200).json({ leaveRecords });
    });
};

exports.editLeave = (req, res) => {
  const {
    id,
    empcode,
    leaveid,
    leavemode,
    reason,
    fromdate,
    todate,
    half,
    no_of_days,
    leave_adjusted,
    approvel_status,
    leave_status,
  } = req.body;

  const updateSql = `
    UPDATE tbl_leave_apply_leave 
    SET 
      leaveid = @leaveid, 
      leavemode = @leavemode, 
      reason = @reason, 
      fromdate = @fromdate, 
      todate = @todate, 
      half = @half, 
      no_of_days = @no_of_days,
      leave_adjusted = @leave_adjusted,
      approvel_status = @approvel_status,
      leave_status = @leave_status
    WHERE 
     id= @id and empcode = @empcode
  `;

  pool.request()
    .input('id',id)
    .input('empcode', empcode)
    .input('leaveid', leaveid)
    .input('leavemode', leavemode)
    .input('reason', reason)
    .input('fromdate', fromdate)
    .input('todate', todate)
    .input('half', half)
    .input('no_of_days', no_of_days)
    .input('leave_adjusted', leave_adjusted)
    .input('approvel_status', approvel_status)
    .input('leave_status', leave_status)
    .query(updateSql, (editErr, editResult) => {
      if (editErr) {
        console.error('Error updating leave record: ', editErr);
        return res.status(500).json({ message: 'Error editing leave record' });
      }
      res.status(200).json({ message: 'Leave record edited successfully' });
    });
};

exports.leaveToApprove =(req,res)=>{
  const { empcode } = req.body; 

  const fetchSql = `
  SELECT empcode, leaveid, fromdate, todate, createddate, approvel_status, leave_status
  FROM tbl_leave_apply_leave
  WHERE approvel_status = 0 and leave_status != 3
  `;

  pool.request()
    .input('empcode', empcode)
    .query(fetchSql, (fetchErr, fetchResult) => {
      if (fetchErr) {
        console.error('Error fetching leave records: ', fetchErr);
        return res.status(500).json({ message: 'Error fetching leave records' });
      }

      const leaveRecords = fetchResult.recordset.map(record => ({
        empcode:record.empcode,
        leaveType: record.leaveid,
        leaveid:record.leaveid,
        fromdate: record.fromdate,
        todate: record.todate,
        createddate: record.createddate,
        approvel_status: record.approvel_status ? 'Approved' : 'Pending',
        leave_status:record.leave_status 
      }));
      res.status(200).json({ leaveRecords });
    });
}


exports.leaveApprove = (req, res) => {
  const { leaveid, empcode, approve } = req.body;
  const approvalStatus = approve ? 1 : 0;
  const leaveStatus = approve ? 6 : 3; 

  const updateSql = `
    UPDATE tbl_leave_apply_leave
    SET approvel_status = @approvalStatus, leave_status = @leaveStatus
    WHERE leaveid = @leaveid AND empcode = @empcode
  `;

  pool.request()
    .input('leaveid', leaveid)
    .input('empcode', empcode)
    .input('approvalStatus', approvalStatus)
    .input('leaveStatus', leaveStatus)
    .query(updateSql, (updateErr, updateResult) => {
      if (updateErr) {
        console.error('Error updating leave record: ', updateErr);
        return res.status(500).json({ message: 'Error updating leave record', error: updateErr });
      }

      res.status(200).json({ message: 'Leave record updated successfully' });
    });
};


