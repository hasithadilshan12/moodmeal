import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/seed/catalog.dart';
import '../../../data/seed/media.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/nearby_service.dart';
import '../../../state/nearby_controller.dart';
import '../../widgets/common.dart';
import '../shell/app_shell.dart';

/// Real nearby restaurants for the user's actual position (or a chosen city),
/// powered by OpenStreetMap (Nominatim first, Photon next, Overpass on native).
class RestaurantsPage extends ConsumerStatefulWidget {
  const RestaurantsPage({super.key, this.mealId});

  /// When set, the page surfaces a shortcut to order that specific dish.
  final String? mealId;

  @override
  ConsumerState<RestaurantsPage> createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends ConsumerState<RestaurantsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Rebuild the search field when the controller finishes a refresh so the
    // text field never disagrees with the filtered list.
    ref.read(nearbyProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || ok) return;
    Toast.show(context, context.l10n.t('common.cannotOpen'));
  }

  Future<void> _pickCity(NearbyController nearby) async {
    final t = context.l10n;
    final picked = await showModalBottomSheet<CityAnchor>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.t('rest.chooseCity'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                t.t('rest.sub'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final city in cityAnchors)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.line),
                    ),
                    tileColor: AppColors.surface,
                    leading: const Icon(Icons.location_city_rounded,
                        color: AppColors.orange),
                    title: Text(city.localized(t.isSinhala)),
                    trailing: (nearby.cityName == city.name)
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.green)
                        : null,
                    onTap: () => Navigator.of(context).pop(city),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    await nearby.useCity(picked);
  }

  Future<void> _useLocation(NearbyController nearby) async {
    HapticFeedback.selectionClick();
    await nearby.useDeviceLocation();
  }

  Future<void> _findDishOnMap(NearbyController nearby) async {
    final media = MediaBook.of(widget.mealId!);
    final term = Uri.encodeComponent(media.searchTerm);
    final url = nearby.hasOrigin
        ? 'https://www.google.com/maps/search/$term/@${nearby.lat},${nearby.lng},15z'
        : 'https://www.google.com/maps/search/?api=1&query=$term';
    await _open(url);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final nearby = ref.watch(nearbyProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BackHeader(
              title: t.t('rest.title'),
              subtitle: t.t('rest.sub'),
              trailing: nearby.hasOrigin
                  ? IconButton(
                      tooltip: t.t('rest.refresh'),
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        nearby.refresh();
                      },
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: nearby.setQuery,
                decoration: InputDecoration(
                  hintText: t.t('rest.searchHint'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: nearby.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            nearby.setQuery('');
                          },
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 15, color: AppColors.orange),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      nearby.usingGps
                          ? t.t('rest.usingGps')
                          : nearby.cityName != null
                              ? t.t('rest.aroundCity', {
                                  'city': t.isSinhala
                                      ? nearby.cityNameSi ?? nearby.cityName!
                                      : nearby.cityName!,
                                })
                              : t.t('rest.pickCityHint'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickCity(nearby),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    child: Text(
                      nearby.hasOrigin
                          ? t.t('rest.changeCity')
                          : t.t('rest.chooseCity'),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.line),
            Expanded(child: _body(nearby)),
          ],
        ),
      ),
    );
  }

  Widget _body(NearbyController nearby) {
    final t = context.l10n;

    if (!nearby.hasOrigin) {
      return _StartPrompt(
        nearby: nearby,
        message: nearby.locationProblem == LocationProblemKind.blockedForever
            ? t.t('rest.permBlocked')
            : nearby.locationProblem != null
                ? t.t('rest.permDenied')
                : null,
        onUseLocation: () => _useLocation(nearby),
        onPickCity: () => _pickCity(nearby),
      );
    }

    if (nearby.stage == NearbyStage.locating ||
        nearby.stage == NearbyStage.loading) {
      return _Loading(
        label: nearby.stage == NearbyStage.locating
            ? t.t('rest.locating')
            : t.t('rest.loading'),
      );
    }

    if (nearby.stage == NearbyStage.error) {
      return _ErrorView(
        message: switch (nearby.errorCode) {
          'network' => t.t('rest.errorNetwork'),
          'server' => t.t('rest.errorServer'),
          'timeout' => t.t('rest.errorTimeout'),
          _ => t.t('rest.errorUnexpected'),
        },
        onRetry: () {
          HapticFeedback.selectionClick();
          nearby.refresh();
        },
        onPickCity: () => _pickCity(nearby),
        onSettings: nearby.locationProblem == LocationProblemKind.blockedForever
            ? () => nearby.openSystemLocationSettings()
            : null,
        settingsLabel: t.t('rest.openSettings'),
      );
    }

    final places = nearby.visible;

    if (places.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          if (widget.mealId != null) ...[
            _DishBanner(
              mealId: widget.mealId!,
              onFindOnMap: () => _findDishOnMap(nearby),
            ),
            const SizedBox(height: 16),
          ],
          EmptyState(
            emoji: nearby.query.isNotEmpty ? '🔍' : '🍽️',
            title: nearby.query.isNotEmpty
                ? t.t('rest.noResults')
                : t.t('rest.emptyNearby'),
            body: nearby.query.isNotEmpty
                ? t.t('rest.noResultsSub')
                : t.t('rest.emptyNearbySub'),
            actionLabel: t.t('rest.changeCity'),
            onAction: () => _pickCity(nearby),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: nearby.refresh,
      color: AppColors.orange,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
        children: [
          if (widget.mealId != null) ...[
            _DishBanner(
              mealId: widget.mealId!,
              onFindOnMap: () => _findDishOnMap(nearby),
            ),
            const SizedBox(height: 16),
          ],
          if (nearby.usingSaved) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.peachSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 18, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.t('rest.savedBanner'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            height: 1.4,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => nearby.refresh(),
                    child: Text(t.t('rest.refresh')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  t.t('rest.found', {'n': '${places.length}'}),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final place in places)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlaceCard(
                place: place,
                onDirections: () => _open(place.directionsUrl),
                onCall: place.phone == null
                    ? null
                    : () => _open('tel:${place.phone}'),
                onWebsite:
                    place.website == null ? null : () => _open(place.website!),
                onMap: () => _open(place.placeUrl),
              ),
            ),
        ],
      ),
    );
  }
}

class _StartPrompt extends StatelessWidget {
  const _StartPrompt({
    required this.nearby,
    required this.message,
    required this.onUseLocation,
    required this.onPickCity,
  });

  final NearbyController nearby;
  final String? message;
  final VoidCallback onUseLocation;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final isSi = t.isSinhala;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.isDark
                  ? [AppColors.surface, AppColors.surfaceAlt]
                  : const [Color(0xFFFFEBD9), Color(0xFFFFF7F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.isDark ? AppColors.line : Colors.white,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📍', style: TextStyle(fontSize: 30)),
              const SizedBox(height: 10),
              Text(
                t.t('rest.pickCityHint'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                message ?? t.t('rest.sub'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.inkSoft,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: t.t('rest.useLocation'),
                icon: Icons.my_location_rounded,
                height: 48,
                onPressed: onUseLocation,
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: onPickCity,
                  child: Text(t.t('rest.chooseCity')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          t.t('rest.chooseCity'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final city in cityAnchors)
              ActionChip(
                avatar: const Icon(Icons.location_city_rounded,
                    size: 15, color: AppColors.orange),
                label: Text(city.localized(isSi)),
                backgroundColor: AppColors.surface,
                side: BorderSide(color: AppColors.line),
                onPressed: () => nearby.useCity(city),
              ),
          ],
        ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.orange),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onPickCity,
    required this.onSettings,
    required this.settingsLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onPickCity;
  final VoidCallback? onSettings;
  final String settingsLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📡', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              t.t('rest.errorTitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(t.t('common.retry')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickCity,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.location_city_rounded, size: 18),
                    label: Text(t.t('rest.chooseCity')),
                  ),
                ),
              ],
            ),
            if (onSettings != null) ...[
              const SizedBox(height: 6),
              TextButton(onPressed: onSettings, child: Text(settingsLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

class _DishBanner extends StatelessWidget {
  const _DishBanner({required this.mealId, required this.onFindOnMap});

  final String mealId;
  final VoidCallback onFindOnMap;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final meal = Catalog.mealById(mealId);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          MealImage(meal: meal, size: 60, radius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.localizedName(t.isSinhala),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  t.t('meal.nearbyTitle'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onFindOnMap,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.orange,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: Theme.of(context).textTheme.labelSmall,
            ),
            child: Text(t.t('meal.orderDish')),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    required this.place,
    required this.onDirections,
    required this.onCall,
    required this.onWebsite,
    required this.onMap,
  });

  final NearbyPlace place;
  final VoidCallback onDirections;
  final VoidCallback? onCall;
  final VoidCallback? onWebsite;
  final VoidCallback onMap;

  IconData get _icon => switch (place.category) {
        'cafe' => Icons.local_cafe_rounded,
        'fast_food' => Icons.fastfood_rounded,
        _ => Icons.restaurant_rounded,
      };

  String _categoryLabel(AppLocalizations t) {
    final key = 'rest.cat.${place.category}';
    final label = t.t(key);
    return label == key ? t.t('rest.cat.restaurant') : label;
  }

  /// OSM cuisine tags look like `ice_cream` or `international;breakfast`.
  /// Turn them into something a person would read.
  String? _cuisineLabel(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw
        .split(';')
        .map((s) => s.replaceAll('_', ' ').trim())
        .where((s) => s.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return null;
    final joined = parts.join(', ');
    return joined[0].toUpperCase() + joined.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      onTap: onMap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.peachSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(_icon, size: 22, color: AppColors.orangeDeep),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        _categoryLabel(t),
                        if (_cuisineLabel(place.cuisine) != null)
                          _cuisineLabel(place.cuisine),
                      ].whereType<String>().join(' Â· '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${place.distanceKm < 1 ? (place.distanceKm * 1000).round() : place.distanceKm.toStringAsFixed(1)}'
                  '${place.distanceKm < 1 ? ' m' : ' ${t.t('common.km')}'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (place.address != null) ...[
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map_outlined, size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    place.address!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
          if (place.openingHours != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule_rounded, size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    place.openingHours!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDirections,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  icon: const Icon(Icons.directions_rounded, size: 16),
                  label: Text(t.t('rest.directions')),
                ),
              ),
              const SizedBox(width: 8),
              if (onCall != null)
                IconButton(
                  tooltip: t.t('rest.call'),
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 19),
                  color: AppColors.green,
                ),
              if (onWebsite != null)
                IconButton(
                  tooltip: t.t('rest.website'),
                  onPressed: onWebsite,
                  icon: const Icon(Icons.language_rounded, size: 19),
                  color: AppColors.violet,
                ),
              IconButton(
                tooltip: t.t('rest.viewOnMap'),
                onPressed: onMap,
                icon: const Icon(Icons.map_outlined, size: 19),
                color: AppColors.orangeDeep,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
