import '../models/models.dart';

/// Step-by-step recipes for every meal in the catalog. Written for two
/// servings unless noted, in both English and Sinhala.
class RecipeBook {
  RecipeBook._();

  static const _recipes = <String, Recipe>{
    'oatmeal': Recipe(
      servings: 2,
      prepMinutes: 3,
      tip: 'Soak the oats in milk overnight and you only need two minutes on '
          'the stove in the morning.',
      tipSi: 'රාත්‍රියේ ඕට්ස් කිරිවල පෙඟෙන්න තැබුවොත් උදේට තත්පර දෙකක් පමණයි.',
      ingredients: [
        RecipeIngredient(
            quantity: '80 g', name: 'rolled oats', nameSi: 'ඕට්ස්'),
        RecipeIngredient(quantity: '250 ml', name: 'milk', nameSi: 'කිරි'),
        RecipeIngredient(quantity: '1', name: 'banana', nameSi: 'කෙසෙල්'),
        RecipeIngredient(quantity: '½ tsp', name: 'cinnamon', nameSi: 'කුරුඳු'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'almond butter', nameSi: 'අල්මන්ඩ් බටර්'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
        RecipeIngredient(quantity: '1 pinch', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text:
              'Warm the milk in a small pan until it steams — do not let it boil.',
          textSi: 'කුඩා තාච්චියක කිරි උණු කරන්න. උතුරන්නට ඉඩ දෙන්න එපා.',
        ),
        RecipeStep(
          text:
              'Stir in the oats and salt. Simmer on low for 5 minutes, stirring now and then.',
          textSi:
              'ඕට්ස් සහ ලුණු එකතු කරන්න. අඩු ගින්නේ මිනිත්තු 5ක් වරින් වර කලවම් කරමින් උයන්න.',
        ),
        RecipeStep(
          text: 'Add the cinnamon and cook for 1 more minute until creamy.',
          textSi: 'කුරුඳු එකතු කර තව මිනිත්තුවක් ක්‍රීමි වන තෙක් උයන්න.',
        ),
        RecipeStep(
          text: 'Spoon into bowls and slice the banana over the top.',
          textSi: 'බෝල්වලට දමා උඩින් කෙසෙල් කපන්න.',
        ),
        RecipeStep(
          text: 'Finish with almond butter and a drizzle of honey.',
          textSi: 'අල්මන්ඩ් බටර් සහ මී පැණි ටිකක් උඩින් දමන්න.',
        ),
      ],
    ),
    'salmon': Recipe(
      servings: 2,
      prepMinutes: 8,
      tip:
          'Pat the salmon very dry before it hits the pan — that is what gives '
          'you a crisp skin instead of a steamed one.',
      tipSi: 'සැල්මන් තාච්චියට දැමීමට පෙර හොඳින් වියලන්න. එතකොට හම කරකර වේ.',
      ingredients: [
        RecipeIngredient(
            quantity: '2 × 150 g',
            name: 'salmon fillets',
            nameSi: 'සැල්මන් ෆිලට්'),
        RecipeIngredient(quantity: '100 g', name: 'quinoa', nameSi: 'කිනෝවා'),
        RecipeIngredient(quantity: '100 g', name: 'spinach', nameSi: 'නිවිති'),
        RecipeIngredient(quantity: '1', name: 'lemon', nameSi: 'ලෙමන්'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'olive oil', nameSi: 'ඔලිව් තෙල්'),
        RecipeIngredient(
            quantity: '1 clove', name: 'garlic', nameSi: 'සුදු ලූනු'),
        RecipeIngredient(
            quantity: 'to taste',
            name: 'salt and pepper',
            nameSi: 'ලුණු සහ ගම්මිරිස්'),
      ],
      steps: [
        RecipeStep(
          text:
              'Rinse the quinoa and simmer in twice its volume of water for 12 minutes.',
          textSi:
              'කිනෝවා සෝදා එහි ප්‍රමාණයට දෙගුණයක් වතුරේ මිනිත්තු 12ක් උයන්න.',
        ),
        RecipeStep(
          text: 'Pat the salmon dry, season both sides with salt and pepper.',
          textSi: 'සැල්මන් වියලා දෙපැත්තටම ලුණු සහ ගම්මිරිස් ගාන්න.',
        ),
        RecipeStep(
          text:
              'Heat the oil in a pan and lay the salmon in skin-side down. Leave it for 4 minutes without moving it.',
          textSi:
              'තෙල් රත් කර සැල්මන් හම පැත්ත පහළට දමන්න. මිනිත්තු 4ක් සෙලවීමකින් තොරව තබන්න.',
        ),
        RecipeStep(
          text: 'Flip and cook 2–3 minutes more, then rest on a plate.',
          textSi: 'පෙරළා තව මිනිත්තු 2–3ක් උයා පිඟානකට ගන්න.',
        ),
        RecipeStep(
          text:
              'Wilt the spinach with the garlic in the same pan for 2 minutes.',
          textSi:
              'එම තාච්චියේම සුදු ලූනු සමඟ නිවිති මිනිත්තු 2ක් මැලවෙන්න සලන්න.',
        ),
        RecipeStep(
          text: 'Plate the quinoa, spinach and salmon with a squeeze of lemon.',
          textSi: 'කිනෝවා, නිවිති සහ සැල්මන් පිඟානකට දමා ලෙමන් යුෂ ඉසින්න.',
        ),
      ],
    ),
    'pumpkin_soup': Recipe(
      servings: 2,
      prepMinutes: 5,
      tip: 'A pinch of nutmeg at the very end makes it taste finished — add it '
          'after blending, not before.',
      tipSi: 'නට්මෙග් අවසානයේ එකතු කරන්න. එය රසය සම්පූර්ණ කරයි.',
      ingredients: [
        RecipeIngredient(
            quantity: '500 g', name: 'pumpkin', nameSi: 'වට්ටක්කා'),
        RecipeIngredient(quantity: '1', name: 'onion', nameSi: 'ලූනු'),
        RecipeIngredient(
            quantity: '2 cloves', name: 'garlic', nameSi: 'සුදු ලූනු'),
        RecipeIngredient(quantity: '1 tsp', name: 'ginger', nameSi: 'ඉඟුරු'),
        RecipeIngredient(
            quantity: '200 ml', name: 'coconut milk', nameSi: 'පොල් කිරි'),
        RecipeIngredient(
            quantity: '300 ml', name: 'vegetable stock', nameSi: 'එළවළු සුප්'),
        RecipeIngredient(
            quantity: '1 pinch', name: 'nutmeg', nameSi: 'නට්මෙග්'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'olive oil', nameSi: 'ඔලිව් තෙල්'),
      ],
      steps: [
        RecipeStep(
          text: 'Soften the onion, garlic and ginger in the oil for 3 minutes.',
          textSi: 'තෙල්වල ලූනු, සුදු ලූනු සහ ඉඟුරු මිනිත්තු 3ක් මෘදු කරන්න.',
        ),
        RecipeStep(
          text:
              'Add the cubed pumpkin and stock. Simmer with the lid on for 15 minutes.',
          textSi:
              'කැබලි කපාගත් වට්ටක්කා සහ සුප් එකතු කර වසා මිනිත්තු 15ක් උයන්න.',
        ),
        RecipeStep(
          text: 'Blend until completely smooth.',
          textSi: 'සම්පූර්ණයෙන් මෘදු වන තෙක් බ්ලෙන්ඩ් කරන්න.',
        ),
        RecipeStep(
          text: 'Stir in the coconut milk and warm through — do not boil.',
          textSi: 'පොල් කිරි එකතු කර රත් කරන්න. උතුරන්නට දෙන්න එපා.',
        ),
        RecipeStep(
          text: 'Season, add nutmeg, and serve with seeds or croutons.',
          textSi: 'ලුණු දමා නට්මෙග් එකතු කර ඇට හෝ ක්‍රූටෝන් සමඟ පිළිගන්වන්න.',
        ),
      ],
    ),
    'parfait': Recipe(
      servings: 2,
      prepMinutes: 5,
      tip:
          'Layer it in a clear glass — we eat with our eyes first, and this is '
          'a five-minute meal that looks like a café one.',
      tipSi: 'පැහැදිලි වීදුරුවක තට්ටු වශයෙන් දමන්න. ඇස්වලින් කන ආහාරයක් මෙයයි.',
      ingredients: [
        RecipeIngredient(
            quantity: '200 g', name: 'Greek yogurt', nameSi: 'ග්‍රීක් යෝගට්'),
        RecipeIngredient(
            quantity: '100 g', name: 'mixed berries', nameSi: 'බෙරි මිශ්‍රණය'),
        RecipeIngredient(
            quantity: '40 g', name: 'granola', nameSi: 'ග්‍රැනෝලා'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'pumpkin seeds', nameSi: 'පම්කින් ඇට'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
      ],
      steps: [
        RecipeStep(
          text: 'Spoon a third of the yogurt into each glass.',
          textSi: 'යෝගට්වලින් තුනෙන් එකක් සෑම වීදුරුවකටම දමන්න.',
        ),
        RecipeStep(
          text: 'Add half the berries, then a layer of granola.',
          textSi: 'බෙරිවලින් අඩක් දමා ඉන්පසු ග්‍රැනෝලා තට්ටුවක් දමන්න.',
        ),
        RecipeStep(
          text: 'Repeat the layers and finish with the remaining yogurt.',
          textSi: 'නැවත තට්ටු කර ඉතිරි යෝගට් උඩින් දමන්න.',
        ),
        RecipeStep(
          text:
              'Top with seeds and a drizzle of honey. Eat within an hour for the crunch.',
          textSi: 'ඇට සහ මී පැණි උඩින් දමන්න. කරකර රසයට පැයක් ඇතුළත කන්න.',
        ),
      ],
    ),
    'dhal': Recipe(
      servings: 2,
      prepMinutes: 5,
      tip:
          'Do not stir the lentils too hard once the coconut milk goes in — you '
          'want some whole grains left.',
      tipSi: 'පොල් කිරි දැමූ පසු පරිප්පු තදින් කලවම් නොකරන්න.',
      ingredients: [
        RecipeIngredient(
            quantity: '150 g', name: 'red lentils', nameSi: 'පරිප්පු'),
        RecipeIngredient(
            quantity: '200 ml', name: 'coconut milk', nameSi: 'පොල් කිරි'),
        RecipeIngredient(quantity: '1', name: 'onion', nameSi: 'ලූනු'),
        RecipeIngredient(
            quantity: '2 cloves', name: 'garlic', nameSi: 'සුදු ලූනු'),
        RecipeIngredient(
            quantity: '10 leaves', name: 'curry leaves', nameSi: 'කරපිංචා'),
        RecipeIngredient(quantity: '½ tsp', name: 'turmeric', nameSi: 'කහ'),
        RecipeIngredient(
            quantity: '1 tsp', name: 'chilli powder', nameSi: 'මිරිස් කුඩු'),
        RecipeIngredient(
            quantity: '½ tsp', name: 'mustard seeds', nameSi: 'අබ ඇට'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'coconut oil', nameSi: 'පොල් තෙල්'),
        RecipeIngredient(quantity: 'to taste', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text:
              'Rinse the lentils and simmer with turmeric and 400 ml water for 15 minutes.',
          textSi:
              'පරිප්පු සෝදා කහ සහ වතුර මිලි ලීටර් 400ක් සමඟ මිනිත්තු 15ක් උයන්න.',
        ),
        RecipeStep(
          text: 'Heat the coconut oil and pop the mustard seeds.',
          textSi: 'පොල් තෙල් රත් කර අබ ඇට පුපුරවන්න.',
        ),
        RecipeStep(
          text: 'Fry the onion, garlic and curry leaves until golden.',
          textSi: 'ලූනු, සුදු ලූනු සහ කරපිංචා රන්වන් වන තෙක් බදින්න.',
        ),
        RecipeStep(
          text: 'Stir the tempering and chilli powder into the lentils.',
          textSi: 'මේ මිශ්‍රණය සහ මිරිස් කුඩු පරිප්පුවලට එකතු කරන්න.',
        ),
        RecipeStep(
          text:
              'Pour in the coconut milk, season, and simmer 5 minutes without boiling hard.',
          textSi:
              'පොල් කිරි දමා ලුණු දමා තදින් උතුරන්නට නොදී මිනිත්තු 5ක් උයන්න.',
        ),
      ],
    ),
    'kottu': Recipe(
      servings: 2,
      prepMinutes: 6,
      tip: 'Have everything chopped before you start. Kottu is a three-minute '
          'cook once the pan is hot.',
      tipSi:
          'උයන්නට පෙර සියල්ල කපාගන්න. තාච්චිය රත් වුණාම කොත්තු තිබෙන්නේ මිනිත්තු තුනක්.',
      ingredients: [
        RecipeIngredient(
            quantity: '3', name: 'godhamba roti', nameSi: 'ගොඩම්බ රොටි'),
        RecipeIngredient(quantity: '1', name: 'carrot', nameSi: 'කැරට්'),
        RecipeIngredient(quantity: '1', name: 'leek', nameSi: 'ලීක්ස්'),
        RecipeIngredient(quantity: '100 g', name: 'cabbage', nameSi: 'ගෝවා'),
        RecipeIngredient(quantity: '2', name: 'eggs', nameSi: 'බිත්තර'),
        RecipeIngredient(
            quantity: '1 tsp', name: 'curry powder', nameSi: 'කරි පවුඩර්'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'soy sauce', nameSi: 'සෝයා සෝස්'),
        RecipeIngredient(quantity: '2 tbsp', name: 'oil', nameSi: 'තෙල්'),
      ],
      steps: [
        RecipeStep(
          text: 'Slice the roti into thin strips with a sharp knife.',
          textSi: 'රොටි තුනී පටි වලට කපන්න.',
        ),
        RecipeStep(
          text:
              'Stir-fry the carrot, leek and cabbage in hot oil for 3 minutes.',
          textSi: 'රත් තෙල්වල කැරට්, ලීක්ස් සහ ගෝවා මිනිත්තු 3ක් බදින්න.',
        ),
        RecipeStep(
          text: 'Push the vegetables to one side and scramble the eggs.',
          textSi: 'එළවළු එක පැත්තකට කර බිත්තර බදින්න.',
        ),
        RecipeStep(
          text: 'Add the roti strips, curry powder and soy sauce. Toss hard.',
          textSi: 'රොටි පටි, කරි පවුඩර් සහ සෝයා සෝස් දමා හොඳින් කලවම් කරන්න.',
        ),
        RecipeStep(
          text:
              'Chop through the mix with two spatulas for 3–4 minutes and serve immediately.',
          textSi:
              'ස්පටුලා දෙකකින් මිනිත්තු 3–4ක් කපමින් මිශ්‍ර කර වහාම පිළිගන්වන්න.',
        ),
      ],
    ),
    'avocado_toast': Recipe(
      servings: 2,
      prepMinutes: 5,
      tip: 'Salt the avocado a full minute before you eat it. It changes the '
          'texture more than you would expect.',
      tipSi: 'ඇවකාඩෝ කෑමට මිනිත්තුවකට පෙර ලුණු දමන්න. එය රසය වෙනස් කරයි.',
      ingredients: [
        RecipeIngredient(
            quantity: '2 slices', name: 'sourdough', nameSi: 'සෝර්ඩෝ පාන්'),
        RecipeIngredient(quantity: '1', name: 'avocado', nameSi: 'ඇවකාඩෝ'),
        RecipeIngredient(quantity: '2', name: 'eggs', nameSi: 'බිත්තර'),
        RecipeIngredient(quantity: '½', name: 'lemon', nameSi: 'ලෙමන්'),
        RecipeIngredient(
            quantity: '1 pinch', name: 'chilli flakes', nameSi: 'මිරිස් පතුරු'),
        RecipeIngredient(quantity: 'to taste', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text: 'Toast the bread until it is properly crisp.',
          textSi: 'පාන් හොඳින් කරකර වන තෙක් ටෝස්ට් කරන්න.',
        ),
        RecipeStep(
          text: 'Mash the avocado with lemon juice and salt — keep it chunky.',
          textSi:
              'ඇවකාඩෝ ලෙමන් යුෂ සහ ලුණු සමඟ මෘදු කරන්න. ගැටිති තිබීම හොඳයි.',
        ),
        RecipeStep(
          text: 'Poach the eggs in gently simmering water for 3 minutes.',
          textSi: 'සෙමින් උතුරන වතුරේ බිත්තර මිනිත්තු 3ක් උයන්න.',
        ),
        RecipeStep(
          text: 'Spread the avocado on the toast and top with an egg.',
          textSi: 'ටෝස්ට් උඩ ඇවකාඩෝ ගා බිත්තරයක් තබන්න.',
        ),
        RecipeStep(
          text: 'Finish with chilli flakes and a little more salt.',
          textSi: 'මිරිස් පතුරු සහ ලුණු ටිකක් උඩින් දමන්න.',
        ),
      ],
    ),
    'chocolate': Recipe(
      servings: 2,
      prepMinutes: 1,
      tip:
          'This is a ritual, not a recipe. Two squares, no phone, and give it a '
          'full minute to melt.',
      tipSi:
          'මේ උයන දෙයක් නොවේ, පුරුද්දක්. කැබැලි දෙකක්, දුරකථනයක් නැතුව මිනිත්තුවක් රස විඳින්න.',
      ingredients: [
        RecipeIngredient(
            quantity: '20 g',
            name: '70% dark chocolate',
            nameSi: '70% ඩාර්ක් චොකලට්'),
      ],
      steps: [
        RecipeStep(
          text: 'Break off two squares and put the rest away — out of reach.',
          textSi: 'කැබැලි දෙකක් කඩා ඉතිරිය අත ළඟ නොතබන්න.',
        ),
        RecipeStep(
          text:
              'Let the first square melt on your tongue instead of chewing it.',
          textSi: 'පළමු කැබැල්ල හපන්නේ නැතුව දිව මත දියවෙන්න දෙන්න.',
        ),
        RecipeStep(
          text:
              'Notice one flavour — fruit, coffee, smoke — before the second square.',
          textSi: 'දෙවන කැබැල්ලට පෙර එක් රසයක් හඳුනාගන්න.',
        ),
        RecipeStep(
          text: 'Finish with a glass of water and go back to your day.',
          textSi: 'වතුර වීදුරුවක් බී දවසේ වැඩට යන්න.',
        ),
      ],
    ),
    'green_tea': Recipe(
      servings: 1,
      prepMinutes: 4,
      tip:
          'Water that is too hot is what makes green tea bitter. Let the kettle '
          'sit for a minute after boiling.',
      tipSi:
          'වැඩිපුර උණු වතුර හරිත තේ තිත්ත කරයි. උතුරන වතුර මිනිත්තුවක් නිවෙන්න දෙන්න.',
      ingredients: [
        RecipeIngredient(
            quantity: '1 tsp', name: 'green tea leaves', nameSi: 'හරිත තේ'),
        RecipeIngredient(quantity: '200 ml', name: 'water', nameSi: 'වතුර'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
        RecipeIngredient(quantity: '1 slice', name: 'lemon', nameSi: 'ලෙමන්'),
      ],
      steps: [
        RecipeStep(
          text: 'Boil the water, then let it cool for a minute to about 80 °C.',
          textSi: 'වතුර උතුරවා මිනිත්තුවක් නිවෙන්න දෙන්න.',
        ),
        RecipeStep(
          text: 'Put the leaves in a cup and pour the water over them.',
          textSi: 'තේ කෝප්පයකට දමා උණු වතුර වක් කරන්න.',
        ),
        RecipeStep(
          text: 'Steep for 2–3 minutes — no longer.',
          textSi: 'මිනිත්තු 2–3ක් පමණක් තබන්න.',
        ),
        RecipeStep(
          text: 'Add honey and lemon once it has cooled slightly.',
          textSi: 'ටිකක් නිවුණු පසු මී පැණි සහ ලෙමන් එකතු කරන්න.',
        ),
      ],
    ),
    'rice_bowl': Recipe(
      servings: 2,
      prepMinutes: 7,
      tip: 'Cook a batch of brown rice on Sunday and this becomes a ten-minute '
          'weeknight bowl.',
      tipSi:
          'ඉරිදා බ්‍රවුන් රයිස් ටිකක් උයා තැබුවොත් සවසට මිනිත්තු දහයක වැඩක්.',
      ingredients: [
        RecipeIngredient(
            quantity: '300 g cooked',
            name: 'brown rice',
            nameSi: 'බ්‍රවුන් රයිස්'),
        RecipeIngredient(
            quantity: '100 g', name: 'sweet corn', nameSi: 'බඩ ඉරිඟු'),
        RecipeIngredient(quantity: '1', name: 'carrot', nameSi: 'කැරට්'),
        RecipeIngredient(quantity: '2', name: 'eggs', nameSi: 'බිත්තර'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'sesame oil', nameSi: 'සෙසම් තෙල්'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'soy sauce', nameSi: 'සෝයා සෝස්'),
        RecipeIngredient(
            quantity: '2', name: 'spring onions', nameSi: 'ලූනු කොළ'),
      ],
      steps: [
        RecipeStep(
          text:
              'Roast the carrot and corn with a little oil at 200 °C for 10 minutes.',
          textSi:
              'කැරට් සහ ඉරිඟු තෙල් ටිකක් සමඟ 200 °C උෂ්ණත්වයේ මිනිත්තු 10ක් බේක් කරන්න.',
        ),
        RecipeStep(
          text: 'Fry the eggs in sesame oil until the whites are set.',
          textSi: 'සෙසම් තෙල්වල බිත්තර බදින්න.',
        ),
        RecipeStep(
          text: 'Warm the rice and divide between two bowls.',
          textSi: 'බත් රත් කර බෝල් දෙකකට බෙදන්න.',
        ),
        RecipeStep(
          text:
              'Arrange the vegetables and egg on top, then add soy sauce and spring onion.',
          textSi: 'එළවළු සහ බිත්තර උඩින් තබා සෝයා සෝස් සහ ලූනු කොළ දමන්න.',
        ),
      ],
    ),
    'soba': Recipe(
      servings: 2,
      prepMinutes: 8,
      tip:
          'Rinse the noodles in cold water straight after boiling. It stops the '
          'cooking and removes the starch that makes them gluey.',
      tipSi:
          'උයා ගත් පසු නූඩ්ල්ස් සිසිල් වතුරෙන් සෝදන්න. එය ඇලෙන ගතිය අඩු කරයි.',
      ingredients: [
        RecipeIngredient(
            quantity: '150 g', name: 'soba noodles', nameSi: 'සෝබා නූඩ්ල්ස්'),
        RecipeIngredient(quantity: '1', name: 'cucumber', nameSi: 'පිපිඤ්ඤා'),
        RecipeIngredient(
            quantity: '2', name: 'spring onions', nameSi: 'ලූනු කොළ'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'sesame seeds', nameSi: 'සෙසම් ඇට'),
        RecipeIngredient(
            quantity: '2 tbsp', name: 'soy sauce', nameSi: 'සෝයා සෝස්'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'rice vinegar', nameSi: 'සහල් විනාකිරි'),
        RecipeIngredient(
            quantity: '1 tsp', name: 'sesame oil', nameSi: 'සෙසම් තෙල්'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
      ],
      steps: [
        RecipeStep(
          text:
              'Boil the soba for 4 minutes, then rinse under cold water and drain well.',
          textSi: 'සෝබා මිනිත්තු 4ක් උයා සිසිල් වතුරෙන් සෝදා හොඳින් වියලන්න.',
        ),
        RecipeStep(
          text:
              'Whisk the soy sauce, vinegar, sesame oil and honey into a dressing.',
          textSi:
              'සෝයා සෝස්, විනාකිරි, සෙසම් තෙල් සහ මී පැණි මිශ්‍ර කර ඩ්‍රෙසිං සාදන්න.',
        ),
        RecipeStep(
          text:
              'Slice the cucumber into thin ribbons and the spring onion finely.',
          textSi: 'පිපිඤ්ඤා තුනීව සහ ලූනු කොළ කුඩාවට කපන්න.',
        ),
        RecipeStep(
          text: 'Toss the noodles, vegetables and dressing together.',
          textSi: 'නූඩ්ල්ස්, එළවළු සහ ඩ්‍රෙසිං එකට කලවම් කරන්න.',
        ),
        RecipeStep(
          text: 'Finish with sesame seeds and serve cold.',
          textSi: 'සෙසම් ඇට උඩින් දමා සිසිල්ව පිළිගන්වන්න.',
        ),
      ],
    ),
    'mango_smoothie': Recipe(
      servings: 2,
      prepMinutes: 6,
      tip: 'Frozen mango gives you a thick smoothie without watering it down '
          'with ice.',
      tipSi: 'ශීත කළ අඹ දැම්මොත් අයිස් දැමීමෙන් තොරව ඝන ස්මූතී එකක් ලැබේ.',
      ingredients: [
        RecipeIngredient(quantity: '1 large', name: 'mango', nameSi: 'අඹ'),
        RecipeIngredient(quantity: '150 g', name: 'yogurt', nameSi: 'යෝගට්'),
        RecipeIngredient(quantity: '½', name: 'lime', nameSi: 'දෙහි'),
        RecipeIngredient(quantity: '1 cm', name: 'ginger', nameSi: 'ඉඟුරු'),
        RecipeIngredient(quantity: '4 cubes', name: 'ice', nameSi: 'අයිස්'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
      ],
      steps: [
        RecipeStep(
          text: 'Peel and chop the mango, keeping a few slices for the top.',
          textSi: 'අඹ ලෙලි අරගෙන කපන්න. කැබැලි කිහිපයක් උඩින් දමන්න තබන්න.',
        ),
        RecipeStep(
          text:
              'Blend the mango, yogurt, lime juice, ginger and ice for 45 seconds.',
          textSi:
              'අඹ, යෝගට්, ලෙමන් යුෂ, ඉඟුරු සහ අයිස් තත්පර 45ක් බ්ලෙන්ඩ් කරන්න.',
        ),
        RecipeStep(
          text: 'Taste and add honey only if the mango needs it.',
          textSi: 'රස බලා අවශ්‍ය නම් පමණක් මී පැණි එකතු කරන්න.',
        ),
        RecipeStep(
          text: 'Pour into cold glasses and drink slowly.',
          textSi: 'සිසිල් වීදුරුවලට වක් කර සෙමින් බොන්න.',
        ),
      ],
    ),
    'sweet_potato': Recipe(
      servings: 2,
      prepMinutes: 8,
      tip: 'Do not crowd the tray. Gaps between the wedges are what make them '
          'crisp rather than steamed.',
      tipSi: 'වට්ටියේ ඉඩ තබන්න. එතකොට බතල කරකර වේ.',
      ingredients: [
        RecipeIngredient(quantity: '2', name: 'sweet potatoes', nameSi: 'බතල'),
        RecipeIngredient(
            quantity: '1 tbsp', name: 'olive oil', nameSi: 'ඔලිව් තෙල්'),
        RecipeIngredient(
            quantity: '1 tsp', name: 'rosemary', nameSi: 'රොස්මේරි'),
        RecipeIngredient(
            quantity: '½ tsp', name: 'paprika', nameSi: 'පැප්‍රිකා'),
        RecipeIngredient(quantity: '100 g', name: 'yogurt', nameSi: 'යෝගට්'),
        RecipeIngredient(
            quantity: '1 clove', name: 'garlic', nameSi: 'සුදු ලූනු'),
        RecipeIngredient(quantity: 'to taste', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text: 'Heat the oven to 200 °C.',
          textSi: 'උඳුන 200 °C උෂ්ණත්වයට රත් කරන්න.',
        ),
        RecipeStep(
          text:
              'Cut the sweet potatoes into wedges and toss with oil, rosemary and paprika.',
          textSi: 'බතල කැබලි කපා තෙල්, රොස්මේරි සහ පැප්‍රිකා සමඟ මිශ්‍ර කරන්න.',
        ),
        RecipeStep(
          text:
              'Spread them on a tray with space between each wedge and salt well.',
          textSi: 'එකිනෙක අතර ඉඩ තබමින් වට්ටියක තබා ලුණු දමන්න.',
        ),
        RecipeStep(
          text: 'Roast for 20–25 minutes, turning once halfway.',
          textSi: 'මිනිත්තු 20–25ක් බේක් කරන්න. මැදදී එක වරක් පෙරළන්න.',
        ),
        RecipeStep(
          text: 'Mix the yogurt with grated garlic for dipping and serve hot.',
          textSi: 'යෝගට් සමඟ සුදු ලූනු අඹරා ඩිප් සාදා උණුසුම්ව පිළිගන්වන්න.',
        ),
      ],
    ),
    'wrap': Recipe(
      servings: 2,
      prepMinutes: 10,
      tip:
          'Warm the wrap for 20 seconds before rolling — cold tortillas crack at '
          'the fold.',
      tipSi: 'රැප් එක තත්පර 20ක් රත් කරන්න. සිසිල් රැප් එක නමන විට ඉරේ.',
      ingredients: [
        RecipeIngredient(quantity: '150 g', name: 'paneer', nameSi: 'පනීර්'),
        RecipeIngredient(quantity: '3 tbsp', name: 'yogurt', nameSi: 'යෝගට්'),
        RecipeIngredient(
            quantity: '1 tsp', name: 'tikka masala', nameSi: 'ටික්කා මසාලා'),
        RecipeIngredient(
            quantity: '2', name: 'whole wheat wraps', nameSi: 'තිරිඟු රැප්'),
        RecipeIngredient(quantity: '100 g', name: 'cabbage', nameSi: 'ගෝවා'),
        RecipeIngredient(
            quantity: '2 tbsp', name: 'mint chutney', nameSi: 'මින්ට් චට්නි'),
        RecipeIngredient(quantity: '½', name: 'lemon', nameSi: 'ලෙමන්'),
      ],
      steps: [
        RecipeStep(
          text:
              'Cube the paneer and marinate in yogurt, tikka masala and lemon for 10 minutes.',
          textSi:
              'පනීර් කැබලි කපා යෝගට්, ටික්කා මසාලා සහ ලෙමන් සමඟ මිනිත්තු 10ක් තබන්න.',
        ),
        RecipeStep(
          text:
              'Grill or pan-fry the paneer for 4 minutes until charred at the edges.',
          textSi: 'පනීර් මිනිත්තු 4ක් ග්‍රිල් කරන්න.',
        ),
        RecipeStep(
          text: 'Shred the cabbage finely and warm the wraps.',
          textSi: 'ගෝවා තුනීව කපා රැප් රත් කරන්න.',
        ),
        RecipeStep(
          text: 'Spread chutney, add cabbage and paneer, then roll tightly.',
          textSi: 'චට්නි ගා ගෝවා සහ පනීර් දමා තදින් රෝල් කරන්න.',
        ),
        RecipeStep(
          text: 'Cut in half on the diagonal so it holds together.',
          textSi: 'දෙකට කපා පිළිගන්වන්න.',
        ),
      ],
    ),
    'chamomile': Recipe(
      servings: 1,
      prepMinutes: 5,
      tip: 'Cover the cup while it steeps. The flowers release more aroma when '
          'the steam stays in.',
      tipSi: 'උයන විට කෝප්පය වසන්න. එතකොට සුවඳ හොඳින් රැඳේ.',
      ingredients: [
        RecipeIngredient(
            quantity: '1 tsp',
            name: 'dried chamomile flowers',
            nameSi: 'වියලි කැමමයිල් මල්'),
        RecipeIngredient(quantity: '200 ml', name: 'water', nameSi: 'වතුර'),
        RecipeIngredient(quantity: '1 tsp', name: 'honey', nameSi: 'මී පැණි'),
      ],
      steps: [
        RecipeStep(
          text: 'Boil the water and let it cool for a minute.',
          textSi: 'වතුර උතුරවා මිනිත්තුවක් නිවෙන්න දෙන්න.',
        ),
        RecipeStep(
          text: 'Put the flowers in a cup, pour the water over and cover.',
          textSi: 'මල් කෝප්පයකට දමා වතුර වක් කර වසන්න.',
        ),
        RecipeStep(
          text: 'Steep for 4 minutes, then strain.',
          textSi: 'මිනිත්තු 4ක් තබා පෙරන්න.',
        ),
        RecipeStep(
          text: 'Add honey if you like and take it to bed, not to a screen.',
          textSi: 'කැමති නම් මී පැණි දමා තිරයක් නැතුව බොන්න.',
        ),
      ],
    ),
    'banana_toast': Recipe(
      servings: 1,
      prepMinutes: 4,
      tip: 'A pinch of salt on top makes the peanut butter taste more like '
          'peanut and less like sugar.',
      tipSi: 'උඩින් ලුණු ටිකක් දැම්මොත් පීනට් බටර් රසය හොඳ වේ.',
      ingredients: [
        RecipeIngredient(
            quantity: '2 slices',
            name: 'wholegrain bread',
            nameSi: 'සම්පූර්ණ ධාන්‍ය පාන්'),
        RecipeIngredient(
            quantity: '2 tbsp', name: 'peanut butter', nameSi: 'පීනට් බටර්'),
        RecipeIngredient(quantity: '1', name: 'banana', nameSi: 'කෙසෙල්'),
        RecipeIngredient(
            quantity: '1 pinch', name: 'cinnamon', nameSi: 'කුරුඳු'),
        RecipeIngredient(quantity: '1 pinch', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text: 'Toast the bread until golden.',
          textSi: 'පාන් රන්වන් වන තෙක් ටෝස්ට් කරන්න.',
        ),
        RecipeStep(
          text: 'Spread the peanut butter while the toast is still warm.',
          textSi: 'පාන් උණුසුම් තියෙද්දී පීනට් බටර් ගාන්න.',
        ),
        RecipeStep(
          text: 'Slice the banana over the top and add cinnamon and salt.',
          textSi: 'කෙසෙල් කපා උඩින් දමා කුරුඳු සහ ලුණු දමන්න.',
        ),
      ],
    ),
    'egg_hoppers': Recipe(
      servings: 2,
      prepMinutes: 30,
      tip:
          'The pan must be very hot before the first ladle goes in, and you only '
          'swirl once. That is what makes the lace edge.',
      tipSi:
          'පළමු හැන්ද දැමීමට පෙර තාච්චිය හොඳින් රත් විය යුතුයි. එක වරක් පමණක් කරකවන්න.',
      ingredients: [
        RecipeIngredient(
            quantity: '200 g', name: 'rice flour', nameSi: 'හාල් පිටි'),
        RecipeIngredient(
            quantity: '200 ml', name: 'coconut milk', nameSi: 'පොල් කිරි'),
        RecipeIngredient(quantity: '½ tsp', name: 'yeast', nameSi: 'යීස්ට්'),
        RecipeIngredient(quantity: '1 tsp', name: 'sugar', nameSi: 'සීනි'),
        RecipeIngredient(quantity: '2', name: 'eggs', nameSi: 'බිත්තර'),
        RecipeIngredient(quantity: '4 tbsp', name: 'sambol', nameSi: 'සම්බෝල'),
        RecipeIngredient(quantity: 'to taste', name: 'salt', nameSi: 'ලුණු'),
      ],
      steps: [
        RecipeStep(
          text:
              'Mix the rice flour, coconut milk, yeast, sugar and salt into a thin batter.',
          textSi:
              'හාල් පිටි, පොල් කිරි, යීස්ට්, සීනි සහ ලුණු මිශ්‍ර කර තුනී මිශ්‍රණයක් සාදන්න.',
        ),
        RecipeStep(
          text: 'Rest the batter for 30 minutes somewhere warm.',
          textSi: 'මිශ්‍රණය උණුසුම් තැනක මිනිත්තු 30ක් තබන්න.',
        ),
        RecipeStep(
          text:
              'Heat a hopper pan and swirl a ladle of batter around the sides.',
          textSi: 'ආප්ප තාච්චිය රත් කර හැන්දක් මිශ්‍රණය අද්දර කරකවන්න.',
        ),
        RecipeStep(
          text: 'Crack an egg into the centre, cover and cook for 3 minutes.',
          textSi: 'මැදට බිත්තරයක් කඩා වසා මිනිත්තු 3ක් උයන්න.',
        ),
        RecipeStep(
          text: 'Lift out with a spatula and serve with sambol.',
          textSi: 'ස්පටුලාවකින් ගෙන සම්බෝල සමඟ පිළිගන්වන්න.',
        ),
      ],
    ),
  };

  static Recipe of(String mealId) => _recipes[mealId] ?? _recipes['oatmeal']!;

  static bool has(String mealId) => _recipes.containsKey(mealId);
}
