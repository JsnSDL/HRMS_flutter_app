// server.js
const express = require('express');
const bodyParser = require('body-parser');
const authRoutes = require('./routes/authRoute');
const attendanceRoutes = require('./routes/attendanceRoute');
const leaveRoutes = require('./routes/leaveRoute');
const taskRoutes = require('./routes/taskRoute');


const app = express();
const port = process.env.PORT || 3000;

// Middleware to parse JSON bodies
app.use(bodyParser.json());

// Routes
app.use('/auth', authRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/leave', leaveRoutes);
app.use('/task', taskRoutes);



// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});