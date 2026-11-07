import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../../app/external_links.dart';
import '../home/app_chrome.dart';

/// Third-party data, service, library, and font credits.
///
/// The public [CREDITS.md] file mirrors this inventory for people reading the
/// repository. Keep the two in step when a provider, dependency, or asset
/// changes. This page is factual attribution, not a legal review.
class CreditsScreen extends StatelessWidget {
  const CreditsScreen({required this.copy, required this.onHome, super.key});

  final AppCopy copy;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    final tagalog = copy.isTagalog;

    return BandScaffold(
      header: SectionHeader(
        title: copy.get('credits'),
        copy: copy,
        onHome: onHome,
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          layout.contentInset,
          16,
          layout.contentInset,
          32,
        ),
        children: [
          _IntroCard(text: copy.get('credits_intro')),
          const SizedBox(height: 20),
          _CreditGroup(
            title: copy.get('credits_maps'),
            icon: Icons.map_outlined,
            entries: _mapCredits,
            tagalog: tagalog,
            copy: copy,
          ),
          const SizedBox(height: 20),
          _CreditGroup(
            title: copy.get('credits_platform'),
            icon: Icons.widgets_outlined,
            entries: _platformCredits,
            tagalog: tagalog,
            copy: copy,
          ),
          const SizedBox(height: 20),
          _CreditGroup(
            title: copy.get('credits_fonts'),
            icon: Icons.text_fields_rounded,
            entries: _fontCredits,
            tagalog: tagalog,
            copy: copy,
          ),
          const SizedBox(height: 20),
          _CreditGroup(
            title: copy.get('credits_content'),
            icon: Icons.info_outline,
            entries: _contentCredits,
            tagalog: tagalog,
            copy: copy,
          ),
          const SizedBox(height: 8),
          _NoteCard(
            title: copy.get('credits_repo'),
            body: copy.get('credits_repo_note'),
          ),
          const SizedBox(height: 10),
          _NoteCard(
            title: copy.get('credits_sample_title'),
            body: copy.get('credits_sample_note'),
          ),
          const SizedBox(height: 10),
          _NoteCard(
            title: copy.get('credits_brand_title'),
            body: copy.get('credits_brand_note'),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            key: const Key('credits-licenses'),
            onPressed: () => _showLicenses(context),
            icon: const Icon(Icons.description_outlined),
            label: Text(copy.get('credits_licenses_button')),
          ),
          const SizedBox(height: 8),
          Text(
            copy.get('credits_licenses_hint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.mutedInk),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Kamus Tambay',
      applicationVersion: '1.0.0 (demo)',
      applicationIcon: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.menu_book_rounded, size: 40),
      ),
    );
  }
}

const _mapCredits = <_Credit>[
  _Credit(
    name: 'OpenStreetMap contributors',
    roleEn: 'Map data',
    roleTl: 'Datos ng mapa',
    licenseEn: 'ODbL 1.0',
    licenseTl: 'ODbL 1.0',
    url: 'https://www.openstreetmap.org/copyright',
    icon: Icons.public,
  ),
  _Credit(
    name: 'OpenFreeMap',
    roleEn: 'Vector tiles and Positron style',
    roleTl: 'Vector tiles at Positron style',
    licenseEn: 'Free public service; no SLA',
    licenseTl: 'Libreng pampublikong serbisyo; walang SLA',
    url: 'https://openfreemap.org/',
    icon: Icons.layers_outlined,
  ),
  _Credit(
    name: 'OpenMapTiles',
    roleEn: 'Tile schema and cartography',
    roleTl: 'Tile schema at kartograpiya',
    licenseEn: 'CC BY 4.0 design; BSD-3-Clause code',
    licenseTl: 'CC BY 4.0 na disenyo; BSD-3-Clause na code',
    url: 'https://www.openmaptiles.org/',
    icon: Icons.grid_on_outlined,
  ),
  _Credit(
    name: 'Natural Earth',
    roleEn: 'Shaded relief raster',
    roleTl: 'Shaded relief raster',
    licenseEn: 'Public domain',
    licenseTl: 'Pampublikong domain',
    url: 'https://www.naturalearthdata.com/',
    icon: Icons.terrain_outlined,
  ),
  _Credit(
    name: 'OpenStreetMap · Fix the map',
    roleEn: 'Report a map error to the community',
    roleTl: 'Iulat ang mali sa mapa sa komunidad',
    licenseEn: 'Community editing',
    licenseTl: 'Pag-edit ng komunidad',
    url: 'https://www.openstreetmap.org/fixthemap',
    icon: Icons.edit_location_alt_outlined,
  ),
];

const _platformCredits = <_Credit>[
  _Credit(
    name: 'Flutter & Dart',
    roleEn: 'App framework and runtime',
    roleTl: 'Framework at runtime ng app',
    licenseEn: 'BSD-3-Clause',
    licenseTl: 'BSD-3-Clause',
    url: 'https://flutter.dev/',
    icon: Icons.flutter_dash,
  ),
  _Credit(
    name: 'Material Icons',
    roleEn: 'Interface icons',
    roleTl: 'Mga icon ng interface',
    licenseEn: 'Apache-2.0',
    licenseTl: 'Apache-2.0',
    url: 'https://fonts.google.com/icons',
    icon: Icons.emoji_emotions_outlined,
  ),
  _Credit(
    name: 'MapLibre GL Native / flutter-maplibre-gl',
    roleEn: 'Map renderer',
    roleTl: 'Map renderer',
    licenseEn: 'BSD-style',
    licenseTl: 'BSD-style',
    url: 'https://maplibre.org/',
    icon: Icons.map,
  ),
  _Credit(
    name: 'Supabase & supabase_flutter',
    roleEn: 'Shared listings',
    roleTl: 'Shared listings',
    licenseEn: 'MIT SDK; PostgreSQL licence for the service',
    licenseTl: 'MIT na SDK; PostgreSQL na lisensya ng serbisyo',
    url: 'https://supabase.com/',
    icon: Icons.storage_outlined,
  ),
  _Credit(
    name: 'url_launcher, shared_preferences, http',
    roleEn: 'Flutter utilities',
    roleTl: 'Mga utility ng Flutter',
    licenseEn: 'BSD-3-Clause',
    licenseTl: 'BSD-3-Clause',
    url: 'https://pub.dev/',
    icon: Icons.extension_outlined,
  ),
  _Credit(
    name: 'cupertino_icons',
    roleEn: 'Icon font dependency',
    roleTl: 'Icon font dependency',
    licenseEn: 'MIT',
    licenseTl: 'MIT',
    url: 'https://pub.dev/packages/cupertino_icons',
    icon: Icons.apple,
  ),
  _Credit(
    name: 'flutter_native_splash',
    roleEn: 'Build-time splash generation',
    roleTl: 'Pagbuo ng splash sa build',
    licenseEn: 'MIT',
    licenseTl: 'MIT',
    url: 'https://pub.dev/packages/flutter_native_splash',
    icon: Icons.brightness_low_outlined,
  ),
];

const _fontCredits = <_Credit>[
  _Credit(
    name: 'Fredoka',
    roleEn: 'Heading typeface',
    roleTl: 'Typeface para sa pamagat',
    licenseEn: 'SIL Open Font License 1.1',
    licenseTl: 'SIL Open Font License 1.1',
    url: 'https://github.com/hafontia/Fredoka-One',
    icon: Icons.text_fields,
  ),
  _Credit(
    name: 'Nunito',
    roleEn: 'Body typeface',
    roleTl: 'Typeface para sa teksto',
    licenseEn: 'SIL Open Font License 1.1',
    licenseTl: 'SIL Open Font License 1.1',
    url: 'https://github.com/googlefonts/nunito',
    icon: Icons.subject_rounded,
  ),
];

const _contentCredits = <_Credit>[
  _Credit(
    name: 'Google Maps',
    roleEn: 'External directions hand-off; no embedded map or API key',
    roleTl: 'Panlabas na directions; walang naka-embed na mapa o API key',
    licenseEn: 'Google Maps terms apply when opened',
    licenseTl: 'Nalalapat ang terms ng Google Maps kapag binuksan',
    url: 'https://www.google.com/maps',
    icon: Icons.directions_outlined,
  ),
];

class _Credit {
  const _Credit({
    required this.name,
    required this.roleEn,
    required this.roleTl,
    required this.licenseEn,
    required this.licenseTl,
    this.url,
    this.icon = Icons.public,
  });

  final String name;
  final String roleEn;
  final String roleTl;
  final String licenseEn;
  final String licenseTl;
  final String? url;
  final IconData icon;

  String role(bool tagalog) => tagalog ? roleTl : roleEn;

  String license(bool tagalog) => tagalog ? licenseTl : licenseEn;
}

class _CreditGroup extends StatelessWidget {
  const _CreditGroup({
    required this.title,
    required this.icon,
    required this.entries,
    required this.tagalog,
    required this.copy,
  });

  final String title;
  final IconData icon;
  final List<_Credit> entries;
  final bool tagalog;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.inkStrong,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final entry in entries)
          _CreditCard(entry: entry, tagalog: tagalog, copy: copy),
      ],
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({
    required this.entry,
    required this.tagalog,
    required this.copy,
  });

  final _Credit entry;
  final bool tagalog;
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final url = entry.url;

    final body = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.bubble,
              shape: BoxShape.circle,
            ),
            child: Icon(entry.icon, size: 20, color: AppColors.inkStrong),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.inkStrong,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (url != null)
                      const Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: AppColors.mutedInk,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.role(tagalog),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedInk,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.license(tagalog),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.surfaceUnder,
              offset: Offset(0, kCardUnderOffset),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: url == null
              ? body
              : InkWell(
                  onTap: () => openExternalLink(
                    context,
                    Uri.parse(url),
                    failureMessage: copy.get('external_link_failed'),
                  ),
                  child: body,
                ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceUnder,
            offset: Offset(0, kCardUnderOffset),
          ),
        ],
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.ink, height: 1.45),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.inkStrong,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
