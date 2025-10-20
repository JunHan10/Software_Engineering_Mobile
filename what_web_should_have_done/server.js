const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

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
  assets: { type: Array, default: [] }
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

// Messaging schemas
const ConversationSchema = new mongoose.Schema({
  itemId: { type: String, required: true },
  itemName: { type: String, required: true },
  ownerId: { type: String, required: true },
  ownerName: { type: String, required: true },
  borrowerId: { type: String, required: true },
  borrowerName: { type: String, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
  status: { type: String, enum: ['active', 'completed', 'cancelled', 'archived'], default: 'active' },
  lastMessage: { type: mongoose.Schema.Types.Mixed },
  unreadCount: { type: Number, default: 0 }
});

const MessageSchema = new mongoose.Schema({
  conversationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation', required: true },
  senderId: { type: String, required: true },
  senderName: { type: String, required: true },
  content: { type: String, required: true },
  type: { type: String, enum: ['text', 'image', 'system', 'request', 'approval', 'rejection'], default: 'text' },
  createdAt: { type: Date, default: Date.now },
  isRead: { type: Boolean, default: false },
  metadata: { type: mongoose.Schema.Types.Mixed }
});

const User = mongoose.model('User', UserSchema);
const Asset = mongoose.model('Asset', AssetSchema);
const Vote = mongoose.model('Vote', VoteSchema);
const Notification = mongoose.model('Notification', NotificationSchema);
const Favorite = mongoose.model('Favorite', FavoriteSchema);
const Conversation = mongoose.model('Conversation', ConversationSchema);
const Message = mongoose.model('Message', MessageSchema);

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
    console.log('\n🆕 NEW USER REGISTRATION ATTEMPT:');
    console.log('📧 Email:', req.body.email);
    console.log('👤 Name:', req.body.firstName, req.body.lastName);
    console.log('📱 Phone:', req.body.phone || 'Not provided');
    
    const user = new User(req.body);
    await user.save();
    
    console.log('✅ USER CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', user._id);
    console.log('💰 Initial Balance:', user.hippoBalanceCents, 'cents');
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(user);
  } catch (error) {
    console.log('❌ REGISTRATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
    console.log('\n📦 NEW ASSET CREATION ATTEMPT:');
    console.log('🏷️  Asset Name:', req.body.name);
    console.log('📝 Description:', req.body.description);
    console.log('💰 Value: $', req.body.value);
    console.log('👤 Owner ID:', req.body.ownerId);
    
    const asset = new Asset(req.body);
    await asset.save();
    
    console.log('✅ ASSET CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', asset._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(asset);
  } catch (error) {
    console.log('❌ ASSET CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
    console.log('\n👍 NEW VOTE CREATION:');
    console.log('📝 Item ID:', req.body.itemId);
    console.log('👤 User ID:', req.body.userId);
    console.log('🗳️  Vote:', req.body.vote === 1 ? '👍 Upvote' : req.body.vote === -1 ? '👎 Downvote' : '❌ No vote');
    
    const vote = new Vote(req.body);
    await vote.save();
    
    console.log('✅ VOTE CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', vote._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(vote);
  } catch (error) {
    console.log('❌ VOTE CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
    console.log('\n🔔 NEW NOTIFICATION CREATION:');
    console.log('👤 User ID:', req.body.userId);
    console.log('📋 Title:', req.body.title);
    console.log('💬 Message:', req.body.message);
    console.log('🏷️  Type:', req.body.type);
    
    const notification = new Notification(req.body);
    await notification.save();
    
    console.log('✅ NOTIFICATION CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', notification._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(notification);
  } catch (error) {
    console.log('❌ NOTIFICATION CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
    console.log('\n❤️  NEW FAVORITE CREATION:');
    console.log('👤 User ID:', req.body.userId);
    console.log('📦 Asset ID:', req.body.assetId);
    
    const favorite = new Favorite(req.body);
    await favorite.save();
    
    console.log('✅ FAVORITE CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', favorite._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(favorite);
  } catch (error) {
    console.log('❌ FAVORITE CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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
    console.log('\n💰 NEW TRANSACTION CREATION:');
    console.log('👤 User ID:', req.body.userId);
    console.log('📦 Asset ID:', req.body.assetId || 'N/A');
    console.log('💵 Amount: $', req.body.amount);
    console.log('🏷️  Type:', req.body.type);
    console.log('📊 Status:', req.body.status);
    
    const transaction = new Transaction(req.body);
    await transaction.save();
    
    console.log('✅ TRANSACTION CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', transaction._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(transaction);
  } catch (error) {
    console.log('❌ TRANSACTION CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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

// ===== LOAN SCHEMAS =====

// Loan Schema
const LoanSchema = new mongoose.Schema({
  itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Asset', required: true },
  itemName: { type: String, required: true },
  itemDescription: { type: String, required: true },
  itemImagePath: { type: String, default: '' },
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  ownerName: { type: String, required: true },
  borrowerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  borrowerName: { type: String, required: true },
  startDate: { type: Date, default: Date.now },
  endDate: { type: Date },
  expectedReturnDate: { type: Date },
  status: { type: String, enum: ['active', 'completed', 'cancelled', 'returned'], default: 'active' },
  notes: { type: String },
  itemValue: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

// Update updatedAt on save
LoanSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

const Loan = mongoose.model('Loan', LoanSchema);

// ===== MESSAGING ENDPOINTS =====

// Create conversation
app.post('/api/conversations', async (req, res) => {
  try {
    const { itemId, itemName, ownerId, ownerName, borrowerId, borrowerName } = req.body;
    
    console.log('\n💬 NEW CONVERSATION CREATION:');
    console.log('📦 Item:', itemName, '(ID:', itemId + ')');
    console.log('👤 Owner:', ownerName, '(ID:', ownerId + ')');
    console.log('🤝 Borrower:', borrowerName, '(ID:', borrowerId + ')');
    
    // Check if conversation already exists
    const existing = await Conversation.findOne({
      itemId,
      $or: [
        { ownerId, borrowerId },
        { ownerId: borrowerId, borrowerId: ownerId }
      ]
    });
    
    if (existing) {
      console.log('✅ EXISTING CONVERSATION FOUND!');
      console.log('🆔 Conversation ID:', existing._id);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      return res.json(existing);
    }
    
    const conversation = new Conversation({
      itemId,
      itemName,
      ownerId,
      ownerName,
      borrowerId,
      borrowerName,
      createdAt: new Date(),
      updatedAt: new Date(),
      status: 'active'
    });
    
    await conversation.save();
    
    console.log('✅ CONVERSATION CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', conversation._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(conversation);
  } catch (error) {
    console.log('❌ CONVERSATION CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    res.status(500).json({ error: error.message });
  }
});

// Get user conversations
app.get('/api/conversations/user/:userId', async (req, res) => {
  try {
    const conversations = await Conversation.find({
      $or: [
        { ownerId: req.params.userId },
        { borrowerId: req.params.userId }
      ]
    }).sort({ updatedAt: -1 });
    
    res.json(conversations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get specific conversation
app.get('/api/conversations/:conversationId', async (req, res) => {
  try {
    const conversation = await Conversation.findById(req.params.conversationId);
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    res.json(conversation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get conversation messages
app.get('/api/conversations/:conversationId/messages', async (req, res) => {
  try {
    const messages = await Message.find({
      conversationId: req.params.conversationId
    }).sort({ createdAt: 1 });
    
    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Send message
app.post('/api/conversations/:conversationId/messages', async (req, res) => {
  try {
    const { senderId, senderName, content, type = 'text', metadata } = req.body;
    
    console.log('\n📨 NEW MESSAGE:');
    console.log('💬 Conversation ID:', req.params.conversationId);
    console.log('👤 Sender:', senderName, '(ID:', senderId + ')');
    console.log('📝 Content:', content.substring(0, 50) + (content.length > 50 ? '...' : ''));
    console.log('🏷️  Type:', type);
    
    const message = new Message({
      conversationId: req.params.conversationId,
      senderId,
      senderName,
      content,
      type,
      metadata,
      createdAt: new Date(),
      isRead: false
    });
    
    await message.save();
    
    // Update conversation's last message and updatedAt
    await Conversation.findByIdAndUpdate(req.params.conversationId, {
      lastMessage: message,
      updatedAt: new Date()
    });
    
    console.log('✅ MESSAGE SENT SUCCESSFULLY!');
    console.log('🆔 Database ID:', message._id);
    console.log('📅 Created at:', new Date().toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(message);
  } catch (error) {
    console.log('❌ MESSAGE SENDING FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    res.status(500).json({ error: error.message });
  }
});

// Mark messages as read
app.put('/api/conversations/:conversationId/read', async (req, res) => {
  try {
    const { userId } = req.body;
    
    await Message.updateMany(
      {
        conversationId: req.params.conversationId,
        senderId: { $ne: userId }
      },
      { isRead: true }
    );
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update conversation status
app.put('/api/conversations/:conversationId/status', async (req, res) => {
  try {
    const { status } = req.body;
    
    const conversation = await Conversation.findByIdAndUpdate(
      req.params.conversationId,
      { status, updatedAt: new Date() },
      { new: true }
    );
    
    if (!conversation) {
      return res.status(404).json({ error: 'Conversation not found' });
    }
    
    res.json(conversation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Find existing conversation
app.get('/api/conversations/find', async (req, res) => {
  try {
    const { itemId, borrowerId } = req.query;
    
    const conversation = await Conversation.findOne({
      itemId,
      $or: [
        { ownerId: borrowerId },
        { borrowerId: borrowerId }
      ]
    });
    
    res.json(conversation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ===== LOAN ENDPOINTS =====

// Create loan
app.post('/api/loans', async (req, res) => {
  try {
    const { itemId, itemName, itemDescription, itemImagePath, ownerId, ownerName, borrowerId, borrowerName, itemValue, expectedReturnDate, notes } = req.body;
    
    console.log('\n📋 NEW LOAN CREATION:');
    console.log('📦 Item:', itemName, '(ID:', itemId + ')');
    console.log('👤 Owner:', ownerName, '(ID:', ownerId + ')');
    console.log('🤝 Borrower:', borrowerName, '(ID:', borrowerId + ')');
    console.log('💰 Value:', itemValue);
    
    const loan = new Loan({
      itemId,
      itemName,
      itemDescription,
      itemImagePath,
      ownerId,
      ownerName,
      borrowerId,
      borrowerName,
      itemValue,
      expectedReturnDate: expectedReturnDate ? new Date(expectedReturnDate) : null,
      notes,
      startDate: new Date(),
      status: 'active'
    });
    
    await loan.save();
    
    console.log('✅ LOAN CREATED SUCCESSFULLY!');
    console.log('🆔 Database ID:', loan._id);
    console.log('📅 Start Date:', loan.startDate.toISOString());
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    res.status(201).json(loan);
  } catch (error) {
    console.log('❌ LOAN CREATION FAILED:', error.message);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    res.status(500).json({ error: error.message });
  }
});

// Get loans for borrower
app.get('/api/loans/borrower/:userId', async (req, res) => {
  try {
    const loans = await Loan.find({
      borrowerId: req.params.userId,
      status: { $in: ['active', 'completed', 'returned'] }
    }).sort({ startDate: -1 });
    
    res.json(loans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get loans for owner
app.get('/api/loans/owner/:userId', async (req, res) => {
  try {
    const loans = await Loan.find({
      ownerId: req.params.userId,
      status: { $in: ['active', 'completed', 'returned'] }
    }).sort({ startDate: -1 });
    
    res.json(loans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get all loans for user (both as borrower and owner)
app.get('/api/loans/user/:userId', async (req, res) => {
  try {
    const loans = await Loan.find({
      $or: [
        { borrowerId: req.params.userId },
        { ownerId: req.params.userId }
      ],
      status: { $in: ['active', 'completed', 'returned'] }
    }).sort({ startDate: -1 });
    
    res.json(loans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get loan by ID
app.get('/api/loans/:loanId', async (req, res) => {
  try {
    const loan = await Loan.findById(req.params.loanId);
    if (!loan) {
      return res.status(404).json({ error: 'Loan not found' });
    }
    res.json(loan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update loan status
app.put('/api/loans/:loanId/status', async (req, res) => {
  try {
    const { status, notes } = req.body;
    
    const loan = await Loan.findByIdAndUpdate(
      req.params.loanId,
      { 
        status, 
        notes,
        updatedAt: new Date()
      },
      { new: true }
    );
    
    if (!loan) {
      return res.status(404).json({ error: 'Loan not found' });
    }
    
    res.json(loan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mark loan as returned
app.put('/api/loans/:loanId/return', async (req, res) => {
  try {
    const loan = await Loan.findByIdAndUpdate(
      req.params.loanId,
      { 
        status: 'returned',
        endDate: new Date(),
        updatedAt: new Date()
      },
      { new: true }
    );
    
    if (!loan) {
      return res.status(404).json({ error: 'Loan not found' });
    }
    
    res.json(loan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Find existing loan
app.get('/api/loans/find', async (req, res) => {
  try {
    const { itemId, borrowerId } = req.query;
    
    const loan = await Loan.findOne({
      itemId,
      borrowerId,
      status: { $in: ['active', 'completed'] }
    });
    
    res.json(loan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Access from mobile: http://192.168.1.144:${PORT}`);
});