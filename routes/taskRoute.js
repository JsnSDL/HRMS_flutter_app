const express = require('express');
const router = express.Router();
const isAuth = require("../middleware/isAuth")
const taskController = require('../controllers/taskController');


// Route for handling login requests
router.post('/apply', isAuth.token,  taskController.insertTask);
router.post('/gettask', isAuth.token, taskController.fetchTask );
router.post('/edit',isAuth.token,taskController.editTask);
router.post('/project',isAuth.token,taskController.createProject);
router.post('/fetchProject',taskController.fetchProjectAdmin);
router.post('/assignProjectTask',isAuth.token,taskController.assignProjectTask);
router.post('/getProjectTask', taskController.fetchProjectTask );
router.post('/editProjectTask', isAuth.token, taskController.editProjectTask);
router.post('/fetchProjectEmployee',taskController.fetchProjectEmployee);


module.exports = router;
