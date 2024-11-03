import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showError(BuildContext? context,
    {required String title, required String description}) {
  toastification.dismissAll();
  toastification.show(
    type: ToastificationType.error,
    style: ToastificationStyle.fillColored,
    title: Text(title),
    description: Text(description),
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 4),
    animationBuilder: (
      context,
      animation,
      alignment,
      child,
    ) {
      return ScaleTransition(
        scale: animation,
        child: child,
      );
    },
    boxShadow: lowModeShadow,
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}

void showSucces({required String title, required String description}) {
  toastification.dismissAll();
  toastification.show(
    type: ToastificationType.success,
    style: ToastificationStyle.minimal,
    title: Text(title),
    description: Text(description),
    alignment: Alignment.topLeft,
    autoCloseDuration: const Duration(seconds: 4),
    animationBuilder: (
      context,
      animation,
      alignment,
      child,
    ) {
      return ScaleTransition(
        scale: animation,
        child: child,
      );
    },
    boxShadow: lowModeShadow,
    showProgressBar: true,
    dragToClose: true,
    applyBlurEffect: true,
  );
}
