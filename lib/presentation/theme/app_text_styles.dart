import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static const subtitle = TextStyle(fontSize: 14, color: AppColors.textGrey);
  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark);
  static const cnpj = TextStyle(fontSize: 12.5, color: AppColors.textGrey);
}
