require('dotenv').config();
const pool = require('../utils/database');
const { format, parseISO, getDay, getDate } = require('date-fns');


const isSecondOrFourthSaturday = (date) => {
  const dayOfWeek = getDay(date); // 0 (Sunday) to 6 (Saturday)
  const weekOfMonth = Math.floor((getDate(date) - 1) / 7) + 1;
  return dayOfWeek === 6 && (weekOfMonth === 2 || weekOfMonth === 4);
};

const isSunday = (date) => {
  return getDay(date) === 0;
};


exports.insertLeave = (req, res) => {
  const {
    company_id, empcode, leaveid, leavemode, reason, fromdate, todate, half, no_of_days, leave_adjusted,
    approvel_status, leave_status, flag, status, createddate, createdby, modifieddate, modifiedby
  } = req.body;

  const startDate = parseISO(fromdate);
  const endDate = parseISO(todate);

  if (isSunday(startDate) || isSunday(endDate) || isSecondOrFourthSaturday(startDate) || isSecondOrFourthSaturday(endDate)) {
    return res.status(400).json({ message: 'Leave cannot be applied on the second and fourth Saturday and on Sunday' });
  }

  const holidaySql = `
    SELECT date FROM tbl_leave_holiday
    WHERE date IN (@fromdate, @todate)
  `;

  pool.request()
    .input('fromdate', fromdate)
    .input('todate', todate)
    .query(holidaySql, (holidayErr, holidayResult) => {
      if (holidayErr) {
        console.error('Error checking holiday record: ', holidayErr);
        return res.status(500).json({ message: 'Error checking holiday record' });
      }

      if (holidayResult.recordset.length > 0) {
        return res.status(400).json({ message: 'Leave cannot be applied on holidays' });
      }

      const checkSql = `
        SELECT * FROM tbl_leave_apply_leave
        WHERE company_id = @company_id 
        AND empcode = @empcode 
        AND ((@fromdate >= fromdate AND @fromdate <= todate) OR (@todate >= fromdate AND @todate <= todate))
      `;

      pool.request()
        .input('company_id', company_id)
        .input('empcode', empcode)
        .input('fromdate', fromdate)
        .input('todate', todate)
        .query(checkSql, (checkErr, checkResult) => {
          if (checkErr) {
            console.error('Error checking leave record: ', checkErr);
            return res.status(500).json({ message: 'Error checking leave record' });
          }

          if (checkResult.recordset.length > 0) {
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
          }

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
            .query(insertSql, (insertErr, insertResult) => {
              if (insertErr) {
                console.error('Error inserting leave record: ', insertErr);
                return res.status(500).json({ message: 'Error inserting leave record' });
              }
              res.status(200).json({ message: 'Leave record inserted successfully' });
            });
        });
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
    SELECT id, leaveid, fromdate, todate, createddate, approvel_status, leave_status, reason, no_of_days, half
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
  } = req.body;

  // Query to check leave balance for the employee excluding the current leave record
  const checkSql = `
    SELECT leaveid, SUM(no_of_days) AS days_used
    FROM tbl_leave_apply_leave
    WHERE empcode = @empcode AND id != @id
    GROUP BY leaveid
  `;

  pool.request()
    .input('empcode', empcode)
    .input('id', id)
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

      if (leaveid !== 1 && (leaveData[leaveid].used + no_of_days > leaveData[leaveid].total)) {
        let leaveType = leaveid === 2 ? 'Sick Leave' : 'Earned/Casual Leave';
        return res.status(400).json({ message: `${leaveType} balance is insufficient` });
      }

      // Query to check overlapping dates with other leave records
      const overlapCheckSql = `
        SELECT id
        FROM tbl_leave_apply_leave
        WHERE empcode = @empcode
          AND id != @id
          AND ((@fromdate >= fromdate AND @fromdate <= todate)
               OR (@todate >= fromdate AND @todate <= todate))
      `;

      pool.request()
        .input('empcode', empcode)
        .input('id', id)
        .input('fromdate', fromdate)
        .input('todate', todate)
        .query(overlapCheckSql, (overlapErr, overlapResult) => {
          if (overlapErr) {
            console.error('Error checking overlapping leave dates: ', overlapErr);
            return res.status(500).json({ message: 'Error checking overlapping leave dates' });
          }

          if (overlapResult.recordset.length > 0) {
            return res.status(400).json({ message: 'Leave dates overlap with existing leave' });
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
              no_of_days = @no_of_days
            WHERE 
              id = @id 
          `;

          pool.request()
            .input('id', id)
            .input('leaveid', leaveid)
            .input('leavemode', leavemode)
            .input('reason', reason)
            .input('fromdate', fromdate)
            .input('todate', todate)
            .input('half', half)
            .input('no_of_days', no_of_days)
            .query(updateSql, (editErr, editResult) => {
              if (editErr) {
                console.error('Error updating leave record: ', editErr);
                return res.status(500).json({ message: 'Error editing leave record' });
              }
              res.status(200).json({ message: 'Leave record edited successfully' });
            });
        });
    });
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

  pool.request()
    .input('id',id)
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


