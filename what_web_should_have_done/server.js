const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// MongoDB connection
mongoose.connect('mongodb://localhost:27017/flutter_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Schemas
const UserSchema = new mongoose.Schema({
  email: String,
  password: String,
  firstName: String,
  lastName: String,
  phone: String,
  currency: { type: Number, default: 0 },
  hippoBalanceCents: { type: Number, default: 0 },
  assets: { type: Array, default: [] },
  profilePicture: String // Base64 encoded image
});

const AssetSchema = new mongoose.Schema({
  ownerId: mongoose.Schema.Types.ObjectId,
  name: String,
  description: String,
  value: Number,
  imagePaths: Array
});

const VoteSchema = new mongoose.Schema({
  itemId: String,
  userId: String,
  vote: Number,
  createdAt: Date
});

const NotificationSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  title: String,
  message: String,
  type: String,
  isRead: Boolean,
  createdAt: Date
});

const FavoriteSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  assetId: mongoose.Schema.Types.ObjectId,
  createdAt: Date
});

const User = mongoose.model('User', UserSchema);
const Asset = mongoose.model('Asset', AssetSchema);
const Vote = mongoose.model('Vote', VoteSchema);
const Notification = mongoose.model('Notification', NotificationSchema);
const Favorite = mongoose.model('Favorite', FavoriteSchema);

// User endpoints
app.get('/api/users', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/users/id/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/users', async (req, res) => {
  try {
    console.log('Registration attempt:', req.body);
    const user = new User(req.body);
    await user.save();
    console.log('User created successfully:', user._id);
    res.status(201).json(user);
  } catch (error) {
    console.log('Registration error:', error.message);
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/users/:id', async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(user);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log('Login attempt:', { email, password });
    
    // Check if user exists by email only
    const userByEmail = await User.findOne({ email: email.toLowerCase().trim() });
    console.log('User found by email:', userByEmail ? 'Yes' : 'No');
    
    if (userByEmail) {
      console.log('Stored password:', userByEmail.password);
      console.log('Provided password:', password);
    }
    
    const user = await User.findOne({ 
      email: email.toLowerCase().trim(), 
      password: password.trim() 
    });
    
    if (user) {
      res.json(user);
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/users/:id/deposit', async (req, res) => {
  try {
    const { amount } = req.body;
    const user = await User.findById(req.params.id);
    user.hippoBalanceCents += amount;
    await user.save();
    res.json({ balance: user.hippoBalanceCents });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.post('/api/users/:id/withdraw', async (req, res) => {
  try {
    const { amount } = req.body;
    const user = await User.findById(req.params.id);
    user.hippoBalanceCents -= amount;
    await user.save();
    res.json({ balance: user.hippoBalanceCents });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.get('/api/users/:id/balance', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    res.json({ balance: user.hippoBalanceCents });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/users/:id/profile-picture', async (req, res) => {
  try {
    const { profilePicture } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.id, 
      { profilePicture }, 
      { new: true }
    );
    res.json({ success: true, profilePicture: user.profilePicture });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Asset endpoints
app.get('/api/assets', async (req, res) => {
  try {
    const assets = await Asset.find();
    res.json(assets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/assets/owner/:ownerId', async (req, res) => {
  try {
    const assets = await Asset.find({ ownerId: req.params.ownerId });
    res.json(assets);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/assets', async (req, res) => {
  try {
    const asset = new Asset(req.body);
    await asset.save();
    res.status(201).json(asset);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/assets/:id', async (req, res) => {
  try {
    const asset = await Asset.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(asset);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/assets/:id', async (req, res) => {
  try {
    await Asset.findByIdAndDelete(req.params.id);
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Vote endpoints
app.get('/api/votes/:itemId', async (req, res) => {
  try {
    const votes = await Vote.find({ itemId: req.params.itemId });
    res.json(votes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/votes', async (req, res) => {
  try {
    const vote = new Vote(req.body);
    await vote.save();
    res.status(201).json(vote);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Notification endpoints
app.get('/api/notifications/:userId', async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.params.userId });
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/notifications', async (req, res) => {
  try {
    const notification = new Notification(req.body);
    await notification.save();
    res.status(201).json(notification);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// Favorite endpoints
app.get('/api/favorites/:userId', async (req, res) => {
  try {
    const favorites = await Favorite.find({ userId: req.params.userId });
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/favorites', async (req, res) => {
  try {
    const favorite = new Favorite(req.body);
    await favorite.save();
    res.status(201).json(favorite);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.delete('/api/favorites/:userId/:assetId', async (req, res) => {
  try {
    await Favorite.findOneAndDelete({ userId: req.params.userId, assetId: req.params.assetId });
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Transaction endpoints
const TransactionSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  assetId: mongoose.Schema.Types.ObjectId,
  amount: Number,
  type: String,
  status: String,
  createdAt: Date
});

const Transaction = mongoose.model('Transaction', TransactionSchema);

app.get('/api/transactions/:userId', async (req, res) => {
  try {
    const transactions = await Transaction.find({ userId: req.params.userId });
    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/transactions', async (req, res) => {
  try {
    const transaction = new Transaction(req.body);
    await transaction.save();
    res.status(201).json(transaction);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.put('/api/transactions/:id', async (req, res) => {
  try {
    const transaction = await Transaction.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(transaction);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Access from mobile: http://192.168.50.158:${PORT}`);
});