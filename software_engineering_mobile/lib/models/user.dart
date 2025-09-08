class User {
  final String? id; // For database primary key
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final int? age;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipcode;
  final double currency;
  final List<Asset> assets;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.age,
    this.streetAddress,
    this.city,
    this.state,
    this.zipcode,
    required this.currency,
    required this.assets,
  });

  // From JSON (for current file-based approach)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      currency: json['currency'].toDouble(),
      assets: (json['assets'] as List)
          .map((asset) => Asset.fromJson(asset))
          .toList(),
    );
  }

  // To JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'currency': currency,
      'assets': assets.map((asset) => asset.toJson()).toList(),
    };
  }
}

class Asset {
  final String? id;
  final String name;
  final double value;
  final String description;

  Asset({
    this.id,
    required this.name,
    required this.value,
    required this.description,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      value: json['value'].toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'description': description,
    };
  }
}