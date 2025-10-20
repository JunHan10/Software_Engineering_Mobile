// Test script for messaging endpoints
const axios = require('axios');

const BASE_URL = 'http://192.168.1.144:3000/api';

async function testMessagingEndpoints() {
  console.log('🧪 Testing Messaging Endpoints...\n');

  try {
    // Test 1: Create a conversation
    console.log('1️⃣ Testing conversation creation...');
    const conversationData = {
      itemId: 'test-item-123',
      itemName: 'Test Item',
      ownerId: 'owner-123',
      ownerName: 'John Doe',
      borrowerId: 'borrower-456',
      borrowerName: 'Jane Smith'
    };

    const conversationResponse = await axios.post(`${BASE_URL}/conversations`, conversationData);
    console.log('✅ Conversation created:', conversationResponse.data._id);
    const conversationId = conversationResponse.data._id;

    // Test 2: Send a message
    console.log('\n2️⃣ Testing message sending...');
    const messageData = {
      senderId: 'borrower-456',
      senderName: 'Jane Smith',
      content: 'Hi! I\'m interested in borrowing your Test Item. When would be a good time?',
      type: 'text'
    };

    const messageResponse = await axios.post(`${BASE_URL}/conversations/${conversationId}/messages`, messageData);
    console.log('✅ Message sent:', messageResponse.data._id);

    // Test 3: Get conversation messages
    console.log('\n3️⃣ Testing message retrieval...');
    const messagesResponse = await axios.get(`${BASE_URL}/conversations/${conversationId}/messages`);
    console.log('✅ Messages retrieved:', messagesResponse.data.length, 'messages');

    // Test 4: Get user conversations
    console.log('\n4️⃣ Testing user conversations...');
    const userConversationsResponse = await axios.get(`${BASE_URL}/conversations/user/borrower-456`);
    console.log('✅ User conversations:', userConversationsResponse.data.length, 'conversations');

    // Test 5: Mark messages as read
    console.log('\n5️⃣ Testing mark as read...');
    const readResponse = await axios.put(`${BASE_URL}/conversations/${conversationId}/read`, {
      userId: 'borrower-456'
    });
    console.log('✅ Messages marked as read:', readResponse.data.success);

    // Test 6: Find existing conversation
    console.log('\n6️⃣ Testing find existing conversation...');
    const findResponse = await axios.get(`${BASE_URL}/conversations/find?itemId=test-item-123&borrowerId=borrower-456`);
    console.log('✅ Found existing conversation:', findResponse.data ? 'Yes' : 'No');

    console.log('\n🎉 All messaging endpoints are working correctly!');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run the test
testMessagingEndpoints();
