extension StringValidation on String {
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(this);
  }

  bool get isValidUsername {
    return isNotEmpty && length >= 3;
  }

  bool get isValidName {
    return isNotEmpty && length >= 2;
  }
}
