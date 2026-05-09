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

// ─── SHARED TIP CONSTANTS ──────────────────────────────────────────────────
const String _breadTip =
    'White bread and rye are the safest. Avoid whole wheat products and bran muffins which are higher in oxalates.';

const String _candyTip =
    'Avoid dark chocolate entirely (67mg!). Non-chocolate candies are safe. Limit regular candy bars.';

const String _condimentsTip =
    'Most condiments are very low oxalate. Ketchup, mustard, and BBQ sauce are all safe in normal amounts.';

const String _plantMilkTip =
    'Avoid almond milk (27mg). Use regular dairy milk or plain plant-based milks (not soy or almond).';

const String _fruitTip =
    'Most fruits are low oxalate. Avoid oranges and tangerines (high). Best choices: apples, peaches, watermelon, grapes.';

const String _dairyTip =
    'Dairy is your best friend! The calcium in dairy binds oxalates in the gut, preventing absorption. Eat dairy with every meal.';

const String _eggTip =
    'All eggs are zero oxalate — a perfect protein source for every meal.';

const String _meatTip =
    'All plain meats, poultry, and fish are zero or near-zero oxalate. They are safe to eat freely. Avoid heavy breading or high-oxalate marinades.';

const String _grainTip =
    'White rice and plain pasta are the safest grains. Avoid quinoa, amaranth, and buckwheat which are very high in oxalates.';

const String _vegTip =
    'Vegetables vary widely. Spinach, beets, and sweet potato are very high. Cauliflower, cabbage, peas, and mushrooms are safe choices.';

const String _nutTip =
    'Most nuts are high to very high in oxalates. If you want a snack, choose macadamia nuts or plain popcorn instead of almonds or peanuts.';

const String _beverageTip =
    'Stay hydrated with water — aim for 2.5L/day. Limit coffee and black tea. Lemonade made with real lemon juice can actually help prevent stones.';

const String _snackTip =
    'Plain popcorn, pretzels, and rice cakes are low-oxalate snack options. Avoid chips made from corn or potato — they vary. Avoid trail mix with nuts.';

const String _soupTip =
    'Broth-based soups made with low-oxalate vegetables are safe. Avoid soups with spinach, lentils, or beans as the main ingredient.';

const String _legumeTip =
    'Beans and lentils are moderate to high in oxalates. If you eat them, keep portions small and drink extra water that day.';

const String _oilTip =
    'All cooking oils are zero oxalate. Use olive oil, canola oil, or butter freely.';

const List<FoodItem> foodItems = [

  // ── BREADS & BAKERY ──────────────────────────────────────────────────────
  FoodItem(name: 'Cracker Regular Refined Grain',      serving: '5-6 crackers',  oxalateMg: 5.1,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Crackers Whole Wheat',               serving: '5-6 crackers',  oxalateMg: 15.0, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Croissant',                          serving: 'one',           oxalateMg: 7.6,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Danish Cinnamon Roll Or Fruit',      serving: 'one',           oxalateMg: 2.6,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Donut Cake Or Yeast',                serving: 'one',           oxalateMg: 4.4,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'French Toast With 2% Milk',          serving: '2 slices',      oxalateMg: 11.6, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin Blueberry',                   serving: 'one',           oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin Bran',                        serving: 'one',           oxalateMg: 9.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin English Wheat',               serving: 'one',           oxalateMg: 8.7,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin English Mixed Grain',         serving: 'one',           oxalateMg: 11.2, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin English Plain Enriched',      serving: 'one',           oxalateMg: 7.3,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Muffin English Whole Wheat',         serving: 'one',           oxalateMg: 28.1, level: OxalateLevel.high,     category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Pancakes & Waffles',                 serving: '2 small',       oxalateMg: 9.7,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Pie Apple Commercial',               serving: '1 slice',       oxalateMg: 4.6,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Roll Reduced Fat Sweet',             serving: 'one',           oxalateMg: 13.5, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Snack Bar Granola Nutrigrain',       serving: 'one',           oxalateMg: 6.1,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Snack Cake Creme-Filled Sponge',     serving: 'one',           oxalateMg: 3.6,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Tortillas Corn',                     serving: 'two',           oxalateMg: 10.0, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Tortillas Flour',                    serving: 'two',           oxalateMg: 9.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'White Bread',                        serving: '2 slices',      oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Whole Wheat Bread',                  serving: '2 slices',      oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Rye Bread',                          serving: '2 slices',      oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Bagel Plain',                        serving: 'one',           oxalateMg: 6.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Biscuit',                            serving: 'one',           oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Cornbread',                          serving: '1 piece',       oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),
  FoodItem(name: 'Pita Bread White',                   serving: 'one',           oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Breads & Bakery',  tip: _breadTip),

  // ── CANDY ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Candies Milk Chocolate',             serving: '1.5 oz',        oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Candies Non-Chocolate',              serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Candy Bar',                          serving: '2 oz',          oxalateMg: 35.4, level: OxalateLevel.high,     category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Chocolate Dark Bar',                 serving: '1.5 oz',        oxalateMg: 67.7, level: OxalateLevel.veryHigh, category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Gummy Bears',                        serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Hard Candy',                         serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Licorice',                           serving: '1 oz',          oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Marshmallows',                       serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),
  FoodItem(name: 'Jelly Beans',                        serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Candy',            tip: _candyTip),

  // ── CONDIMENTS ───────────────────────────────────────────────────────────
  FoodItem(name: 'Catsup Ketchup',                     serving: '1 tbsp',        oxalateMg: 1.5,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Mustard Yellow',                     serving: '1 tsp',         oxalateMg: 0.6,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Sauce Barbecue',                     serving: '2 tbsp',        oxalateMg: 2.3,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Sauce Soy',                          serving: '1 tbsp',        oxalateMg: 2.9,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Mayonnaise',                         serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Ranch Dressing',                     serving: '2 tbsp',        oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Italian Dressing',                   serving: '2 tbsp',        oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Salsa',                              serving: '2 tbsp',        oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Hot Sauce',                          serving: '1 tsp',         oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Vinegar',                            serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Worcestershire Sauce',               serving: '1 tbsp',        oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Pickle Dill',                        serving: 'one spear',     oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Relish Sweet',                       serving: '1 tbsp',        oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Jam Or Jelly',                       serving: '1 tbsp',        oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Honey',                              serving: '1 tbsp',        oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Maple Syrup',                        serving: '2 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),
  FoodItem(name: 'Sugar White',                        serving: '1 tsp',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Condiments',       tip: _condimentsTip),

  // ── DAIRY ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Butter Salted',                      serving: '1 tsp',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Buttermilk Lowfat',                  serving: '1 cup',         oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese American Pasteurized',        serving: '1 oz',          oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese American Nonfat',             serving: '1 slice',       oxalateMg: 0.2,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cheddar',                     serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cheddar Low Fat',             serving: '1 oz',          oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cottage',                     serving: '1/2 cup',       oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cottage 1% Lowfat',           serving: '1/2 cup',       oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cottage Nonfat',              serving: '1/2 cup',       oxalateMg: 0.8,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cream',                       serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Cream Fat Free',              serving: '1 oz',          oxalateMg: 0.2,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Mozzarella Part Skim',        serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Mozzarella Whole Milk',       serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Parmesan',                    serving: '2 tbsp',        oxalateMg: 0.2,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Ricotta Whole Milk',          serving: '1/2 cup',       oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Swiss',                       serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cheese Neufchatel',                  serving: '1 oz',          oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Coffeemate Powdered',                serving: '1 tbsp',        oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cream Fluid Light',                  serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Cream Sour',                         serving: '1 tbsp',        oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Ice Cream Light Vanilla',            serving: '1 cup',         oxalateMg: 0.6,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Ice Cream Vanilla',                  serving: '1 cup',         oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Milk 1%',                            serving: '8 oz',          oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Milk 2%',                            serving: '8 oz',          oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Milk Skim',                          serving: '8 oz',          oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Milk Whole',                         serving: '8 oz',          oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Sherbet Orange',                     serving: '1 cup',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Whipped Topping',                    serving: '2 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Frozen Low Fat',              serving: '1 cup',         oxalateMg: 0.9,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Chobani',               serving: '5.3 oz',        oxalateMg: 0.9,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Frozen',                serving: '1 bar',         oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Fruit Whole Milk',      serving: '6 oz',          oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Light',                 serving: '5.3 oz',        oxalateMg: 0.6,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Plain Nonfat',          serving: '5.3 oz',        oxalateMg: 0.6,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Greek Plain Whole Milk',      serving: '6 oz',          oxalateMg: 0.8,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Lowfat Fruited',              serving: '6 oz',          oxalateMg: 1.2,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Nonfat Light Fruit',          serving: '6 oz',          oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Plain Lowfat',                serving: '6 oz',          oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Plain Whole Milk',            serving: '6 oz',          oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),
  FoodItem(name: 'Yogurt Whole Fruit',                 serving: '6 oz',          oxalateMg: 0.8,  level: OxalateLevel.low,      category: 'Dairy',            tip: _dairyTip),

  // ── PLANT-BASED MILK ─────────────────────────────────────────────────────
  FoodItem(name: 'Almond Milk',                        serving: '8 oz',          oxalateMg: 27.1, level: OxalateLevel.high,     category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Plant-Based Milk (not soy/almond)',  serving: '1 cup',         oxalateMg: 0.2,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Soymilk Fortified',                  serving: '8 oz',          oxalateMg: 9.6,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Whey Protein Powder',                serving: '1 scoop',       oxalateMg: 1.5,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Oat Milk',                           serving: '8 oz',          oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Coconut Milk Beverage',              serving: '8 oz',          oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),
  FoodItem(name: 'Rice Milk',                          serving: '8 oz',          oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Plant-Based Milk', tip: _plantMilkTip),

  // ── EGGS ─────────────────────────────────────────────────────────────────
  FoodItem(name: 'Egg Beaters',                        serving: '1/4 cup',       oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Egg Raw Whole',                      serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Egg Yolk Raw',                       serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Eggs Omega-3 Enriched',              serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Egg Scrambled With Milk',            serving: '2 eggs',        oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Egg Hard Boiled',                    serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),
  FoodItem(name: 'Egg Fried',                          serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Eggs',             tip: _eggTip),

  // ── FRUIT ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Apples Raw With Skin',               serving: 'one',           oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Apples Raw Without Skin',            serving: 'one',           oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Apples Dried',                       serving: '1/4 cup',       oxalateMg: 0.4,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Applesauce Unsweetened',             serving: '1/2 cup',       oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Apricots Raw',                       serving: '1 fruit',       oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Apricots Dried',                     serving: '5 halves',      oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Avocado',                            serving: '1/2 fruit',     oxalateMg: 9.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Bananas Raw',                        serving: 'one',           oxalateMg: 10.3, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Blackberries Raw',                   serving: '1/2 cup',       oxalateMg: 19.0, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Blueberries',                        serving: '1/2 cup',       oxalateMg: 18.5, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Cantaloupe',                         serving: '1/4 melon',     oxalateMg: 1.4,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Cherries Sweet Raw',                 serving: '1/2 cup',       oxalateMg: 1.7,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Cranberries Dried Sweetened',        serving: '1/4 cup',       oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Cranberries Raw',                    serving: '1 cup',         oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Cranberry Sauce Canned',             serving: '1/8 cup',       oxalateMg: 0.4,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Dates',                              serving: '5 dates',       oxalateMg: 25.5, level: OxalateLevel.high,     category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Figs Dried',                         serving: 'one',           oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Figs Raw',                           serving: 'one',           oxalateMg: 9.3,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Grapefruit Raw',                     serving: '1/2 medium',    oxalateMg: 13.2, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Grapes Red Or Green Seedless',       serving: '1/2 cup',       oxalateMg: 1.2,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Honeydew Melon',                     serving: '1 cup',         oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Kiwi Raw',                           serving: 'one',           oxalateMg: 16.0, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Lemons Raw',                         serving: '1/4 lemon',     oxalateMg: 1.2,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Limes Raw',                          serving: '1/8 lime',      oxalateMg: 0.7,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Mangos Raw',                         serving: '1/2 fruit',     oxalateMg: 0.3,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Mixed Dried Fruit',                  serving: '1/4 cup',       oxalateMg: 6.1,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Nectarines Raw',                     serving: 'one',           oxalateMg: 0.4,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Olives Canned Ripe',                 serving: '3 medium',      oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Oranges Raw',                        serving: 'one',           oxalateMg: 23.3, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Papayas Raw',                        serving: '1/2 medium',    oxalateMg: 0.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Peaches Canned In Syrup',            serving: '1/2 cup',       oxalateMg: 0.9,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Peaches Raw',                        serving: 'one',           oxalateMg: 1.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Pears Raw',                          serving: 'one',           oxalateMg: 1.7,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Pineapple Raw',                      serving: '1/2 cup',       oxalateMg: 2.2,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Plums Raw',                          serving: 'one',           oxalateMg: 1.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Pomegranate',                        serving: '1/2 cup seeds', oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Prunes Dried',                       serving: '5 prunes',      oxalateMg: 3.3,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Raisins Seedless',                   serving: '1/4 cup',       oxalateMg: 7.2,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Raspberries Raw',                    serving: '1/2 cup',       oxalateMg: 48.0, level: OxalateLevel.veryHigh, category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Strawberries Raw',                   serving: '1/2 cup',       oxalateMg: 2.5,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Tangerines Raw',                     serving: 'one',           oxalateMg: 18.0, level: OxalateLevel.moderate,  category: 'Fruit',            tip: _fruitTip),
  FoodItem(name: 'Watermelon Raw',                     serving: '1 cup',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Fruit',            tip: _fruitTip),

  // ── VEGETABLES ───────────────────────────────────────────────────────────
  FoodItem(name: 'Spinach Raw',                        serving: '1 cup',         oxalateMg: 656.0,level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Spinach Cooked',                     serving: '1/2 cup',       oxalateMg: 750.0,level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Beets Raw',                          serving: '1/2 cup',       oxalateMg: 152.0,level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Beets Canned',                       serving: '1/2 cup',       oxalateMg: 76.0, level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Swiss Chard Cooked',                 serving: '1/2 cup',       oxalateMg: 660.0,level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Rhubarb Raw',                        serving: '1/2 cup',       oxalateMg: 541.0,level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Okra Cooked',                        serving: '1/2 cup',       oxalateMg: 57.0, level: OxalateLevel.veryHigh, category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Leeks Cooked',                       serving: '1/2 cup',       oxalateMg: 32.0, level: OxalateLevel.high,     category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Sweet Potato Baked',                 serving: 'one medium',    oxalateMg: 28.0, level: OxalateLevel.high,     category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Kale Raw',                           serving: '1 cup',         oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Celery Raw',                         serving: '1 stalk',       oxalateMg: 19.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Green Beans Cooked',                 serving: '1/2 cup',       oxalateMg: 16.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Carrots Raw',                        serving: 'one medium',    oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Broccoli Raw',                       serving: '1/2 cup',       oxalateMg: 12.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Tomatoes Raw',                       serving: 'one medium',    oxalateMg: 13.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Tomato Sauce Canned',                serving: '1/2 cup',       oxalateMg: 22.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Corn Canned',                        serving: '1/2 cup',       oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Asparagus Cooked',                   serving: '1/2 cup',       oxalateMg: 15.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Potato White Baked With Skin',       serving: 'one medium',    oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Cauliflower Raw',                    serving: '1/2 cup',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Cabbage Green Raw',                  serving: '1/2 cup',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Mushrooms Raw',                      serving: '1/2 cup',       oxalateMg: 2.5,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Onions Raw',                         serving: '1/2 cup',       oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Garlic Raw',                         serving: '1 clove',       oxalateMg: 1.5,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Cucumber Raw',                       serving: '1/2 cup',       oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Lettuce Iceberg',                    serving: '1 cup',         oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Lettuce Romaine',                    serving: '1 cup',         oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Peas Green Frozen',                  serving: '1/2 cup',       oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Peppers Bell Green',                 serving: '1/2 cup',       oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Peppers Bell Red',                   serving: '1/2 cup',       oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Potato White Boiled',                serving: 'one medium',    oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Zucchini Raw',                       serving: '1/2 cup',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Brussels Sprouts Cooked',            serving: '1/2 cup',       oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Artichoke Hearts',                   serving: '1/2 cup',       oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Arugula Raw',                        serving: '1 cup',         oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Bok Choy Cooked',                    serving: '1/2 cup',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Eggplant Cooked',                    serving: '1/2 cup',       oxalateMg: 18.0, level: OxalateLevel.moderate,  category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Pumpkin Canned',                     serving: '1/2 cup',       oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Radishes Raw',                       serving: '1/2 cup',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),
  FoodItem(name: 'Snow Peas Raw',                      serving: '1/2 cup',       oxalateMg: 6.0,  level: OxalateLevel.low,      category: 'Vegetables',       tip: _vegTip),

  // ── GRAINS & PASTA ───────────────────────────────────────────────────────
  FoodItem(name: 'White Rice Cooked',                  serving: '1 cup',         oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Brown Rice Cooked',                  serving: '1 cup',         oxalateMg: 13.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Pasta White Cooked',                 serving: '1 cup',         oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Pasta Whole Wheat Cooked',           serving: '1 cup',         oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Oatmeal Cooked',                     serving: '1 cup',         oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Oatmeal Instant Plain',              serving: '1 packet',      oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Quinoa Cooked',                      serving: '1 cup',         oxalateMg: 51.0, level: OxalateLevel.veryHigh, category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cornmeal Cooked',                    serving: '1 cup',         oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Grits Cooked',                       serving: '1 cup',         oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Corn Flakes',                 serving: '1 cup',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Rice Krispies',               serving: '1 cup',         oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Raisin Bran',                 serving: '1 cup',         oxalateMg: 57.0, level: OxalateLevel.veryHigh, category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Cream Of Wheat',              serving: '1 cup',         oxalateMg: 16.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Cheerios',                    serving: '1 cup',         oxalateMg: 6.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Cereal Frosted Flakes',              serving: '1 cup',         oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Granola',                            serving: '1/2 cup',       oxalateMg: 21.0, level: OxalateLevel.moderate,  category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Buckwheat Groats Cooked',            serving: '1 cup',         oxalateMg: 133.0,level: OxalateLevel.veryHigh, category: 'Grains & Pasta',   tip: _grainTip),
  FoodItem(name: 'Barley Cooked',                      serving: '1 cup',         oxalateMg: 9.0,  level: OxalateLevel.low,      category: 'Grains & Pasta',   tip: _grainTip),

  // ── MEAT, POULTRY & FISH ─────────────────────────────────────────────────
  FoodItem(name: 'Chicken Breast Cooked',              serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Chicken Thigh Cooked',               serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Chicken Wings',                      serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Ground Beef 80% Lean',               serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Steak Beef Cooked',                  serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Beef Roast',                         serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Pork Chop Cooked',                   serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Pork Ribs',                          serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Bacon Cooked',                       serving: '3 slices',      oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Ham Cooked',                         serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Turkey Breast Cooked',               serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Tuna Canned In Water',               serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Salmon Cooked',                      serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Shrimp Cooked',                      serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Tilapia Cooked',                     serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Cod Cooked',                         serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Sardines Canned',                    serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Crab Cooked',                        serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Lobster Cooked',                     serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Scallops Cooked',                    serving: '3 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Hot Dog Beef',                       serving: 'one',           oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Sausage Pork',                       serving: '2 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Deli Turkey Sliced',                 serving: '2 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),
  FoodItem(name: 'Pepperoni',                          serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Meat & Fish',      tip: _meatTip),

  // ── NUTS & SEEDS ─────────────────────────────────────────────────────────
  FoodItem(name: 'Almonds',                            serving: '1 oz (23 nuts)',oxalateMg: 122.0,level: OxalateLevel.veryHigh, category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Peanuts Dry Roasted',                serving: '1 oz',          oxalateMg: 27.0, level: OxalateLevel.high,     category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Peanut Butter',                      serving: '2 tbsp',        oxalateMg: 13.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Cashews',                            serving: '1 oz',          oxalateMg: 49.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Walnuts',                            serving: '1 oz',          oxalateMg: 31.0, level: OxalateLevel.high,     category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Pecans',                             serving: '1 oz',          oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Macadamia Nuts',                     serving: '1 oz',          oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Pistachio Nuts',                     serving: '1 oz',          oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Brazil Nuts',                        serving: '1 oz',          oxalateMg: 73.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Hazelnuts',                          serving: '1 oz',          oxalateMg: 31.0, level: OxalateLevel.high,     category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Sunflower Seeds',                    serving: '1 oz',          oxalateMg: 45.0, level: OxalateLevel.veryHigh, category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Pumpkin Seeds',                      serving: '1 oz',          oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Sesame Seeds',                       serving: '1 tbsp',        oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Chia Seeds',                         serving: '1 tbsp',        oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Flaxseeds',                          serving: '1 tbsp',        oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Nuts & Seeds',     tip: _nutTip),
  FoodItem(name: 'Tahini',                             serving: '2 tbsp',        oxalateMg: 34.0, level: OxalateLevel.high,     category: 'Nuts & Seeds',     tip: _nutTip),

  // ── BEANS & LEGUMES ──────────────────────────────────────────────────────
  FoodItem(name: 'Kidney Beans Cooked',                serving: '1/2 cup',       oxalateMg: 15.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Black Beans Cooked',                 serving: '1/2 cup',       oxalateMg: 21.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Pinto Beans Cooked',                 serving: '1/2 cup',       oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Chickpeas Cooked',                   serving: '1/2 cup',       oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Lentils Cooked',                     serving: '1/2 cup',       oxalateMg: 19.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Soybeans Cooked',                    serving: '1/2 cup',       oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Navy Beans Cooked',                  serving: '1/2 cup',       oxalateMg: 11.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Great Northern Beans',               serving: '1/2 cup',       oxalateMg: 12.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Tofu Firm',                          serving: '3 oz',          oxalateMg: 13.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Hummus',                             serving: '2 tbsp',        oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Edamame',                            serving: '1/2 cup',       oxalateMg: 17.0, level: OxalateLevel.moderate,  category: 'Beans & Legumes',  tip: _legumeTip),
  FoodItem(name: 'Split Peas Cooked',                  serving: '1/2 cup',       oxalateMg: 9.0,  level: OxalateLevel.low,      category: 'Beans & Legumes',  tip: _legumeTip),

  // ── BEVERAGES ────────────────────────────────────────────────────────────
  FoodItem(name: 'Water',                              serving: '8 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Coffee Brewed',                      serving: '8 oz',          oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Tea Black Brewed',                   serving: '8 oz',          oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Tea Green Brewed',                   serving: '8 oz',          oxalateMg: 12.0, level: OxalateLevel.moderate,  category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Tea Herbal Brewed',                  serving: '8 oz',          oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Lemonade From Concentrate',          serving: '8 oz',          oxalateMg: 1.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Lemon Juice Fresh',                  serving: '1/4 cup',       oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Orange Juice',                       serving: '8 oz',          oxalateMg: 10.0, level: OxalateLevel.moderate,  category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Apple Juice',                        serving: '8 oz',          oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Grape Juice',                        serving: '8 oz',          oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Cranberry Juice Cocktail',           serving: '8 oz',          oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Pineapple Juice',                    serving: '8 oz',          oxalateMg: 3.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Tomato Juice',                       serving: '8 oz',          oxalateMg: 7.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Soda Cola',                          serving: '12 oz',         oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Soda Diet',                          serving: '12 oz',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Soda Lemon-Lime',                    serving: '12 oz',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Beer',                               serving: '12 oz',         oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Wine Red',                           serving: '5 oz',          oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Wine White',                         serving: '5 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Sports Drink Gatorade',              serving: '12 oz',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Hot Chocolate Mix',                  serving: '1 packet',      oxalateMg: 16.0, level: OxalateLevel.moderate,  category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Coconut Water',                      serving: '8 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),
  FoodItem(name: 'Energy Drink',                       serving: '8 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Beverages',        tip: _beverageTip),

  // ── SNACKS ───────────────────────────────────────────────────────────────
  FoodItem(name: 'Popcorn Plain Air-Popped',           serving: '3 cups',        oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Pretzels',                           serving: '1 oz',          oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Rice Cakes',                         serving: '2 cakes',       oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Potato Chips',                       serving: '1 oz',          oxalateMg: 9.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Corn Chips Fritos',                  serving: '1 oz',          oxalateMg: 8.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Tortilla Chips',                     serving: '1 oz',          oxalateMg: 8.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Trail Mix With Nuts',                serving: '1/4 cup',       oxalateMg: 45.0, level: OxalateLevel.veryHigh, category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Graham Crackers',                    serving: '2 sheets',      oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Animal Crackers',                    serving: '1 oz',          oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Cheese Crackers',                    serving: '1 oz',          oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Pork Rinds',                         serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'Beef Jerky',                         serving: '1 oz',          oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),
  FoodItem(name: 'String Cheese',                      serving: 'one stick',     oxalateMg: 0.1,  level: OxalateLevel.low,      category: 'Snacks',           tip: _snackTip),

  // ── SOUPS ────────────────────────────────────────────────────────────────
  FoodItem(name: 'Chicken Noodle Soup Canned',         serving: '1 cup',         oxalateMg: 2.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Tomato Soup Canned With Water',      serving: '1 cup',         oxalateMg: 12.0, level: OxalateLevel.moderate,  category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Beef Broth',                         serving: '1 cup',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Chicken Broth',                      serving: '1 cup',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Vegetable Soup Canned',              serving: '1 cup',         oxalateMg: 8.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Minestrone Soup',                    serving: '1 cup',         oxalateMg: 14.0, level: OxalateLevel.moderate,  category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Lentil Soup',                        serving: '1 cup',         oxalateMg: 22.0, level: OxalateLevel.moderate,  category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Clam Chowder',                       serving: '1 cup',         oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'French Onion Soup',                  serving: '1 cup',         oxalateMg: 4.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),
  FoodItem(name: 'Cream Of Mushroom Soup',             serving: '1 cup',         oxalateMg: 5.0,  level: OxalateLevel.low,      category: 'Soups',            tip: _soupTip),

  // ── OILS & FATS ──────────────────────────────────────────────────────────
  FoodItem(name: 'Olive Oil',                          serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Canola Oil',                         serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Vegetable Oil',                      serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Coconut Oil',                        serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Margarine',                          serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Avocado Oil',                        serving: '1 tbsp',        oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),
  FoodItem(name: 'Sesame Oil',                         serving: '1 tsp',         oxalateMg: 0.0,  level: OxalateLevel.low,      category: 'Oils & Fats',      tip: _oilTip),

];
