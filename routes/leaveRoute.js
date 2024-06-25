const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const leaveController = require('../controllers/leaveController');


// Route for handling login requests
router.post('/apply', isAuth.token,  leaveController.insertLeave);
router.post('/check', isAuth.token,  leaveController.checkLeaveExists);
router.post('/remain', isAuth.token,  leaveController.checkRemainLeave);
router.post('/get', isAuth.token,  leaveController.fetchLeave);
router.post('/approveGet', isAuth.token, leaveController.leaveToApprove)
router.post('/approve', isAuth.token, leaveController.leaveApprove)
router.post('/edit', isAuth.token, leaveController.editLeave)



module.exports = router;