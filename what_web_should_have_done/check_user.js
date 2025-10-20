const mongoose = require('mongoose');

mongoose.connect('mongodb://localhost:27017/flutter_app', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

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

const User = mongoose.model('User', UserSchema);

async function checkUser() {
  try {
    const user = await User.findOne({ email: 'brockschoenthaler@gmail.com' });
    if (user) {
      console.log('User found:', user);
    } else {
      console.log('User not found, creating...');
      const newUser = new User({
        email: 'brockschoenthaler@gmail.com',
        password: 'password123',
        firstName: 'Brock',
        lastName: 'Schoenthaler',
        phone: '',
        currency: 1000,
        hippoBalanceCents: 50000,
        assets: []
      });
      await newUser.save();
      console.log('User created:', newUser);
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    mongoose.connection.close();
  }
}

checkUser();