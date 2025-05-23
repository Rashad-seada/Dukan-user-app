import 'package:flutter/material.dart';
import 'package:dukan_user_app/features/language/domain/models/language_model.dart';

abstract class LanguageServiceInterface {
  bool setLTR(Locale locale);
  updateHeader(Locale locale, int? moduleId);
  Locale getLocaleFromSharedPref();
  setSelectedIndex(List<LanguageModel> languages, Locale locale);
  void saveLanguage(Locale locale);
  void saveCacheLanguage(Locale locale);
  Locale getCacheLocaleFromSharedPref();
}
