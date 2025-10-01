// lib/models/category.dart

import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String color;
  final List<Item> items;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final IconData icon;
  final String imageUrl;
  final String categoryId;
  final String ownerId;
  final String ownerName;
  final bool isAvailable;
  final List<String> tags;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.icon,
    required this.imageUrl,
    required this.categoryId,
    required this.ownerId,
    required this.ownerName,
    required this.isAvailable,
    required this.tags,
  });

  String get formattedPrice => '$currency ${price.toStringAsFixed(2)}';
}
