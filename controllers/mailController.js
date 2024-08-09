require('dotenv').config(); 
const nodemailer = require('nodemailer');
const emailTemplates = require('../utils/emailTemplate');

const approverName = 'Vani Satwik';

// Create a transporter object using the SMTP transport
let transporter = nodemailer.createTransport({
    service: 'gmail', // Use Gmail service
    auth: {
        user: process.env.EMAIL_USER, 
        pass: process.env.EMAIL_PASS  
    }
});


exports.sendLeaveApplicationEmails = (employeeName, employeeEmail, fromdate, todate) => {
    const toEmployee = emailTemplates.leaveApplicationSubmitted.toEmployee
        .replace('(Employee Name)', employeeName)
        .replace('(Approver Name)', approverName)
        .replace('(DD-MON-YYYY)', fromdate)
        .replace('(DD-MON-YYYY)', todate);

    const toApprover = emailTemplates.leaveApplicationSubmitted.toApprover
        .replace('(Employee Name)', employeeName)
        .replace('(Employee ID)', employeeEmail)
        .replace('(DD-MON-YYYY)', fromdate)
        .replace('(DD-MON-YYYY)', todate)
        .replace('(Approver Name)', approverName); ;

    const employeeMailOptions = {
        from: process.env.EMAIL_USER,
        to: employeeEmail,
        subject: 'Leave Application Submitted',
        text: toEmployee
    };

    const approverMailOptions = {
        from:process.env.EMAIL_USER,
        to: 'rakesh.d@sdlglobe.com',
        subject: 'New Leave Application',
        text: toApprover
    };

    // Send email to employee
    transporter.sendMail(employeeMailOptions, (error, info) => {
        if (error) {
            console.error('Error sending email to employee:', error);
        } else {
            console.log('Email sent to employee:', info.messageId);
        }
    });

    // Send email to approver
    transporter.sendMail(approverMailOptions, (error, info) => {
        if (error) {
            console.error('Error sending email to approver:', error);
        } else {
            console.log('Email sent to approver:', info.messageId);
        }
    });
};