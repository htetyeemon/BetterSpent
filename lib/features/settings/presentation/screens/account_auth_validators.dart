String? validateEmail(String value) {
  final email = value.trim();
  if (email.isEmpty) return 'Email is required';
  const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  if (!RegExp(pattern).hasMatch(email)) return 'Enter a valid email';
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'At least 8 characters';
  final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
  final hasNumber = RegExp(r'\d').hasMatch(value);
  if (!hasLetter || !hasNumber) return 'Use letters and numbers';
  return null;
}

String? validateUsername(String value) {
  final username = value.trim();
  if (username.isEmpty) return 'Username is required';
  if (username.length < 3 || username.length > 24) {
    return 'Username must be 3-24 characters';
  }
  if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(username)) {
    return 'Only letters, numbers, and underscore are allowed';
  }
  return null;
}

String friendlyAuthError(String raw) {
  final msg = raw.toLowerCase();
  if (msg.contains('invalid-credential')) return 'Invalid email or password.';
  if (msg.contains('user-not-found')) {
    return 'No account found for this email. Please create an account first.';
  }
  if (msg.contains('wrong-password')) return 'Invalid email or password.';
  if (msg.contains('email-already-in-use')) {
    return 'Email already in use. Please sign in instead.';
  }
  if (msg.contains('weak-password')) return 'Password is too weak.';
  if (msg.contains('invalid-email')) return 'Please enter a valid email.';
  if (msg.contains('too-many-requests')) return 'Too many attempts. Try again later.';
  return 'Authentication failed. Please try again.';
}

String friendlyDeleteError(String raw) {
  final msg = raw.toLowerCase();
  if (msg.contains('requires-recent-login')) {
    return 'For security, sign in again and retry deleting the account.';
  }
  return 'Failed to delete account. Please try again.';
}
