// lib/services/category_service.dart

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryService {
  static final List<Category> _categories = [
    Category(
      id: 'electronics',
      name: 'Electronics',
      description: 'Gadgets, computers, and electronic devices',
      icon: Icons.devices,
      color: '#2196F3',
      items: [
        Item(
          id: 'laptop1',
          name: 'MacBook Pro 13"',
          description:
              '2023 MacBook Pro with M2 chip, 8GB RAM, 256GB SSD. Perfect for students and professionals.',
          price: 1200.00,
          currency: 'HB',
          icon: Icons.laptop_mac,
          imageUrl: '',
          categoryId: 'electronics',
          ownerId: 'user1',
          ownerName: 'Alex Johnson',
          isAvailable: true,
          tags: ['laptop', 'macbook', 'computer', 'm2'],
        ),
        Item(
          id: 'headphones1',
          name: 'Sony WH-1000XM4',
          description:
              'Noise-canceling wireless headphones with excellent sound quality.',
          price: 280.00,
          currency: 'HB',
          icon: Icons.headphones,
          imageUrl: '',
          categoryId: 'electronics',
          ownerId: 'user2',
          ownerName: 'Sarah Chen',
          isAvailable: true,
          tags: ['headphones', 'wireless', 'noise-canceling', 'sony'],
        ),
        Item(
          id: 'phone1',
          name: 'iPhone 14',
          description: 'Latest iPhone with 128GB storage, excellent condition.',
          price: 800.00,
          currency: 'HB',
          icon: Icons.phone_iphone,
          imageUrl: '',
          categoryId: 'electronics',
          ownerId: 'user3',
          ownerName: 'Mike Davis',
          isAvailable: true,
          tags: ['iphone', 'phone', 'apple', 'mobile'],
        ),
      ],
    ),
    Category(
      id: 'sports',
      name: 'Sports & Fitness',
      description: 'Sports equipment, fitness gear, and outdoor activities',
      icon: Icons.sports_soccer,
      color: '#4CAF50',
      items: [
        Item(
          id: 'bike1',
          name: 'Mountain Bike',
          description:
              'Trek mountain bike, 21-speed, great for trails and commuting.',
          price: 450.00,
          currency: 'HB',
          icon: Icons.directions_bike,
          imageUrl: '',
          categoryId: 'sports',
          ownerId: 'user4',
          ownerName: 'Emma Wilson',
          isAvailable: true,
          tags: ['bike', 'mountain', 'cycling', 'outdoor'],
        ),
        Item(
          id: 'soccer1',
          name: 'Soccer Ball',
          description: 'Professional quality soccer ball, barely used.',
          price: 25.00,
          currency: 'HB',
          icon: Icons.sports_soccer,
          imageUrl: '',
          categoryId: 'sports',
          ownerId: 'user5',
          ownerName: 'David Lee',
          isAvailable: true,
          tags: ['soccer', 'football', 'ball', 'sports'],
        ),
        Item(
          id: 'yoga1',
          name: 'Yoga Mat',
          description:
              'Premium yoga mat with carrying strap, non-slip surface.',
          price: 35.00,
          currency: 'HB',
          icon: Icons.fitness_center,
          imageUrl: '',
          categoryId: 'sports',
          ownerId: 'user6',
          ownerName: 'Lisa Park',
          isAvailable: true,
          tags: ['yoga', 'mat', 'fitness', 'exercise'],
        ),
      ],
    ),
    Category(
      id: 'furniture',
      name: 'Furniture',
      description: 'Desks, chairs, and home furniture',
      icon: Icons.chair,
      color: '#FF9800',
      items: [
        Item(
          id: 'chair1',
          name: 'Ergonomic Office Chair',
          description:
              'Comfortable office chair with lumbar support and adjustable height.',
          price: 120.00,
          currency: 'HB',
          icon: Icons.chair,
          imageUrl: '',
          categoryId: 'furniture',
          ownerId: 'user7',
          ownerName: 'Tom Brown',
          isAvailable: true,
          tags: ['chair', 'office', 'ergonomic', 'desk'],
        ),
        Item(
          id: 'desk1',
          name: 'Standing Desk',
          description:
              'Electric standing desk with memory presets, excellent condition.',
          price: 300.00,
          currency: 'HB',
          icon: Icons.desk,
          imageUrl: '',
          categoryId: 'furniture',
          ownerId: 'user8',
          ownerName: 'Rachel Green',
          isAvailable: true,
          tags: ['desk', 'standing', 'electric', 'office'],
        ),
        Item(
          id: 'bookshelf1',
          name: 'Bookshelf',
          description:
              '5-tier wooden bookshelf, perfect for books and decorations.',
          price: 80.00,
          currency: 'HB',
          icon: Icons.library_books,
          imageUrl: '',
          categoryId: 'furniture',
          ownerId: 'user9',
          ownerName: 'Kevin Smith',
          isAvailable: true,
          tags: ['bookshelf', 'wooden', 'storage', 'books'],
        ),
      ],
    ),
    Category(
      id: 'books',
      name: 'Books & Education',
      description: 'Textbooks, novels, and educational materials',
      icon: Icons.menu_book,
      color: '#9C27B0',
      items: [
        Item(
          id: 'textbook1',
          name: 'Calculus Textbook',
          description:
              'Stewart Calculus 8th Edition, used for MATH 101, good condition.',
          price: 60.00,
          currency: 'HB',
          icon: Icons.calculate,
          imageUrl: '',
          categoryId: 'books',
          ownerId: 'user10',
          ownerName: 'Amy Zhang',
          isAvailable: true,
          tags: ['calculus', 'math', 'textbook', 'education'],
        ),
        Item(
          id: 'novel1',
          name: 'The Great Gatsby',
          description: 'Classic American novel, paperback edition.',
          price: 8.00,
          currency: 'HB',
          icon: Icons.book,
          imageUrl: '',
          categoryId: 'books',
          ownerId: 'user11',
          ownerName: 'Chris Taylor',
          isAvailable: true,
          tags: ['novel', 'classic', 'literature', 'fiction'],
        ),
        Item(
          id: 'programming1',
          name: 'Clean Code',
          description: 'Programming best practices book by Robert Martin.',
          price: 25.00,
          currency: 'HB',
          icon: Icons.code,
          imageUrl: '',
          categoryId: 'books',
          ownerId: 'user12',
          ownerName: 'Jordan Kim',
          isAvailable: true,
          tags: ['programming', 'code', 'software', 'development'],
        ),
      ],
    ),
    Category(
      id: 'kitchen',
      name: 'Kitchen & Appliances',
      description: 'Kitchen tools, appliances, and cooking equipment',
      icon: Icons.kitchen,
      color: '#F44336',
      items: [
        Item(
          id: 'coffee1',
          name: 'Coffee Maker',
          description:
              'Drip coffee maker, 12-cup capacity, programmable timer.',
          price: 45.00,
          currency: 'HB',
          icon: Icons.coffee,
          imageUrl: '',
          categoryId: 'kitchen',
          ownerId: 'user13',
          ownerName: 'Maria Garcia',
          isAvailable: true,
          tags: ['coffee', 'maker', 'appliance', 'kitchen'],
        ),
        Item(
          id: 'blender1',
          name: 'Blender',
          description: 'High-speed blender for smoothies and food prep.',
          price: 65.00,
          currency: 'HB',
          icon: Icons.blender,
          imageUrl: '',
          categoryId: 'kitchen',
          ownerId: 'user14',
          ownerName: 'James Wilson',
          isAvailable: true,
          tags: ['blender', 'smoothie', 'kitchen', 'appliance'],
        ),
        Item(
          id: 'microwave1',
          name: 'Microwave',
          description: 'Compact microwave oven, perfect for dorm rooms.',
          price: 75.00,
          currency: 'HB',
          icon: Icons.microwave,
          imageUrl: '',
          categoryId: 'kitchen',
          ownerId: 'user15',
          ownerName: 'Sophie Martin',
          isAvailable: true,
          tags: ['microwave', 'oven', 'kitchen', 'appliance'],
        ),
      ],
    ),
    Category(
      id: 'music',
      name: 'Music & Instruments',
      description:
          'Musical instruments, audio equipment, and music accessories',
      icon: Icons.music_note,
      color: '#E91E63',
      items: [
        Item(
          id: 'guitar1',
          name: 'Acoustic Guitar',
          description:
              'Yamaha acoustic guitar, perfect for beginners and intermediate players.',
          price: 150.00,
          currency: 'HB',
          icon: Icons.piano,
          imageUrl: '',
          categoryId: 'music',
          ownerId: 'user16',
          ownerName: 'Noah Anderson',
          isAvailable: true,
          tags: ['guitar', 'acoustic', 'music', 'instrument'],
        ),
        Item(
          id: 'keyboard1',
          name: 'Digital Piano',
          description: '88-key weighted digital piano with stand and bench.',
          price: 400.00,
          currency: 'HB',
          icon: Icons.piano,
          imageUrl: '',
          categoryId: 'music',
          ownerId: 'user17',
          ownerName: 'Olivia Davis',
          isAvailable: true,
          tags: ['piano', 'keyboard', 'digital', 'music'],
        ),
        Item(
          id: 'speaker1',
          name: 'Bluetooth Speaker',
          description:
              'Portable Bluetooth speaker with excellent sound quality.',
          price: 50.00,
          currency: 'HB',
          icon: Icons.speaker,
          imageUrl: '',
          categoryId: 'music',
          ownerId: 'user18',
          ownerName: 'Ethan Brown',
          isAvailable: true,
          tags: ['speaker', 'bluetooth', 'portable', 'audio'],
        ),
      ],
    ),
  ];

  static List<Category> getAllCategories() {
    return _categories;
  }

  static List<Item> getAllItems() {
    return _categories.expand((category) => category.items).toList();
  }

  static List<Category> searchCategories(String query) {
    if (query.isEmpty) return _categories;

    final lowercaseQuery = query.toLowerCase();
    return _categories.where((category) {
      return category.name.toLowerCase().contains(lowercaseQuery) ||
          category.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  static List<Item> searchItems(String query) {
    if (query.isEmpty) return getAllItems();

    final lowercaseQuery = query.toLowerCase();
    return getAllItems().where((item) {
      return item.name.toLowerCase().contains(lowercaseQuery) ||
          item.description.toLowerCase().contains(lowercaseQuery) ||
          item.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static Item? getItemById(String id) {
    try {
      return getAllItems().firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}
