import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:arora/features/player/providers/player_providers.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  AndroidEqualizerParameters? _params;
  double _loudnessGain = 0.0;
  bool _equalizerEnabled = true;
  bool _loudnessEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadParameters();
  }

  Future<void> _loadParameters() async {
    final service = ref.read(audioPlayerServiceProvider);
    try {
      final eq = service.equalizer;
      final loudness = service.loudnessEnhancer;
      if (eq != null) {
        final params = await eq.parameters;
        if (mounted) {
          setState(() {
            _params = params;
            _loudnessGain = loudness?.targetGain ?? 0.0;
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Equalizer'),
        actions: [
          Text('EQ', style: theme.textTheme.labelMedium),
          Switch(
            value: _equalizerEnabled,
            onChanged: (val) async {
              await ref.read(audioPlayerServiceProvider).equalizer?.setEnabled(val);
              setState(() => _equalizerEnabled = val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _params == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.equalizer_rounded,
                            size: 56, color: colorScheme.outlineVariant,),
                        const SizedBox(height: 16),
                        Text(
                          'Equalizer is only available on Android.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 24,),
                  children: [
                    // ── EQ Band Sliders ─────────────────────────────────
                    Text('Frequency Bands',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),),
                    const SizedBox(height: 16),
                    ..._params!.bands.map((band) => _BandSlider(
                          band: band,
                          minDecibels: _params!.minDecibels,
                          maxDecibels: _params!.maxDecibels,
                          enabled: _equalizerEnabled,
                          onChanged: (gain) async {
                            await band.setGain(gain);
                          },
                        ),),

                    const Divider(height: 40),

                    // ── Loudness Enhancer ────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text('Loudness Enhancer',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                letterSpacing: 0.8,
                              ),),
                        ),
                        Switch(
                          value: _loudnessEnabled,
                          onChanged: (val) async {
                            await ref.read(audioPlayerServiceProvider).loudnessEnhancer?.setEnabled(val);
                            setState(() => _loudnessEnabled = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded, size: 20),
                        Expanded(
                          child: Slider(
                            value: _loudnessGain.clamp(0.0, 1000.0),
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            label:
                                '${(_loudnessGain / 10).toStringAsFixed(0)} dB',
                            onChanged: _loudnessEnabled
                                ? (val) async {
                                    await ref.read(audioPlayerServiceProvider).loudnessEnhancer?.setTargetGain(val);
                                    setState(() => _loudnessGain = val);
                                  }
                                : null,
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, size: 20),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Reset button ─────────────────────────────────────
                    OutlinedButton.icon(
                      onPressed: () async {
                        final service = ref.read(audioPlayerServiceProvider);
                        for (final band in _params!.bands) {
                          await band.setGain(0.0);
                        }
                        await service.loudnessEnhancer?.setTargetGain(0);
                        setState(() => _loudnessGain = 0.0);
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset to Flat'),
                    ),
                  ],
                ),
    );
  }
}

class _BandSlider extends StatefulWidget {
  const _BandSlider({
    required this.band,
    required this.minDecibels,
    required this.maxDecibels,
    required this.enabled,
    required this.onChanged,
  });
  final AndroidEqualizerBand band;
  final double minDecibels;
  final double maxDecibels;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  State<_BandSlider> createState() => _BandSliderState();
}

class _BandSliderState extends State<_BandSlider> {
  late double _gain;

  @override
  void initState() {
    super.initState();
    _gain = widget.band.gain;
  }

  String _formatHz(double hz) {
    if (hz >= 1000) return '${(hz / 1000).toStringAsFixed(0)}k';
    return hz.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              _formatHz(widget.band.centerFrequency),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: _gain.clamp(
                widget.minDecibels,
                widget.maxDecibels,
              ),
              min: widget.minDecibels,
              max: widget.maxDecibels,
              label: '${_gain.toStringAsFixed(1)} dB',
              onChanged: widget.enabled
                  ? (val) {
                      setState(() => _gain = val);
                      widget.onChanged(val);
                    }
                  : null,
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              _gain.toStringAsFixed(1),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
