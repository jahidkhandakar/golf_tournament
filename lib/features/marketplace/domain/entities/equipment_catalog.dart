import 'package:flutter/material.dart';

/// One catalogue entry, whose [imageKey] matches a photo under
/// assets/pics/equipments/<imageKey>.jpg.
typedef EquipmentItem = ({String title, double price, String imageKey, IconData icon});

/// The 15 product types the marketplace sells — one per bundled equipment
/// photo, so there's no image reuse. Shared by the global marketplace and each
/// club's marketplace.
const List<EquipmentItem> equipmentCatalog = [
  (title: 'Driver, 10.5°', price: 240, imageKey: 'driver', icon: Icons.sports_golf),
  (title: 'Iron set, 5–PW', price: 520, imageKey: 'irons', icon: Icons.golf_course),
  (title: 'Golf balls, dozen', price: 32, imageKey: 'balls', icon: Icons.sports_golf),
  (title: 'Leather glove & tools', price: 45, imageKey: 'glove', icon: Icons.back_hand_outlined),
  (title: 'Cart bag, loaded', price: 180, imageKey: 'cart_bag', icon: Icons.golf_course),
  (title: 'Sun Mountain stand bag', price: 85, imageKey: 'stand_bag', icon: Icons.backpack_outlined),
  (title: 'Golf shoes, size 10.5', price: 60, imageKey: 'shoes', icon: Icons.hiking_outlined),
  (title: 'Tour balls, sleeve', price: 14, imageKey: 'tour_balls', icon: Icons.sports_golf),
  (title: 'GPS golf watch', price: 190, imageKey: 'watch', icon: Icons.watch_outlined),
  (title: 'Players towel', price: 22, imageKey: 'towel', icon: Icons.dry_cleaning_outlined),
  (title: 'Complete starter set', price: 430, imageKey: 'starter_set', icon: Icons.golf_course),
  (title: 'Cap & sunglasses', price: 40, imageKey: 'cap', icon: Icons.visibility_outlined),
  (title: 'Scotty Cameron putter', price: 260, imageKey: 'putter', icon: Icons.straighten_outlined),
  (title: 'Wooden tees, 30-pack', price: 12, imageKey: 'tees', icon: Icons.park_outlined),
  (title: 'Electric golf cart', price: 3200, imageKey: 'cart', icon: Icons.electric_car_outlined),
];
