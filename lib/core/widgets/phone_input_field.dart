import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class CountryPhoneInfo {
  final String code;
  final String nameFr;
  final String nameEn;
  final String dialCode;
  final String flag;
  final int nationalDigits;
  final String? mustStartWith;
  final String hint;

  const CountryPhoneInfo({
    required this.code,
    required this.nameFr,
    required this.nameEn,
    required this.dialCode,
    required this.flag,
    required this.nationalDigits,
    this.mustStartWith,
    required this.hint,
  });
}

const List<CountryPhoneInfo> kSupportedCountries = [
  CountryPhoneInfo(
    code: 'BJ',
    nameFr: 'Bénin',
    nameEn: 'Benin',
    dialCode: '+229',
    flag: '🇧🇯',
    nationalDigits: 10,
    mustStartWith: '01',
    hint: '01 97 12 34 56',
  ),
  CountryPhoneInfo(
    code: 'TG',
    nameFr: 'Togo',
    nameEn: 'Togo',
    dialCode: '+228',
    flag: '🇹🇬',
    nationalDigits: 8,
    hint: '90 12 34 56',
  ),
  CountryPhoneInfo(
    code: 'CI',
    nameFr: "Côte d'Ivoire",
    nameEn: 'Ivory Coast',
    dialCode: '+225',
    flag: '🇨🇮',
    nationalDigits: 10,
    hint: '07 12 34 56 78',
  ),
  CountryPhoneInfo(
    code: 'SN',
    nameFr: 'Sénégal',
    nameEn: 'Senegal',
    dialCode: '+221',
    flag: '🇸🇳',
    nationalDigits: 9,
    hint: '77 123 45 67',
  ),
  CountryPhoneInfo(
    code: 'NG',
    nameFr: 'Nigéria',
    nameEn: 'Nigeria',
    dialCode: '+234',
    flag: '🇳🇬',
    nationalDigits: 10,
    hint: '802 123 4567',
  ),
  CountryPhoneInfo(
    code: 'BF',
    nameFr: 'Burkina Faso',
    nameEn: 'Burkina Faso',
    dialCode: '+226',
    flag: '🇧🇫',
    nationalDigits: 8,
    hint: '70 12 34 56',
  ),
  CountryPhoneInfo(
    code: 'NE',
    nameFr: 'Niger',
    nameEn: 'Niger',
    dialCode: '+227',
    flag: '🇳🇪',
    nationalDigits: 8,
    hint: '90 12 34 56',
  ),
  CountryPhoneInfo(
    code: 'CM',
    nameFr: 'Cameroun',
    nameEn: 'Cameroon',
    dialCode: '+237',
    flag: '🇨🇲',
    nationalDigits: 9,
    hint: '6 71 23 45 67',
  ),
  CountryPhoneInfo(
    code: 'FR',
    nameFr: 'France',
    nameEn: 'France',
    dialCode: '+33',
    flag: '🇫🇷',
    nationalDigits: 9,
    hint: '6 12 34 56 78',
  ),
];

/// Formats phone digits into spaced groups (e.g. 01 97 12 34 56)
class PhoneNumberFormatter extends TextInputFormatter {
  final int maxDigits;
  PhoneNumberFormatter({required this.maxDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 2 == 0) {
        buffer.write(' ');
      }
      buffer.write(limitedDigits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<CountryPhoneInfo>? onCountryChanged;
  final String? Function(String?)? customValidator;
  final bool autofocus;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.onCountryChanged,
    this.customValidator,
    this.autofocus = false,
  });

  @override
  State<PhoneInputField> createState() => PhoneInputFieldState();
}

class PhoneInputFieldState extends State<PhoneInputField> {
  CountryPhoneInfo _selectedCountry = kSupportedCountries.first; // Bénin par défaut

  CountryPhoneInfo get selectedCountry => _selectedCountry;

  /// Returns full international phone number with country code, e.g. "+229 01 97 12 34 56"
  String get fullPhoneNumber {
    final digits = widget.controller.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return '${_selectedCountry.dialCode} ${widget.controller.text.trim()}';
  }

  @override
  void initState() {
    super.initState();
    _parseInitialText();
  }

  void _parseInitialText() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) return;

    for (final country in kSupportedCountries) {
      if (text.startsWith(country.dialCode)) {
        _selectedCountry = country;
        final remainder = text.substring(country.dialCode.length).trim();
        widget.controller.text = remainder;
        break;
      }
    }
  }

  void _showCountryPicker(BuildContext context, bool isFr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = kSupportedCountries.where((c) {
              final name = isFr ? c.nameFr.toLowerCase() : c.nameEn.toLowerCase();
              final q = searchQuery.toLowerCase();
              return name.contains(q) || c.dialCode.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isFr ? 'Sélectionnez un pays' : 'Select a country',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: isFr ? 'Rechercher un pays...' : 'Search country...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() => searchQuery = val);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, idx) {
                        final country = filtered[idx];
                        final isSelected = country.code == _selectedCountry.code;
                        return ListTile(
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            isFr ? country.nameFr : country.nameEn,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                country.dialCode,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 20),
                              ],
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              _selectedCountry = country;
                            });
                            widget.onCountryChanged?.call(country);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String? _validatePhone(String? val, bool isFr) {
    if (widget.customValidator != null) {
      final customRes = widget.customValidator!(val);
      if (customRes != null) return customRes;
    }

    if (val == null || val.trim().isEmpty) {
      return isFr ? 'Le numéro de téléphone est requis' : 'Phone number is required';
    }

    final digits = val.replaceAll(RegExp(r'\D'), '');

    // Validation spécifique pour le Bénin (+229) : 10 chiffres commençant par 01
    if (_selectedCountry.code == 'BJ') {
      if (digits.length == 8) {
        return isFr
            ? 'Le Bénin est à 10 chiffres (ajoutez 01 au début)'
            : 'Benin has 10 digits (add 01 at start)';
      }
      if (!digits.startsWith('01')) {
        return isFr
            ? 'Le numéro béninois doit commencer par 01 (ex: 01 97 12 34 56)'
            : 'Benin phone must start with 01 (e.g. 01 97 12 34 56)';
      }
      if (digits.length < 10) {
        return isFr
            ? 'Numéro incomplet (${digits.length}/10 chiffres)'
            : 'Incomplete number (${digits.length}/10 digits)';
      }
      if (digits.length > 10) {
        return isFr
            ? 'Numéro trop long (${digits.length}/10 chiffres)'
            : 'Number too long (${digits.length}/10 digits)';
      }
      return null;
    }

    // Validation pour les autres pays
    if (digits.length < _selectedCountry.nationalDigits) {
      return isFr
          ? 'Numéro incomplet (${digits.length}/${_selectedCountry.nationalDigits} chiffres)'
          : 'Incomplete number (${digits.length}/${_selectedCountry.nationalDigits} digits)';
    }

    if (digits.length > _selectedCountry.nationalDigits && _selectedCountry.code != 'FR' && _selectedCountry.code != 'NG') {
      return isFr
          ? 'Numéro trop long (${digits.length}/${_selectedCountry.nationalDigits} chiffres)'
          : 'Number too long (${digits.length}/${_selectedCountry.nationalDigits} digits)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isFr = lang.isFrench;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFr ? 'Numéro de téléphone' : 'Phone Number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (_selectedCountry.code == 'BJ')
              Text(
                isFr ? 'Format Bénin (10 chiffres)' : 'Benin format (10 digits)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2563EB),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          autofocus: widget.autofocus,
          inputFormatters: [
            PhoneNumberFormatter(
              maxDigits: _selectedCountry.code == 'BJ' ? 10 : 12,
            ),
          ],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: _selectedCountry.hint,
            hintStyle: const TextStyle(
              color: Color(0xFFCBD5E1),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: InkWell(
              onTap: () => _showCountryPicker(context, isFr),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.dialCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF64748B),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
          ),
          validator: (val) => _validatePhone(val, isFr),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
