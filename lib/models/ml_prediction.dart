class MLPrediction {
  final double prediction;
  final List<double>? proba;

  MLPrediction({
    required this.prediction,
    this.proba,
  });

  factory MLPrediction.fromJson(Map<String, dynamic> json) {
    return MLPrediction(
      prediction: (json['prediction'] as num).toDouble(),
      proba: json['proba'] != null
          ? List<double>.from(
              (json['proba'] as List).map((x) => (x as num).toDouble()),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'proba': proba,
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

  ModelMeta({
    required this.modelType,
    this.nFeatures,
    this.featureOrder,
    this.nEstimators,
  });

  factory ModelMeta.fromJson(Map<String, dynamic> json) {
    return ModelMeta(
      modelType: json['model_type'] as String,
      nFeatures: json['n_features'] as int?,
      featureOrder: json['feature_order'] != null
          ? List<String>.from(json['feature_order'] as List)
          : null,
      nEstimators: json['n_estimators'] as int?,
    );
  }
}
