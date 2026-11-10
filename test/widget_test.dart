import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/app_color_theme.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/log_dimension.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/backup_repository.dart';
import 'package:wooden_mill_app/repositories/draft_repository.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';

class MockOrderRepository extends OrderRepository {
  bool saveCalled = false;
  OrderModel? savedOrder;

  @override
  Future<int> saveOrder(OrderModel order) async {
    saveCalled = true;
    savedOrder = order;
    return 42;
  }
}

class MockDraftRepository extends DraftRepository {
  DraftOrderData? currentDraft;

  @override
  Future<void> saveDraft(DraftOrderData draft) async {
    currentDraft = draft;
  }

  @override
  Future<DraftOrderData?> loadDraft() async {
    return currentDraft;
  }

  @override
  Future<void> clearDraft() async {
    currentDraft = null;
  }
}

void main() {
  group('VolumeCalculator Tests', () {
    test('calculateVolume performs business formula correctly', () {
      final volume = VolumeCalculator.calculateVolume(length: 12.0, girth: 8.0);
      expect(volume, equals(48.0));
    });

    test('calculateVolume returns zero for negative or zero parameters', () {
      expect(VolumeCalculator.calculateVolume(length: -10.0, girth: 5.0), equals(0.0));
      expect(VolumeCalculator.calculateVolume(length: 10.0, girth: 0.0), equals(0.0));
    });

    test('calculateLogPrice computes price correctly', () {
      final price = VolumeCalculator.calculateLogPrice(volume: 5.0, rate: 4800.0);
      expect(price, equals(24000.0));
    });
  });

  group('HomeController State Tests', () {
    late HomeController controller;
    late MockOrderRepository mockRepository;
    late MockDraftRepository mockDraftRepository;

    setUp(() {
      mockRepository = MockOrderRepository();
      mockDraftRepository = MockDraftRepository();
      controller = HomeController(
        repository: mockRepository,
        draftRepository: mockDraftRepository,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state has one log row', () {
      expect(controller.logs.length, equals(1));
      expect(controller.totalVolume, equals(0.0));
      expect(controller.subtotal, equals(0.0));
      expect(controller.finalPrice, equals(0.0));
    });

    test('adding and removing log rows respects bounds', () {
      for (int i = 0; i < 25; i++) {
        controller.addLog();
      }
      expect(controller.logs.length, equals(AppConstants.maxLogs));

      for (int i = 0; i < 25; i++) {
        controller.removeLogAt(0);
      }
      expect(controller.logs.length, equals(AppConstants.minLogs));
    });

    test('recalculates live values when log inputs change', () {
      final log = controller.logs.first;
      log.lengthController.text = '10.0';
      log.girthController.text = '4.0';
      
      expect(controller.totalVolume, equals(10.0));
      expect(controller.subtotal, equals(48000.0));
      expect(controller.finalPrice, equals(48000.0));

      controller.selectedWoodType = AppConstants.woodTypes.firstWhere((w) => w.name == 'Coconut');
      expect(controller.subtotal, equals(45000.0));
      expect(controller.finalPrice, equals(45000.0));
    });

    test('validates form inputs correctly', () {
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Enter the customer name'));

      controller.customerNameController.text = 'John Doe';
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Enter the phone number'));

      controller.phoneController.text = '12345';
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('must be exactly 10 digits'));

      controller.phoneController.text = '9876543210';
      expect(controller.validateForm(), isFalse);
      expect(controller.errorMessage, contains('Enter the length and girth'));

      controller.logs[0].lengthController.text = '10';
      controller.logs[0].girthController.text = '4';
      
      expect(controller.validateForm(), isTrue);
      expect(controller.errorMessage, isNull);
    });

    test('submitting order calls repository save and clears draft', () async {
      controller.customerNameController.text = 'Alice';
      controller.phoneController.text = '9876543210';
      controller.logs[0].lengthController.text = '10';
      controller.logs[0].girthController.text = '4';

      expect(controller.validateForm(), isTrue);

      final order = await controller.submitOrder();
      expect(order, isNotNull);
      expect(mockRepository.saveCalled, isTrue);
      expect(mockRepository.savedOrder?.customerName, equals('Alice'));
      expect(mockRepository.savedOrder?.finalPrice, equals(48000.0));
      expect(mockDraftRepository.currentDraft, isNull);
    });
  });

  group('ThemeController & Settings Tests', () {
    test('initial themeMode defaults to light, density to recommended, and colorTheme to plain', () {
      final themeController = ThemeController();
      expect(themeController.themeMode, equals(ThemeMode.light));
      expect(themeController.displayDensity, equals(AppDisplayDensity.recommended));
      expect(themeController.colorTheme, equals(AppColorTheme.plain));
    });

    test('setThemeMode, setDisplayDensity, and setColorTheme update state correctly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final themeController = ThemeController();

      await themeController.setThemeMode(ThemeMode.dark);
      expect(themeController.themeMode, equals(ThemeMode.dark));
      expect(themeController.isDarkMode, isTrue);

      await themeController.setDisplayDensity(AppDisplayDensity.large);
      expect(themeController.displayDensity, equals(AppDisplayDensity.large));
      expect(themeController.displayDensity.scaleFactor, equals(1.1));

      await themeController.setColorTheme(AppColorTheme.teak);
      expect(themeController.colorTheme, equals(AppColorTheme.teak));

      await themeController.resetSettings();
      expect(themeController.themeMode, equals(ThemeMode.light));
      expect(themeController.displayDensity, equals(AppDisplayDensity.recommended));
      expect(themeController.colorTheme, equals(AppColorTheme.plain));
    });
  });

  group('Backup Tests', () {
    test('backup round-trip keeps every log row', () {
      final order = OrderModel(
        id: 7,
        customerName: 'Alice',
        phone: '9876543210',
        woodType: 'Teak',
        numberOfLogs: 2,
        totalVolume: 12.5,
        subtotal: 60000,
        cuttingCharge: 500,
        discount: 100,
        finalPrice: 60400,
        dateTime: DateTime(2026, 11, 10, 9, 30),
        logs: const [
          LogDimension(length: 10, girth: 4, volume: 10, price: 48000),
          LogDimension(length: 2.5, girth: 4, volume: 2.5, price: 12000),
        ],
      );

      final restored = BackupRepository.decodeBackup(BackupRepository.encodeBackup([order]));

      expect(restored, hasLength(1));
      expect(restored.first.id, equals(7));
      expect(restored.first.finalPrice, equals(60400));
      expect(restored.first.logs, hasLength(2));
      expect(restored.first.logs[1].length, equals(2.5));
      expect(restored.first.logs[1].price, equals(12000));
    });

    test('old backups without logs still load', () {
      const oldBackup = '{"version":1,"app":"Timbr","orders":[{"id":1,"customerName":"Bob",'
          '"phone":"9876543210","woodType":"Teak","numberOfLogs":1,"totalVolume":1.0,'
          '"subtotal":4800.0,"cuttingCharge":0.0,"discount":0.0,"finalPrice":4800.0,'
          '"dateTime":"2026-01-01T10:00:00.000"}]}';

      final restored = BackupRepository.decodeBackup(oldBackup);

      expect(restored.single.customerName, equals('Bob'));
      expect(restored.single.logs, isEmpty);
    });

    test('rejects files that are not Timbr backups', () {
      expect(() => BackupRepository.decodeBackup('{"app":"Other"}'), throwsFormatException);
      expect(() => BackupRepository.decodeBackup('not json'), throwsFormatException);
    });
  });
}
