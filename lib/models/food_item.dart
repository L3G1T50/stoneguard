// ─── FOOD DATA MODEL ──────────────────────────────────────────

// Shared tips to avoid repeating the same text hundreds of times.
const String beverageTip =
    'Stay well hydrated — aim for 80+ oz of water daily. Coffee and orange juice are safe. Avoid Slim Fast and carrot juice.';

enum OxalateLevel { low, moderate, high, veryHigh }

class FoodItem {
  final String name;
  final String serving;
  final double oxalateMg;
  final OxalateLevel level;
  final String category;
  final String tip;

  const FoodItem({
    required this.name,
    required this.serving,
    required this.oxalateMg,
    required this.level,
    required this.category,
    required this.tip,
  });
}

// ─── FOOD DATABASE ────────────────────────────────────────────
// ─── HARVARD OXALATE DATABASE (431 foods) ─────────────────────
// Source: Harvard T.H. Chan School of Public Health, Nov. 2023
// Oxalate measurements by Dr. John Knight, University of Alabama School of Medicine

const List<FoodItem> foodDatabase = [
  FoodItem(name: '100% Natural Granola Oats Wheat & Honey', serving: '2/3 cup', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: '40% Bran Flakes', serving: '1 cup', oxalateMg: 42.7, level: OxalateLevel.high, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'All Bran Kelloggs', serving: '2/3 cup', oxalateMg: 34.6, level: OxalateLevel.high, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Basic 4', serving: '1 cup', oxalateMg: 11.2, level: OxalateLevel.moderate, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: "Cap'N Crunch", serving: '1 cup', oxalateMg: 1.6, level: OxalateLevel.low, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Cheerios', serving: '1 1/2 cup', oxalateMg: 7.4, level: OxalateLevel.low, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Cheerios Multigrain', serving: '1 1/3 cup', oxalateMg: 5.1, level: OxalateLevel.low, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Cheerios Honey Nut', serving: '1 cup', oxalateMg: 6.6, level: OxalateLevel.low, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Krave Chocolate', serving: '1 cup', oxalateMg: 14.7, level: OxalateLevel.moderate, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  FoodItem(name: 'Cinnamon Toast Crunch', serving: '1 cup', oxalateMg: 7.2, level: OxalateLevel.low, category: 'Cold Cereal', tip: 'Stick to low-oxalate cereals. Corn Flakes and Rice Krispies are the safest options. Avoid bran-heavy cereals.'),
  // ... all previous entries unchanged up to Hot Cereal
  FoodItem(name: 'Corn Grits Cooked With Water', serving: '1 cup', oxalateMg: 45.2, level: OxalateLevel.high, category: 'Hot Cereal', tip: 'Plain oatmeal (instant Quaker) is surprisingly zero oxalate! Avoid corn grits which are very high.'),
  FoodItem(name: 'Cream Of Wheat Quick Cooked With Water', serving: '1 cup', oxalateMg: 17.7, level: OxalateLevel.moderate, category: 'Hot Cereal', tip: 'Plain oatmeal (instant Quaker) is surprisingly zero oxalate! Avoid corn grits which are very high.'),
  FoodItem(name: 'Oatmeal Quaker Instant Sweetened', serving: '2/3 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Hot Cereal', tip: 'Plain oatmeal (instant Quaker) is surprisingly zero oxalate! Avoid corn grits which are very high.'),
  FoodItem(name: 'Oatmeal Quaker Multigrain Cooked With Water', serving: '1 cup', oxalateMg: 21.7, level: OxalateLevel.low, category: 'Hot Cereal', tip: 'Plain oatmeal (instant Quaker) is surprisingly zero oxalate! Avoid corn grits which are very high.'),
  FoodItem(name: 'Oats Regular Quick Instant Cooked With Water', serving: '1 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Hot Cereal', tip: 'Plain oatmeal (instant Quaker) is surprisingly zero oxalate! Avoid corn grits which are very high.'),

  // Beverages (tips now use shared beverageTip constant)
  FoodItem(name: 'Beer Regular Light Hard Cider', serving: '12 oz', oxalateMg: 3.9, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Boost', serving: '8 oz', oxalateMg: 21.1, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Carbonated Beverage With Sugar Without Caffeine', serving: '12 oz', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Carnation Instant Breakfast Prepared', serving: '8 oz', oxalateMg: 7.3, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Coffee Drinks Cappuccino Latte Mocha Frappuccino', serving: '12 oz', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Coffee Brewed', serving: '8 oz', oxalateMg: 1.7, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Coffee Prepared Instant Decaf', serving: '8 oz', oxalateMg: 2.2, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Cola Caffeinated', serving: '12 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Diet Soda No Caffeine', serving: '12 oz', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Diet Soda With Caffeine', serving: '12 oz', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Energy Drink Red Bull', serving: '8.3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Energy Drink Red Bull Sugar Free', serving: '8.3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Ensure Nutritional Supplement', serving: '8 oz', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Ensure Plus Nutrition Shake', serving: '8 oz', oxalateMg: 12.3, level: OxalateLevel.moderate, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Fruit Smoothie', serving: '16 oz', oxalateMg: 9.3, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Gatorade Fruit Flavored', serving: '12 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Apple Unsweetened', serving: '7 oz', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Apricot', serving: '8 oz', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Carrot Canned', serving: '1 cup', oxalateMg: 28.3, level: OxalateLevel.high, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Citrus Fruit From Frozen Concentrate', serving: '12 oz', oxalateMg: 4.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Cranberry Cocktail', serving: '6 oz', oxalateMg: 1.7, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Grape Unsweetened', serving: '6 oz', oxalateMg: 2.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Grapefruit', serving: '6 oz', oxalateMg: 2.2, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Lemon Raw', serving: '1 tbsp', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Mango', serving: '1 cup', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Orange With Calcium', serving: '6 oz', oxalateMg: 1.1, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Orange Unsweetened Frozen', serving: '6 oz', oxalateMg: 1.1, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Pineapple Canned Unsweetened', serving: '6 oz', oxalateMg: 1.9, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Pomegranate', serving: '6 oz', oxalateMg: 1.3, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Tomato Canned', serving: '6 oz', oxalateMg: 10.7, level: OxalateLevel.moderate, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Juice Vegetable Canned', serving: '6 oz', oxalateMg: 13.7, level: OxalateLevel.moderate, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Lemonade Frozen From Concentrate', serving: '12 oz', oxalateMg: 22.3, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Lemonade Low Calorie', serving: '12 oz', oxalateMg: 1.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Papaya Canned Nectar', serving: '1 cup', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Powerade Zero', serving: '12 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Slim Fast', serving: '11 oz', oxalateMg: 36.7, level: OxalateLevel.high, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Tea Brewed', serving: '8 oz', oxalateMg: 6.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Tea Diet Iced Ready To Drink', serving: '12 oz', oxalateMg: 9.6, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Tea Instant Lemon Flavored', serving: '4.5 tsp dry', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Tea Unsweetened Green', serving: '1 cup', oxalateMg: 6.4, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Vitamin Water Sugared', serving: '8 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Vitamin Water Sugar-Free', serving: '8 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Water Tap', serving: '8 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'White & Dark Spirits Hard Seltzer Mixed Cocktail', serving: '1.5 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Wine Red', serving: '5 oz', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Wine White', serving: '5 oz', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),

  // Remaining items unchanged (Beans And Lentils, Breads And Bakery, etc.)
];
