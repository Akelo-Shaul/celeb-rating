enum AwardType {
  timeSpent,
  celebrityEngagement,
  likes,
  comments,
  reposts,
  followers,
  posts,
  streak,
  special,
}

enum AwardTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  legendary,
}

enum PrivilegeType {
  dmCelebrity,
  videoCallCelebrity,
  exclusiveContent,
  meetAndGreet,
  backstagePass,
  vipAccess,
  earlyAccess,
  customBadge,
  prioritySupport,
  betaFeatures,
}

class Award {
  final String id;
  final String name;
  final String description;
  final AwardType type;
  final AwardTier tier;
  final int requiredPoints;
  final String? iconPath;
  final String? badgePath;
  final List<PrivilegeType> privileges;
  final Map<String, dynamic>? metadata;

  Award({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.requiredPoints,
    this.iconPath,
    this.badgePath,
    this.privileges = const [],
    this.metadata,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: AwardType.values.firstWhere(
        (e) => e.toString() == 'AwardType.${json['type']}',
      ),
      tier: AwardTier.values.firstWhere(
        (e) => e.toString() == 'AwardTier.${json['tier']}',
      ),
      requiredPoints: json['requiredPoints'],
      iconPath: json['iconPath'],
      badgePath: json['badgePath'],
      privileges: (json['privileges'] as List<dynamic>?)
          ?.map((e) => PrivilegeType.values.firstWhere(
                (p) => p.toString() == 'PrivilegeType.$e',
              ))
          .toList() ?? [],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'tier': tier.toString().split('.').last,
      'requiredPoints': requiredPoints,
      'iconPath': iconPath,
      'badgePath': badgePath,
      'privileges': privileges.map((e) => e.toString().split('.').last).toList(),
      'metadata': metadata,
    };
  }
}

class UserAchievement {
  final String id;
  final String userId;
  final String awardId;
  final DateTime earnedAt;
  final int pointsEarned;
  final bool isActive;
  final Map<String, dynamic>? progress;

  UserAchievement({
    required this.id,
    required this.userId,
    required this.awardId,
    required this.earnedAt,
    required this.pointsEarned,
    this.isActive = true,
    this.progress,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      userId: json['userId'],
      awardId: json['awardId'],
      earnedAt: DateTime.parse(json['earnedAt']),
      pointsEarned: json['pointsEarned'],
      isActive: json['isActive'] ?? true,
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'awardId': awardId,
      'earnedAt': earnedAt.toIso8601String(),
      'pointsEarned': pointsEarned,
      'isActive': isActive,
      'progress': progress,
    };
  }
}

class UserPrivilege {
  final String id;
  final String userId;
  final PrivilegeType type;
  final DateTime grantedAt;
  final DateTime? expiresAt;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  UserPrivilege({
    required this.id,
    required this.userId,
    required this.type,
    required this.grantedAt,
    this.expiresAt,
    this.isActive = true,
    this.metadata,
  });

  factory UserPrivilege.fromJson(Map<String, dynamic> json) {
    return UserPrivilege(
      id: json['id'],
      userId: json['userId'],
      type: PrivilegeType.values.firstWhere(
        (e) => e.toString() == 'PrivilegeType.${json['type']}',
      ),
      grantedAt: DateTime.parse(json['grantedAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'grantedAt': grantedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }
}

class UserRanking {
  final String userId;
  final int totalPoints;
  final int rank;
  final AwardTier currentTier;
  final List<String> activeAwards;
  final List<PrivilegeType> activePrivileges;
  final Map<AwardType, int> typePoints;
  final DateTime lastUpdated;

  UserRanking({
    required this.userId,
    required this.totalPoints,
    required this.rank,
    required this.currentTier,
    required this.activeAwards,
    required this.activePrivileges,
    required this.typePoints,
    required this.lastUpdated,
  });

  factory UserRanking.fromJson(Map<String, dynamic> json) {
    return UserRanking(
      userId: json['userId'],
      totalPoints: json['totalPoints'],
      rank: json['rank'],
      currentTier: AwardTier.values.firstWhere(
        (e) => e.toString() == 'AwardTier.${json['currentTier']}',
      ),
      activeAwards: List<String>.from(json['activeAwards']),
      activePrivileges: (json['activePrivileges'] as List<dynamic>)
          .map((e) => PrivilegeType.values.firstWhere(
                (p) => p.toString() == 'PrivilegeType.$e',
              ))
          .toList(),
      typePoints: Map<AwardType, int>.from(
        (json['typePoints'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            AwardType.values.firstWhere((e) => e.toString() == 'AwardType.$key'),
            value as int,
          ),
        ),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'rank': rank,
      'currentTier': currentTier.toString().split('.').last,
      'activeAwards': activeAwards,
      'activePrivileges': activePrivileges.map((e) => e.toString().split('.').last).toList(),
      'typePoints': typePoints.map((key, value) => MapEntry(key.toString().split('.').last, value)),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
} 