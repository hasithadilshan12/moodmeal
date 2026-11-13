import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/models.dart';
import '../models/mood_entry.dart';

/// Curated local catalog. Everything works offline; Supabase only stores the
/// user's own data (check-ins, favourites, profile).
class Catalog {
  Catalog._();

  static const meals = <Meal>[
    Meal(
      id: 'oatmeal',
      name: 'Warm oatmeal bowl',
      nameSi: 'උණුසුම් ඕට්මීල් බෝල්',
      description:
          'Creamy oats with cinnamon, banana and a spoon of almond butter.',
      descriptionSi: 'කුරුඳු, කෙසෙල් සහ අල්මන්ඩ් බටර් සමඟ ක්‍රීමි ඕට්ස්.',
      emoji: '🥣',
      colors: [Color(0xFFFFE3C1), Color(0xFFF6B87A)],
      moods: [Mood.sad, Mood.tired, Mood.calm],
      minutes: 8,
      calories: 320,
      protein: 11,
      carbs: 48,
      fat: 9,
      ingredients: ['Rolled oats', 'Banana', 'Cinnamon', 'Almond butter'],
      ingredientsSi: ['ඕට්ස්', 'කෙසෙල්', 'කුරුඳු', 'අල්මන්ඩ් බටර්'],
      mindfulPrompt:
          'Hold the warm bowl for a moment. Let the cinnamon reach you before the first bite.',
      mindfulPromptSi:
          'උණුසුම් බෝල් එක මොහොතක් අතේ තබාගන්න. පළමු හපනට පෙර කුරුඳු සුවඳ විඳගන්න.',
      why: 'Slow-release carbs steady a low, tired mood without a sugar crash.',
      whySi: 'සෙමින් මුදාහරින කාබෝහයිඩ්‍රේට් වෙහෙසට පත් හැඟීම ස්ථිරව තබා ගනී.',
      allergens: ['nuts'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'salmon',
      name: 'Grilled salmon & greens',
      nameSi: 'ග්‍රිල් කළ සැල්මන් සහ එළවළු',
      description: 'Omega-rich salmon with lemon, greens and quinoa.',
      descriptionSi: 'ලෙමන්, එළවළු සහ කිනෝවා සමඟ ඔමේගා බහුල සැල්මන්.',
      emoji: '🐟',
      colors: [Color(0xFFFFD9C7), Color(0xFFF49C7E)],
      moods: [Mood.stressed, Mood.tired, Mood.calm],
      minutes: 22,
      calories: 480,
      protein: 38,
      carbs: 26,
      fat: 22,
      ingredients: ['Salmon fillet', 'Lemon', 'Quinoa', 'Spinach'],
      ingredientsSi: ['සැල්මන්', 'ලෙමන්', 'කිනෝවා', 'නිවිති'],
      mindfulPrompt:
          'Notice the colours on the plate. Eat the greens first, slowly.',
      mindfulPromptSi: 'පිඟානේ වර්ණ දෙස බලන්න. පළමුව එළවළු සෙමින් කන්න.',
      why: 'Omega-3s and protein are linked with steadier stress responses.',
      whySi: 'ඔමේගා-3 සහ ප්‍රෝටීන් ආතති ප්‍රතිචාර ස්ථාවර කිරීමට උදව් වේ.',
      allergens: ['seafood'],
      cuisine: 'cuisine.healthy',
    ),
    Meal(
      id: 'pumpkin_soup',
      name: 'Spiced pumpkin soup',
      nameSi: 'සුවඳ එකතු කළ වට්ටක්කා සුප්',
      description: 'Velvety pumpkin, ginger and coconut milk.',
      descriptionSi: 'මෘදු වට්ටක්කා, ඉඟුරු සහ පොල් කිරි.',
      emoji: '🍲',
      colors: [Color(0xFFFFE0B2), Color(0xFFEDA65B)],
      moods: [Mood.sad, Mood.tired, Mood.stressed],
      minutes: 15,
      calories: 260,
      protein: 6,
      carbs: 34,
      fat: 11,
      ingredients: ['Pumpkin', 'Ginger', 'Coconut milk', 'Nutmeg'],
      ingredientsSi: ['වට්ටක්කා', 'ඉඟුරු', 'පොල් කිරි', 'නට්මෙග්'],
      mindfulPrompt:
          'Sip, don’t swallow. Feel the warmth travel down before the next spoon.',
      mindfulPromptSi:
          'ගිලින්න එපා, රුවට බොන්න. උණුසුම පහළට යන හැටි දැනගෙන ඊළඟ හැන්ද ගන්න.',
      why: 'Warm, soft textures soothe the body on heavy days.',
      whySi: 'උණුසුම් මෘදු ආහාර බර දවස්වල ශරීරය සන්සුන් කරයි.',
      allergens: [],
      cuisine: 'cuisine.healthy',
    ),
    Meal(
      id: 'parfait',
      name: 'Berry yogurt parfait',
      nameSi: 'බෙරි යෝගට් පාෆේ',
      description: 'Greek yogurt, berries and toasted seeds.',
      descriptionSi: 'ග්‍රීක් යෝගට්, බෙරි සහ බැදපු ඇට.',
      emoji: '🍓',
      colors: [Color(0xFFFFDDE4), Color(0xFFF79CAF)],
      moods: [Mood.happy, Mood.excited],
      minutes: 5,
      calories: 240,
      protein: 16,
      carbs: 24,
      fat: 8,
      ingredients: ['Greek yogurt', 'Mixed berries', 'Pumpkin seeds', 'Honey'],
      ingredientsSi: ['ග්‍රීක් යෝගට්', 'බෙරි', 'පම්කින් ඇට', 'මී පැණි'],
      mindfulPrompt:
          'Eat it with a small spoon. Let each berry burst separately.',
      mindfulPromptSi: 'කුඩා හැන්දකින් කන්න. එක් එක් බෙරි රස වෙන වෙනම විඳගන්න.',
      why: 'Protein and colour — a bright plate to match a bright mood.',
      whySi: 'ප්‍රෝටීන් සහ වර්ණ — සතුටු හැඟීමට ගැළපෙන දීප්තිමත් පිඟානක්.',
      allergens: ['dairy'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'dhal',
      name: 'Coconut dhal curry',
      nameSi: 'පොල් පරිප්පු කරිය',
      description: 'Red lentils simmered with coconut milk and curry leaves.',
      descriptionSi: 'පොල් කිරි සහ කරපිංචා සමඟ උයන ලද පරිප්පු.',
      emoji: '🥘',
      colors: [Color(0xFFFFE6A7), Color(0xFFE8B54A)],
      moods: [Mood.calm, Mood.bored, Mood.sad],
      minutes: 25,
      calories: 380,
      protein: 18,
      carbs: 52,
      fat: 12,
      ingredients: ['Red lentils', 'Coconut milk', 'Curry leaves', 'Turmeric'],
      ingredientsSi: ['පරිප්පු', 'පොල් කිරි', 'කරපිංචා', 'කහ'],
      mindfulPrompt:
          'This is a meal many of us grew up with. Notice what memory arrives with the smell.',
      mindfulPromptSi:
          'මේක අපි හැදුණු කෑමක්. සුවඳ සමඟ එන මතකය මොකක්ද කියා සිතන්න.',
      why: 'Familiar comfort food, with plant protein and fibre to stay full.',
      whySi: 'හුරු පුරුදු සැනසුම් ආහාරයක්, පැලෑටි ප්‍රෝටීන් සමඟ.',
      allergens: [],
      cuisine: 'cuisine.srilankan',
    ),
    Meal(
      id: 'kottu',
      name: 'Vegetable kottu',
      nameSi: 'එළවළු කොත්තු',
      description: 'Chopped roti with vegetables and a light curry sauce.',
      descriptionSi: 'එළවළු සහ සැහැල්ලු කරි සෝස් සමඟ කපන ලද රොටි.',
      emoji: '🍛',
      colors: [Color(0xFFFFE1B8), Color(0xFFF2A65A)],
      moods: [Mood.excited, Mood.happy, Mood.bored],
      minutes: 18,
      calories: 520,
      protein: 17,
      carbs: 68,
      fat: 19,
      ingredients: ['Godhamba roti', 'Carrot', 'Leeks', 'Egg'],
      ingredientsSi: ['ගොඩම්බ රොටි', 'කැරට්', 'ලීක්ස්', 'බිත්තර'],
      mindfulPrompt:
          'It’s easy to eat kottu fast. Put the fork down between every third bite.',
      mindfulPromptSi:
          'කොත්තු ඉක්මනින් කන්න ලේසි. හැම තුන්වන හපනට පස්සේ ෆෝක් එක තබන්න.',
      why:
          'A little joy with your food is part of mindful eating, not against it.',
      whySi: 'ආහාරයේ පොඩි සතුටක් තිබීම සිහිකල්පනා ආහාරයට විරුද්ධ නැත.',
      allergens: ['eggs', 'gluten'],
      avoidTags: ['fried', 'oily'],
      cuisine: 'cuisine.srilankan',
    ),
    Meal(
      id: 'avocado_toast',
      name: 'Avocado toast & egg',
      nameSi: 'ඇවකාඩෝ ටෝස්ට් සහ බිත්තර',
      description: 'Sourdough, smashed avocado, chilli and a soft egg.',
      descriptionSi: 'සෝර්ඩෝ පාන්, ඇවකාඩෝ, මිරිස් සහ මෘදු බිත්තරයක්.',
      emoji: '🥑',
      colors: [Color(0xFFDDF0C8), Color(0xFF9FCB78)],
      moods: [Mood.happy, Mood.calm],
      minutes: 10,
      calories: 360,
      protein: 15,
      carbs: 30,
      fat: 21,
      ingredients: ['Sourdough', 'Avocado', 'Egg', 'Chilli flakes'],
      ingredientsSi: ['සෝර්ඩෝ පාන්', 'ඇවකාඩෝ', 'බිත්තර', 'මිරිස් කුඩු'],
      mindfulPrompt: 'Eat standing up? Sit down. Three minutes is enough.',
      mindfulPromptSi: 'හිටගෙන කනවද? වාඩිවෙන්න. මිනිත්තු තුනක් ප්‍රමාණවත්.',
      why: 'Healthy fats and steady carbs for an even, content afternoon.',
      whySi: 'සෞඛ්‍ය සම්පන්න මේද සහ කාබෝහයිඩ්‍රේට් සන්සුන් දහවලකට.',
      allergens: ['eggs', 'gluten'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'chocolate',
      name: 'Dark chocolate square',
      nameSi: 'ඩාර්ක් චොකලට් කැබැල්ලක්',
      description: 'Two squares of 70 % chocolate — a deliberate treat.',
      descriptionSi: '70 % චොකලට් කැබැලි දෙකක් — හිතාමතා ගන්නා රසවින්දනයක්.',
      emoji: '🍫',
      colors: [Color(0xFFE8D3C4), Color(0xFFB08163)],
      moods: [Mood.sad, Mood.stressed, Mood.angry],
      minutes: 1,
      calories: 120,
      protein: 2,
      carbs: 12,
      fat: 8,
      ingredients: ['70% dark chocolate'],
      ingredientsSi: ['70% ඩාර්ක් චොකලට්'],
      mindfulPrompt:
          'Let it melt. You are not fixing the feeling, just sitting with it.',
      mindfulPromptSi:
          'එය දියවෙන්න දෙන්න. ඔබ හැඟීම හදන්නේ නැහැ, එය සමඟ ඉන්නවා.',
      why: 'A small, intentional pleasure can soften an intense moment.',
      whySi: 'කුඩා, හිතාමතා ගන්නා රසවින්දනයක් තද හැඟීමක් මෘදු කරයි.',
      allergens: ['dairy'],
      avoidTags: ['sugary', 'caffeine'],
      cuisine: 'cuisine.bakery',
    ),
    Meal(
      id: 'green_tea',
      name: 'Green tea with honey',
      nameSi: 'මී පැණි සමඟ හරිත තේ',
      description: 'Loose-leaf green tea, a teaspoon of honey, no rush.',
      descriptionSi: 'හරිත තේ, මී පැණි තේ හැන්දක්, ඉක්මන් නැත.',
      emoji: '🍵',
      colors: [Color(0xFFD9EFD2), Color(0xFF8FC48A)],
      moods: [Mood.calm, Mood.stressed, Mood.angry],
      minutes: 5,
      calories: 45,
      protein: 0,
      carbs: 11,
      fat: 0,
      ingredients: ['Green tea', 'Honey', 'Lemon'],
      ingredientsSi: ['හරිත තේ', 'මී පැණි', 'ලෙමන්'],
      mindfulPrompt:
          'Hold the cup with both hands. Three slow breaths before the first sip.',
      mindfulPromptSi:
          'කෝප්පය අත් දෙකෙන් අල්ලන්න. පළමු බීමට පෙර සෙමින් හුස්ම තුනක්.',
      why: 'A pause in a cup — warmth and L-theanine for a calmer system.',
      whySi: 'කෝප්පයක ඇති විරාමයක් — උණුසුම සහ සන්සුන් බව.',
      allergens: [],
      avoidTags: ['caffeine', 'sugary'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'rice_bowl',
      name: 'Sunrise rice bowl',
      nameSi: 'සූර්යෝදය බත් බෝල්',
      description: 'Brown rice, roasted vegetables, egg and sesame.',
      descriptionSi: 'බ්‍රවුන් රයිස්, බැදපු එළවළු, බිත්තර සහ සෙසම්.',
      emoji: '🍚',
      colors: [Color(0xFFFFECC2), Color(0xFFF3C96B)],
      moods: [Mood.tired, Mood.excited, Mood.bored],
      minutes: 20,
      calories: 540,
      protein: 21,
      carbs: 72,
      fat: 16,
      ingredients: ['Brown rice', 'Sweet corn', 'Egg', 'Sesame oil'],
      ingredientsSi: ['බ්‍රවුන් රයිස්', 'බඩ ඉරිඟු', 'බිත්තර', 'සෙසම් තෙල්'],
      mindfulPrompt: 'Mix slowly. Notice the steam before you begin.',
      mindfulPromptSi: 'සෙමින් මිශ්‍ර කරන්න. පටන් ගැනීමට පෙර වාෂ්පය දෙස බලන්න.',
      why: 'Sustained energy for a day that needs you at your best.',
      whySi: 'දිගු වේලාවක් ශක්තිය ලබා දෙන ආහාරයක්.',
      allergens: ['eggs'],
      cuisine: 'cuisine.healthy',
    ),
    Meal(
      id: 'soba',
      name: 'Soba noodle salad',
      nameSi: 'සෝබා නූඩ්ල්ස් සලාදය',
      description: 'Chilled buckwheat noodles, cucumber and sesame dressing.',
      descriptionSi: 'සිසිල් බක්වීට් නූඩ්ල්ස්, පිපිඤ්ඤා සහ සෙසම් ඩ්‍රෙසිං.',
      emoji: '🍜',
      colors: [Color(0xFFD8EBD8), Color(0xFF8CB98D)],
      moods: [Mood.calm, Mood.bored],
      minutes: 12,
      calories: 390,
      protein: 14,
      carbs: 58,
      fat: 10,
      ingredients: ['Soba noodles', 'Cucumber', 'Spring onion', 'Sesame'],
      ingredientsSi: ['සෝබා නූඩ්ල්ස්', 'පිපිඤ්ඤා', 'ලූනු කොළ', 'සෙසම්'],
      mindfulPrompt:
          'Cool food, cool mind. Chew each noodle rather than slurp.',
      mindfulPromptSi: 'සිසිල් ආහාර, සිසිල් සිත. සූප් නොකර හපන්න.',
      why: 'Light and fresh — keeps a calm afternoon from feeling heavy.',
      whySi: 'සැහැල්ලු හා නැවුම් — සන්සුන් දහවලක් බර නොවී තබයි.',
      allergens: ['gluten', 'soy'],
      cuisine: 'cuisine.japanese',
    ),
    Meal(
      id: 'mango_smoothie',
      name: 'Mango sunrise smoothie',
      nameSi: 'අඹ ස්මූතී',
      description: 'Mango, yogurt, lime and a little ginger.',
      descriptionSi: 'අඹ, යෝගට්, දෙහි සහ ඉඟුරු ටිකක්.',
      emoji: '🥭',
      colors: [Color(0xFFFFE29B), Color(0xFFF7B733)],
      moods: [Mood.happy, Mood.tired, Mood.excited],
      minutes: 6,
      calories: 210,
      protein: 9,
      carbs: 32,
      fat: 4,
      ingredients: ['Mango', 'Yogurt', 'Lime', 'Ginger'],
      ingredientsSi: ['අඹ', 'යෝගට්', 'දෙහි', 'ඉඟුරු'],
      mindfulPrompt: 'Drink it slowly, without a screen in front of you.',
      mindfulPromptSi: 'තිරයක් ඉදිරියේ නොව, සෙමින් බොන්න.',
      why: 'Bright flavour and quick energy for a low-energy morning.',
      whySi: 'වෙහෙසකර උදෑසනකට දීප්තිමත් රසය සහ ඉක්මන් ශක්තිය.',
      allergens: ['dairy'],
      avoidTags: ['sugary'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'sweet_potato',
      name: 'Roasted sweet potato',
      nameSi: 'බැදපු බතල',
      description: 'Wedges with rosemary, yogurt dip and cracked pepper.',
      descriptionSi: 'රොස්මේරි, යෝගට් ඩිප් සහ ගම්මිරිස් සමඟ.',
      emoji: '🍠',
      colors: [Color(0xFFFFDCC0), Color(0xFFF09A63)],
      moods: [Mood.bored, Mood.stressed],
      minutes: 25,
      calories: 290,
      protein: 7,
      carbs: 46,
      fat: 8,
      ingredients: ['Sweet potato', 'Rosemary', 'Yogurt', 'Olive oil'],
      ingredientsSi: ['බතල', 'රොස්මේරි', 'යෝගට්', 'ඔලිව් තෙල්'],
      mindfulPrompt: 'Eat with your hands if you can. Texture counts.',
      mindfulPromptSi: 'හැකි නම් අතින් කන්න. ස්පර්ශයත් වැදගත්.',
      why: 'Warm, starchy comfort with more fibre than fried snacks.',
      whySi: 'බැදපු කෑමට වඩා තන්තු සහිත උණුසුම් සැනසුම.',
      allergens: ['dairy'],
      cuisine: 'cuisine.healthy',
    ),
    Meal(
      id: 'wrap',
      name: 'Paneer tikka wrap',
      nameSi: 'පනීර් ටික්කා රැප්',
      description: 'Grilled paneer, mint yogurt and crunchy slaw.',
      descriptionSi: 'ග්‍රිල් කළ පනීර්, මින්ට් යෝගට් සහ ක්‍රන්චි සලාදය.',
      emoji: '🌯',
      colors: [Color(0xFFFFE3D6), Color(0xFFF2A38F)],
      moods: [Mood.excited, Mood.happy, Mood.angry],
      minutes: 16,
      calories: 450,
      protein: 24,
      carbs: 42,
      fat: 19,
      ingredients: ['Paneer', 'Whole wheat wrap', 'Mint yogurt', 'Cabbage'],
      ingredientsSi: ['පනීර්', 'තිරිඟු රැප්', 'මින්ට් යෝගට්', 'ගෝවා'],
      mindfulPrompt: 'Put it down between bites. Wraps disappear too quickly.',
      mindfulPromptSi: 'හපනක් අතරේ එය තබන්න. රැප් ඉක්මනින් ඉවර වේ.',
      why: 'Protein-rich and satisfying when frustration makes you restless.',
      whySi: 'ප්‍රෝටීන් බහුල, අපහසු හැඟීම් සමඟ ඉවසීමට උදව් වේ.',
      allergens: ['dairy', 'gluten'],
      avoidTags: ['spicy'],
      cuisine: 'cuisine.indian',
    ),
    Meal(
      id: 'chamomile',
      name: 'Chamomile tea',
      nameSi: 'කැමමයිල් තේ',
      description: 'A quiet cup before bed, with a drizzle of honey.',
      descriptionSi: 'නින්දට පෙර නිහඬ කෝප්පයක්, මී පැණි ටිකක් සමඟ.',
      emoji: '🫖',
      colors: [Color(0xFFF3E7C8), Color(0xFFD9C077)],
      moods: [Mood.stressed, Mood.angry, Mood.sad],
      minutes: 4,
      calories: 30,
      protein: 0,
      carbs: 8,
      fat: 0,
      ingredients: ['Chamomile flowers', 'Honey'],
      ingredientsSi: ['කැමමයිල් මල්', 'මී පැණි'],
      mindfulPrompt:
          'Let the cup cool in your hands. Nothing needs to be solved tonight.',
      mindfulPromptSi:
          'කෝප්පය අතේ සිසිල් වෙන්න දෙන්න. අද රෑ විසඳිය යුතු දෙයක් නැත.',
      why: 'A ritual that tells your body the day is closing.',
      whySi: 'දවස අවසන් වන බව ශරීරයට කියන පුරුද්දක්.',
      allergens: [],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'banana_toast',
      name: 'Banana peanut butter toast',
      nameSi: 'කෙසෙල් පීනට් බටර් ටෝස්ට්',
      description: 'Wholegrain toast, peanut butter and sliced banana.',
      descriptionSi: 'සම්පූර්ණ ධාන්‍ය පාන්, පීනට් බටර් සහ කෙසෙල්.',
      emoji: '🍌',
      colors: [Color(0xFFFFEFC2), Color(0xFFF2D06B)],
      moods: [Mood.tired, Mood.sad, Mood.bored],
      minutes: 4,
      calories: 330,
      protein: 12,
      carbs: 44,
      fat: 12,
      ingredients: ['Wholegrain bread', 'Peanut butter', 'Banana'],
      ingredientsSi: ['සම්පූර්ණ ධාන්‍ය පාන්', 'පීනට් බටර්', 'කෙසෙල්'],
      mindfulPrompt: 'Two minutes of quiet while you eat is still mindfulness.',
      mindfulPromptSi: 'කන විට නිහඬ මිනිත්තු දෙකක් තිබීමත් සිහිකල්පනාවක්.',
      why: 'Fast comfort that still gives you protein and slow energy.',
      whySi: 'ඉක්මන් සැනසුමක්, ඒත් ප්‍රෝටීන් සහ ස්ථිර ශක්තිය සමඟ.',
      allergens: ['nuts', 'gluten'],
      cuisine: 'cuisine.cafe',
    ),
    Meal(
      id: 'egg_hoppers',
      name: 'Egg hoppers',
      nameSi: 'බිත්තර ආප්ප',
      description: 'Two lacy hoppers with an egg and sambol.',
      descriptionSi: 'බිත්තර සහ සම්බෝල සමඟ ආප්ප දෙකක්.',
      emoji: '🍳',
      colors: [Color(0xFFFFEBD1), Color(0xFFF4C27A)],
      moods: [Mood.happy, Mood.excited, Mood.bored],
      minutes: 12,
      calories: 340,
      protein: 16,
      carbs: 38,
      fat: 14,
      ingredients: ['Rice flour', 'Egg', 'Coconut milk', 'Sambol'],
      ingredientsSi: ['හාල් පිටි', 'බිත්තර', 'පොල් කිරි', 'සම්බෝල'],
      mindfulPrompt:
          'Eat the crisp edge first, then the soft centre. Notice the contrast.',
      mindfulPromptSi: 'මුලින්ම කරදිය අද්දර, පසුව මෘදු මැද. වෙනස දැනගන්න.',
      why: 'A local favourite that can be a gentle, unhurried breakfast.',
      whySi: 'ඉක්මන් නොවන උදෑසනකට ගැළපෙන දේශීය ප්‍රියතමයක්.',
      allergens: ['eggs'],
      cuisine: 'cuisine.srilankan',
    ),
  ];

  static const tips = <Tip>[
    Tip(
      id: 'water',
      emoji: '💧',
      title: 'Drink water before meals',
      titleSi: 'ආහාරයට පෙර වතුර බොන්න',
      body:
          'Drinking water before meals can help you feel full and reduce overeating. Try a glass 30 minutes before you eat.',
      bodySi:
          'ආහාරයට පෙර වතුර බීම බඩ පිරුණු බවක් දැනීමට සහ වැඩිපුර කෑම අඩු කිරීමට උදව් වේ. කෑමට මිනිත්තු 30කට පෙර වීදුරුවක් බොන්න.',
      steps: [
        'Fill a glass and keep it where you can see it.',
        'Sip slowly for about a minute.',
        'Ask: am I hungry, or thirsty, or tired?',
      ],
      stepsSi: [
        'වීදුරුවක් පුරවා ඔබට පෙනෙන තැනක තබන්න.',
        'මිනිත්තුවක් පමණ සෙමින් බොන්න.',
        'අසන්න: මට බඩගිනිද, පිපාසයිද, නැත්නම් වෙහෙසද?',
      ],
      tint: Color(0xFFE4F1FB),
      minutes: 2,
    ),
    Tip(
      id: 'breaths',
      emoji: '😮‍💨',
      title: 'Focus on 3 deep breaths',
      titleSi: 'සෙමින් හුස්ම තුනක් ගන්න',
      body:
          'A few deep breaths before you start eating can help you relax and become more aware of your hunger cues.',
      bodySi:
          'කෑම පටන් ගැනීමට පෙර සෙමින් හුස්ම ගැනීම ඔබව සන්සුන් කර බඩගිනි හැඟීම් ගැන දැනුවත් කරයි.',
      steps: [
        'Sit down and place both feet flat.',
        'Inhale for four counts, exhale for six.',
        'Repeat three times before the first bite.',
      ],
      stepsSi: [
        'වාඩිවී පාද දෙකම බිම තබන්න.',
        'හතරක් ගණන් කර හුස්ම ගන්න, හයක් ගණන් කර හුස්ම හරින්න.',
        'පළමු හපනට පෙර තුන් වරක් නැවත කරන්න.',
      ],
      tint: Color(0xFFFFF3D6),
      minutes: 1,
    ),
    Tip(
      id: 'slowly',
      emoji: '🍽️',
      title: 'Eat slowly and savour each bite',
      titleSi: 'සෙමින් කන්න, හැම හපනක්ම විඳගන්න',
      body:
          'Pay attention to the taste, texture and smell of your food. Chewing well helps you feel satisfied with less.',
      bodySi:
          'ආහාරයේ රසය, ස්පර්ශය සහ සුවඳ දෙස අවධානය යොමු කරන්න. හොඳින් හපන විට අඩුවෙන් කා සතුටු විය හැක.',
      steps: [
        'Put the fork down between bites.',
        'Chew until the food is almost liquid.',
        'Name one flavour you can taste.',
      ],
      stepsSi: [
        'හපනක් අතරේ ෆෝක් එක තබන්න.',
        'ආහාරය පාහේ දියර වන තෙක් හපන්න.',
        'ඔබට දැනෙන එක් රසයක් නම් කරන්න.',
      ],
      tint: Color(0xFFFFEDE0),
      minutes: 3,
    ),
    Tip(
      id: 'distractions',
      emoji: '📵',
      title: 'Minimise distractions',
      titleSi: 'බාධා අවම කරන්න',
      body:
          'Turn off the TV, put your phone away and avoid working while eating. Focus on your meal to recognise fullness.',
      bodySi:
          'ටීවී නිවන්න, දුරකථනය ඉවත් කරන්න, කන අතර වැඩ නොකරන්න. පිරුණු බව හඳුනාගැනීමට ආහාරය කෙරෙහි අවධානය යොමු කරන්න.',
      steps: [
        'Put your phone in another room.',
        'Eat at a table, not on the sofa.',
        'If you must scroll, stop after one minute.',
      ],
      stepsSi: [
        'දුරකථනය වෙනත් කාමරයක තබන්න.',
        'සෝෆාවේ නොව, මේසයේ කන්න.',
        'අවශ්‍ය නම්, මිනිත්තුවකින් නවත්වන්න.',
      ],
      tint: Color(0xFFEDE9FF),
      minutes: 2,
    ),
    Tip(
      id: 'hunger',
      emoji: '🧘',
      title: 'Notice hunger before you eat',
      titleSi: 'කෑමට පෙර බඩගිනි දැනගන්න',
      body:
          'Rate your hunger from 1 to 10 before eating. It separates real hunger from boredom, stress or habit.',
      bodySi:
          'කෑමට පෙර ඔබේ බඩගිනි 1 සිට 10 දක්වා ලකුණු කරන්න. එය සැබෑ බඩගිනි, කම්මැලිකම, ආතතිය හෝ පුරුද්ද වෙන් කරයි.',
      steps: [
        'Pause before opening the fridge.',
        'Rate your hunger out of 10.',
        'If it is under 4, ask what you actually need.',
      ],
      stepsSi: [
        'ෆ්‍රිජ් එක ඇරීමට පෙර නවතින්න.',
        'ඔබේ බඩගිනි 10න් ලකුණු කරන්න.',
        '4ට අඩු නම්, ඔබට ඇත්තටම අවශ්‍ය කුමක්ද කියා සිතන්න.',
      ],
      tint: Color(0xFFE9F7EF),
      minutes: 2,
    ),
    Tip(
      id: 'gratitude',
      emoji: '🙏',
      title: 'End with gratitude',
      titleSi: 'ස්තූතියෙන් අවසන් කරන්න',
      body:
          'Before you leave the table, notice how your body feels and name one thing you are grateful for.',
      bodySi:
          'මේසයෙන් ඉවත් වීමට පෙර ඔබේ ශරීරයට දැනෙන හැටි සහ ඔබ ස්තූතිවන්ත වන එක් දෙයක් නම් කරන්න.',
      steps: [
        'Rest your hands on your stomach.',
        'Take one slow breath.',
        'Say one small thank you — to the food, the cook, or yourself.',
      ],
      stepsSi: [
        'අත් දෙක බඩ මත තබන්න.',
        'සෙමින් එක් හුස්මක් ගන්න.',
        'ආහාරයට, උයපු අයට හෝ ඔබටම කුඩා ස්තූතියක් කියන්න.',
      ],
      tint: Color(0xFFFFF0E4),
      minutes: 1,
    ),
  ];

  static List<Meal> mealsForMood(
    Mood mood, {
    Set<String> filters = const {},
    List<String> allergies = const [],
    List<String> avoid = const [],
  }) {
    var list = meals.where((m) {
      if (m.allergens.any(allergies.contains)) return false;
      // The avoid list must actually filter: previously "avoid red meat" was a
      // no-op and sugary/caffeine/oily were ignored entirely.
      if (m.avoidTags.any(avoid.contains)) return false;
      if (filters.contains('veg') && !m.isVegetarian) return false;
      if (filters.contains('quick') && m.minutes > 20) return false;
      if (filters.contains('protein') && m.protein < 20) return false;
      return true;
    }).toList();

    list.sort((a, b) => b.matchScore(mood).compareTo(a.matchScore(mood)));
    // keep the mood-matched meals first, then the rest
    final matched = list.where((m) => m.worksFor(mood)).toList();
    final rest = list.where((m) => !m.worksFor(mood)).toList();
    return [...matched, ...rest];
  }

  static Meal mealById(String id) =>
      meals.firstWhere((m) => m.id == id, orElse: () => meals.first);

  static Tip tipById(String id) =>
      tips.firstWhere((t) => t.id == id, orElse: () => tips.first);

  static final List<String> allergyKeys = [
    'dairy',
    'nuts',
    'eggs',
    'seafood',
    'gluten',
    'soy',
  ];

  static final List<String> conditionKeys = [
    'highBp',
    'gastritis',
    'cholesterol',
    'vegan',
    'kidney',
    'diabetes',
  ];

  static final List<String> avoidKeys = [
    'spicy',
    'fried',
    'oily',
    'sugary',
    'caffeine',
    'redMeat',
  ];

  static final Map<String, String> tagEmoji = {
    'work': '💼',
    'family': '🏡',
    'sleep': '🌙',
    'health': '🩺',
    'food': '🍽️',
    'weather': '🌦️',
    'social': '👥',
  };

  static final List<String> moodTags = [
    'work',
    'family',
    'sleep',
    'health',
    'food',
    'weather',
    'social',
  ];

  static const List<String> popularAllergies = [
    'dairy',
    'nuts',
    'eggs',
    'seafood'
  ];

  static Color moodColor(Mood mood) => AppColors.moods[mood.name]![1];
}
