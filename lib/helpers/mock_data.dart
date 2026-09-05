class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerName;
  final String sellerPhone;
  final String sellerWhatsApp;
  final String distance;
  final double rating;
  final String imageUrl;
  final List<String> tags;
  final String category;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerWhatsApp,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.images,
  });
}

class MockData {
  static final List<Product> products = [
    Product(
      id: '1',
      title: 'iPhone 15 Pro Max',
      description: 'Super Retina XDR OLED, 120Hz, HDR10, Dolby Vision. A17 Pro chip. Triple camera setup with 5x optical zoom. 256GB, Titanium Blue. Excellent condition, box and original cable included.',
      price: 1299.00,
      sellerName: 'Karim Electronics',
      sellerPhone: '+8801712345678',
      sellerWhatsApp: '+8801712345678',
      distance: '1.2 km',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=500',
      tags: ['iphone', 'iphone15', 'apple', 'mobile', 'smartphone', 'usediphone', 'iphonepro'],
      category: 'Electronics',
      images: [
        'https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=500',
        'https://images.unsplash.com/photo-1695048133140-ae011f67f70b?q=80&w=500',
      ],
    ),
    Product(
      id: '2',
      title: 'MacBook Pro 14" M3',
      description: 'Apple M3 Chip with 8-core CPU and 10-core GPU, 8GB Unified Memory, 512GB SSD storage. Space Grey. 100% battery health, only 3 months used with official warranty.',
      price: 1599.00,
      sellerName: 'Mac Studio BD',
      sellerPhone: '+8801812345678',
      sellerWhatsApp: '+8801812345678',
      distance: '2.5 km',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=500',
      tags: ['macbook', 'laptop', 'apple', 'computer', 'macbookpro', 'm3'],
      category: 'Electronics',
      images: [
        'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=500',
        'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?q=80&w=500',
      ],
    ),
    Product(
      id: '3',
      title: 'Yamaha R15 V4 (Blue)',
      description: 'Racing Blue, dual channel ABS, quickshifter, traction control. 155cc VVA engine. Only 4,500 km ridden, single hand driven, all documents are up-to-date.',
      price: 3800.00,
      sellerName: 'Dhaka Speed Masters',
      sellerPhone: '+8801912345678',
      sellerWhatsApp: '+8801912345678',
      distance: '3.8 km',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=500',
      tags: ['bike', 'yamaha', 'motorcycle', 'r15', 'sportbike', 'usedbike'],
      category: 'Vehicles',
      images: [
        'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?q=80&w=500',
        'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?q=80&w=500',
      ],
    ),
    Product(
      id: '4',
      title: 'Samsung Galaxy S24 Ultra',
      description: 'Dynamic AMOLED 2X, 120Hz, HDR10+, 2600 nits. Snapdragon 8 Gen 3. Quad camera with 200MP main sensor. Built-in S-Pen. Titanium Black, 12GB RAM, 256GB storage.',
      price: 1150.00,
      sellerName: 'Samsung Plaza Gulshan',
      sellerPhone: '+8801612345678',
      sellerWhatsApp: '+8801612345678',
      distance: '0.8 km',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?q=80&w=500',
      tags: ['samsung', 'galaxy', 's24', 'mobile', 'smartphone', 'android', 's24ultra'],
      category: 'Electronics',
      images: [
        'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?q=80&w=500',
      ],
    ),
    Product(
      id: '5',
      title: 'Nike Air Max 90',
      description: 'Classic lifestyle sneakers with visible Air-Sole unit in the heel. White and black accents. US Size 10. Brand new with box and extra laces.',
      price: 130.00,
      sellerName: 'Sneaker Head BD',
      sellerPhone: '+8801512345678',
      sellerWhatsApp: '+8801512345678',
      distance: '1.7 km',
      rating: 4.5,
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500',
      tags: ['shoes', 'nike', 'sneakers', 'footwear', 'airmax'],
      category: 'Fashion',
      images: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500',
      ],
    ),
    Product(
      id: '6',
      title: 'Premium Leather Sofa Set',
      description: '3+2+1 seating sofa set made of genuine Italian leather and mahogany wood frame. Elegant design, super comfortable foam, no tears or scratches.',
      price: 650.00,
      sellerName: 'Furniture Land',
      sellerPhone: '+8801312345678',
      sellerWhatsApp: '+8801312345678',
      distance: '4.5 km',
      rating: 4.4,
      imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=500',
      tags: ['sofa', 'furniture', 'leather', 'livingroom', 'home'],
      category: 'Home & Living',
      images: [
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=500',
      ],
    )
  ];
}
