class LivenessVerification {
  final String userId;
  final bool isVerified;
  final double? confidenceScore;
  static const int requiredMovements = 1; // Changed from 2 to 3

  const LivenessVerification({
    required this.userId,
    this.isVerified = false,
    this.confidenceScore,
  });

  LivenessVerification copyWith({
    bool? isVerified,
    double? confidenceScore,
  }) {
    return LivenessVerification(
      userId: userId,
      isVerified: isVerified ?? this.isVerified,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }
}
