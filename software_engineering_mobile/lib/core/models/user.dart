/// User Model - Core data structure representing a user in the loan application
///
/// This class serves as the primary data model for user information throughout
/// the application. It's designed to be database-agnostic, meaning it can work
/// with JSON files, SharedPreferences, MongoDB, or any other storage system.
///
/// Design Decisions:
/// - Uses nullable ID for flexibility (auto-generated when saving to storage)
/// - Separates address into components for better data structure and validation
/// - Includes both authentication (email/password) and profile data
/// - Uses double for currency to handle decimal values accurately
/// - Contains assets list for loan collateral tracking
class User {
  // Nullable ID allows for new users (no ID) vs existing users (with ID)
  // This pattern works well with both local storage and databases
  final String? id;

  // Authentication fields - required for login functionality
  final String email;    // Primary identifier for user accounts
  final String password; // Stored in plain text for development (should be hashed in production)

  // Personal information - collected during registration
  final String firstName;
  final String lastName;
  final int? age; // Nullable because age might not be provided in all cases
  final String? phone; // Phone number - optional field

  // Address components - separated for better data structure and validation
  // Nullable because address might be optional or collected separately
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? zipcode;

  // Financial data
  final double currency; // User's available currency for loans
  final List<Asset> assets; // List of assets that can be used as collateral

  // NEW: Hippopotamoney balance stored in cents to avoid floating point issues
  final int hippoBalanceCents;

  // NEW: Total number of completed transactions for the user
  final int transactionCount;

  /// Constructor with named parameters for clarity and flexibility
  /// Required fields are those essential for basic user functionality
  /// Optional fields can be added later or left empty
  User({
    this.id,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.age,
    this.phone,
    this.streetAddress,
    this.city,
    this.state,
    this.zipcode,
    required this.currency,
    required this.assets,
    this.hippoBalanceCents = 0, // NEW: default to 0
    this.transactionCount = 0, // NEW: default to 0
  });

  // NEW: copyWith method for immutability and easy field updates
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    int? age,
    String? phone,
    String? streetAddress,
    String? city,
    String? state,
    String? zipcode,
    double? currency,
    List<Asset>? assets,
    int? hippoBalanceCents,
    int? transactionCount,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      zipcode: zipcode ?? this.zipcode,
      currency: currency ?? this.currency,
      assets: assets ?? this.assets,
      hippoBalanceCents: hippoBalanceCents ?? this.hippoBalanceCents,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  /// Factory constructor for creating User objects from JSON data
  ///
  /// This is essential for:
  /// - Loading data from SharedPreferences
  /// - Reading from JSON files (like test_data.json)
  /// - Receiving data from APIs
  /// - Database deserialization
  ///
  /// Uses .toDouble() to ensure currency is always a double type,
  /// even if JSON contains an integer
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      age: json['age'],
      phone: json['phone'],
      streetAddress: json['streetAddress'],
      city: json['city'],
      state: json['state'],
      zipcode: json['zipcode'],
      // Ensure currency is always a double for consistent calculations
      currency: json['currency'].toDouble(),
      // Convert assets array from JSON to List<Asset> objects
      assets: (json['assets'] as List)
          .map((asset) => Asset.fromJson(asset))
          .toList(),
      hippoBalanceCents: (json['hippoBalanceCents'] ?? 0) as int, // NEW
      transactionCount: (json['transactionCount'] ?? 0) as int, // NEW
    );
  }

  /// Converts User object to JSON Map for storage
  ///
  /// This is essential for:
  /// - Saving to SharedPreferences
  /// - Writing to JSON files
  /// - Sending to APIs
  /// - Database serialization
  ///
  /// All fields are included, even nullable ones, to maintain
  /// data integrity and allow for future expansion
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'phone': phone,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipcode': zipcode,
      'currency': currency,
      // Convert assets list to JSON array
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'hippoBalanceCents': hippoBalanceCents, // NEW
      'transactionCount': transactionCount, // NEW
    };
  }
}

/// Asset Model - Represents items that users can use as loan collateral
///
/// Assets are valuable items that users own and can potentially loan out
/// or use as collateral for loans. This model tracks the essential information
/// needed for loan processing and valuation.
///
/// Design Decisions:
/// - Nullable ID for same flexibility as User model
/// - Double value for precise monetary calculations
/// - Description field for detailed asset information
/// - Simple structure that can be extended for specific asset types
class Asset {
  final String? id; // Nullable for new vs existing assets
  final String name; // Asset name/title (e.g., "MacBook Pro", "Car")
  final double value; // Monetary value in the app's base currency
  final String description; // Detailed description for identification
  final List<String> imagePaths; // Local file paths to images for this asset

  /// Constructor with required fields for essential asset data
  /// ID is optional to allow for new asset creation
  Asset({
    this.id,
    required this.name,
    required this.value,
    required this.description,
    this.imagePaths = const [],
  });

  /// Factory constructor for creating Asset objects from JSON
  /// Mirrors the User.fromJson pattern for consistency
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      // Ensure value is always a double for monetary calculations
      value: json['value'].toDouble(),
      description: json['description'],
      imagePaths: (json['imagePaths'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  /// Converts Asset object to JSON Map for storage
  /// Mirrors the User.toJson pattern for consistency
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'description': description,
      'imagePaths': imagePaths,
    };
  }
}
