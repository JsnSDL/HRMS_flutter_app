require('dotenv').config();
const pool = require('../utils/database');
const emailController = require('./mailController');
const { format, parseISO, getDay, getDate } = require('date-fns');


const isSecondOrFourthSaturday = (date) => {
  const dayOfWeek = getDay(date); // 0 (Sunday) to 6 (Saturday)
  const weekOfMonth = Math.floor((getDate(date) - 1) / 7) + 1;
  return dayOfWeek === 6 && (weekOfMonth === 2 || weekOfMonth === 4);
};

const isSunday = (date) => {
  return getDay(date) === 0;
};


exports.insertLeave = async (req, res) => {
  const {
    company_id, empcode, leaveid, leavemode, reason, fromdate, todate, half, shift, no_of_days, leave_adjusted,
    approvel_status, leave_status, flag, status, createddate, createdby, modifieddate, modifiedby
  } = req.body;

  try {
    const startDate = parseISO(fromdate);
    const endDate = parseISO(todate);

    // Validate dates
    if (isSunday(startDate) || isSunday(endDate) || isSecondOrFourthSaturday(startDate) || isSecondOrFourthSaturday(endDate)) {
      return res.status(400).json({ message: 'Leave cannot be applied on the second and fourth Saturday and on Sunday' });
    }

    // Check if the dates are holidays
    const holidaySql = `
      SELECT date FROM tbl_leave_holiday
      WHERE date IN (@fromdate, @todate)
    `;
    const holidayResult = await pool.request()
      .input('fromdate', fromdate)
      .input('todate', todate)
      .query(holidaySql);

    if (holidayResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Leave cannot be applied on holidays' });
    }

    // Check for overlapping leave
    const checkSql = `
      SELECT * FROM tbl_leave_apply_leave
      WHERE company_id = @company_id 
      AND empcode = @empcode 
      AND ((@fromdate >= fromdate AND @fromdate <= todate) OR (@todate >= fromdate AND @todate <= todate))
    `;
    const checkResult = await pool.request()
      .input('company_id', company_id)
      .input('empcode', empcode)
      .input('fromdate', fromdate)
      .input('todate', todate)
      .query(checkSql);

    const overlappingLeave = checkResult.recordset.find(leave => {
      const leaveFromDate = new Date(leave.fromdate);
      const leaveToDate = new Date(leave.todate);
      const newFromDate = new Date(fromdate);
      const newToDate = new Date(todate);

      return (
        (newFromDate >= leaveFromDate && newFromDate <= leaveToDate) ||
        (newToDate >= leaveFromDate && newToDate <= leaveToDate)
      );
    });

    if (overlappingLeave) {
      return res.status(400).json({ message: 'Leave dates overlap with existing leave' });
    }

    // Check leave balance
    let leaveData = {
      1: { total: 0, used: 0 }, // Loss of Pay (No limit)
      2: { total: 6.0, used: 0 }, // Sick Leave
      3: { total: 12.0, used: 0 } // Earned/Casual Leave
    };

    checkResult.recordset.forEach(record => {
      leaveData[record.leaveid].used += record.no_of_days || 0;
    });

    if (leaveid !== 1 && (leaveData[leaveid].used + no_of_days > leaveData[leaveid].total)) {
      let leaveType = leaveid === 2 ? 'Sick Leave' : 'Earned/Casual Leave';
      return res.status(400).json({ message: `${leaveType} balance is insufficient` });
    }

    // Insert leave record
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
        shift,
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
        @shift, 
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
    await pool.request()
      .input('company_id', company_id)
      .input('empcode', empcode)
      .input('leaveid', leaveid)
      .input('leavemode', leavemode)
      .input('reason', reason)
      .input('fromdate', fromdate)
      .input('todate', todate)
      .input('half', half)
      .input('shift',shift)
      .input('no_of_days', no_of_days)
      .input('leave_adjusted', leave_adjusted)
      .input('approvel_status', approvel_status)
      .input('leave_status', leave_status)
      .input('flag', flag)
      .input('status', status)
      .input('createddate', createddate)
      .input('createdby', createdby)
      .input('modifieddate', modifieddate)
      .input('modifiedby', modifiedby)
      .query(insertSql);

    // Fetch employee details
    const sql = `
      SELECT 
        ejd.empcode,
        ejd.emp_fname, 
        ejd.official_email_id
      FROM tbl_intranet_employee_jobDetails ejd
      JOIN tbl_intranet_designation des ON ejd.degination_id = des.id
      WHERE ejd.empcode = @empcode
    `;
    const userResult = await pool.request()
      .input('empcode', empcode)
      .query(sql);

    if (userResult.recordset.length > 0) {
      const empName = userResult.recordset[0].emp_fname;
      const official_email_id = userResult.recordset[0].official_email_id;
      emailController.sendLeaveApplicationEmails(empName, official_email_id, fromdate, todate);
      return res.status(200).json({ message: 'Leave record inserted successfully and email sent' });
    } else {
      return res.status(404).json({ message: 'Employee not found' });
    }

  } catch (error) {
    console.error('Error processing leave application: ', error);
    return res.status(error.status || 500).json({ message: error.message || 'Internal server error' });
  }
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
  const { company_id, empcode } = req.body;

  const checkSql = `
    SELECT leaveid, SUM(no_of_days) AS days_used
    FROM tbl_leave_apply_leave
    WHERE company_id = @company_id AND empcode = @empcode AND approvel_status = 1
    GROUP BY leaveid
  `;

  const probationSql = `
    SELECT probationenddate 
    FROM tbl_intranet_employee_jobDetails 
    WHERE empcode = @empcode
  `;

  pool.request()
    .input('empcode', empcode)
    .query(probationSql, (probErr, probResult) => {
      if (probErr) {
        console.error('Error checking probation end date: ', probErr);
        return res.status(500).json({ message: 'Error checking probation end date' });
      }
      
      const probationEndDate = probResult.recordset[0]?.probationenddate;
      pool.request()
        .input('company_id', company_id)
        .input('empcode', empcode)
        .query(checkSql, (checkErr, checkResult) => {
          if (checkErr) {
            console.error('Error checking leave record: ', checkErr);
            return res.status(500).json({ message: 'Error checking leave record' });
          }
          
          let leaveData = {
            1: { total: 0, used: 0 }, 
            2: { total: 6.0, used: 0 }, 
            3: { total: 12.0, used: 0 } 
          };
          
          checkResult.recordset.forEach(record => {
            leaveData[record.leaveid].used = record.days_used || 0;
          });
          
          let isEligibleForOtherLeaves = !probationEndDate;

          res.status(200).json({ leaveData, isEligibleForOtherLeaves });
        });
    });
};


exports.fetchLeave = (req, res) => {
  const { empcode } = req.body; 

  const fetchSql = `
    SELECT id, leaveid, fromdate, todate, createddate, approvel_status, leave_status, reason, no_of_days, half, shift
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
        half:record.half,
        shift:record.shift,
        fromdate: record.fromdate,
        todate: record.todate,
        createddate: record.createddate,
        reason: record.reason,
        approvel_status: record.approvel_status ? 'Approved' : 'Pending',
        leave_status: record.leave_status,
        no_of_days: record.no_of_days
      }));
      res.status(200).json({ leaveRecords });
    });
};

exports.editLeave = async (req, res) => {
  const {
    id,
    empcode,
    leaveid,
    leavemode,
    reason,
    fromdate,
    todate,
    half,
    shift,
    no_of_days,
  } = req.body;

  try {
    const startDate = parseISO(fromdate);
    const endDate = parseISO(todate);

    // Validate dates
    if (isSunday(startDate) || isSunday(endDate) || isSecondOrFourthSaturday(startDate) || isSecondOrFourthSaturday(endDate)) {
      return res.status(400).json({ message: 'Leave cannot be applied on the second and fourth Saturday and on Sunday' });
    }

    // Check if the dates are holidays
    const holidaySql = `
      SELECT date FROM tbl_leave_holiday
      WHERE date IN (@fromdate, @todate)
    `;
    const holidayResult = await pool.request()
      .input('fromdate', fromdate)
      .input('todate', todate)
      .query(holidaySql);

    if (holidayResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Leave cannot be applied on holidays' });
    }

    // Check for overlapping leave
    const overlapCheckSql = `
      SELECT id
      FROM tbl_leave_apply_leave
      WHERE empcode = @empcode
        AND id != @id
        AND ((@fromdate >= fromdate AND @fromdate <= todate)
             OR (@todate >= fromdate AND @todate <= todate))
    `;
    const overlapResult = await pool.request()
      .input('empcode', empcode)
      .input('id', id)
      .input('fromdate', fromdate)
      .input('todate', todate)
      .query(overlapCheckSql);

    if (overlapResult.recordset.length > 0) {
      return res.status(400).json({ message: 'Leave dates overlap with existing leave' });
    }

    // Check leave balance
    const checkSql = `
      SELECT leaveid, SUM(no_of_days) AS days_used
      FROM tbl_leave_apply_leave
      WHERE empcode = @empcode AND id != @id
      GROUP BY leaveid
    `;
    const checkResult = await pool.request()
      .input('empcode', empcode)
      .input('id', id)
      .query(checkSql);

    let leaveData = {
      1: { total: 0, used: 0 }, // Loss of Pay (No limit)
      2: { total: 6.0, used: 0 }, // Sick Leave
      3: { total: 12.0, used: 0 } // Earned/Casual Leave
    };

    checkResult.recordset.forEach(record => {
      leaveData[record.leaveid].used = record.days_used || 0;
    });

    if (leaveid !== 1 && (leaveData[leaveid].used + no_of_days > leaveData[leaveid].total)) {
      let leaveType = leaveid === 2 ? 'Sick Leave' : 'Earned/Casual Leave';
      return res.status(400).json({ message: `${leaveType} balance is insufficient` });
    }

    // Proceed with updating the leave record
    const updateSql = `
      UPDATE tbl_leave_apply_leave 
      SET 
        leaveid = @leaveid, 
        leavemode = @leavemode, 
        reason = @reason, 
        fromdate = @fromdate, 
        todate = @todate, 
        half = @half, 
        shift= @shift,
        no_of_days = @no_of_days
      WHERE 
        id = @id 
    `;

    await pool.request()
      .input('id', id)
      .input('leaveid', leaveid)
      .input('leavemode', leavemode)
      .input('reason', reason)
      .input('fromdate', fromdate)
      .input('todate', todate)
      .input('half', half)
      .input('shift', shift)
      .input('no_of_days', no_of_days)
      .query(updateSql);

    // Fetch employee details
    const sql = `
      SELECT 
        ejd.empcode,
        ejd.emp_fname, 
        ejd.official_email_id
      FROM tbl_intranet_employee_jobDetails ejd
      JOIN tbl_intranet_designation des ON ejd.degination_id = des.id
      WHERE ejd.empcode = @empcode
    `;
    const userResult = await pool.request()
      .input('empcode', empcode)
      .query(sql);

    if (userResult.recordset.length > 0) {
      const empName = userResult.recordset[0].emp_fname;
      const official_email_id = userResult.recordset[0].official_email_id;
      emailController.sendLeaveApplicationEmails(empName, official_email_id, fromdate, todate);
      return res.status(200).json({ message: 'Leave record updated successfully and email sent' });
    } else {
      return res.status(404).json({ message: 'Employee not found' });
    }

  } catch (error) {
    console.error('Error processing leave application: ', error);
    return res.status(error.status || 500).json({ message: error.message || 'Internal server error' });
  }
};

exports.leaveToApprove =(req,res)=>{
  const { empcode } = req.body; 

  const fetchSql = `
  SELECT id, empcode, leaveid, fromdate, todate, createddate, approvel_status, leave_status
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
        id:record.id,
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
  const { id, leaveid, empcode, approve } = req.body;
  const approvalStatus = approve ? 1 : 0;
  const leaveStatus = approve ? 6 : 3; 

  const updateSql = `
      UPDATE tbl_leave_apply_leave
      SET approvel_status = @approvalStatus, leave_status = @leaveStatus
      WHERE id = @id AND empcode = @empcode
  `;

  // SQL to fetch leave details along with employee information after the update
  const fetchSql = `
      SELECT 
        l.id, 
        l.empcode, 
        l.fromdate, 
        l.todate, 
        l.approvel_status, 
        l.leave_status,
        ejd.emp_fname, 
        ejd.official_email_id
      FROM tbl_leave_apply_leave l
      JOIN tbl_intranet_employee_jobDetails ejd ON l.empcode = ejd.empcode
      WHERE l.id = @id AND l.empcode = @empcode
  `;

  const request = pool.request()
      .input('id', id)
      .input('leaveid', leaveid)
      .input('empcode', empcode)
      .input('approvalStatus', approvalStatus)
      .input('leaveStatus', leaveStatus);

  // Update the leave record
  request.query(updateSql, (updateErr, updateResult) => {
      if (updateErr) {
          console.error('Error updating leave record: ', updateErr);
          return res.status(500).json({ message: 'Error updating leave record', error: updateErr });
      }

      // Fetch the updated leave details and employee information
      pool.request()
          .input('id', id)
          .input('empcode', empcode)
          .query(fetchSql, (fetchErr, fetchResult) => {
              if (fetchErr) {
                  console.error('Error fetching leave and employee details: ', fetchErr);
                  return res.status(500).json({ message: 'Error fetching leave and employee details', error: fetchErr });
              }

              if (fetchResult.recordset.length > 0) {
                  const leaveData = fetchResult.recordset[0];
                  const { emp_fname, official_email_id, fromdate, todate } = leaveData;

                  // Send the leave status email
                  emailController.sendLeaveStatus(
                      emp_fname,
                      official_email_id,
                      fromdate,
                      todate,
                      approvalStatus
                  );

                  res.status(200).json({ message: 'Leave record updated successfully' });
              } else {
                  res.status(404).json({ message: 'Leave record not found' });
              }
          });
  });
};
