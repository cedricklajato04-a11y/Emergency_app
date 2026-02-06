class FallbackNumbers {
  static const String police = "911";
  static const String hospital = "911";
  static const String fireStation = "911";

  static String getByType(String type) {
    switch (type) {
      case "Police":
        return police;
      case "Hospital":
        return hospital;
      case "Fire Station":
        return fireStation;
      default:
        return "911";
    }
  }
}
