const emailTemplates = {
    leaveApplicationSubmitted: {
      toEmployee: `Dear (Employee Name),
  
  Your Leave Application has been submitted successfully to Approver (Approver Name) dated from (DD-MON-YYYY)-To date (DD-MON-YYYY) for Approval / Reject.
  
  
  Regards,
  ------`,
      toApprover: `Dear (Approver Name),
  
  You have a Leave Application from (Employee Name) - (Employee ID) dated from (DD-MON-YYYY)-To (DD-MON-YYYY) for Approval / Reject.
  
  
  Regards,
  --------`
    },


    leaveApplicationApproved: {
      toEmployee: `Dear (Employee Name),
  
  Your Leave Application has been Approved by (Approver Name) dated from (DD-MON-YYYY)-To date (DD-MON-YYYY).
  
  
  Regards,
  ------`
    },
    leaveApplicationRejected: {
      toEmployee: `Dear (Employee Name),
  
  Your Leave Application has been Rejected by (Approver Name) dated from (DD-MON-YYYY)-To date (DD-MON-YYYY).
  
  
  Regards,
  ------`
    },
  };
  

module.exports = emailTemplates;