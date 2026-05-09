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

// ─── SHARED TIP CONSTANTS ────────────────────────────────────────────────────────────
const String candyTip =
    'Avoid dark chocolate entirely (67mg!). Non-chocolate candies are safe. Limit regular candy bars.';

const String condimentsTip =
    'Most condiments are very low oxalate. Ketchup, mustard, and BBQ sauce are all safe in normal amounts.';

const String plantMilkTip =
    'Avoid almond milk (27mg). Use regular dairy milk or plain plant-based milks (not soy or almond).';

const String fruitTip =
    'Most fruits are low oxalate. Avoid oranges and tangerines (high). Best choices: apples, peaches, watermelon, grapes.';

const String breadTip =
    'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.';

const String dairyTip =
    'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.';

const String meatTip =
    'All plain meats, poultry, and fish are zero or near-zero oxalate. They are your safest protein choices.';

const String vegTip =
    'Vegetables vary widely. Spinach, beets, and Swiss chard are extremely high. Stick to cabbage, cauliflower, mushrooms, and green beans.';

const String grainTip =
    'White rice and plain pasta are your safest grain options. Avoid bran, wheat germ, and whole grain products.';

const String nutTip =
    'Most nuts are high in oxalates. Limit almonds, peanuts, and cashews. Safest choices: macadamia nuts and flax seeds in small amounts.';

const String beverageTip =
    'Stay well hydrated — aim for 2.5–3 L of fluid daily. Lemonade (real lemon juice) helps prevent stones. Limit black tea and instant coffee.';

const String soupTip =
    'Most broth-based soups are low oxalate. Avoid soups made with spinach, tomatoes, or beans as the main ingredient.';

const String snackTip =
    'Pretzels and plain popcorn are safe snack choices. Avoid chips made with whole grains or seasoned with spinach/tomato powders.';

const String eggTip =
    'All eggs are zero oxalate — a perfect protein source for every meal.';

const List<FoodItem> foodItems = [

  // ── BREADS & BAKERY ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Cracker Regular Refined Grain', serving: '5-6 crackers', oxalateMg: 5.1, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Crackers Whole Wheat', serving: '5-6 crackers', oxalateMg: 15.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Croissant', serving: 'one', oxalateMg: 7.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Danish Cinnamon Roll Or Fruit', serving: 'one', oxalateMg: 2.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Donut Cake Or Yeast', serving: 'one', oxalateMg: 4.4, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'French Toast Homemade With 2% Milk', serving: '2 slices', oxalateMg: 11.6, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin Blueberry', serving: 'one', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin Bran', serving: 'one', oxalateMg: 9.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin English Wheat', serving: 'one', oxalateMg: 8.7, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin English Mixed Grain', serving: 'one', oxalateMg: 11.2, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin English Plain Enriched', serving: 'one', oxalateMg: 7.3, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Muffin English Whole Wheat', serving: 'one', oxalateMg: 28.1, level: OxalateLevel.high, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Pancakes & Waffles', serving: '2 small', oxalateMg: 9.7, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Pie Apple Commercial', serving: '1 slice', oxalateMg: 4.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Roll Reduced Fat Sweet', serving: 'one', oxalateMg: 13.5, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Snack Bar Granola Nutrigrain', serving: 'one', oxalateMg: 6.1, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Snack Cake Creme-Filled Sponge', serving: 'one', oxalateMg: 3.6, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Tortillas Corn', serving: 'two', oxalateMg: 10.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Tortillas Flour', serving: 'two', oxalateMg: 9.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bread White', serving: '1 slice', oxalateMg: 2.7, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bread Whole Wheat', serving: '1 slice', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bread Rye', serving: '1 slice', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bread Pumpernickel', serving: '1 slice', oxalateMg: 8.5, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bagel Plain', serving: 'one', oxalateMg: 8.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Bagel Whole Wheat', serving: 'one', oxalateMg: 21.0, level: OxalateLevel.moderate, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Cornbread', serving: '1 piece', oxalateMg: 8.5, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),
  FoodItem(name: 'Biscuit', serving: 'one', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Breads And Bakery', tip: breadTip),

  // ── CANDY ────────────────────────────────────────────────────────────────────
  FoodItem(name: 'Candies Milk Chocolate', serving: '1.5 oz', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Candies Non-Chocolate', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Candy Bar', serving: '2 oz', oxalateMg: 35.4, level: OxalateLevel.high, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Chocolate Dark Bar', serving: '1.5 oz', oxalateMg: 67.7, level: OxalateLevel.veryHigh, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Chocolate White', serving: '1.5 oz', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Candy', tip: candyTip),
  FoodItem(name: 'Gummy Bears', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Candy', tip: candyTip),

  // ── CONDIMENTS ──────────────────────────────────────────────────────────────────
  FoodItem(name: 'Catsup Ketchup', serving: '1 tbsp', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Mustard Yellow', serving: '1 tsp', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Sauce Barbecue', serving: '2 tbsp', oxalateMg: 2.3, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Sauce Soy', serving: '1 tbsp', oxalateMg: 2.9, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Mayonnaise', serving: '1 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Ranch Dressing', serving: '2 tbsp', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Italian Dressing', serving: '2 tbsp', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Salsa', serving: '2 tbsp', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Hot Sauce', serving: '1 tsp', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Vinegar White Or Apple Cider', serving: '1 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Honey', serving: '1 tbsp', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Maple Syrup', serving: '1 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),
  FoodItem(name: 'Jam Or Jelly', serving: '1 tbsp', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Condiments', tip: condimentsTip),

  // ── DAIRY ──────────────────────────────────────────────────────────────────────
  FoodItem(name: 'Butter Salted', serving: '1 tsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Buttermilk Lowfat', serving: '1 cup', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese American Pasteurized', serving: '1 oz', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese American Pasteurized Nonfat', serving: '1 slice', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cheddar', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cheddar/Colby Low Fat', serving: '1 oz', oxalateMg: 0.3, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cottage', serving: '1/2 cup', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cottage 1% Lowfat', serving: '1/2 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cottage Nonfat', serving: '1/2 cup', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cream', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Cream Fat Free', serving: '1 oz', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Mozzarella Part Skim', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Mozzarella Whole Milk', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Neufchatel Lowfat Cream Cheese', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Coffeemate Powdered And Liquid', serving: '1 tbsp', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cream Fluid Light', serving: '1 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cream Sour', serving: '1 tbsp', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Ice Cream Light Vanilla', serving: '1 cup', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Ice Cream Vanilla', serving: '1 cup', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Milk 1%', serving: '8 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Milk 2%', serving: '8 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Milk Skim', serving: '8 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Milk Whole', serving: '8 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Sherbet Orange', serving: '1 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Whipped Topping', serving: '2 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Frozen Low Fat', serving: '1 cup', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Chobani', serving: '5.3 oz', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Frozen', serving: '1 bar', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Fruit Whole Milk', serving: '6 oz', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Light', serving: '5.3 oz', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Plain Nonfat/Lowfat', serving: '5.3 oz', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Greek Plain Whole Milk', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Lowfat Fruited', serving: '6 oz', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Nonfat Light Fruit', serving: '6 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Nonfat With Fruit', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Plain Lowfat', serving: '6 oz', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Plain Whole Milk', serving: '6 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Yogurt Whole Fruit', serving: '6 oz', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Parmesan', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Swiss', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Ricotta Whole Milk', serving: '1/2 cup', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Provolone', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Cheese Feta', serving: '1 oz', oxalateMg: 0.1, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),
  FoodItem(name: 'Half And Half', serving: '2 tbsp', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Dairy', tip: dairyTip),

  // ── PLANT-BASED MILK ─────────────────────────────────────────────────────────
  FoodItem(name: 'Almond Milk Sweetened Or Unsweetened', serving: '8 oz', oxalateMg: 27.1, level: OxalateLevel.high, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Plant-Based Milk Excludes Soy & Almond', serving: '1 cup', oxalateMg: 0.2, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Soymilk Fortified', serving: '8 oz', oxalateMg: 9.6, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Whey Powder High Protein Drink', serving: '1 scoop', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Oat Milk', serving: '8 oz', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Coconut Milk Beverage', serving: '8 oz', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),
  FoodItem(name: 'Rice Milk', serving: '8 oz', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Plant-Based Milk', tip: plantMilkTip),

  // ── EGGS ───────────────────────────────────────────────────────────────────────
  FoodItem(name: 'Egg Beaters', serving: '1/4 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),
  FoodItem(name: 'Egg Raw Whole', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),
  FoodItem(name: 'Egg Yolk Raw Fresh', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),
  FoodItem(name: 'Eggs Omega 3 Supplemented', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),
  FoodItem(name: 'Eggs Scrambled', serving: '2 eggs', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),
  FoodItem(name: 'Eggs Hard Boiled', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Eggs', tip: eggTip),

  // ── FRUIT (complete) ───────────────────────────────────────────────────────────
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
  FoodItem(name: 'Peaches Raw', serving: 'one', oxalateMg: 1.4, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Pears Raw', serving: 'one', oxalateMg: 5.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Pineapple Raw', serving: '1/2 cup', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Plums Raw', serving: 'one', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Pomegranate Raw', serving: '1/2 fruit', oxalateMg: 6.2, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Prunes Dried', serving: '5 prunes', oxalateMg: 2.5, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Raisins', serving: '1/4 cup', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Raspberries Raw', serving: '1/2 cup', oxalateMg: 48.0, level: OxalateLevel.veryHigh, category: 'Fruit', tip: 'Raspberries are very high in oxalates. Limit to occasional small portions or avoid entirely if prone to stones.'),
  FoodItem(name: 'Strawberries Raw', serving: '1/2 cup', oxalateMg: 2.3, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Tangerines Raw', serving: 'one', oxalateMg: 16.0, level: OxalateLevel.moderate, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Watermelon Raw', serving: '1 cup', oxalateMg: 0.8, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Kiwi Raw', serving: 'one', oxalateMg: 6.8, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Coconut Shredded', serving: '2 tbsp', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),
  FoodItem(name: 'Honeydew Melon', serving: '1 cup', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Fruit', tip: fruitTip),

  // ── VEGETABLES ──────────────────────────────────────────────────────────────────
  FoodItem(name: 'Spinach Raw', serving: '1 cup', oxalateMg: 656.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Spinach is one of the highest oxalate foods — avoid entirely if prone to calcium oxalate stones.'),
  FoodItem(name: 'Spinach Cooked', serving: '1/2 cup', oxalateMg: 755.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Cooking concentrates oxalates in spinach. Avoid entirely.'),
  FoodItem(name: 'Beet Greens Cooked', serving: '1/2 cup', oxalateMg: 916.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Beet greens are the highest oxalate vegetable. Avoid completely.'),
  FoodItem(name: 'Beets Canned', serving: '1/2 cup', oxalateMg: 76.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Both beet greens and beet root are very high in oxalates. Avoid.'),
  FoodItem(name: 'Beets Raw', serving: '1/2 cup', oxalateMg: 76.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Both beet greens and beet root are very high in oxalates. Avoid.'),
  FoodItem(name: 'Swiss Chard Cooked', serving: '1/2 cup', oxalateMg: 660.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Swiss chard is extremely high in oxalates. Avoid completely.'),
  FoodItem(name: 'Rhubarb Cooked With Sugar', serving: '1/2 cup', oxalateMg: 541.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Rhubarb has one of the highest oxalate levels of any food. Avoid.'),
  FoodItem(name: 'Sweet Potato Baked', serving: 'one medium', oxalateMg: 28.0, level: OxalateLevel.high, category: 'Vegetables', tip: 'Sweet potatoes are high oxalate. Limit to small occasional portions.'),
  FoodItem(name: 'Okra Cooked', serving: '1/2 cup', oxalateMg: 57.0, level: OxalateLevel.veryHigh, category: 'Vegetables', tip: 'Okra is very high in oxalates. Avoid if prone to calcium oxalate stones.'),
  FoodItem(name: 'Leeks Cooked', serving: '1/2 cup', oxalateMg: 32.0, level: OxalateLevel.high, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Parsley Raw', serving: '1/4 cup', oxalateMg: 17.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Celery Raw', serving: '1 stalk', oxalateMg: 19.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Green Beans Cooked', serving: '1/2 cup', oxalateMg: 3.1, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Broccoli Cooked', serving: '1/2 cup', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Cauliflower Cooked', serving: '1/2 cup', oxalateMg: 1.2, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Cabbage Raw', serving: '1 cup', oxalateMg: 1.3, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Cabbage Cooked', serving: '1/2 cup', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Mushrooms Raw', serving: '1/2 cup', oxalateMg: 2.5, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Peas Green Cooked', serving: '1/2 cup', oxalateMg: 2.3, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Corn Canned Or Cooked', serving: '1/2 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Carrots Raw', serving: 'one medium', oxalateMg: 9.5, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Carrots Cooked', serving: '1/2 cup', oxalateMg: 9.4, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Cucumber Raw', serving: '1/2 cup', oxalateMg: 3.8, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Lettuce Iceberg', serving: '1 cup', oxalateMg: 3.6, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Lettuce Romaine', serving: '1 cup', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Onions Raw', serving: '1/2 cup', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Garlic Raw', serving: '1 clove', oxalateMg: 1.7, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Tomato Raw', serving: 'one medium', oxalateMg: 7.9, level: OxalateLevel.low, category: 'Vegetables', tip: 'Tomatoes are low-moderate. Tomato sauce and paste are more concentrated; limit large portions.'),
  FoodItem(name: 'Tomato Sauce Canned', serving: '1/2 cup', oxalateMg: 15.3, level: OxalateLevel.moderate, category: 'Vegetables', tip: 'Tomato sauce is more concentrated than fresh tomato. Limit to 1/2 cup per meal.'),
  FoodItem(name: 'Pumpkin Canned', serving: '1/2 cup', oxalateMg: 5.3, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Squash Summer Cooked', serving: '1/2 cup', oxalateMg: 3.4, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Squash Winter Acorn Cooked', serving: '1/2 cup', oxalateMg: 5.4, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Asparagus Cooked', serving: '1/2 cup', oxalateMg: 15.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Brussels Sprouts Cooked', serving: '1/2 cup', oxalateMg: 11.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Kale Cooked', serving: '1/2 cup', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Peppers Bell Green', serving: '1/2 cup', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Peppers Bell Red', serving: '1/2 cup', oxalateMg: 2.8, level: OxalateLevel.low, category: 'Vegetables', tip: vegTip),
  FoodItem(name: 'Potato Baked With Skin', serving: 'one medium', oxalateMg: 19.0, level: OxalateLevel.moderate, category: 'Vegetables', tip: 'White potatoes are moderate. Peel before eating to reduce oxalate. Avoid eating the skin.'),
  FoodItem(name: 'Potato Boiled No Skin', serving: 'one medium', oxalateMg: 9.2, level: OxalateLevel.low, category: 'Vegetables', tip: 'Peeled boiled potato is a safe choice. Avoid fries and potato with skin.'),

  // ── MEATS, POULTRY & FISH ───────────────────────────────────────────────────────
  FoodItem(name: 'Beef Ground Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Beef Steak Grilled', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Beef Roast', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Chicken Breast Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Chicken Thigh Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Chicken Wings Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Turkey Breast Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Turkey Ground Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Pork Chop Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Pork Tenderloin Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Ham Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Bacon Cooked', serving: '2 strips', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Hot Dog Beef Or Pork', serving: 'one', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Sausage Pork', serving: '2 links', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Salmon Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Tuna Canned In Water', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Tilapia Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Cod Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Shrimp Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Crab Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Lobster Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Sardines Canned In Oil', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Catfish Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Lamb Cooked', serving: '3 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Deli Turkey Sliced', serving: '2 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),
  FoodItem(name: 'Deli Ham Sliced', serving: '2 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Meat & Fish', tip: meatTip),

  // ── GRAINS, PASTA & RICE ────────────────────────────────────────────────────────
  FoodItem(name: 'Rice White Cooked', serving: '1/2 cup', oxalateMg: 0.7, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Rice Brown Cooked', serving: '1/2 cup', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Pasta White Cooked', serving: '1/2 cup', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Pasta Whole Wheat Cooked', serving: '1/2 cup', oxalateMg: 19.5, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Noodles Egg Cooked', serving: '1/2 cup', oxalateMg: 8.5, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Oatmeal Cooked', serving: '1 cup', oxalateMg: 13.7, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: 'Oatmeal is moderate oxalate. Limit to 1 cup per serving and pair with dairy to offset absorption.'),
  FoodItem(name: 'Grits White Cooked', serving: '1 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Cornmeal Cooked', serving: '1/2 cup', oxalateMg: 5.1, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Cereal Corn Flakes', serving: '1 cup', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Cereal Rice Krispies', serving: '1 cup', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Cereal Cheerios', serving: '1 cup', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Cereal Raisin Bran', serving: '1 cup', oxalateMg: 57.0, level: OxalateLevel.veryHigh, category: 'Grains & Pasta', tip: 'Bran cereals are very high in oxalates. Avoid raisin bran and all-bran products.'),
  FoodItem(name: 'Cereal Granola', serving: '1/2 cup', oxalateMg: 21.0, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Wheat Germ', serving: '2 tbsp', oxalateMg: 52.0, level: OxalateLevel.veryHigh, category: 'Grains & Pasta', tip: 'Wheat germ is extremely high in oxalates. Avoid.'),
  FoodItem(name: 'Couscous Cooked', serving: '1/2 cup', oxalateMg: 15.0, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: grainTip),
  FoodItem(name: 'Quinoa Cooked', serving: '1/2 cup', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Grains & Pasta', tip: grainTip),

  // ── NUTS & SEEDS ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Almonds', serving: '1 oz', oxalateMg: 122.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds', tip: 'Almonds are extremely high in oxalates. Avoid — even almond butter, almond flour, and almond milk.'),
  FoodItem(name: 'Peanuts', serving: '1 oz', oxalateMg: 27.0, level: OxalateLevel.high, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Peanut Butter', serving: '2 tbsp', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Nuts & Seeds', tip: 'Peanut butter is moderate. Limit to 2 tbsp per day.'),
  FoodItem(name: 'Cashews', serving: '1 oz', oxalateMg: 49.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds', tip: 'Cashews are very high in oxalates. Avoid.'),
  FoodItem(name: 'Walnuts', serving: '1 oz', oxalateMg: 31.0, level: OxalateLevel.high, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Pecans', serving: '1 oz', oxalateMg: 9.0, level: OxalateLevel.low, category: 'Nuts & Seeds', tip: 'Pecans are one of the safest nuts for stone formers. Enjoy in moderation.'),
  FoodItem(name: 'Macadamia Nuts', serving: '1 oz', oxalateMg: 0.6, level: OxalateLevel.low, category: 'Nuts & Seeds', tip: 'Macadamia nuts are the lowest oxalate nut — a great safe choice.'),
  FoodItem(name: 'Pistachios', serving: '1 oz', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Sunflower Seeds', serving: '1 oz', oxalateMg: 26.0, level: OxalateLevel.high, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Pumpkin Seeds', serving: '1 oz', oxalateMg: 17.0, level: OxalateLevel.moderate, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Sesame Seeds', serving: '1 tbsp', oxalateMg: 6.0, level: OxalateLevel.low, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Flax Seeds', serving: '1 tbsp', oxalateMg: 9.3, level: OxalateLevel.low, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Chia Seeds', serving: '1 oz', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Nuts & Seeds', tip: nutTip),
  FoodItem(name: 'Hazelnuts', serving: '1 oz', oxalateMg: 75.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds', tip: 'Hazelnuts are very high in oxalates. Avoid.'),
  FoodItem(name: 'Pine Nuts', serving: '1 oz', oxalateMg: 17.0, level: OxalateLevel.moderate, category: 'Nuts & Seeds', tip: nutTip),

  // ── LEGUMES & BEANS ──────────────────────────────────────────────────────────────
  FoodItem(name: 'Black Beans Cooked', serving: '1/2 cup', oxalateMg: 23.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Beans are moderate-high. Limit to 1/2 cup per meal. Rinsing canned beans reduces oxalate slightly.'),
  FoodItem(name: 'Kidney Beans Cooked', serving: '1/2 cup', oxalateMg: 15.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Beans are moderate-high. Limit to 1/2 cup per meal. Rinsing canned beans reduces oxalate slightly.'),
  FoodItem(name: 'Navy Beans Cooked', serving: '1/2 cup', oxalateMg: 76.0, level: OxalateLevel.veryHigh, category: 'Legumes & Beans', tip: 'Navy beans are very high in oxalates. Avoid.'),
  FoodItem(name: 'Pinto Beans Cooked', serving: '1/2 cup', oxalateMg: 11.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Beans are moderate-high. Limit to 1/2 cup per meal.'),
  FoodItem(name: 'Chickpeas Cooked', serving: '1/2 cup', oxalateMg: 16.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Chickpeas are moderate. Limit hummus portions to 2 tbsp.'),
  FoodItem(name: 'Lentils Cooked', serving: '1/2 cup', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Legumes & Beans', tip: 'Lentils are one of the lowest oxalate legumes — a safer bean choice.'),
  FoodItem(name: 'Tofu Firm', serving: '4 oz', oxalateMg: 13.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Tofu is moderate oxalate. Limit to small portions; do not use as a primary protein source.'),
  FoodItem(name: 'Soybeans Cooked', serving: '1/2 cup', oxalateMg: 21.0, level: OxalateLevel.moderate, category: 'Legumes & Beans', tip: 'Soybeans are moderate-high. Limit portions.'),
  FoodItem(name: 'Hummus', serving: '2 tbsp', oxalateMg: 8.0, level: OxalateLevel.low, category: 'Legumes & Beans', tip: 'Hummus in small amounts is low oxalate. Limit to 2 tbsp per serving.'),

  // ── BEVERAGES ───────────────────────────────────────────────────────────────────
  FoodItem(name: 'Water', serving: '8 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: 'Water is your #1 defense against kidney stones. Aim for 2.5–3 liters daily.'),
  FoodItem(name: 'Coffee Brewed', serving: '8 oz', oxalateMg: 1.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Coffee Instant', serving: '8 oz', oxalateMg: 12.0, level: OxalateLevel.moderate, category: 'Beverages', tip: 'Instant coffee is higher in oxalates than brewed. Prefer brewed coffee and limit to 1–2 cups daily.'),
  FoodItem(name: 'Tea Black Brewed', serving: '8 oz', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Beverages', tip: 'Black tea is a significant source of oxalates, especially iced tea made from concentrate. Limit to 1 cup daily.'),
  FoodItem(name: 'Tea Green Brewed', serving: '8 oz', oxalateMg: 12.0, level: OxalateLevel.moderate, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Tea Herbal Chamomile', serving: '8 oz', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Lemonade Made With Real Lemon', serving: '8 oz', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Beverages', tip: 'Real lemonade is one of the BEST drinks for kidney stone prevention. The citrate in lemon juice inhibits stone formation.'),
  FoodItem(name: 'Orange Juice', serving: '8 oz', oxalateMg: 4.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Apple Juice', serving: '8 oz', oxalateMg: 1.1, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Grape Juice', serving: '8 oz', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Cranberry Juice Cocktail', serving: '8 oz', oxalateMg: 2.2, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Soda Cola', serving: '12 oz', oxalateMg: 1.8, level: OxalateLevel.low, category: 'Beverages', tip: 'Cola sodas are low oxalate but high phosphate. Limit to occasional use. Water and lemonade are better choices.'),
  FoodItem(name: 'Soda Non-Cola', serving: '12 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Beer', serving: '12 oz', oxalateMg: 4.3, level: OxalateLevel.low, category: 'Beverages', tip: 'Beer is low oxalate but alcohol can increase uric acid and dehydration. Drink in moderation and increase water intake.'),
  FoodItem(name: 'Wine Red', serving: '5 oz', oxalateMg: 0.9, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Wine White', serving: '5 oz', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Sports Drink Gatorade', serving: '12 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Beverages', tip: beverageTip),
  FoodItem(name: 'Hot Cocoa Mix Made With Milk', serving: '8 oz', oxalateMg: 71.0, level: OxalateLevel.veryHigh, category: 'Beverages', tip: 'Hot cocoa is very high in oxalates due to cocoa powder. Avoid or use a very small amount.'),

  // ── SOUPS ──────────────────────────────────────────────────────────────────────
  FoodItem(name: 'Chicken Noodle Soup Canned', serving: '1 cup', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Tomato Soup Canned With Water', serving: '1 cup', oxalateMg: 10.5, level: OxalateLevel.moderate, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Beef Broth', serving: '1 cup', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Chicken Broth', serving: '1 cup', oxalateMg: 0.5, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Vegetable Broth', serving: '1 cup', oxalateMg: 2.0, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Minestrone Soup', serving: '1 cup', oxalateMg: 7.0, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Clam Chowder New England', serving: '1 cup', oxalateMg: 3.0, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Bean Soup Canned', serving: '1 cup', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Soups', tip: soupTip),
  FoodItem(name: 'Lentil Soup', serving: '1 cup', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Soups', tip: soupTip),
  FoodItem(name: 'French Onion Soup', serving: '1 cup', oxalateMg: 3.5, level: OxalateLevel.low, category: 'Soups', tip: soupTip),

  // ── SNACKS ──────────────────────────────────────────────────────────────────────
  FoodItem(name: 'Potato Chips Plain', serving: '1 oz', oxalateMg: 8.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Pretzels', serving: '1 oz', oxalateMg: 6.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Popcorn Plain', serving: '2 cups', oxalateMg: 5.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Corn Chips', serving: '1 oz', oxalateMg: 5.4, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Rice Cakes Plain', serving: '2 cakes', oxalateMg: 1.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Graham Crackers', serving: '2 squares', oxalateMg: 6.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Animal Crackers', serving: '1 oz', oxalateMg: 4.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Cookies Chocolate Chip', serving: '2 cookies', oxalateMg: 8.0, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Cookies Oatmeal Raisin', serving: '2 cookies', oxalateMg: 14.0, level: OxalateLevel.moderate, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Pork Rinds', serving: '1 oz', oxalateMg: 0.0, level: OxalateLevel.low, category: 'Snacks', tip: 'Pork rinds are zero oxalate — one of the few truly safe crunchy snacks.'),
  FoodItem(name: 'Cheese Crackers', serving: '1 oz', oxalateMg: 4.5, level: OxalateLevel.low, category: 'Snacks', tip: snackTip),
  FoodItem(name: 'Trail Mix With Nuts', serving: '1 oz', oxalateMg: 35.0, level: OxalateLevel.high, category: 'Snacks', tip: 'Trail mix is high in oxalates due to nuts (especially almonds and cashews). Avoid or choose a nut-free version.'),

];
