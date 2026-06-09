import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';

// ---------------------------------------------------------------------------
// Logic Helpers
// ---------------------------------------------------------------------------

class ReverseResult {
  final int reversed;
  final int difference;

  ReverseResult({required this.reversed, required this.difference});
}

ReverseResult computeReverseDifference(int number) {
  final reversedStr = number.toString().split('').reversed.join();
  final reversedNum = int.tryParse(reversedStr) ?? 0;
  final difference = (number - reversedNum).abs();
  return ReverseResult(reversed: reversedNum, difference: difference);
}

String fizzBuzz(int n) {
  if (n == 0) return '';
  if (n % 15 == 0) return 'FizzBuzz';
  if (n % 3 == 0) return 'Fizz';
  if (n % 5 == 0) return 'Buzz';
  return '$n';
}

List<int> fibonacciUntil(int max) {
  if (max < 0) return [];

  List<int> result = [0];

  if (max == 0) return result;

  int a = 0;
  int b = 1;

  while (b <= max) {
    result.add(b);

    int next = a + b;
    a = b;
    b = next;
  }

  return result;
}

List<String> fibonacciFizzBuzz(int max) {
  final fibs = fibonacciUntil(max);

  return fibs.map((n) {
    if (n == 0) return '0';
    return fizzBuzz(n);
  }).toList();
}

/// Entry page for the number reversal feature.
class NumberPage extends StatefulWidget {
  const NumberPage({super.key});

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _fizzBuzzController = TextEditingController();

  bool _isLoading = false;
  int? _original;
  int? _reversed;
  int? _difference;
  String? _errorMessage;
  List<String> _fizzBuzzItems = [];

  @override
  void dispose() {
    _controller.dispose();
    _fizzBuzzController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _original = null;
        _reversed = null;
        _difference = null;
      });

      // Simulate a slight delay for UX (optional, but keeps the original feel)
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      final inputStr = _controller.text.trim();
      final number = int.tryParse(inputStr);

      if (number == null || number < 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid number format.';
        });
        return;
      }

      final result = computeReverseDifference(number);

      setState(() {
        _isLoading = false;
        _original = number;
        _reversed = result.reversed;
        _difference = result.difference;
      });
    }
  }

  void _reset() {
    _controller.clear();
    _formKey.currentState?.reset();
    setState(() {
      _isLoading = false;
      _original = null;
      _reversed = null;
      _difference = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'LogicLab',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderSection(textTheme: textTheme, colorScheme: colorScheme),
                  const SizedBox(height: 40),
                  _InputCard(
                    formKey: _formKey,
                    controller: _controller,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: 20),
                  _SubmitButton(
                    onSubmit: _submit,
                    colorScheme: colorScheme,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),
                  _FizzBuzzSection(
                    controller: _fizzBuzzController,
                    items: _fizzBuzzItems,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onChanged: (value) {
                      final n = int.tryParse(value.trim());
                      setState(() {
                        if (n == null || n <= 0) {
                          _fizzBuzzItems = [];
                        } else {
                          final cap = n.clamp(1, 100);
                          _fizzBuzzItems = List.generate(
                            cap,
                            (i) => fizzBuzz(i + 1),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _buildResultArea(colorScheme, textTheme),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultArea(ColorScheme colorScheme, TextTheme textTheme) {
    if (_isLoading) {
      return _LoadingIndicator(key: const ValueKey('loading'), colorScheme: colorScheme);
    }
    if (_errorMessage != null) {
      return _ErrorCard(
        key: ValueKey('error-$_errorMessage'),
        message: _errorMessage!,
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }
    if (_original != null && _reversed != null && _difference != null) {
      return _ResultCard(
        key: ValueKey('success-$_original'),
        original: _original!,
        reversed: _reversed!,
        difference: _difference!,
        colorScheme: colorScheme,
        textTheme: textTheme,
        onReset: _reset,
      );
    }
    return const SizedBox.shrink(key: ValueKey('initial'));
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.textTheme,
    required this.colorScheme,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number Reversal',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter any positive integer to compute the absolute difference between the number and its digit-reversal.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Input Card
// ---------------------------------------------------------------------------

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.formKey,
    required this.controller,
    required this.colorScheme,
    required this.textTheme,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: TextFormField(
            key: const Key('number_input_field'),
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              letterSpacing: 4,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: textTheme.displaySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
              border: InputBorder.none,
              errorStyle: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a number.';
              }
              return null;
            },
            onFieldSubmitted: (_) => onSubmit(),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Submit Button
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.onSubmit,
    required this.colorScheme,
    required this.isLoading,
  });

  final VoidCallback onSubmit;
  final ColorScheme colorScheme;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('submit_button'),
      onPressed: isLoading ? null : onSubmit,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: colorScheme.primary,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.onPrimary,
              ),
            )
          : const Text(
              'Calculate',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Result Card
// ---------------------------------------------------------------------------

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    super.key,
    required this.original,
    required this.reversed,
    required this.difference,
    required this.colorScheme,
    required this.textTheme,
    required this.onReset,
  });

  final int original;
  final int reversed;
  final int difference;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Result',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _ResultRow(
              label: 'Original',
              value: '$original',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            _ResultRow(
              label: 'Reversed',
              value: '$reversed',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            Divider(
              height: 32,
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Difference',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$difference',
                      style: textTheme.displaySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${fizzBuzz(difference)})',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            //
            // Text(
            //   'Fibonacci Sequence',
            //   style: textTheme.labelLarge?.copyWith(
            //     color: colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
            //     fontWeight: FontWeight.w700,
            //     letterSpacing: 1,
            //   ),
            // ),
            //
            // const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fibonacciFizzBuzz(difference).map((item) {
                final isFizzBuzz = item == 'FizzBuzz';
                final isFizz = item == 'Fizz';
                final isBuzz = item == 'Buzz';

                Color chipColor = colorScheme.onPrimaryContainer;

                if (isFizzBuzz) {
                  chipColor = Colors.purple;
                } else if (isFizz) {
                  chipColor = Colors.green;
                } else if (isBuzz) {
                  chipColor = Colors.green;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: chipColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item,
                    style: textTheme.labelMedium?.copyWith(
                      color: chipColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            TextButton.icon(
              key: const Key('reset_button'),
              onPressed: onReset,
              icon: Icon(Icons.refresh_rounded,
                  size: 18, color: colorScheme.onPrimaryContainer),
              label: Text(
                'Try another number',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Error Card
// ---------------------------------------------------------------------------

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.textTheme,
  });

  final String message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FizzBuzz Section
// ---------------------------------------------------------------------------

class _FizzBuzzSection extends StatelessWidget {
  const _FizzBuzzSection({
    required this.controller,
    required this.items,
    required this.colorScheme,
    required this.textTheme,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<String> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<String> onChanged;

  static Color _chipColor(String label) {
    if (label == 'FizzBuzz') return const Color(0xFF7C3AED); // purple
    if (label == 'Fizz') return const Color(0xFF16A34A);    // green
    if (label == 'Buzz') return const Color(0xFFEA580C);    // orange
    return const Color(0xFF64748B);                          // slate
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: false,
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FizzBuzz',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Div by 3 → Fizz  •  by 5 → Buzz  •  by both → FizzBuzz',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('fizzbuzz_input_field'),
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelText: 'Enter N (shows 1 … N)',
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _FizzBuzzChip(
                        index: i + 1,
                        label: items[i],
                        color: _chipColor(items[i]),
                        textTheme: textTheme,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FizzBuzzChip extends StatelessWidget {
  const _FizzBuzzChip({
    required this.index,
    required this.label,
    required this.color,
    required this.textTheme,
  });

  final int index;
  final String label;
  final Color color;
  final TextTheme textTheme;

  bool get _isWord => label == 'Fizz' || label == 'Buzz' || label == 'FizzBuzz';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _isWord ? 0.15 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: _isWord ? 0.5 : 0.2),
        ),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: _isWord ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
