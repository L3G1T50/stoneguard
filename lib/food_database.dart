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

// ─── SHARED TIP CONSTANTS ────────────────────────────────────
const String candyTip =
    'Avoid dark chocolate entirely (67mg!). Non-chocolate candies are safe. Limit regular candy bars.';

const String condimentsTip =
    'Most condiments are very low oxalate. Ketchup, mustard, and BBQ sauce are all safe in normal amounts.';

const String plantMilkTip =
    'Avoid almond milk (27mg). Use regular dairy milk or plain plant-based milks (not soy or almond).';

const String fruitTip =
    'Most fruits are low oxalate. Avoid oranges and tangerines (high). Best choices: apples, peaches, watermelon, grapes.';

const List<FoodItem> foodItems = [

  // ── BREADS & BAKERY ──────────────────────────────────────────
  FoodItem(name: 'Cracker Regular Refined Grain', serving: '5-6 crackers', oxalateMg: 5.1, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Crackers Whole Wheat', serving: '5-6 crackers', oxalateMg: 15.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Croissant', serving: 'one', oxalateMg: 7.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Danish Cinnamon Roll Or Fruit', serving: 'one', oxalateMg: 2.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Donut Cake Or Yeast', serving: 'one', oxalateMg: 4.4, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'French Toast Homemade With 2% Milk', serving: '2 slices', oxalateMg: 11.6, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin Blueberry', serving: 'one', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin Bran', serving: 'one', oxalateMg: 9.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin English Wheat', serving: 'one', oxalateMg: 8.7, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin English Mixed Grain', serving: 'one', oxalateMg: 11.2, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin English Plain Enriched', serving: 'one', oxalateMg: 7.3, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Muffin English Whole Wheat', serving: 'one', oxalateMg: 28.1, level: OxalateLevel.high, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Pancakes & Waffles', serving: '2 small', oxalateMg: 9.7, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Pie Apple Commercial', serving: '1 slice', oxalateMg: 4.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Roll Reduced Fat Sweet', serving: 'one', oxalateMg: 13.5, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Snack Bar Granola Nutrigrain', serving: 'one', oxalateMg: 6.1, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Snack Cake Creme-Filled Sponge', serving: 'one', oxalateMg: 3.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Tortillas Corn', serving: 'two', oxalateMg: 10.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),
  FoodItem(name: 'Tortillas Flour', serving: 'two', oxalateMg: 9.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: 'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.'),

  // ── CANDY ────────────────────────────────────────────────────
  FoodItem(name: 'Candies Milk Chocolate', serving: '1.5 oz', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Candies Non-Chocolate', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Candy Bar', serving: '2 oz', oxalateMg: 35.4, level: OxalateLevel.high, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Chocolate Dark Bar', serving: '1.5 oz', oxalateMg: 67.7, level: OxalateLevel.veryHigh, category: 'Candy', tip: candyTip),

  // ── CONDIMENTS ───────────────────────────────────────────────
  FoodItem(name: 'Catsup Ketchup', serving: '1 tbsp', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Mustard Yellow', serving: '1 tsp', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Sauce Barbecue', serving: '2 tbsp', oxalateMg: 2.3, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Sauce Soy', serving: '1 tbsp', oxalateMg: 2.9, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),

  // ── DAIRY ────────────────────────────────────────────────────
  FoodItem(name: 'Butter Salted', serving: '1 tsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Buttermilk Lowfat', serving: '1 cup', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese American Pasteurized', serving: '1 oz', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese American Pasteurized Nonfat', serving: '1 slice', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cheddar', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cheddar/Colby Low Fat', serving: '1 oz', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cottage', serving: '1/2 cup', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cottage 1% Lowfat', serving: '1/2 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cottage Nonfat', serving: '1/2 cup', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cream', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Cream Fat Free', serving: '1 oz', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Mozzarella Part Skim', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Mozzarella Whole Milk', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cheese Neufchatel Lowfat Cream Cheese', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Coffeemate Powdered And Liquid', serving: '1 tbsp', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cream Fluid Light', serving: '1 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Cream Sour', serving: '1 tbsp', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Ice Cream Light Vanilla', serving: '1 cup', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Ice Cream Vanilla', serving: '1 cup', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Milk 1%', serving: '8 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Milk 2%', serving: '8 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Milk Skim', serving: '8 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Milk Whole', serving: '8 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Sherbet Orange', serving: '1 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Whipped Topping', serving: '2 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Frozen Low Fat', serving: '1 cup', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Chobani', serving: '5.3 oz', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Frozen', serving: '1 bar', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Fruit Whole Milk', serving: '6 oz', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Light', serving: '5.3 oz', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Plain Nonfat/Lowfat', serving: '5.3 oz', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Greek Plain Whole Milk', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Lowfat Fruited', serving: '6 oz', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Nonfat Light Fruit', serving: '6 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Nonfat With Fruit', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Plain Lowfat', serving: '6 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Plain Whole Milk', serving: '6 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),
  FoodItem(name: 'Yogurt Whole Fruit', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: 'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.'),

  // ── PLANT-BASED MILK ─────────────────────────────────────────
  FoodItem(name: 'Almond Milk Sweetened Or Unsweetened', serving: '8 oz', oxalateMg: 27.1, level: OxalateLevel.high, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Plant-Based Milk Excludes Soy & Almond', serving: '1 cup', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Soymilk Fortified', serving: '8 oz', oxalateMg: 9.6, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Whey Powder High Protein Drink', serving: '1 scoop', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),

  // ── EGGS ─────────────────────────────────────────────────────
  FoodItem(name: 'Egg Beaters', serving: '1/4 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: 'All eggs are zero oxalate — a perfect protein source for every meal.'),
  FoodItem(name: 'Egg Raw Whole', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: 'All eggs are zero oxalate — a perfect protein source for every meal.'),
  FoodItem(name: 'Egg Yolk Raw Fresh', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: 'All eggs are zero oxalate — a perfect protein source for every meal.'),
  FoodItem(name: 'Eggs Omega 3 Supplemented', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: 'All eggs are zero oxalate — a perfect protein source for every meal.'),

  // ── FRUIT ────────────────────────────────────────────────────
  FoodItem(name: 'Apples Raw With Skin', serving: 'one', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Apples Raw Without Skin', serving: 'one', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Apples Sulfured Dried', serving: '1/4 cup', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Apricots Raw', serving: '1 fruit', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Apricots Sulfured Dried', serving: '5 halves', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Avocado', serving: '1/2 fruit', oxalateMg: 9.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Bananas Raw', serving: 'one', oxalateMg: 10.3, level: OxalateLevel.moderate, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Blueberries', serving: '1/2 cup', oxalateMg: 18.5, level: OxalateLevel.moderate, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Cantaloupe', serving: '1/4 melon', oxalateMg: 1.4, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Cherries Sweet Raw', serving: '1/2 cup', oxalateMg: 1.7, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Cranberries Dried Sweetened', serving: '1/4 cup', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Cranberries Raw', serving: '1 cup', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Cranberry Sauce Canned Sweetened', serving: '1/8 cup', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Dates', serving: '5 dates', oxalateMg: 25.5, level: OxalateLevel.high, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Figs Dried', serving: 'one', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Figs Raw', serving: 'one', oxalateMg: 9.3, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Grapefruit Raw', serving: '1/2 medium', oxalateMg: 13.2, level: OxalateLevel.moderate, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Grapes Red Or Green Seedless', serving: '1/2 cup', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Lemons Raw Without Peel', serving: '1/4 lemon', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Limes Raw', serving: '1/8 lime', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Mangos Raw', serving: '1/2 fruit', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Mixed Dried Fruit Prunes Apricots Pears', serving: '1/4 cup', oxalateMg: 6.1, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Nectarines Raw', serving: 'one', oxalateMg: 0.4, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Olives Canned Ripe', serving: '3 medium', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Oranges Raw', serving: 'one', oxalateMg: 23.3, level: OxalateLevel.moderate, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Papayas Raw', serving: '1/2 medium', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Peaches Canned In Heavy Syrup', serving: '1/2 cup', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),

  // ── MORE CATEGORIES WILL GO HERE ─────────────────────────────

];