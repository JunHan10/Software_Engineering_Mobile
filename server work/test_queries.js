use flutter_app;

// Check if collections exist and count documents
print("=== COLLECTION COUNTS ===");
print("Users: " + db.users.countDocuments());
print("Assets: " + db.assets.countDocuments());
print("Votes: " + db.votes.countDocuments());
print("Notifications: " + db.notifications.countDocuments());
print("Favorites: " + db.favorites.countDocuments());

// Show all users
print("\n=== ALL USERS ===");
db.users.find().forEach(printjson);

// Show all assets
print("\n=== ALL ASSETS ===");
db.assets.find().forEach(printjson);

// Find specific user
print("\n=== FIND JOHN ===");
db.users.findOne({"email": "john@example.com"});

// Show assets with owner info
print("\n=== ASSETS WITH OWNERS ===");
db.assets.aggregate([
  {
    $lookup: {
      from: "users",
      localField: "ownerId",
      foreignField: "_id",
      as: "owner"
    }
  }
]).forEach(printjson);