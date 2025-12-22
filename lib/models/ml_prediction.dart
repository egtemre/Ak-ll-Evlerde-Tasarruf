class MLPrediction {
  final double prediction;
  final List<double>? proba;
  final DateTime? timestamp;

  MLPrediction({
    required this.prediction,
    this.proba,
    this.timestamp,
  });

  factory MLPrediction.fromJson(Map<String, dynamic> json) {
    return MLPrediction(
      prediction: (json['prediction'] as num).toDouble(),
      proba: json['proba'] != null
          ? List<double>.from(
              (json['proba'] as List).map((x) => (x as num).toDouble()),
            )
          : null,
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'proba': proba,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class MLPredictionMany {
  final List<double> predictions;
  final List<List<double>>? proba;

  MLPredictionMany({
    required this.predictions,
    this.proba,
  });

  factory MLPredictionMany.fromJson(Map<String, dynamic> json) {
    return MLPredictionMany(
      predictions: List<double>.from(
        (json['prediction'] as List).map((x) => (x as num).toDouble()),
      ),
      proba: json['proba'] != null
          ? (json['proba'] as List)
              .map((x) => List<double>.from(
                    (x as List).map((y) => (y as num).toDouble()),
                  ))
              .toList()
          : null,
    );
  }
}

class ModelMeta {
  final String modelType;
  final int? nFeatures;
  final List<String>? featureOrder;
  final int? nEstimators;
  final String version;
  final String lastTrainedDate;

  ModelMeta({
    required this.modelType,
    this.nFeatures,
    this.featureOrder,
    this.nEstimators,
    this.version = '1.0.0',
    this.lastTrainedDate = '2024-01-01',
  });

  factory ModelMeta.fromJson(Map<String, dynamic> json) {
    return ModelMeta(
      modelType: json['model_type'] as String? ?? 'unknown',
      nFeatures: json['n_features'] as int?,
      featureOrder: json['feature_order'] != null
          ? List<String>.from(json['feature_order'] as List)
          : null,
      nEstimators: json['n_estimators'] as int?,
      version: json['version'] as String? ?? '1.0.0',
      lastTrainedDate: json['last_trained_date'] as String? ?? '2024-01-01',
    );
  }
}
