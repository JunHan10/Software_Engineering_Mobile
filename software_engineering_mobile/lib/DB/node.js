const express = require('express');
const { MongoClient } = require('mongodb');
const cors = require('cors');
const bcrypt = require('bcrypt');
require('dotenv').config({ path: '../../.env' });

const app = express();
app.use(cors());
app.use(express.json());
// Request logger
app.use((req, _res, next) => {
  console.log(`➡️ ${req.method} ${req.url}`, req.body);
  next();
});

// MongoDB client
const client = new MongoClient(process.env.DATABASE_URL);

// Registration endpoint
app.post('/register', async (req, res) => {
  console.log('💡 Incoming request body:', req.body); // <- debug

  try {
    const db = client.db('Mobile');
    const users = db.collection('users');

    if (!req.body || !req.body.email) {
      console.log('⚠️ Missing email in request body');
      return res.status(400).json({ error: 'Email is required' });
    }

    const existing = await users.findOne({ email: req.body.email });
    if (existing) return res.status(400).json({ error: 'Email already in use' });

    const hashedPassword = await bcrypt.hash(req.body.password, 10);
    const userPayload = { ...req.body, password: hashedPassword };
    const result = await users.insertOne(userPayload);

    console.log('✅ Registration successful for:', req.body.email);
    res.status(200).json({ id: result.insertedId });
  } catch (e) {
    console.error('⛔ Exception during registration', e);
    res.status(500).json({ error: 'Registration failed' });
  }
});


// Login endpoint
app.post('/login', async (req, res) => {
  console.log('💡 Login request body:', req.body);

  try {
    const db = client.db('Mobile');
    const users = db.collection('users');

    if (!req.body || !req.body.email) {
      console.log('⚠️ Missing email in login request');
      return res.status(400).json({ error: 'Email is required' });
    }

    const user = await users.findOne({ email: req.body.email });
    if (!user) {
      console.log('❌ No user found for:', req.body.email);
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    const match = await bcrypt.compare(req.body.password, user.password);
    if (!match) {
      console.log('❌ Password mismatch for:', req.body.email);
      return res.status(400).json({ error: 'Invalid email or password' });
    }

    console.log('✅ Login successful for:', req.body.email);
    res.status(200).json({ id: user._id });
  } catch (e) {
    console.error('⛔ Exception during login', e);
    res.status(500).json({ error: 'Login failed' });
  }
});



// Connect to MongoDB and start server
async function startServer() {
  try {
    await client.connect();
    console.log('Connected to MongoDB');

    const port = process.env.PORT || 3000;
    app.listen(port, '0.0.0.0', () => {
      console.log(`Server running on port ${port}`);
    });
  } catch (err) {
    console.error('Failed to connect to MongoDB', err);
  }
}

startServer();
