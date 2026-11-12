import 'package:flutter/widgets.dart';

/// Lightweight localisation: one table, two languages, zero codegen.
/// Index 0 = English, 1 = Sinhala.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[Locale('en'), Locale('si')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  bool get isSinhala => locale.languageCode == 'si';

  String t(String key, [Map<String, String>? args]) {
    final entry = _table[key];
    if (entry == null) return key;
    var value = entry[isSinhala ? 1 : 0];
    args?.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }

  static const Map<String, List<String>> _table = {
    // App / brand
    'app.name': ['MoodMeal', 'MoodMeal'],
    'app.tagline': [
      'Choose with heart. Eat with calm.',
      'හදවතින් තෝරන්න. සන්සුන්ව කන්න.'
    ],
    'app.greeting': ['Hi {name}!', 'ආයුබෝවන් {name}!'],
    'app.morning': ['Good morning', 'සුබ උදෑසනක්'],
    'app.afternoon': ['Good afternoon', 'සුබ දහවලක්'],
    'app.evening': ['Good evening', 'සුබ සන්ධ්‍යාවක්'],

    // Common
    'common.continue': ['Continue', 'ඉදිරියට'],
    'common.skip': ['Skip', 'මඟ හරින්න'],
    'common.next': ['Next', 'ඊළඟ'],
    'common.back': ['Back', 'ආපසු'],
    'common.save': ['Save', 'සුරකින්න'],
    'common.cancel': ['Cancel', 'අවලංගු'],
    'common.done': ['Done', 'හරි'],
    'common.seeAll': ['See all', 'සියල්ල බලන්න'],
    'common.retry': ['Try again', 'නැවත උත්සාහ කරන්න'],
    'common.today': ['Today', 'අද'],
    'common.yesterday': ['Yesterday', 'ඊයේ'],
    'common.min': ['min', 'මිනිත්තු'],
    'common.kcal': ['kcal', 'කැලරි'],
    // Sinhala puts the unit before the number, so these need a template.
    'common.minValue': ['{n} min', 'මිනිත්තු {n}'],
    'common.kcalValue': ['{n} kcal', 'කැලරි {n}'],
    'common.openNow': ['Open now', 'දැන් විවෘත'],
    'common.closed': ['Closed', 'වසා ඇත'],
    'common.km': ['km', 'කි.මී.'],
    'common.items': ['{n} items', 'අයිතම {n}'],
    'common.loading': ['One moment…', 'මොහොතක්…'],
    'common.cannotOpen': [
      'Could not open that link.',
      'එම සබැඳිය විවෘත කළ නොහැක.'
    ],

    // Splash / onboarding
    'onb.1.title': [
      'Your emotions affect what you eat',
      'ඔබේ හැඟීම් ඔබ කන දේට බලපායි'
    ],
    'onb.1.body': [
      'MoodMeal helps you understand your eating patterns by connecting them to your daily emotions.',
      'MoodMeal ඔබේ දෛනික හැඟීම් සමඟ ආහාර රටාවන් සම්බන්ධ කර ඔබට තේරුම් ගැනීමට උදව් කරයි.'
    ],
    'onb.2.title': [
      'Get meal suggestions that support your feelings',
      'ඔබේ හැඟීමට ගැළපෙන ආහාර යෝජනා ලබාගන්න'
    ],
    'onb.2.body': [
      'Calm, comfort or energy — discover meals that match the way you feel right now.',
      'සන්සුන්, සැනසුම හෝ ශක්තිය — දැන් ඔබට දැනෙන හැඟීමට ගැළපෙන ආහාර සොයාගන්න.'
    ],
    'onb.getStarted': ['Get Started', 'ආරම්භ කරන්න'],
    'onb.haveAccount': ['I already have an account', 'මට දැනටමත් ගිණුමක් ඇත'],

    // Auth
    'auth.welcomeBack': ['Welcome Back', 'නැවත සාදරයෙන් පිළිගනිමු'],
    'auth.loginSub': [
      'Sign in to continue your mindful journey.',
      'ඔබේ සිහිකල්පනා ගමන දිගටම කරගෙන යාමට පිවිසෙන්න.'
    ],
    'auth.email': ['Email', 'විද්‍යුත් තැපෑල'],
    'auth.password': ['Password', 'මුරපදය'],
    'auth.name': ['Full name', 'සම්පූර්ණ නම'],
    'auth.login': ['Login', 'පිවිසෙන්න'],
    'auth.signUp': ['Sign Up', 'ලියාපදිංචි වන්න'],
    'auth.forgot': ['Forgot Password?', 'මුරපදය අමතකද?'],
    'auth.noAccount': ["Don't have an account?", 'ගිණුමක් නැද්ද?'],
    'auth.haveAccount': ['Already have an account?', 'දැනටමත් ගිණුමක් තිබේද?'],
    'auth.createTitle': ['Create your account', 'ඔබේ ගිණුම සාදන්න'],
    'auth.createSub': [
      'A few details and your first check-in awaits.',
      'තොරතුරු කීපයක් පමණයි — ඔබේ පළමු සටහන බලා සිටී.'
    ],
    'auth.demo': ['Continue in demo mode', 'නිදර්ශන ලෙස ඉදිරියට'],
    'auth.demoHint': [
      'No account needed — explore freely.',
      'ගිණුමක් අවශ්‍ය නැත — නිදහසේ බලන්න.'
    ],
    'auth.or': ['or', 'හෝ'],
    'auth.google': ['Continue with Google', 'Google සමඟ ඉදිරියට'],
    'auth.googleHint': [
      'Use your Google account — no new password.',
      'ඔබේ Google ගිණුම භාවිතා කරන්න — නව මුරපදයක් අවශ්‍ය නැත.'
    ],
    'auth.googleNeedsBackend': [
      'Google sign-in turns on when MoodMeal is connected to Supabase. Add SUPABASE_URL and SUPABASE_ANON_KEY, then try again.',
      'MoodMeal Supabase වෙත සම්බන්ධ වූ විට Google පිවිසුම සක්‍රීය වේ. SUPABASE_URL සහ SUPABASE_ANON_KEY එකතු කර නැවත උත්සාහ කරන්න.'
    ],
    'auth.googleRedirect': [
      'Finish signing in with Google in the browser, then return to MoodMeal.',
      'බ්‍රව්සරයේ Google සමඟ පිවිසීම සම්පූර්ණ කර MoodMeal වෙත නැවත එන්න.'
    ],
    'auth.googleError': [
      'Google sign-in could not start. Please try again.',
      'Google පිවිසුම ආරම්භ කළ නොහැක. නැවත උත්සාහ කරන්න.'
    ],
    'auth.googleNotEnabled': [
      'Google sign-in is not enabled in Supabase yet. Turn it on in Authentication → Sign In / Providers.',
      'Supabase තුළ Google පිවිසුම තවම සක්‍රීය නැහැ. Authentication → Sign In / Providers තුළ එය සක්‍රීය කරන්න.'
    ],
    'auth.confirmEmailTitle': ['Confirm your email', 'ඔබේ ඊමේල් තහවුරු කරන්න'],
    'auth.confirmEmail': [
      'We sent a confirmation link to your inbox. Open it, then log in.',
      'ඔබේ ඊමේල් ලිපිනයට තහවුරු කිරීමේ සබැඳියක් යැව්වා. එය විවෘත කර පසුව පිවිසෙන්න.'
    ],
    'auth.errEmail': [
      'Enter a valid email address.',
      'වලංගු විද්‍යුත් තැපැල් ලිපිනයක් ඇතුළත් කරන්න.'
    ],
    'auth.errPassword': [
      'Password needs at least 6 characters.',
      'මුරපදයට අවම අකුරු 6ක් අවශ්‍යයි.'
    ],
    'auth.errName': ['Please tell us your name.', 'ඔබේ නම ඇතුළත් කරන්න.'],
    'auth.forgotToast': [
      'Reset links are coming soon.',
      'මුරපදය නැවත සැකසීම ළඟදීම.'
    ],
    'auth.signOut': ['Sign out', 'පිටවන්න'],
    'auth.signOutConfirm': [
      'Sign out of MoodMeal?',
      'MoodMeal වෙතින් පිටවෙන්නද?'
    ],

    // Home
    'home.moodQuestion': [
      'How are you feeling today?',
      'අද ඔබට කොහොමද දැනෙන්නේ?'
    ],
    'home.chooseMood': ['Choose Your Mood', 'ඔබේ හැඟීම තෝරන්න'],
    'home.chooseNow': ['Choose now', 'දැන් තෝරන්න'],
    'home.choose': ['Choose', 'තෝරන්න'],
    'home.todaySuggestion': ["Today's Suggestion", 'අදට යෝජනාව'],
    'home.lastCheckIn': ['Last Check In', 'පසුගිය සටහන'],
    'home.moodCheckIn': ['Mood Check-in', 'හැඟීම් සටහන'],
    'home.noCheckIn': ['No check-in yet', 'තවම සටහනක් නැත'],
    'home.mindfulTip': ['Mindful Tip', 'සිහිකල්පනා ඉඟිය'],
    'home.streak': ['{n} day streak', 'දින {n}ක් අඛණ්ඩව'],
    'home.streakStart': ['Start your streak today', 'අද ඔබේ ගමන අරඹන්න'],
    'home.quickActions': ['Quick actions', 'ඉක්මන් ක්‍රියා'],
    'home.nearby': ['Nearby', 'අසල'],
    'home.favourites': ['Favourites', 'ප්‍රියතම'],
    'home.insights': ['Insights', 'විශ්ලේෂණ'],
    'home.history': ['History', 'ඉතිහාසය'],
    'home.tips': ['Tips', 'ඉඟි'],
    'home.settings': ['Settings', 'සැකසුම්'],
    'home.nav.home': ['Home', 'මුල් පිටුව'],
    'home.nav.history': ['History', 'ඉතිහාසය'],
    'home.nav.tips': ['Tips', 'ඉඟි'],
    'home.nav.settings': ['Settings', 'සැකසුම්'],
    'home.recommended': ['Recommended for you', 'ඔබට නිර්දේශිත'],
    'home.view': ['View', 'බලන්න'],
    'home.openNow': ['{n} restaurants open now', 'දැන් විවෘත අවන්හල් {n}'],
    'home.favouriteMeals': ['Favourite meals', 'ප්‍රියතම ආහාර'],

    // Mood check-in
    'mood.title': ['Mood check-in', 'හැඟීම් සටහන'],
    'mood.question': [
      'What is present for you right now?',
      'දැන් ඔබට දැනෙන්නේ මොකක්ද?'
    ],
    'mood.intensity': ['How strong is it?', 'එය කොතරම් තදින් දැනෙනවාද?'],
    'mood.low': ['Gentle', 'මෘදු'],
    'mood.high': ['Intense', 'තද'],
    'mood.tags': ['What is influencing it?', 'ඊට බලපාන්නේ මොකක්ද?'],
    'mood.note': ['Anything else? (optional)', 'තව යමක්? (අත්‍යවශ්‍ය නොවේ)'],
    'mood.noteHint': ['A word about your day…', 'ඔබේ දවස ගැන වචනයක්…'],
    'mood.cta': ['Find my meals', 'මගේ ආහාර සොයන්න'],
    'mood.saved': ['Check-in saved', 'සටහන සුරකින ලදී'],
    'mood.resultTitle': ['For your {mood} mood', 'ඔබේ {mood} හැඟීමට'],
    'mood.resultSub': [
      'Meals picked to support how you feel right now.',
      'දැන් ඔබට දැනෙන හැඟීමට සහාය වන ආහාර තෝරාගෙන ඇත.'
    ],
    'mood.match': ['{n}% match', '{n}% ගැළපීම'],

    'mood.calm': ['Calm', 'සන්සුන්'],
    'mood.happy': ['Happy', 'සතුටු'],
    'mood.stressed': ['Stressed', 'මානසික ආතතිය'],
    'mood.sad': ['Sad', 'දුක්මුසු'],
    'mood.tired': ['Tired', 'වෙහෙසට පත්'],
    'mood.excited': ['Excited', 'උද්‍යෝගිමත්'],
    'mood.angry': ['Angry', 'කේන්තිය'],
    'mood.bored': ['Bored', 'කම්මැලි'],

    'tag.work': ['Work', 'වැඩ'],
    'tag.family': ['Family', 'පවුල'],
    'tag.sleep': ['Sleep', 'නින්ද'],
    'tag.health': ['Health', 'සෞඛ්‍යය'],
    'tag.food': ['Food', 'ආහාර'],
    'tag.weather': ['Weather', 'කාලගුණය'],
    'tag.social': ['Friends', 'මිතුරන්'],

    // Recommendations / meal
    'rec.title': ['Meal suggestions', 'ආහාර යෝජනා'],
    'rec.why': ['Why this meal', 'මේ ආහාරය ඇයි'],
    'rec.all': ['All', 'සියල්ල'],
    'rec.veg': ['Vegetarian', 'නිර්මාංශ'],
    'rec.quick': ['Under 20 min', 'මිනිත්තු 20ට අඩු'],
    'rec.protein': ['High protein', 'ඉහළ ප්‍රෝටීන්'],
    'rec.empty': ['No meals match those filters', 'එම පෙරහන් සමඟ ආහාර නැත'],
    'rec.emptySub': ['Try clearing a filter.', 'පෙරහනක් ඉවත් කර බලන්න.'],
    'rec.nearbyTitle': ['Places near you', 'ඔබ අසල ස්ථාන'],
    'meal.about': ['About this meal', 'මේ ආහාරය ගැන'],
    'meal.ingredients': ['Ingredients', 'අමුද්‍රව්‍ය'],
    'meal.nutrition': ['Nutrition', 'පෝෂණය'],
    'meal.protein': ['Protein', 'ප්‍රෝටීන්'],
    'meal.carbs': ['Carbs', 'කාබෝහයිඩ්‍රේට්'],
    'meal.fat': ['Fat', 'මේද'],
    'meal.prep': ['Prep time', 'සකසන වේලාව'],
    'meal.mindful': ['Mindful moment', 'සිහිකල්පනා මොහොත'],
    'meal.log': ['Log this meal', 'මේ ආහාරය සටහන් කරන්න'],
    'meal.logged': ['Meal logged', 'ආහාරය සටහන් කළා'],
    'meal.favourite': ['Save to favourites', 'ප්‍රියතමවලට සුරකින්න'],
    'meal.removeFavourite': [
      'Remove from favourites',
      'ප්‍රියතමවලින් ඉවත් කරන්න'
    ],
    'meal.saved': ['Added to favourites', 'ප්‍රියතමවලට එකතු කළා'],
    'meal.removed': ['Removed from favourites', 'ප්‍රියතමවලින් ඉවත් කළා'],
    'meal.energy': ['Energy', 'ශක්තිය'],
    'meal.serves': ['Serves {n}', '{n} දෙනෙකුට'],
    'meal.why': ['Why it helps', 'එය උදව් වන්නේ ඇයි'],
    'meal.tickOff': ['Tick off as you go', 'කරන අතරේ ලකුණු කරන්න'],
    'meal.method': ['Method', 'ක්‍රමය'],
    'meal.cookTip': ["Cook's tip", 'පිසින ඉඟිය'],
    'meal.nearbyTitle': [
      'Where to eat this near you',
      'මේ ආහාරය අසල කන්නේ කොහෙන්ද'
    ],
    'meal.nearbySub': [
      'Find real restaurants and cafés within 2.5 km, with directions in Google Maps.',
      'කිලෝමීටර 2.5ක් ඇතුළත සැබෑ අවන්හල් සහ කැෆේ සොයන්න, Google Maps හරහා මාර්ග උපදෙස් සමඟ.'
    ],
    'meal.findNearby': ['Find nearby', 'අසල සොයන්න'],
    'meal.orderDish': ['Find on map', 'සිතියමේ සොයන්න'],
    'meal.watch': ['Watch the recipe', 'වට්ටෝරුව බලන්න'],
    'meal.videoSi': ['Sinhala', 'සිංහල'],
    'meal.loggedToday': ['Logged today', 'අද සටහන් කළා'],
    'meal.photoCredit': ['Photo credits', 'ඡායාරූප ණය'],

    // Restaurants
    'rest.title': ['Nearby restaurants', 'අසල අවන්හල්'],
    'rest.sub': [
      'Real restaurants and cafés around you, from OpenStreetMap.',
      'OpenStreetMap වෙතින් ඔබ අවට සැබෑ අවන්හල් සහ කැෆේ.'
    ],
    'rest.openOnly': ['Open now', 'දැන් විවෘත'],
    'rest.distance': ['{d} km away', 'කි.මී. {d} දුරින්'],
    'rest.rating': ['{r} rating', 'ශ්‍රේණිගත {r}'],
    'rest.menu': ['Mood menu', 'හැඟීම් මෙනුව'],
    'rest.price': ['Price', 'මිල'],
    'rest.empty': ['Nothing open nearby', 'අසල විවෘත කිසිවක් නැත'],
    'rest.searchHint': [
      'Search by name or cuisine',
      'නම හෝ ආහාර වර්ගයෙන් සොයන්න'
    ],
    'rest.useLocation': ['Use my location', 'මගේ ස්ථානය භාවිතා කරන්න'],
    'rest.changeCity': ['Change area', 'ප්‍රදේශය වෙනස් කරන්න'],
    'rest.chooseCity': ['Choose an area', 'ප්‍රදේශයක් තෝරන්න'],
    'rest.pickCityHint': [
      'No location? Pick your area.',
      'ස්ථානය නැද්ද? ඔබේ ප්‍රදේශය තෝරන්න.'
    ],
    'rest.locating': ['Finding your location…', 'ඔබේ ස්ථානය සොයමින්…'],
    'rest.loading': ['Looking for restaurants nearby…', 'අසල අවන්හල් සොයමින්…'],
    'rest.errorTitle': [
      'We could not load restaurants',
      'අවන්හල් පූරණය කළ නොහැක'
    ],
    'rest.errorNetwork': [
      'Check your internet connection and try again.',
      'අන්තර්ජාල සම්බන්ධතාවය පරීක්ෂා කර නැවත උත්සාහ කරන්න.'
    ],
    'rest.errorServer': [
      'The map service is busy right now. Please try again.',
      'සිතියම් සේවාව දැන් කාර්යබහුලයි. නැවත උත්සාහ කරන්න.'
    ],
    'rest.errorTimeout': [
      'The map service is taking too long. Try again, or choose an area below.',
      'සිතියම් සේවාවට වැඩි වේලාවක් ගත වේ. නැවත උත්සාහ කරන්න, නැතහොත් පහතින් ප්‍රදේශයක් තෝරන්න.'
    ],
    'rest.savedBanner': [
      'Saved results from your last search.',
      'ඔබේ පසුගිය සෙවුමේ සුරකින ලද ප්‍රතිඵල.'
    ],
    'rest.errorUnexpected': [
      'Something went wrong while loading.',
      'පූරණය කරන අතරේ යම් දෝෂයක් සිදු විය.'
    ],
    'rest.permTitle': ['Location is off', 'ස්ථානය අක්‍රීයයි'],
    'rest.permDenied': [
      'Allow location access, or pick your city below.',
      'ස්ථාන ප්‍රවේශයට අවසර දෙන්න, නැතහොත් පහතින් ඔබේ නගරය තෝරන්න.'
    ],
    'rest.permBlocked': [
      'Location is blocked for MoodMeal. Enable it in Settings, or pick your city.',
      'MoodMeal සඳහා ස්ථානය අවහිර කර ඇත. සැකසුම්වලින් සක්‍රීය කරන්න, නැතහොත් නගරය තෝරන්න.'
    ],
    'rest.openSettings': ['Open settings', 'සැකසුම් විවෘත කරන්න'],
    'rest.noResults': [
      'No restaurants match that search',
      'එම සෙවුමට අවන්හල් නැත'
    ],
    'rest.noResultsSub': [
      'Try a different name, or clear the search.',
      'වෙනත් නමක් උත්සාහ කරන්න, නැතහොත් සෙවුම ඉවත් කරන්න.'
    ],
    'rest.emptyNearby': [
      'No restaurants found around here',
      'මෙම ප්‍රදේශයේ අවන්හල් හමු නොවීය'
    ],
    'rest.emptyNearbySub': [
      'OpenStreetMap has no listings within 2.5 km. Try another city.',
      'කි.මී. 2.5ක් ඇතුළත සටහන් නැත. වෙනත් නගරයක් උත්සාහ කරන්න.'
    ],
    'rest.directions': ['Directions', 'මාර්ග උපදෙස්'],
    'rest.call': ['Call', 'අමතන්න'],
    'rest.website': ['Website', 'වෙබ් අඩවිය'],
    'rest.refresh': ['Refresh', 'නැවත යාවත්කාලීන'],
    'rest.usingGps': ['Using your location', 'ඔබේ ස්ථානය භාවිතයෙන්'],
    'rest.aroundCity': ['Around {city}', '{city} අවට'],
    'rest.found': ['{n} places nearby', 'අසල ස්ථාන {n}'],
    'rest.viewOnMap': ['View on map', 'සිතියමේ බලන්න'],
    'rest.noPhone': ['No phone number listed', 'දුරකථන අංකයක් නැත'],
    'rest.cuisine': ['Cuisine', 'ආහාර වර්ගය'],
    'rest.cat.restaurant': ['Restaurant', 'අවන්හල'],
    'rest.cat.cafe': ['Café', 'කැෆේ'],
    'rest.cat.fast_food': ['Fast food', 'ඉක්මන් ආහාර'],
    'cuisine.srilankan': ['Sri Lankan', 'ශ්‍රී ලංකා'],
    'cuisine.healthy': ['Healthy bowls', 'සෞඛ්‍යමය බවුල්'],
    'cuisine.cafe': ['Cafe', 'කැෆේ'],
    'cuisine.vegan': ['Vegan', 'වීගන්'],
    'cuisine.japanese': ['Japanese', 'ජපන්'],
    'cuisine.indian': ['Indian', 'ඉන්දියානු'],
    'cuisine.bakery': ['Bakery', 'බේකරි'],

    // History / insights
    'history.title': ['Your history', 'ඔබේ ඉතිහාසය'],
    'history.streak': ['Current streak', 'වත්මන් අඛණ්ඩතාව'],
    'history.days': ['days', 'දින'],
    'history.week': ['This week', 'මේ සතියේ'],
    'history.moodMap': ['Mood map', 'හැඟීම් සිතියම'],
    'history.timeline': ['Check-in timeline', 'සටහන් කාලරේඛාව'],
    'history.empty': ['Your journey starts here', 'ඔබේ ගමන මෙතැනින් පටන් ගනී'],
    'history.emptySub': [
      'Log your first mood to see patterns over time.',
      'කාලයත් සමඟ රටා බලන්න පළමු හැඟීම සටහන් කරන්න.'
    ],
    'history.checkins': ['Check-ins', 'සටහන්'],
    'history.mealsTitle': ['Meals you cooked', 'ඔබ පිසූ ආහාර'],
    'history.mealsSub': [
      'Every meal you logged from a recipe page.',
      'වට්ටෝරු පිටුවකින් ඔබ සටහන් කළ සෑම ආහාරයක්ම.'
    ],
    'history.mealsEmpty': ['No meals logged yet', 'තවම ආහාර සටහන් නැත'],
    'history.mealsEmptySub': [
      'Open a meal and tap "Log this meal".',
      'ආහාරයක් විවෘත කර "මේ ආහාරය සටහන් කරන්න" තට්ටු කරන්න.'
    ],
    'history.mealsThisWeek': ['Meals this week', 'මේ සතියේ ආහාර'],
    'history.mealsTotal': ['Meals logged', 'සටහන් කළ ආහාර'],
    'history.avgMood': ['Top mood', 'ප්‍රධාන හැඟීම'],
    'insights.title': ['Insights', 'විශ්ලේෂණ'],
    'insights.sub': [
      'How moods and meals move together.',
      'හැඟීම් හා ආහාර එකට ගමන් කරන හැටි.'
    ],
    'insights.distribution': ['Mood distribution', 'හැඟීම් ව්‍යාප්තිය'],
    'insights.correlation': [
      'Your mindful connection',
      'ඔබේ සිහිකල්පනා සම්බන්ධය'
    ],
    'insights.correlationBody': [
      'On calm days you pick lighter, plant-forward meals. On stressed days, comfort food wins more often — that is worth noticing, not judging.',
      'සන්සුන් දිනවල ඔබ සැහැල්ලු, පැලෑටි බහුල ආහාර තෝරයි. ආතති දිනවල සැනසුම් ආහාර බොහෝ විට තේරේ — එය විනිශ්චය නොකර හඳුනාගැනීම වටී.'
    ],
    'insights.plantForward': ['Plant-forward meals', 'පැලෑටි බහුල ආහාර'],
    'insights.comfort': ['Comfort meals', 'සැනසුම් ආහාර'],
    'insights.mindfulDays': ['Mindful days', 'සිහිකල්පනා දින'],
    'insights.noData': [
      'Log a few days to unlock insights.',
      'විශ්ලේෂණ බලන්න දින කීපයක් සටහන් කරන්න.'
    ],
    'insights.donut': ['How your week felt', 'ඔබේ සතිය දැනුණු හැටි'],
    'insights.whenYouCheckIn': ['When you check in', 'ඔබ සටහන් කරන වේලාව'],
    'insights.morning': ['Morning', 'උදෑසන'],
    'insights.afternoon': ['Afternoon', 'දහවල'],
    'insights.evening': ['Evening', 'සවස'],
    'insights.night': ['Night', 'රාත්‍රී'],
    'insights.matchesMood': [
      'Meals for your top mood',
      'ඔබේ ප්‍රධාන හැඟීමට ආහාර'
    ],
    'insights.reflection': ['A question to sit with', 'සිතා බැලීමට ප්‍රශ්නයක්'],
    'insights.reflectionBody': [
      'On your heaviest day this week, what did you reach for — and what did you actually need?',
      'මේ සතියේ ඔබට බරම දවසේ ඔබ තෝරාගත්තේ මොකක්ද — ඇත්තටම අවශ්‍ය වුණේ මොකක්ද?'
    ],
    'insights.logToday': ["Log today's mood", 'අද හැඟීම සටහන් කරන්න'],
    'insights.lightDays': ['Lighter days', 'සැහැල්ලු දින'],
    'insights.heavyDays': ['Heavier days', 'බර දින'],
    'insights.percent': ['{n}% of check-ins', 'සටහන්වලින් {n}%'],
    'insights.entries': ['{n} check-ins', 'සටහන් {n}'],

    // Tips
    'tips.title': ['Mindful eating tips', 'සිහිකල්පනා ආහාර ඉඟි'],
    'tips.sub': [
      'Small pauses that change how you eat.',
      'ඔබ කන ආකාරය වෙනස් කරන කුඩා විරාම.'
    ],
    'tips.read': ['Read tip', 'ඉඟිය කියවන්න'],
    'tips.step': ['Try this', 'මෙය උත්සාහ කරන්න'],
    'tips.done': ['Mark as practised', 'පුරුදු කළා ලෙස සලකුණු කරන්න'],
    'tips.practised': ['Practised today', 'අද පුරුදු කළා'],
    'tips.featured': ["Today's practice", 'අදේ පුරුද්ද'],
    'tips.progress': ['{n} of {total} practised', '{total}න් {n} පුරුදු කළා'],
    'tips.minutes': ['{n} min practice', 'මිනිත්තු {n} පුරුද්ද'],
    'tips.all': ['All practices', 'සියලු පුරුදු'],
    'tips.marked': ['Marked as practised', 'පුරුදු කළා ලෙස සලකුණු කළා'],
    'tips.unmarked': ['Removed from practised', 'පුරුදු ලැයිස්තුවෙන් ඉවත් කළා'],

    // Favourites
    'explore.title': ['Explore meals', 'ආහාර ගවේෂණය'],
    'explore.sub': [
      'Search a dish, an ingredient or how you feel.',
      'ආහාරයක්, අමුද්‍රව්‍යයක් හෝ ඔබට දැනෙන ආකාරය සොයන්න.'
    ],
    'explore.hint': [
      'Search meals or ingredients',
      'ආහාර හෝ අමුද්‍රව්‍ය සොයන්න'
    ],
    'explore.all': ['All meals', 'සියලු ආහාර'],
    'explore.results': ['{n} meals', 'ආහාර {n}'],
    'explore.resultOne': ['1 meal', 'ආහාර 1'],
    'explore.empty': ['No meals found', 'ආහාර හමු නොවීය'],
    'explore.emptySub': [
      'Try a different word, or clear the search.',
      'වෙනත් වචනයක් උත්සාහ කරන්න, නැතහොත් සෙවීම ඉවත් කරන්න.'
    ],
    'explore.clear': ['Clear search', 'සෙවීම ඉවත් කරන්න'],
    'explore.moodPrompt': [
      'Or pick how you feel',
      'නැතහොත් ඔබට දැනෙන ආකාරය තෝරන්න'
    ],
    'fav.title': ['Favourites', 'ප්‍රියතම'],
    'fav.sub': ['Meals you keep coming back to.', 'ඔබ නැවත නැවත තෝරන ආහාර.'],
    'fav.empty': ['Nothing saved yet', 'තවම කිසිවක් සුරකා නැත'],
    'fav.emptySub': [
      'Tap the heart on any meal to keep it here.',
      'රැඳවීමට කැමති ආහාරයේ හදවත තට්ටු කරන්න.'
    ],
    'fav.explore': ['Explore meals', 'ආහාර බලන්න'],
    'fav.count': ['{n} saved meals', 'සුරකින ලද ආහාර {n}'],
    'fav.suggested': ['You might also like', 'ඔබටත් කැමති විය හැක'],

    // Profile / settings
    'profile.title': ['Profile', 'පැතිකඩ'],
    'profile.demo': ['Demo mode', 'නිරූපණ ප්‍රකාරය'],
    'profile.edit': ['Edit profile', 'පැතිකඩ සංස්කරණය'],
    'profile.checkins': ['Check-ins', 'සටහන්'],
    'profile.streak': ['Streak', 'අඛණ්ඩතාව'],
    'profile.saved': ['Saved', 'සුරකින ලද'],
    'profile.account': ['Account', 'ගිණුම'],
    'profile.preferences': ['Food preferences', 'ආහාර මනාප'],
    'profile.reminders': ['Mood reminders', 'හැඟීම් මතක් කිරීම්'],
    'profile.notifications': ['Notifications', 'දැනුම්දීම්'],
    'profile.language': ['Language', 'භාෂාව'],
    'profile.about': ['About MoodMeal', 'MoodMeal ගැන'],
    'profile.version': ['Version 1.0.0', 'අනුවාදය 1.0.0'],
    'profile.editName': ['Your name', 'ඔබේ නම'],
    'profile.editEmail': ['Email address', 'විද්‍යුත් තැපෑල'],
    'profile.savedToast': ['Profile updated', 'පැතිකඩ යාවත්කාලීන කළා'],
    'profile.avatar': ['Choose an avatar', 'අවතාරයක් තෝරන්න'],
    'profile.addPhoto': ['Add a photo', 'ඡායාරූපයක් එකතු කරන්න'],
    'profile.changePhoto': ['Change photo', 'ඡායාරූපය වෙනස් කරන්න'],
    'profile.removePhoto': ['Remove photo', 'ඡායාරූපය ඉවත් කරන්න'],
    'profile.photoHint': [
      'Your photo appears across MoodMeal.',
      'ඔබේ ඡායාරූපය MoodMeal පුරා දිස්වේ.'
    ],
    'profile.photoError': [
      'That photo could not be read. Try another image.',
      'එම ඡායාරූපය කියවිය නොහැක. වෙනත් ඡායාරූපයක් උත්සාහ කරන්න.'
    ],
    'profile.photoTooBig': [
      'That image is too large. Choose one under 2 MB.',
      'එම රූපය විශාල වැඩියි. 2 MBට අඩු එකක් තෝරන්න.'
    ],
    'profile.details': ['Your details', 'ඔබේ විස්තර'],
    'profile.detailsSub': [
      'Name, email, photo and avatar.',
      'නම, විද්‍යුත් තැපෑල, ඡායාරූපය සහ අවතාරය.'
    ],
    'profile.accountSection': ['Your account', 'ඔබේ ගිණුම'],
    'profile.appSection': ['App', 'යෙදුම'],
    'profile.languageSub': ['English or සිංහල', 'English හෝ සිංහල'],
    'profile.signOutSub': [
      'You can sign back in anytime.',
      'ඕනෑම වේලාවක නැවත පිවිසිය හැක.'
    ],
    'profile.aboutBody': [
      'MoodMeal connects what you eat with how you feel. It is a gentle journal, not a diet — no scores, no guilt, just patterns you can notice and meals that support you.',
      'MoodMeal ඔබ කන දේ ඔබට දැනෙන හැටි සමඟ සම්බන්ධ කරයි. මෙය ආහාර වේලක් නොව, මෘදු සටහන් පොතකි — ලකුණු නැත, වරදකාරී හැඟීම් නැත, ඔබට හඳුනාගත හැකි රටා පමණි.'
    ],
    'profile.memberSince': [
      'With MoodMeal since {date}',
      '{date} සිට MoodMeal සමඟ'
    ],
    'settings.title': ['Settings', 'සැකසුම්'],
    'settings.general': ['General', 'සාමාන්‍ය'],
    'settings.reminderOn': ['Daily reminder', 'දෛනික මතක් කිරීම'],
    'settings.reminderTime': ['Reminder time', 'මතක් කිරීමේ වේලාව'],
    'settings.language': ['App language', 'යෙදුම් භාෂාව'],
    'settings.english': ['English', 'English'],
    'settings.sinhala': ['සිංහල', 'සිංහල'],
    'settings.support': ['Support', 'සහාය'],
    'settings.personalise': ['Personalise', 'පුද්ගලීකරණය'],
    'settings.notificationsSub': [
      'Reminders and gentle nudges',
      'මතක් කිරීම් සහ මෘදු දැනුම්දීම්'
    ],
    'settings.about': ['About', 'ගැන'],
    'settings.aboutSub': ['The story behind MoodMeal', 'MoodMeal පිටුපස කතාව'],
    'settings.credits': ['Photo & video credits', 'ඡායාරූප සහ වීඩියෝ ණය'],
    'settings.creditsSub': [
      'Sources for the food photos and recipes',
      'ආහාර ඡායාරූප සහ වට්ටෝරුවල මූලාශ්‍ර'
    ],

    // Credits
    'credits.title': ['Photo & video credits', 'ඡායාරූප සහ වීඩියෝ ණය'],
    'credits.sub': [
      'Food photographs come from Wikimedia Commons and are reused under the licences below. Videos belong to their creators on YouTube.',
      'ආහාර ඡායාරූප Wikimedia Commons වෙතින් ලබාගෙන පහත බලපත්‍ර යටතේ භාවිතා කරයි. වීඩියෝ YouTube හි ඒවායේ නිර්මාපකයින්ට අයත් වේ.'
    ],
    'credits.by': ['By {author}', '{author} විසින්'],
    'credits.license': ['Licence', 'බලපත්‍රය'],
    'credits.source': ['Source page', 'මූලාශ්‍ර පිටුව'],
    'credits.videosTitle': ['Recipe videos', 'වට්ටෝරු වීඩියෝ'],
    'credits.videosSub': [
      'Each dish links to a real, independently made walkthrough. Please watch, like and subscribe to support the creators.',
      'සෑම ආහාරයක්ම ස්වාධීනව සාදන ලද සැබෑ වීඩියෝවකට සම්බන්ධ වේ. නිර්මාපකයින්ට සහාය දීමට බලන්න, කැමති වන්න සහ subscribe වන්න.'
    ],
    'credits.view': ['View', 'බලන්න'],
    'credits.unknown': ['Unknown author', 'නොදන්නා කර්තෘ'],
    'credits.mapTitle': ['Map data', 'සිතියම් දත්ත'],
    'credits.mapBody': [
      'Nearby restaurants and cafés come from OpenStreetMap contributors, retrieved through Photon with Overpass as a fallback. Map data is © OpenStreetMap contributors, available under the Open Database Licence.',
      'අසල අවන්හල් සහ කැෆේ OpenStreetMap දායකයින්ගෙන් ලබාගනී. දත්ත Photon හරහා ලබාගෙන, අවශ්‍ය විට Overpass භාවිතා කරයි. සිතියම් දත්ත © OpenStreetMap දායකයින්, Open Database Licence යටතේ.'
    ],
    'credits.mapSource': [
      'OpenStreetMap copyright',
      'OpenStreetMap ප්‍රකාශන අයිතිය'
    ],
    'settings.data': [
      'Your data stays on this device in demo mode.',
      'නිදර්ශන ප්‍රකාරයේදී ඔබේ දත්ත මෙම උපාංගයේ රැඳේ.'
    ],
    'settings.theme': ['Appearance', 'පෙනුම'],
    'settings.themeValue': ['Warm light', 'උණුසුම් ආලෝකය'],
    'settings.themeSub': [
      'Light, dark, or match your device.',
      'ආලෝකය, අඳුරු හෝ ඔබේ උපාංගයට ගැළපෙන ලෙස.'
    ],
    'settings.themeLight': ['Light', 'ආලෝකය'],
    'settings.themeDark': ['Dark', 'අඳුරු'],
    'settings.themeSystem': ['System', 'පද්ධතිය'],
    'settings.themeSaved': ['Appearance updated', 'පෙනුම යාවත්කාලීන කළා'],
    'settings.languageSub': [
      'Choose the language used across the app.',
      'යෙදුම පුරා භාවිතා වන භාෂාව තෝරන්න.'
    ],
    'settings.reminderSub': [
      'A gentle nudge to check in',
      'සටහන් කිරීමට මෘදු මතක් කිරීමක්'
    ],
    'settings.off': ['Off', 'නිවා ඇත'],
    'settings.onAt': ['Every day at {time}', 'දිනපතා {time}ට'],
    'settings.saved': ['Setting updated', 'සැකසුම යාවත්කාලීන කළා'],

    // Preferences
    'prefs.title': ['Food preferences', 'ආහාර මනාප'],
    'prefs.sub': [
      'Personalise your meal preferences.',
      'ඔබේ ආහාර මනාප පුද්ගලීකරණය කරන්න.'
    ],
    'prefs.allergies': ['Allergies', 'අසාත්මිකතා'],
    'prefs.allergiesSub': [
      'Select any allergies you have.',
      'ඔබට ඇති අසාත්මිකතා තෝරන්න.'
    ],
    'prefs.conditions': ['Health conditions', 'සෞඛ්‍ය තත්ත්ව'],
    'prefs.conditionsSub': [
      'We avoid food that may trigger symptoms.',
      'රෝග ලක්ෂණ ඇති කළ හැකි ආහාර අපි වළකිනවා.'
    ],
    'prefs.avoid': ['Foods you prefer to avoid', 'ඔබ වළකින ආහාර'],
    'prefs.avoidSub': [
      "We won't show these in your suggestions.",
      'ඒවා ඔබේ යෝජනාවල නොපෙන්වයි.'
    ],
    'prefs.other': ['Other allergies…', 'වෙනත් අසාත්මිකතා…'],
    'prefs.saved': ['Preferences saved', 'මනාප සුරකින ලදී'],

    'allergy.dairy': ['Dairy', 'කිරි'],
    'allergy.nuts': ['Nuts', 'ගෙඩි'],
    'allergy.eggs': ['Eggs', 'බිත්තර'],
    'allergy.seafood': ['Sea food', 'මුහුදු ආහාර'],
    'allergy.gluten': ['Gluten', 'ග්ලූටන්'],
    'allergy.soy': ['Soy', 'සෝයා'],
    'cond.highBp': ['High BP', 'අධි රුධිර පීඩනය'],
    'cond.gastritis': ['Gastritis', 'ගැස්ට්‍රයිටිස්'],
    'cond.cholesterol': ['Cholesterol', 'කොලෙස්ටරෝල්'],
    'cond.vegan': ['Vegan', 'වීගන්'],
    'cond.kidney': ['Kidney', 'වකුගඩු'],
    'cond.diabetes': ['Diabetes', 'දියවැඩියාව'],
    'avoid.spicy': ['Spicy', 'සැර'],
    'avoid.fried': ['Fried', 'බැදපු'],
    'avoid.oily': ['Oily', 'තෙල් සහිත'],
    'avoid.sugary': ['Sugary', 'පැණිරස'],
    'avoid.caffeine': ['Caffeine', 'කැෆීන්'],
    'avoid.redMeat': ['Red meat', 'රතු මාංශ'],

    // Reminders / notifications
    'reminders.title': ['Mood reminders', 'හැඟීම් මතක් කිරීම්'],
    'reminders.sub': [
      'A gentle nudge to check in with yourself.',
      'ඔබ ගැන සිතන්න කුඩා මතක් කිරීමක්.'
    ],
    'reminders.enable': ['Remind me daily', 'දිනපතා මතක් කරන්න'],
    'reminders.time': ['Time', 'වේලාව'],
    'reminders.days': ['Days', 'දින'],
    'reminders.saved': ['Reminder updated', 'මතක් කිරීම යාවත්කාලීන කළා'],
    'reminders.next': ['Next reminder {time}', 'ඊළඟ මතක් කිරීම {time}'],
    'reminders.daysSub': [
      'Choose the days you want a nudge.',
      'මතක් කිරීම අවශ්‍ය දින තෝරන්න.'
    ],
    'reminders.off': ['Reminders are off', 'මතක් කිරීම් නිවා ඇත'],
    'reminders.offSub': [
      'Turn the switch on to choose a time.',
      'වේලාවක් තෝරාගැනීමට ස්විචය සක්‍රීය කරන්න.'
    ],
    'reminders.permission': [
      'MoodMeal cannot send system notifications in this demo. Your chosen time is saved and shown here.',
      'මෙම නිදර්ශනයේදී MoodMealට පද්ධති දැනුම්දීම් යැවිය නොහැක. ඔබ තෝරාගත් වේලාව සුරකිනු ලැබේ.'
    ],
    'reminders.daily': ['Every day', 'දිනපතා'],
    'notifications.today': ['Today', 'අද'],
    'notifications.earlier': ['Earlier', 'කලින්'],
    'notifications.unread': ['{n} unread', 'කියවා නැති {n}'],
    'notifications.allRead': [
      'All notifications marked read',
      'සියලු දැනුම්දීම් කියවූ ලෙස සලකුණු කළා'
    ],
    'notifications.welcomeTitle': [
      'Welcome to MoodMeal',
      'MoodMeal වෙත සාදරයෙන් පිළිගනිමු'
    ],
    'notifications.welcomeBody': [
      'Start with one check-in. We will take it from there.',
      'එක් සටහනකින් පටන් ගන්න. ඉතිරිය අපි බලාගන්නම්.'
    ],
    'notifications.loggedTitle': [
      'First check-in saved',
      'පළමු සටහන සුරකින ලදී'
    ],
    'notifications.loggedBody': [
      'Your patterns begin here. See them in History.',
      'ඔබේ රටා මෙතැනින් පටන් ගනී. ඉතිහාසයේ බලන්න.'
    ],
    'notifications.title': ['Notifications', 'දැනුම්දීම්'],
    'notifications.empty': ['All caught up', 'සියල්ල කියවා අවසන්'],
    'notifications.emptySub': [
      'Reminders and gentle nudges will appear here.',
      'මතක් කිරීම් මෙහි දිස්වේ.'
    ],
    'notifications.markAll': ['Mark all read', 'සියල්ල කියවූ ලෙස'],
    'notif.reminderTitle': ['Time for a check-in', 'සටහන් කිරීමට වේලාව'],
    'notif.reminderBody': [
      'How are you feeling right now?',
      'දැන් ඔබට කොහොමද දැනෙන්නේ?'
    ],
    'notif.tipTitle': ['A mindful nudge', 'සිහිකල්පනා ඉඟියක්'],
    'notif.tipBody': [
      'Take three slow breaths before your next meal.',
      'ඊළඟ ආහාරයට පෙර සෙමින් හුස්ම තුනක් ගන්න.'
    ],
    'notif.streakTitle': ['Your streak is growing', 'ඔබේ අඛණ්ඩතාව වර්ධනය වේ'],
    'notif.streakBody': [
      'You checked in {n} days in a row. Keep going.',
      'ඔබ දින {n}ක් අඛණ්ඩව සටහන් කළා. දිගටම කරගෙන යන්න.'
    ],

    // Weekdays
    'day.mon': ['Mon', 'සඳුදා'],
    'day.tue': ['Tue', 'අඟහ'],
    'day.wed': ['Wed', 'බදාදා'],
    'day.thu': ['Thu', 'බ්‍රහස්'],
    'day.fri': ['Fri', 'සිකු'],
    'day.sat': ['Sat', 'සෙන'],
    'day.sun': ['Sun', 'ඉරිදා'],
    'day.short.mon': ['M', 'ස'],
    'day.short.tue': ['T', 'අ'],
    'day.short.wed': ['W', 'බ'],
    'day.short.thu': ['T', 'බ්‍ර'],
    'day.short.fri': ['F', 'සි'],
    'day.short.sat': ['S', 'සෙ'],
    'day.short.sun': ['S', 'ඉ'],
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales
      .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String t(String key, [Map<String, String>? args]) => l10n.t(key, args);
}
