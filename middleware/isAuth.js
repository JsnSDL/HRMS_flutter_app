require('dotenv').config();
const jwt = require('jsonwebtoken');

exports.token = (req, res, next) => {
  const authHeader = req.get("Authorization");
  if (!authHeader) {
    console.log('Authorization header missing');
    return res.status(401).json({ message: 'Authorization header missing' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    console.log('Token missing');
    return res.status(401).json({ message: 'Token missing' });
  }

  let decodedToken;
  try {
    decodedToken = jwt.verify(token, process.env.TOKEN_SECRET);
  } catch (err) {
    console.error('JWT verification error:', err);
    return res.status(401).json({ message: 'Invalid token' });
  }

  req.userID = decodedToken.userID;
  next();
};
