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

  test('a new local account starts empty', () async {
    final repo = LocalRepository();

    final created =
        await repo.signUp('Nimal', 'nimal@example.com', 'secret123');
    expect((await repo.loadProfile(created)).name, 'Nimal');
    expect(await repo.loadMoods(), isEmpty);
    expect(await repo.loadFavourites(), isEmpty);
  });

  test('moods and favourites never leak between accounts', () async {
    final repo = LocalRepository();
    final first = await repo.signUp('Nimal', 'nimal@example.com', 'secret123');
    await repo.loadProfile(first);

    await repo.saveMood(
      MoodEntry(
        id: 'test-entry',
        mood: Mood.happy,
        intensity: 4,
        createdAt: DateTime.now(),
      ),
    );
    await repo.saveFavourites({'soba'});
    expect((await repo.loadMoods()).length, 1);

    await repo.signUp('Kamal', 'kamal@example.com', 'secret123');
    expect(await repo.loadMoods(), isEmpty);
    expect(await repo.loadFavourites(), isEmpty);

    await repo.signIn('nimal@example.com', 'secret123');
    final restored = await repo.loadMoods();
    expect(restored.length, 1);
    expect(restored.first.id, 'test-entry');
    expect(await repo.loadFavourites(), {'soba'});
  });
}
