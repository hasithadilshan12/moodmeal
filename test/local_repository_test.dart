import 'package:flutter_test/flutter_test.dart';
import 'package:moodmeal/data/models/mood_entry.dart';
import 'package:moodmeal/data/repositories/repository.dart';
import 'package:moodmeal/data/services/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await Store.init();
  });

  test('the demo account is seeded and new accounts start empty', () async {
    final repo = LocalRepository();

    final demo = await repo.continueAsDemo();
    final demoProfile = await repo.loadProfile(demo);
    expect(demoProfile.name, 'Cameron Wilson');
    expect((await repo.loadMoods()).length, 6);
    expect((await repo.loadFavourites()).length, 2);

    final created =
        await repo.signUp('Nimal', 'nimal@example.com', 'secret123');
    expect((await repo.loadProfile(created)).name, 'Nimal');
    expect(await repo.loadMoods(), isEmpty);
    expect(await repo.loadFavourites(), isEmpty);
  });

  test('moods and favourites never leak between accounts', () async {
    final repo = LocalRepository();
    final demo = await repo.continueAsDemo();
    await repo.loadProfile(demo);

    await repo.saveMood(
      MoodEntry(
        id: 'test-entry',
        mood: Mood.happy,
        intensity: 4,
        // Must be newer than every seeded entry so the ordering assertion below
        // stays valid no matter what today's date is.
        createdAt: DateTime.now(),
      ),
    );
    await repo.saveFavourites({'soba'});
    expect((await repo.loadMoods()).length, 7);

    await repo.signUp('Nimal', 'nimal@example.com', 'secret123');
    expect(await repo.loadMoods(), isEmpty);
    expect(await repo.loadFavourites(), isEmpty);

    await repo.signIn(Store.demoEmail, 'anything');
    final restored = await repo.loadMoods();
    expect(restored.length, 7);
    expect(restored.first.id, 'test-entry');
    expect(await repo.loadFavourites(), {'soba'});
  });
}
