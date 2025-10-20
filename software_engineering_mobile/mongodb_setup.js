use software_engineering_mobile;

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
  }
]);
db.votes.createIndex({ "itemId": 1 });

// Insert sample votes
db.votes.insertMany([
  {
    "_id": ObjectId(),
    "itemId": db.assets.findOne({"name": "Canon EOS R5"})._id.toString(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id.toString(),
    "vote": 1, // 1 for upvote, -1 for downvote, 0 for no vote
    "createdAt": new Date()
  },
  {
    "_id": ObjectId(),
    "itemId": db.assets.findOne({"name": "MacBook Pro 14-inch"})._id.toString(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id.toString(),
    "vote": 1,
    "createdAt": new Date()
  }
]);

// ============================================================================
// 8. NOTIFICATIONS COLLECTION
// ============================================================================
db.createCollection("notifications");

// Create indexes for notifications
db.notifications.createIndex({ "userId": 1 });
db.notifications.createIndex({ "isRead": 1 });
db.notifications.createIndex({ "createdAt": -1 });

// Insert sample notifications
db.notifications.insertMany([
  {
    "_id": ObjectId(),
    "userId": db.users.findOne({"email": "john.doe@example.com"})._id,
    "title": "New loan request",
    "message": "Jane Smith wants to borrow your Canon EOS R5",
    "type": "loan_request",
    "relatedId": null,
    "isRead": false,
    "createdAt": new Date()
  },
  {
    "_id": ObjectId(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id,
    "title": "Welcome to Hippo Bucks!",
    "message": "Your account has been credited with $750 welcome bonus",
    "type": "system",
    "relatedId": null,
    "isRead": false,
    "createdAt": new Date()
  }
]);

// ============================================================================
// 9. FAVORITES COLLECTION
// ============================================================================
db.createCollection("favorites");

// Create indexes for favorites
db.favorites.createIndex({ "userId": 1, "assetId": 1 }, { unique: true });
db.favorites.createIndex({ "userId": 1 });

// Insert sample favorites
db.favorites.insertMany([
  {
    "_id": ObjectId(),
    "userId": db.users.findOne({"email": "jane.smith@example.com"})._id,
    "assetId": db.assets.findOne({"name": "Canon EOS R5"})._id,
    "createdAt": new Date()
  }
]);

// ============================================================================
// 10. USER SESSIONS COLLECTION (for authentication tracking)
// ============================================================================
db.createCollection("user_sessions");

// Create indexes for sessions
db.sessions.createIndex({ "userId": 1 });
db.sessions.createIndex({ "sessionToken": 1 }, { unique: true });
db.sessions.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 });

// ============================================================================
// PRINT SUMMARY
// ============================================================================
print("=".repeat(60));
print("DATABASE SETUP COMPLETE");
print("=".repeat(60));
print("Collections created:");
print("- users: " + db.users.countDocuments());
print("- assets: " + db.assets.countDocuments());
print("- categories: " + db.categories.countDocuments());
print("- loans: " + db.loans.countDocuments());
print("- transactions: " + db.transactions.countDocuments());
print("- comments: " + db.comments.countDocuments());
print("- votes: " + db.votes.countDocuments());
print("- notifications: " + db.notifications.countDocuments());
print("- favorites: " + db.favorites.countDocuments());
print("- user_sessions: " + db.user_sessions.countDocuments());
print("=".repeat(60));
print("Sample data inserted successfully!");
print("Database ready for Flutter app integration.");