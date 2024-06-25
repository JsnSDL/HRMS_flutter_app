const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const taskController = require('../controllers/taskController');


// Route for handling login requests
router.post('/apply', isAuth.token,  taskController.insertTask);

module.exports = router;
