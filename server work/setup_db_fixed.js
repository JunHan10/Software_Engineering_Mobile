use flutter_app;

// Remove validation and clear collections
db.runCommand({ collMod: "users", validator: {}, validationLevel: "off" });
db.users.deleteMany({});
db.assets.deleteMany({});
db.votes.deleteMany({});
db.notifications.deleteMany({});
db.favorites.deleteMany({});

// Users
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.insertMany([
  {
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "currency": 2500.75,
    "hippoBalanceCents": 150000,
    "assets": []
  },
  {
    "email": "jane.smith@example.com",
    "password": "password123",
    "firstName": "Jane",
    "lastName": "Smith",
    "currency": 1800.50,
    "hippoBalanceCents": 75000,
    "assets": []
  },
  {
    "email": "john.doe@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "currency": 3200.25,
    "hippoBalanceCents": 200000,
    "assets": []
  }
]);

// Assets
db.assets.createIndex({ "ownerId": 1 });
db.assets.insertMany([
  {
    "ownerId": db.users.findOne({"email": "john@example.com"})._id,
    "name": "MacBook Pro",
    "description": "2021 MacBook Pro 14-inch",
    "value": 1200.00,
    "imagePaths": []
  },
  {
    "ownerId": db.users.findOne({"email": "john.doe@example.com"})._id,
    "name": "Canon EOS R5",
    "description": "Professional camera",
    "value": 2500.00,
    "imagePaths": []
  },
  {
    "ownerId": db.users.findOne({"email": "john.doe@example.com"})._id,
    "name": "MacBook Pro 14-inch",
    "description": "Another MacBook",
    "value": 1800.00,
    "imagePaths": []
  }
]);

// Votes
db.votes.createIndex({ "itemId": 1 });
db.votes.insertMany([
  {
    "itemId": db.assets.findOne({"name": "Canon EOS R5"})._id.toString(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id.toString(),
    "vote": 1,
    "createdAt": new Date()
  },
  {
    "itemId": db.assets.findOne({"name": "MacBook Pro 14-inch"})._id.toString(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id.toString(),
    "vote": 1,
    "createdAt": new Date()
  }
]);

// Notifications
db.notifications.createIndex({ "userId": 1 });
db.notifications.insertMany([
  {
    "userId": db.users.findOne({"email": "john.doe@example.com"})._id,
    "title": "New loan request",
    "message": "Jane Smith wants to borrow your Canon EOS R5",
    "type": "loan_request",
    "isRead": false,
    "createdAt": new Date()
  },
  {
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id,
    "title": "Welcome to Hippo Bucks!",
    "message": "Your account has been credited with $750 welcome bonus",
    "type": "system",
    "isRead": false,
    "createdAt": new Date()
  }
]);

// Favorites
db.favorites.createIndex({ "userId": 1, "assetId": 1 }, { unique: true });
db.favorites.insertMany([
  {
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id,
    "assetId": db.assets.findOne({"name": "Canon EOS R5"})._id,
    "createdAt": new Date()
  }
]);

print("Database setup complete!");
print("Users: " + db.users.countDocuments());
print("Assets: " + db.assets.countDocuments());
print("Votes: " + db.votes.countDocuments());
print("Notifications: " + db.notifications.countDocuments());
print("Favorites: " + db.favorites.countDocuments());