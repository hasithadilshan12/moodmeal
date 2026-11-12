import '../models/models.dart';

/// Real media attached to each catalog meal: a bundled photograph, a verified
/// YouTube walkthrough and a search phrase for finding the dish nearby.
///
/// Photos come from Wikimedia Commons (see `assets/images/food/CREDITS.md`);
/// video ids were checked against YouTube's oEmbed endpoint so they resolve.
class MediaBook {
  MediaBook._();

  static const _media = <String, MealMedia>{
    'oatmeal': MealMedia(
      image: 'assets/images/food/oatmeal.jpg',
      searchTerm: 'oatmeal porridge',
      video: MealVideo(
        id: 'niLP5pLD4UQ',
        title: 'Oats porridge in 10 minutes',
        channel: 'Always Yummy!',
      ),
    ),
    'salmon': MealMedia(
      image: 'assets/images/food/salmon.jpg',
      searchTerm: 'grilled salmon restaurant',
      video: MealVideo(
        id: 'j7BkpjD-HZ0',
        title: 'Grilled salmon with garlic lime butter',
        channel: "Natasha's Kitchen",
      ),
    ),
    'pumpkin_soup': MealMedia(
      image: 'assets/images/food/pumpkin_soup.jpg',
      searchTerm: 'pumpkin soup',
      video: MealVideo(
        id: 'pXO1l9tZmic',
        title: 'Creamy pumpkin soup',
        channel: 'Spice Bangla',
      ),
    ),
    'parfait': MealMedia(
      image: 'assets/images/food/parfait.jpg',
      searchTerm: 'yogurt parfait cafe',
      video: MealVideo(
        id: '6OOfOgKy7mY',
        title: 'Make-ahead yogurt and granola parfait',
        channel: "Food Lovin' Family",
      ),
    ),
    'dhal': MealMedia(
      image: 'assets/images/food/dhal.jpg',
      searchTerm: 'dhal curry rice and curry',
      video: MealVideo(
        id: 'xTn7U4ioPJY',
        title: 'පරිප්පු කරිය (parippu curry)',
        channel: 'Bandi Full',
        sinhala: true,
      ),
    ),
    'kottu': MealMedia(
      image: 'assets/images/food/kottu.jpg',
      searchTerm: 'kottu roti',
      video: MealVideo(
        id: 'uTBMNjUDG_U',
        title: 'ඉක්මනින් කොත්තු හදමු (quick kottu)',
        channel: 'M.R Kitchen',
        sinhala: true,
      ),
    ),
    'avocado_toast': MealMedia(
      image: 'assets/images/food/avocado_toast.jpg',
      searchTerm: 'avocado toast cafe',
      video: MealVideo(
        id: '7z96ide2-no',
        title: 'Avocado toast with egg, four ways',
        channel: 'Feelgoodfoodie',
      ),
    ),
    'chocolate': MealMedia(
      image: 'assets/images/food/chocolate.jpg',
      searchTerm: 'dark chocolate',
      video: MealVideo(
        id: 'i0TD3IU0d6I',
        title: 'From cacao pod to chocolate bar',
        channel: 'In The Kitchen With Matt',
      ),
    ),
    'green_tea': MealMedia(
      image: 'assets/images/food/green_tea.jpg',
      searchTerm: 'green tea cafe',
      video: MealVideo(
        id: 'ExtFskrOHUQ',
        title: 'How to brew green tea properly',
        channel: 'Nio Teas TV',
      ),
    ),
    'rice_bowl': MealMedia(
      image: 'assets/images/food/rice_bowl.jpg',
      searchTerm: 'rice bowl healthy',
      video: MealVideo(
        id: 'oxXNklNgmbM',
        title: 'The 1 dollar healthy rice bowl',
        channel: 'Joshua Weissman',
      ),
    ),
    'soba': MealMedia(
      image: 'assets/images/food/soba.jpg',
      searchTerm: 'soba noodles japanese',
      video: MealVideo(
        id: 'YQQlDqJ0G_k',
        title: 'Soba noodle salad with miso dressing',
        channel: 'goop',
      ),
    ),
    'mango_smoothie': MealMedia(
      image: 'assets/images/food/mango_smoothie.jpg',
      searchTerm: 'mango smoothie juice bar',
      video: MealVideo(
        id: 'kv9Qux0IEno',
        title: '1-minute mango smoothie',
        channel: 'Spice Bangla',
      ),
    ),
    'sweet_potato': MealMedia(
      image: 'assets/images/food/sweet_potato.jpg',
      searchTerm: 'sweet potato wedges',
      video: MealVideo(
        id: 'HOJyYNxu43s',
        title: 'Crispy baked sweet potato wedges',
        channel: 'Clean & Delicious',
      ),
    ),
    'wrap': MealMedia(
      image: 'assets/images/food/wrap.jpg',
      searchTerm: 'paneer wrap',
      video: MealVideo(
        id: 'rre7unozEJk',
        title: 'Paneer tikka wrap',
        channel: 'CookingShooking',
      ),
    ),
    'chamomile': MealMedia(
      image: 'assets/images/food/chamomile.jpg',
      searchTerm: 'chamomile tea cafe',
      video: MealVideo(
        id: 'p4eJRxTDtEA',
        title: 'How to brew the perfect cup of chamomile tea',
        channel: 'Hallmark',
      ),
    ),
    'banana_toast': MealMedia(
      image: 'assets/images/food/banana_toast.jpg',
      searchTerm: 'peanut butter banana toast',
      video: MealVideo(
        id: '-D-lh50PZL0',
        title: 'Peanut butter banana toast, no oven',
        channel: 'Bread toast recipe',
      ),
    ),
    'egg_hoppers': MealMedia(
      image: 'assets/images/food/egg_hoppers.jpg',
      searchTerm: 'egg hoppers sri lankan',
      video: MealVideo(
        id: 'T-1B-a64ekM',
        title: 'How to make Sri Lankan egg hoppers',
        channel: 'Jetwing Hotels',
      ),
    ),
  };

  static MealMedia of(String mealId) => _media[mealId] ?? _media['oatmeal']!;

  static List<MealVideo> get allVideos =>
      _media.values.map((m) => m.video).toList(growable: false);
}

class MealMedia {
  const MealMedia({
    required this.image,
    required this.searchTerm,
    required this.video,
  });

  final String image;
  final String searchTerm;
  final MealVideo video;
}
