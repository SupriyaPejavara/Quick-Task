class AppRegexHelper {
  static bool isEmailValid(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
  }

  static bool hasMinLength(String password) {
    return RegExp(r'^(?=.{6,})').hasMatch(password);
  }
}
