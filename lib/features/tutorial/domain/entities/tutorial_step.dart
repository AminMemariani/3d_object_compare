import 'package:equatable/equatable.dart';

/// Represents a single step in a tutorial
class TutorialStep extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imagePath;
  final TutorialStepType type;
  final TutorialStepPosition position;
  final List<String> actions;
  final Map<String, dynamic> metadata;
  final bool isCompleted;
  final bool isSkippable;
  final Duration? timeout;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    required this.type,
    required this.position,
    this.actions = const [],
    this.metadata = const {},
    this.isCompleted = false,
    this.isSkippable = true,
    this.timeout,
  });

  TutorialStep copyWith({
    String? id,
    String? title,
    String? description,
    String? imagePath,
    TutorialStepType? type,
    TutorialStepPosition? position,
    List<String>? actions,
    Map<String, dynamic>? metadata,
    bool? isCompleted,
    bool? isSkippable,
    Duration? timeout,
  }) {
    return TutorialStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      position: position ?? this.position,
      actions: actions ?? this.actions,
      metadata: metadata ?? this.metadata,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkippable: isSkippable ?? this.isSkippable,
      timeout: timeout ?? this.timeout,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imagePath,
    type,
    position,
    actions,
    metadata,
    isCompleted,
    isSkippable,
    timeout,
  ];
}

/// Types of tutorial steps
enum TutorialStepType {
  introduction,
  instruction,
  demonstration,
  interaction,
  completion,
  tip,
  warning,
}

/// Position of tutorial step overlay
enum TutorialStepPosition {
  top,
  bottom,
  left,
  right,
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  custom,
}

/// Tutorial session containing multiple steps
class TutorialSession extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<TutorialStep> steps;
  final int currentStepIndex;
  final bool isCompleted;
  final bool isSkipped;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> progress;

  const TutorialSession({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isSkipped = false,
    required this.startedAt,
    this.completedAt,
    this.progress = const {},
  });

  TutorialSession copyWith({
    String? id,
    String? name,
    String? description,
    List<TutorialStep>? steps,
    int? currentStepIndex,
    bool? isCompleted,
    bool? isSkipped,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? progress,
  }) {
    return TutorialSession(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
    );
  }

  TutorialStep? get currentStep {
    if (currentStepIndex >= 0 && currentStepIndex < steps.length) {
      return steps[currentStepIndex];
    }
    return null;
  }

  bool get hasNextStep => currentStepIndex < steps.length - 1;
  bool get hasPreviousStep => currentStepIndex > 0;
  double get progressPercentage =>
      steps.isEmpty ? 0.0 : (currentStepIndex + 1) / steps.length;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    steps,
    currentStepIndex,
    isCompleted,
    isSkipped,
    startedAt,
    completedAt,
    progress,
  ];
}

/// Tutorial configuration
class TutorialConfig extends Equatable {
  final bool autoStart;
  final bool showProgress;
  final bool allowSkipping;
  final bool showHints;
  final Duration stepTimeout;
  final String theme;
  final Map<String, dynamic> customizations;

  const TutorialConfig({
    this.autoStart = false,
    this.showProgress = true,
    this.allowSkipping = true,
    this.showHints = true,
    this.stepTimeout = const Duration(seconds: 30),
    this.theme = 'default',
    this.customizations = const {},
  });

  TutorialConfig copyWith({
    bool? autoStart,
    bool? showProgress,
    bool? allowSkipping,
    bool? showHints,
    Duration? stepTimeout,
    String? theme,
    Map<String, dynamic>? customizations,
  }) {
    return TutorialConfig(
      autoStart: autoStart ?? this.autoStart,
      showProgress: showProgress ?? this.showProgress,
      allowSkipping: allowSkipping ?? this.allowSkipping,
      showHints: showHints ?? this.showHints,
      stepTimeout: stepTimeout ?? this.stepTimeout,
      theme: theme ?? this.theme,
      customizations: customizations ?? this.customizations,
    );
  }

  @override
  List<Object?> get props => [
    autoStart,
    showProgress,
    allowSkipping,
    showHints,
    stepTimeout,
    theme,
    customizations,
  ];
}
