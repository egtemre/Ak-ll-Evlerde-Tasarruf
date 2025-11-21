class FeatureVector {
  final int hour;
  final int dayOfWeek;
  final int month;
  final int isWeekend;
  final int season;
  final int timeOfDay;
  final double prevHourPower;
  final double prev2HourPower;
  final double prevDayPower;
  final double rollingMean24h;
  final double rollingStd24h;
  final double temperature;
  final double humidity;
  final int tempCategory;
  final double prevHourTemp;
  final double subMetering1;
  final double subMetering2;
  final double subMetering3;
  final double voltage;
  final double globalIntensity;

  FeatureVector({
    required this.hour,
    required this.dayOfWeek,
    required this.month,
    required this.isWeekend,
    required this.season,
    required this.timeOfDay,
    required this.prevHourPower,
    required this.prev2HourPower,
    required this.prevDayPower,
    required this.rollingMean24h,
    required this.rollingStd24h,
    required this.temperature,
    required this.humidity,
    required this.tempCategory,
    required this.prevHourTemp,
    required this.subMetering1,
    required this.subMetering2,
    required this.subMetering3,
    required this.voltage,
    required this.globalIntensity,
  });

  Map<String, dynamic> toJson() {
    return {
      'Hour': hour,
      'DayOfWeek': dayOfWeek,
      'Month': month,
      'IsWeekend': isWeekend,
      'Season': season,
      'TimeOfDay': timeOfDay,
      'Prev_Hour_Power': prevHourPower,
      'Prev_2Hour_Power': prev2HourPower,
      'Prev_Day_Power': prevDayPower,
      'Rolling_Mean_24h': rollingMean24h,
      'Rolling_Std_24h': rollingStd24h,
      'Temperature': temperature,
      'Humidity': humidity,
      'Temp_Category': tempCategory,
      'Prev_Hour_Temp': prevHourTemp,
      'Sub_metering_1': subMetering1,
      'Sub_metering_2': subMetering2,
      'Sub_metering_3': subMetering3,
      'Voltage': voltage,
      'Global_intensity': globalIntensity,
    };
  }

  factory FeatureVector.fromJson(Map<String, dynamic> json) {
    return FeatureVector(
      hour: json['Hour'] as int,
      dayOfWeek: json['DayOfWeek'] as int,
      month: json['Month'] as int,
      isWeekend: json['IsWeekend'] as int,
      season: json['Season'] as int,
      timeOfDay: json['TimeOfDay'] as int,
      prevHourPower: (json['Prev_Hour_Power'] as num).toDouble(),
      prev2HourPower: (json['Prev_2Hour_Power'] as num).toDouble(),
      prevDayPower: (json['Prev_Day_Power'] as num).toDouble(),
      rollingMean24h: (json['Rolling_Mean_24h'] as num).toDouble(),
      rollingStd24h: (json['Rolling_Std_24h'] as num).toDouble(),
      temperature: (json['Temperature'] as num).toDouble(),
      humidity: (json['Humidity'] as num).toDouble(),
      tempCategory: json['Temp_Category'] as int,
      prevHourTemp: (json['Prev_Hour_Temp'] as num).toDouble(),
      subMetering1: (json['Sub_metering_1'] as num).toDouble(),
      subMetering2: (json['Sub_metering_2'] as num).toDouble(),
      subMetering3: (json['Sub_metering_3'] as num).toDouble(),
      voltage: (json['Voltage'] as num).toDouble(),
      globalIntensity: (json['Global_intensity'] as num).toDouble(),
    );
  }
}
