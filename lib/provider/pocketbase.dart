import 'dart:io';
import 'package:pocketbase/pocketbase.dart';

Future<void> updateAvatar(File avatarFile, PocketBase pb) async {
  try {
    // Get the current user
    final user = pb.collection('users');
    if (!pb.authStore.isValid) {
      return;
    }

    // Update the user's avatar
    await user.update(
      pb.authStore.model.data['id'],
    );

    // Refresh the user data
    await pb.collection('users').authRefresh();
  } catch (error) {
  }
}
