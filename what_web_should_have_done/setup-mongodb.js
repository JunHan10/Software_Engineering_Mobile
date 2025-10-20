const mongoose = require('mongoose');

// MongoDB connection
const MONGODB_URI = 'mongodb://localhost:27017/flutter_app';

// Schemas (same as in server.js)
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

const TransactionSchema = new mongoose.Schema({
  userId: mongoose.Schema.Types.ObjectId,
  assetId: mongoose.Schema.Types.ObjectId,
  amount: Number,
  type: String,
  status: String,
  createdAt: Date
});

const User = mongoose.model('User', UserSchema);
const Asset = mongoose.model('Asset', AssetSchema);
const Vote = mongoose.model('Vote', VoteSchema);
const Notification = mongoose.model('Notification', NotificationSchema);
const Favorite = mongoose.model('Favorite', FavoriteSchema);
const Transaction = mongoose.model('Transaction', TransactionSchema);

async function setupDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB successfully!');

    // Clear existing data (optional)
    console.log('🧹 Clearing existing data...');
    await User.deleteMany({});
    await Asset.deleteMany({});
    await Vote.deleteMany({});
    await Notification.deleteMany({});
    await Favorite.deleteMany({});
    await Transaction.deleteMany({});

    // Create sample users
    console.log('👥 Creating sample users...');
    const johnUser = new User({
      email: 'john@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      currency: 2500.75,
      hippoBalanceCents: 150000,
      assets: []
    });
    await johnUser.save();

    const janeUser = new User({
      email: 'jane.smith@example.com',
      password: 'password456',
      firstName: 'Jane',
      lastName: 'Smith',
      currency: 1800.50,
      hippoBalanceCents: 120000,
      assets: []
    });
    await janeUser.save();

    // Create sample assets
    console.log('📦 Creating sample assets...');
    const macbookAsset = new Asset({
      ownerId: johnUser._id,
      name: 'MacBook Pro',
      description: '2021 MacBook Pro 14-inch',
      value: 1200.00,
      imagePaths: []
    });
    await macbookAsset.save();

    const canonAsset = new Asset({
      ownerId: janeUser._id,
      name: 'Canon EOS R5',
      description: 'Professional camera with 45MP sensor',
      value: 2500.00,
      imagePaths: []
    });
    await canonAsset.save();

    // Create sample notifications
    console.log('🔔 Creating sample notifications...');
    const notification1 = new Notification({
      userId: johnUser._id,
      title: 'New loan request',
      message: 'Jane Smith wants to borrow your Canon EOS R5',
      type: 'loan_request',
      isRead: false,
      createdAt: new Date()
    });
    await notification1.save();

    const notification2 = new Notification({
      userId: janeUser._id,
      title: 'Welcome to Hippo Bucks!',
      message: 'Your account has been credited with $750 welcome bonus',
      type: 'system',
      isRead: false,
      createdAt: new Date()
    });
    await notification2.save();

    // Create sample transactions
    console.log('💰 Creating sample transactions...');
    const transaction1 = new Transaction({
      userId: johnUser._id,
      amount: 100.00,
      type: 'deposit',
      status: 'completed',
      createdAt: new Date()
    });
    await transaction1.save();

    const transaction2 = new Transaction({
      userId: janeUser._id,
      amount: 75.00,
      type: 'deposit',
      status: 'completed',
      createdAt: new Date()
    });
    await transaction2.save();

    console.log('🎉 Database setup completed successfully!');
    console.log('📊 Summary:');
    console.log(`   - Users: ${await User.countDocuments()}`);
    console.log(`   - Assets: ${await Asset.countDocuments()}`);
    console.log(`   - Notifications: ${await Notification.countDocuments()}`);
    console.log(`   - Transactions: ${await Transaction.countDocuments()}`);

  } catch (error) {
    console.error('❌ Database setup failed:', error);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 Database connection closed');
  }
}

// Run the setup
setupDatabase();
