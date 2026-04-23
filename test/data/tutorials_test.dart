import 'package:flutter_test/flutter_test.dart';
import 'package:techare_application_comp3003/data/tutorials.dart';

void main() {
  group('TutorialStep', () {
    test('stores title and description', () {
      const step = TutorialStep(title: 'Title', description: 'Desc');
      expect(step.title, 'Title');
      expect(step.description, 'Desc');
      expect(step.imageAsset, isNull);
    });

    test('stores optional imageAsset when provided', () {
      const step = TutorialStep(
        title: 'Title',
        description: 'Desc',
        imageAsset: 'assets/img.png',
      );
      expect(step.imageAsset, 'assets/img.png');
    });
  });

  group('Tutorial', () {
    test('stores all required fields', () {
      const t = Tutorial(
        title: 'My Tutorial',
        description: 'A description',
        duration: '10min',
        category: 'Battery',
        steps: [],
      );
      expect(t.title, 'My Tutorial');
      expect(t.description, 'A description');
      expect(t.duration, '10min');
      expect(t.category, 'Battery');
      expect(t.steps, isEmpty);
    });

    test('tools and warning default to empty when omitted', () {
      const t = Tutorial(
        title: 'T',
        description: 'D',
        duration: '5min',
        category: 'Storage',
        steps: [],
      );
      expect(t.tools, isEmpty);
      expect(t.warning, isEmpty);
    });

    test('stores optional tools and warning when provided', () {
      const t = Tutorial(
        title: 'T',
        description: 'D',
        duration: '45min',
        category: 'Battery',
        tools: ['Screwdriver', 'Pry tool'],
        warning: 'Be careful',
        steps: [],
      );
      expect(t.tools, ['Screwdriver', 'Pry tool']);
      expect(t.warning, 'Be careful');
    });
  });

  group('iosStorageTutorial', () {
    test('is a Storage category tutorial with title and 5 steps', () {
      expect(iosStorageTutorial.category, 'Storage');
      expect(iosStorageTutorial.title, 'Free up Storage Space');
      expect(iosStorageTutorial.steps.length, 5);
    });

    test('all steps have a non-empty title, description and an image asset', () {
      for (final step in iosStorageTutorial.steps) {
        expect(step.title, isNotEmpty);
        expect(step.description, isNotEmpty);
        expect(step.imageAsset, isNotNull);
      }
    });
  });

  group('androidStorageTutorial', () {
    test('is a Storage category tutorial with title and 5 steps', () {
      expect(androidStorageTutorial.category, 'Storage');
      expect(androidStorageTutorial.title, 'Archiving Unused Apps');
      expect(androidStorageTutorial.steps.length, 5);
    });

    test('all steps have a non-empty title and description', () {
      for (final step in androidStorageTutorial.steps) {
        expect(step.title, isNotEmpty);
        expect(step.description, isNotEmpty);
      }
    });
  });

  group('baseTutorials', () {
    test('contains exactly 4 tutorials', () {
      expect(baseTutorials.length, 4);
    });

    test('covers Battery, Storage and Overheating categories', () {
      final categories = baseTutorials.map((t) => t.category).toSet();
      expect(categories, containsAll(['Battery', 'Storage', 'Overheating']));
    });

    test('every tutorial has at least one step', () {
      for (final t in baseTutorials) {
        expect(t.steps, isNotEmpty, reason: '${t.title} has no steps');
      }
    });

    test('every step in every tutorial has a title and description', () {
      for (final t in baseTutorials) {
        for (final step in t.steps) {
          expect(step.title, isNotEmpty);
          expect(step.description, isNotEmpty);
        }
      }
    });

    test('Replace Battery tutorial has required tools and a safety warning', () {
      final battery = baseTutorials.firstWhere((t) => t.title == 'Replace Battery');
      expect(battery.tools, isNotEmpty);
      expect(battery.warning, isNotEmpty);
    });
  });

  group('tutorialsForBrand', () {
    test('Apple returns iOS storage tutorial as the last entry', () {
      final tutorials = tutorialsForBrand('Apple');
      expect(tutorials.last.title, iosStorageTutorial.title);
    });

    test('Samsung returns Android storage tutorial', () {
      final tutorials = tutorialsForBrand('Samsung');
      expect(tutorials.last.title, androidStorageTutorial.title);
    });

    test('Google returns Android storage tutorial', () {
      final tutorials = tutorialsForBrand('Google');
      expect(tutorials.last.title, androidStorageTutorial.title);
    });

    test('Other returns Android storage tutorial', () {
      final tutorials = tutorialsForBrand('Other');
      expect(tutorials.last.title, androidStorageTutorial.title);
    });

    test('result has baseTutorials.length + 1 entries', () {
      expect(tutorialsForBrand('Apple').length, baseTutorials.length + 1);
      expect(tutorialsForBrand('Samsung').length, baseTutorials.length + 1);
    });

    test('is case-insensitive for brand matching', () {
      expect(tutorialsForBrand('apple').last.title, iosStorageTutorial.title);
      expect(tutorialsForBrand('APPLE').last.title, iosStorageTutorial.title);
      expect(tutorialsForBrand('SAMSUNG').last.title, androidStorageTutorial.title);
    });
  });
}
