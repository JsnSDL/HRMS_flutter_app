const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const notificationController = require('../controllers/notificationController');

// Route for handling login requests
router.post('/get', isAuth.token, notificationController.fetchNotification );
router.post('/send', isAuth.token, notificationController.insertBirthdayWish);
router.post('/getData', isAuth.token, notificationController.fetchWishNotification);
router.post('/count', isAuth.token, notificationController.checkNotification);

module.exports = router;