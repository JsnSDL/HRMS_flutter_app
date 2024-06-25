const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const attendanceController = require('../controllers/attendanceController');


// Route for handling login requests
router.post('/time', isAuth.token,  attendanceController.insertIntime);
router.post('/get', isAuth.token,  attendanceController.fetchAttendance);

module.exports = router;