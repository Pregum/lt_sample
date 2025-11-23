import 'dart:math';
import '../models/product.dart';
import '../models/user_profile.dart';

class MockDataService {
  static final Random _random = Random();

  static List<Product> generateProducts(int count) {
    final categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Sports'];
    final products = <Product>[];

    for (int i = 0; i < count; i++) {
      products.add(Product(
        id: 'prod_${i + 1}',
        name: 'Product ${i + 1}',
        description:
            'This is a high-quality product with excellent features and great value for money. Perfect for everyday use.',
        price: 10.0 + _random.nextDouble() * 990.0,
        imageUrl: 'https://via.placeholder.com/150x150?text=Product+${i + 1}',
        stock: _random.nextInt(100),
        category: categories[_random.nextInt(categories.length)],
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      ));
    }

    return products;
  }

  static UserProfile generateUserProfile({
    required String userId,
    bool isEmpty = false,
    bool isPartial = false,
    bool isComplete = false,
  }) {
    if (isEmpty) {
      return UserProfile.empty(userId);
    }

    if (isPartial) {
      return UserProfile(
        id: userId,
        name: 'John',
        email: 'john@example.com',
        bio: null,
        avatarUrl: null,
        phoneNumber: null,
        birthDate: null,
        interests: const ['Technology'],
        isComplete: false,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      );
    }

    if (isComplete) {
      return UserProfile(
        id: userId,
        name: 'John Doe',
        email: 'john.doe@example.com',
        bio:
            'Passionate developer and tech enthusiast. Love building amazing apps and exploring new technologies.',
        avatarUrl: 'https://via.placeholder.com/150x150?text=JD',
        phoneNumber: '+1234567890',
        birthDate: DateTime(1990, 5, 15),
        interests: const [
          'Technology',
          'Programming',
          'Mobile Development',
          'UI/UX Design',
          'Open Source'
        ],
        isComplete: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }

    return UserProfile.empty(userId);
  }

  static Future<T> simulateNetworkDelay<T>(
    T data, {
    Duration delay = const Duration(seconds: 2),
    bool shouldFail = false,
    String? errorMessage,
  }) async {
    await Future.delayed(delay);

    if (shouldFail) {
      throw Exception(errorMessage ?? 'Network request failed');
    }

    return data;
  }

  static List<Product> searchProducts(
    List<Product> products,
    String query,
  ) {
    if (query.isEmpty) return products;

    final lowerQuery = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}