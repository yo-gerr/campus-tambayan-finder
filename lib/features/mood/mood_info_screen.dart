import 'package:flutter/material.dart';

import '../../app/app_copy.dart';
import '../../app/app_layout.dart';
import '../../app/app_theme.dart';
import '../home/app_chrome.dart';
import '../home/speech_bubble.dart';

enum _MoodStep { intro, consent, checkIn, review, complete }

class MoodInfoScreen extends StatefulWidget {
  const MoodInfoScreen({required this.copy, required this.onHome, super.key});

  final AppCopy copy;
  final VoidCallback onHome;

  @override
  State<MoodInfoScreen> createState() => _MoodInfoScreenState();
}

class _MoodInfoScreenState extends State<MoodInfoScreen> {
  _MoodStep _step = _MoodStep.intro;
  String? _selectedMood;
  bool _consentAccepted = false;
  final _nicknameController = TextEditingController();

  AppCopy get copy => widget.copy;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      _step = switch (_step) {
        _MoodStep.intro => _MoodStep.consent,
        _MoodStep.consent => _MoodStep.checkIn,
        _MoodStep.checkIn => _MoodStep.review,
        _MoodStep.review => _MoodStep.complete,
        _MoodStep.complete => _MoodStep.intro,
      };
    });
  }

  void _back() {
    setState(() {
      _step = switch (_step) {
        _MoodStep.intro => _MoodStep.intro,
        _MoodStep.consent => _MoodStep.intro,
        _MoodStep.checkIn => _MoodStep.consent,
        _MoodStep.review => _MoodStep.checkIn,
        _MoodStep.complete => _MoodStep.intro,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    return BandScaffold(
      header: SectionHeader(
        title: copy.get('mood_title'),
        copy: copy,
        onHome: widget.onHome,
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          layout.contentInset,
          16,
          layout.contentInset,
          32,
        ),
        children: [
          if (_step != _MoodStep.intro) ...[
            LinearProgressIndicator(
              value: (_step.index + 1) / _MoodStep.values.length,
              minHeight: 6,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 20),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildStep(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    return switch (_step) {
      _MoodStep.intro => _IntroStep(
        copy: copy,
        onStart: _next,
        onHome: widget.onHome,
      ),
      _MoodStep.consent => _ConsentStep(
        copy: copy,
        accepted: _consentAccepted,
        onChanged: (value) => setState(() => _consentAccepted = value),
        onBack: _back,
        onContinue: _consentAccepted ? _next : null,
      ),
      _MoodStep.checkIn => _CheckInStep(
        copy: copy,
        selectedMood: _selectedMood,
        nicknameController: _nicknameController,
        onSelected: (mood) => setState(() => _selectedMood = mood),
        onBack: _back,
        onContinue: _selectedMood == null ? null : _next,
      ),
      _MoodStep.review => _ReviewStep(
        copy: copy,
        mood: _selectedMood!,
        nickname: _nicknameController.text,
        onBack: _back,
        onPreview: _next,
      ),
      _MoodStep.complete => _CompleteStep(
        copy: copy,
        onHome: widget.onHome,
        onRestart: () => setState(() {
          _step = _MoodStep.intro;
          _selectedMood = null;
          _consentAccepted = false;
          _nicknameController.clear();
        }),
      ),
    };
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.copy,
    required this.onStart,
    required this.onHome,
  });

  final AppCopy copy;
  final VoidCallback onStart;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MoodPanel(child: const MoodFaces(width: 150)),
        const SizedBox(height: 34),
        Text(
          copy.get('mood_preview_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(
          copy.get('mood_body'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        _Notice(icon: Icons.lock_outline, text: copy.get('mood_privacy')),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('mood-start-checkin'),
          onPressed: onStart,
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(copy.get('mood_start')),
        ),
        TextButton(
          key: const Key('mood-back-home'),
          onPressed: onHome,
          child: Text(copy.get('mood_cta')),
        ),
      ],
    );
  }
}

class _ConsentStep extends StatelessWidget {
  const _ConsentStep({
    required this.copy,
    required this.accepted,
    required this.onChanged,
    required this.onBack,
    required this.onContinue,
  });

  final AppCopy copy;
  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onBack;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.get('mood_consent_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(copy.get('mood_consent_body')),
        const SizedBox(height: 18),
        _Notice(
          icon: Icons.privacy_tip_outlined,
          text: copy.get('mood_consent_data'),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: CheckboxListTile(
            key: const Key('mood-consent'),
            value: accepted,
            onChanged: (value) => onChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(copy.get('mood_consent_agree')),
          ),
        ),
        const SizedBox(height: 16),
        _StepActions(copy: copy, onBack: onBack, onContinue: onContinue),
      ],
    );
  }
}

class _CheckInStep extends StatelessWidget {
  const _CheckInStep({
    required this.copy,
    required this.selectedMood,
    required this.nicknameController,
    required this.onSelected,
    required this.onBack,
    required this.onContinue,
  });

  final AppCopy copy;
  final String? selectedMood;
  final TextEditingController nicknameController;
  final ValueChanged<String> onSelected;
  final VoidCallback onBack;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final moods = [
      ('happy', Icons.sentiment_very_satisfied_rounded),
      ('relaxed', Icons.sentiment_satisfied_alt_rounded),
      ('stressed', Icons.sentiment_dissatisfied_rounded),
      ('sad', Icons.sentiment_very_dissatisfied_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.get('mood_select_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(copy.get('mood_select_body')),
        const SizedBox(height: 18),
        for (final mood in moods)
          Card(
            color: selectedMood == mood.$1 ? AppColors.bubble : null,
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                key: Key('mood-${mood.$1}'),
                onTap: () => onSelected(mood.$1),
                leading: Icon(mood.$2, color: AppColors.inkStrong),
                title: Text(copy.get('mood_${mood.$1}')),
                trailing: Icon(
                  selectedMood == mood.$1
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('mood-nickname'),
          controller: nicknameController,
          decoration: InputDecoration(
            labelText: copy.get('mood_nickname'),
            helperText: copy.get('mood_nickname_help'),
          ),
        ),
        const SizedBox(height: 16),
        _StepActions(copy: copy, onBack: onBack, onContinue: onContinue),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.copy,
    required this.mood,
    required this.nickname,
    required this.onBack,
    required this.onPreview,
  });

  final AppCopy copy;
  final String mood;
  final String nickname;
  final VoidCallback onBack;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.get('mood_review_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        _ReviewRow(
          label: copy.get('mood_review_mood'),
          value: copy.get('mood_$mood'),
        ),
        _ReviewRow(
          label: copy.get('mood_review_nickname'),
          value: nickname.isEmpty ? copy.get('mood_not_provided') : nickname,
        ),
        _Notice(icon: Icons.info_outline, text: copy.get('mood_demo_notice')),
        const SizedBox(height: 20),
        _StepActions(
          copy: copy,
          onBack: onBack,
          onContinue: onPreview,
          continueLabel: copy.get('mood_preview_submit'),
        ),
      ],
    );
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({
    required this.copy,
    required this.onHome,
    required this.onRestart,
  });

  final AppCopy copy;
  final VoidCallback onHome;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MoodPanel(
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 96,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          copy.get('mood_complete_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(copy.get('mood_complete_body')),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('mood-complete-home'),
          onPressed: onHome,
          icon: const Icon(Icons.home_rounded),
          label: Text(copy.get('mood_cta')),
        ),
        TextButton(onPressed: onRestart, child: Text(copy.get('mood_restart'))),
      ],
    );
  }
}

class _StepActions extends StatelessWidget {
  const _StepActions({
    required this.copy,
    required this.onBack,
    required this.onContinue,
    this.continueLabel,
  });

  final AppCopy copy;
  final VoidCallback onBack;
  final VoidCallback? onContinue;
  final String? continueLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(onPressed: onBack, child: Text(copy.get('back'))),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onContinue,
            child: Text(continueLabel ?? copy.get('mood_continue')),
          ),
        ),
      ],
    );
  }
}

class _MoodPanel extends StatelessWidget {
  const _MoodPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(color: AppColors.surfaceUnder, offset: Offset(0, 6)),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.bubble,
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.inkStrong),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
