import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool compact;
  final Color? textColor;

  const LanguageSelector({
    super.key,
    this.compact = false,
    this.textColor,
  }) : assert(compact != null); // ignore: unnecessary_null_comparison

  @override
  Widget build(BuildContext context) {
    LocaleProvider? localeProvider;
    try {
      localeProvider = Provider.of<LocaleProvider>(context);
    } catch (_) {
      // Fallback for tests or contexts without provider
    }
    final isTamil = localeProvider?.isTamil ?? false;

    if (compact) {
      return InkWell(
        onTap: () => localeProvider?.toggleLanguage(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF5B21B6).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF5B21B6).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: 16,
                color: Color(0xFF5B21B6),
              ),
              const SizedBox(width: 4),
              Text(
                isTamil ? 'தமிழ்' : 'EN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? const Color(0xFF5B21B6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context: context,
            label: 'English',
            isSelected: !isTamil,
            onTap: () => localeProvider?.setLocale(const Locale('en')),
          ),
          const SizedBox(width: 4),
          _buildLanguageOption(
            context: context,
            label: 'தமிழ்',
            isSelected: isTamil,
            onTap: () => localeProvider?.setLocale(const Locale('ta')),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B21B6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
