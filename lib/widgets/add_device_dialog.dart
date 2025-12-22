import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  DeviceType _selectedType = DeviceType.light;

  // Model bazlı tüketim veritabanı (Watt cinsinden)
  static const Map<String, Map<String, double>> _deviceDatabase = {
    // Aydınlatma
    'LED Ampul': {'consumption': 10},
    'Akkor Ampul': {'consumption': 60},
    'Floresan': {'consumption': 40},
    'Halogen': {'consumption': 50},
    'Avize': {'consumption': 150},

    // Klima
    'Split Klima 9000 BTU': {'consumption': 900},
    'Split Klima 12000 BTU': {'consumption': 1200},
    'Split Klima 18000 BTU': {'consumption': 1600},
    'Split Klima 24000 BTU': {'consumption': 2000},
    'Inverter Klima': {'consumption': 1000},

    // Beyaz Eşya
    'Buzdolabı A+': {'consumption': 100},
    'Buzdolabı A++': {'consumption': 80},
    'Çamaşır Makinesi': {'consumption': 2000},
    'Bulaşık Makinesi': {'consumption': 1800},
    'Kurutma Makinesi': {'consumption': 2500},
    'Fırın': {'consumption': 2000},

    // Elektronik
    'LED TV 32"': {'consumption': 50},
    'LED TV 43"': {'consumption': 80},
    'LED TV 55"': {'consumption': 120},
    'OLED TV 55"': {'consumption': 150},
    'Bilgisayar': {'consumption': 300},
    'Laptop': {'consumption': 65},
    'Oyun Konsolu': {'consumption': 150},

    // Diğer
    'Elektrikli Süpürge': {'consumption': 1500},
    'Ütü': {'consumption': 2000},
    'Mikrodalga': {'consumption': 1200},
    'Kahve Makinesi': {'consumption': 1000},
    'Su Isıtıcısı': {'consumption': 2200},
  };

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  double _calculateDailyConsumption(String model, DeviceType type) {
    // Model eşleşmesi ara
    double watt = 0;

    // Tam eşleşme
    if (_deviceDatabase.containsKey(model)) {
      watt = _deviceDatabase[model]!['consumption']!;
    } else {
      // Kısmi eşleşme ara
      for (var entry in _deviceDatabase.entries) {
        if (model.toLowerCase().contains(entry.key.toLowerCase()) ||
            entry.key.toLowerCase().contains(model.toLowerCase())) {
          watt = entry.value['consumption']!;
          break;
        }
      }
    }

    // Eğer bulunamadıysa, cihaz tipine göre varsayılan değer
    if (watt == 0) {
      switch (type) {
        case DeviceType.light:
          watt = 15;
          break;
        case DeviceType.airConditioner:
          watt = 1500;
          break;
        case DeviceType.refrigerator:
          watt = 120;
          break;
        case DeviceType.tv:
          watt = 100;
          break;
        case DeviceType.washingMachine:
          watt = 2000;
          break;
        case DeviceType.other:
          watt = 100;
          break;
      }
    }

    // Günlük kullanım saatine göre kWh hesapla
    double dailyHours;
    switch (type) {
      case DeviceType.light:
        dailyHours = 8;
        break;
      case DeviceType.airConditioner:
        dailyHours = 8;
        break;
      case DeviceType.refrigerator:
        dailyHours = 24; // Sürekli açık
        break;
      case DeviceType.tv:
        dailyHours = 5;
        break;
      case DeviceType.washingMachine:
        dailyHours = 1;
        break;
      case DeviceType.other:
        dailyHours = 4;
        break;
    }

    // kWh = (Watt × Saat) / 1000
    return (watt * dailyHours) / 1000;
  }

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      final dailyConsumption = _calculateDailyConsumption(
        _modelController.text.trim(),
        _selectedType,
      );

      appState.addDevice(
        name: _nameController.text.trim(),
        type: _selectedType,
        model: _modelController.text.trim(),
        consumption: dailyConsumption,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_nameController.text} eklendi (${dailyConsumption.toStringAsFixed(2)} kWh/gün)',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Yeni Cihaz Ekle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Cihaz Adı
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Cihaz Adı',
                    hintText: 'Örn: Salon Lambası',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cihaz adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Cihaz Tipi
                DropdownButtonFormField<DeviceType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Cihaz Tipi',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: DeviceType.light,
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline,
                              color: Colors.yellow[700]),
                          const SizedBox(width: 12),
                          const Text('Aydınlatma'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.airConditioner,
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          const Text('Klima'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.refrigerator,
                      child: Row(
                        children: [
                          Icon(Icons.kitchen, color: Colors.teal[700]),
                          const SizedBox(width: 12),
                          const Text('Buzdolabı'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.tv,
                      child: Row(
                        children: [
                          Icon(Icons.tv, color: Colors.purple[700]),
                          const SizedBox(width: 12),
                          const Text('Televizyon'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.washingMachine,
                      child: Row(
                        children: [
                          Icon(Icons.local_laundry_service,
                              color: Colors.indigo[700]),
                          const SizedBox(width: 12),
                          const Text('Çamaşır Makinesi'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: DeviceType.other,
                      child: Row(
                        children: [
                          Icon(Icons.devices_other, color: Colors.grey[700]),
                          const SizedBox(width: 12),
                          const Text('Diğer'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Model/Marka
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: 'Model/Marka',
                    hintText: 'Örn: LED Ampul, Split Klima 12000 BTU',
                    prefixIcon: const Icon(Icons.info_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Sistem otomatik tüketim hesaplayacak',
                    helperMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Model bilgisi gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Bilgi kutusu
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sistem cihazınızın modelini tanıyarak günlük enerji tüketimini otomatik hesaplayacak.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('İptal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ekle'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
