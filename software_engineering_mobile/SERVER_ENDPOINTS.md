# Server Endpoints for Messaging System

## Database Schema

### Conversations Collection
```javascript
{
  _id: ObjectId,
  itemId: String,           // ID of the item being discussed
  itemName: String,         // Name of the item (for display)
  ownerId: String,          // ID of the item owner
  ownerName: String,        // Name of the item owner
  borrowerId: String,       // ID of the person wanting to borrow
  borrowerName: String,     // Name of the borrower
  createdAt: Date,
  updatedAt: Date,
  status: String,           // 'active', 'completed', 'cancelled', 'archived'
  lastMessage: Object,      // Most recent message (embedded)
  unreadCount: Number       // Unread count for each user
}
```

### Messages Collection
```javascript
{
  _id: ObjectId,
  conversationId: ObjectId, // Reference to conversation
  senderId: String,         // ID of the user who sent the message
  senderName: String,       // Name of the sender (for display)
  content: String,          // Message content
  type: String,             // 'text', 'image', 'system', 'request', 'approval', 'rejection'
  createdAt: Date,
  isRead: Boolean,
  metadata: Object          // Additional data (image URLs, etc.)
}
```

## Required API Endpoints

### 1. Create Conversation
```
POST /api/conversations
Body: {
  itemId: String,
  itemName: String,
  ownerId: String,
  ownerName: String,
  borrowerId: String,
  borrowerName: String
}
Response: Conversation object
```

### 2. Get User Conversations
```
GET /api/conversations/user/:userId
Response: Array of Conversation objects
```

### 3. Get Specific Conversation
```
GET /api/conversations/:conversationId
Response: Conversation object
```

### 4. Get Conversation Messages
```
GET /api/conversations/:conversationId/messages
Response: Array of Message objects
```

### 5. Send Message
```
POST /api/conversations/:conversationId/messages
Body: {
  senderId: String,
  senderName: String,
  content: String,
  type: String,
  metadata: Object
}
Response: Message object
```

### 6. Mark Messages as Read
```
PUT /api/conversations/:conversationId/read
Body: {
  userId: String
}
Response: Success status
```

### 7. Update Conversation Status
```
PUT /api/conversations/:conversationId/status
Body: {
  status: String
}
Response: Success status
```

### 8. Find Existing Conversation
```
GET /api/conversations/find?itemId=:itemId&borrowerId=:borrowerId
Response: Conversation object or null
```

## Sample Express.js Implementation

```javascript
// conversations.js
const express = require('express');
const router = express.Router();
const Conversation = require('../models/Conversation');
const Message = require('../models/Message');

// Create conversation
router.post('/', async (req, res) => {
  try {
    const { itemId, itemName, ownerId, ownerName, borrowerId, borrowerName } = req.body;
    
    // Check if conversation already exists
    const existing = await Conversation.findOne({
      itemId,
      $or: [
        { ownerId, borrowerId },
        { ownerId: borrowerId, borrowerId: ownerId }
      ]
    });
    
    if (existing) {
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
    res.status(201).json(conversation);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get user conversations
router.get('/user/:userId', async (req, res) => {
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

// Get conversation messages
router.get('/:conversationId/messages', async (req, res) => {
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
router.post('/:conversationId/messages', async (req, res) => {
  try {
    const { senderId, senderName, content, type = 'text', metadata } = req.body;
    
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
    
    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mark messages as read
router.put('/:conversationId/read', async (req, res) => {
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

module.exports = router;
```

## MongoDB Models

```javascript
// models/Conversation.js
const mongoose = require('mongoose');

const conversationSchema = new mongoose.Schema({
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

module.exports = mongoose.model('Conversation', conversationSchema);
```

```javascript
// models/Message.js
const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  conversationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation', required: true },
  senderId: { type: String, required: true },
  senderName: { type: String, required: true },
  content: { type: String, required: true },
  type: { type: String, enum: ['text', 'image', 'system', 'request', 'approval', 'rejection'], default: 'text' },
  createdAt: { type: Date, default: Date.now },
  isRead: { type: Boolean, default: false },
  metadata: { type: mongoose.Schema.Types.Mixed }
});

module.exports = mongoose.model('Message', messageSchema);
```

## Integration Steps

1. **Add the conversation routes to your main server file:**
```javascript
const conversationRoutes = require('./routes/conversations');
app.use('/api/conversations', conversationRoutes);
```

2. **Update your main app to include the messaging navigation:**
   - Add a "Messages" tab to your main navigation
   - Link it to the `ConversationListPage`

3. **Test the endpoints using Postman or similar tools before testing in the app**

4. **Add real-time updates (optional):**
   - Consider using Socket.io for real-time message updates
   - This would require additional setup but provides a better user experience
