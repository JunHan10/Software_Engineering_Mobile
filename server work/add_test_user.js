const mongoose = require('mongoose');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/flutter_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// User Schema
const UserSchema = new mongoose.Schema({
  email: String,
  password: String,
  firstName: String,
  lastName: String,
  currency: Number,
  hippoBalanceCents: Number,
  assets: Array
});

const User = mongoose.model('User', UserSchema);

// Add test user
async function addTestUser() {
  try {
    // Check if user already exists
    const existingUser = await User.findOne({ email: 'john.doe@example.com' });
    if (existingUser) {
      console.log('Test user already exists');
      return;
    }

    // Create test user
    const testUser = new User({
      email: 'john.doe@example.com',
      password: 'password123',
      firstName: 'John',
      lastName: 'Doe',
      currency: 2500.75,
      hippoBalanceCents: 0,
      assets: []
    });

    await testUser.save();
    console.log('Test user created successfully');
  } catch (error) {
    console.error('Error creating test user:', error);
  } finally {
    mongoose.connection.close();
  }
}

addTestUser();