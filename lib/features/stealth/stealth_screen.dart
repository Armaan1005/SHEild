import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../state/providers.dart';

class StealthScreen extends ConsumerStatefulWidget {
  const StealthScreen({super.key});

  @override
  ConsumerState<StealthScreen> createState() => _StealthScreenState();
}

class _StealthScreenState extends ConsumerState<StealthScreen> {
  String _display = '0';
  String _pinBuffer = '';
  bool _newNumber = true;

  void _onDigit(String digit) {
    setState(() {
      if (_newNumber) {
        _display = digit;
        _newNumber = false;
      } else {
        _display += digit;
      }
      _pinBuffer += digit;
    });
  }

  void _onOperator(String op) {
    setState(() {
      _newNumber = true;
      if (op == '=') {
        // Check PIN
        final settings = ref.read(settingsProvider);
        if (_pinBuffer == settings.stealthPin ||
            _pinBuffer.contains(settings.stealthPin)) {
          // Unlock - go to home
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
        _display = _evaluateSimple();
        _pinBuffer = '';
      } else {
        _display += ' $op ';
        _pinBuffer = '';
      }
    });
  }

  String _evaluateSimple() {
    try {
      // Simple evaluation for display
      final parts = _display.replaceAll(' ', '').split(RegExp(r'[+\-×÷]'));
      if (parts.isNotEmpty) {
        return _display;
      }
    } catch (_) {}
    return _display;
  }

  void _onClear() {
    setState(() {
      _display = '0';
      _pinBuffer = '';
      _newNumber = true;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _newNumber = true;
      }
      if (_pinBuffer.isNotEmpty) {
        _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calculator',
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Text(
                _display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Buttons
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildRow(['C', '⌫', '%', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '-']),
                  _buildRow(['1', '2', '3', '+']),
                  _buildRow(['0', '.', '', '=']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) {
          if (btn.isEmpty) return const Expanded(child: SizedBox());

          final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
          final isFunction = ['C', '⌫', '%'].contains(btn);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (btn == 'C') {
                      _onClear();
                    } else if (btn == '⌫') {
                      _onBackspace();
                    } else if (btn == '%') {
                      // do nothing for now
                    } else if (isOperator) {
                      _onOperator(btn == '÷'
                          ? '/'
                          : btn == '×'
                              ? '*'
                              : btn);
                    } else {
                      _onDigit(btn);
                    }
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOperator
                          ? AppColors.primary
                          : isFunction
                              ? const Color(0xFF333333)
                              : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      btn,
                      style: TextStyle(
                        color: isFunction ? Colors.white : Colors.white,
                        fontSize: btn == '⌫' ? 22 : 28,
                        fontWeight:
                            isOperator ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
