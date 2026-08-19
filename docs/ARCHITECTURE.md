# Architecture — FitCoach

Ce document décrit l'organisation du code de FitCoach, les choix d'architecture et leurs raisons.

## Vue d'ensemble

FitCoach suit le pattern **MVVM (Model-View-ViewModel)**, standard pour les applications Qt/QML :

```
┌─────────────────────┐
│   View (QML)         │  ui/pages/*.qml
│   Affichage pur       │
└──────────┬───────────┘
           │ bindings (Q_PROPERTY / Q_INVOKABLE)
┌──────────▼───────────┐
│   ViewModel (C++)     │  viewmodels/*ViewModel.h/cpp
│   Logique de présentation
│   + accès données      │
└──────────┬───────────┘
           │
┌──────────▼───────────┐      ┌──────────────────┐
│   DatabaseManager      │      │  API Groq (IA)     │
│   Singleton SQLite      │      │  Chat + Vision      │
└─────────────────────┘      └──────────────────┘
```

## Couches

### View — `ui/pages/*.qml`
Écrans purement déclaratifs (QML). Aucune logique métier : chaque page se contente d'afficher les propriétés exposées par son ViewModel et d'appeler ses méthodes `Q_INVOKABLE` en réaction aux actions utilisateur.

Les ViewModels sont injectés globalement dans `main.cpp` via le contexte QML :

```cpp
engine.rootContext()->setContextProperty("exerciseVM", &exerciseVM);
```

Chaque page accède donc à son ViewModel par un identifiant global (`exerciseVM`, `coachVM`, `nutritionVM`...), sans passage de propriétés QML explicite entre pages.

### ViewModel — `viewmodels/*ViewModel.h/cpp`
Chaque écran principal a un ViewModel dédié : `HomeViewModel`, `NutritionViewModel`, `ExerciseViewModel`, `ProgressViewModel`, `CoachViewModel`, `ProfileViewModel`, `ProgrammeViewModel`, `SessionViewModel`.

Responsabilités actuelles :
- Exposer l'état à la vue (`Q_PROPERTY` + signaux `NOTIFY`)
- Exposer les actions utilisateur (`Q_INVOKABLE`)
- **Accéder directement à la base de données** via `DatabaseManager::instance().execQuery(...)`
- Pour `CoachViewModel` et `ProgrammeViewModel` : **appeler directement l'API Groq** (chat, vision, génération de programme)

C'est un choix pragmatique pour un projet solo en développement actif : pas de couche Repository/Service intermédiaire pour l'instant, les ViewModels concentrent logique de présentation *et* accès aux données.

### DatabaseManager — `database/DatabaseManager.h/cpp`
Singleton SQLite (`DatabaseManager::instance()`), point d'entrée unique pour toutes les requêtes SQL de l'application. Expose une API générique (`execQuery`) plutôt que des méthodes métier spécifiques par table — chaque ViewModel écrit ses propres requêtes SQL.

### Services (prévu) — `services/`
Dossier réservé à une future couche d'abstraction entre les ViewModels et (a) la base de données, (b) les API externes. L'objectif serait d'en extraire par exemple la logique d'appel à Groq (actuellement dans `CoachViewModel`/`ProgrammeViewModel`) vers un `AICoachService` dédié, testable indépendamment de l'UI.

## Base de données

SQLite, 9 tables principales : `users`, `meals`, `workouts`, `workout_exercises`, `weight_history`, `coach_messages`, `settings`, `exercises_library`, `programme_suggere` (+ `programme_exercices`).

Toutes les dates sont gérées côté C++ (`QDate::currentDate()`), jamais via `date('now')` de SQLite, pour éviter les décalages de fuseau horaire.

## Intégration IA (Groq)

Deux usages, tous deux appelés directement depuis les ViewModels concernés :
- **Chat coach** (`CoachViewModel`) : `llama-3.3-70b-versatile`, historique persistant en BDD
- **Vision** (analyse photo repas, `NutritionViewModel`/`CoachViewModel`) et **génération de programme** (`ProgrammeViewModel`) : `llama-4-scout`

La clé API est injectée à la compilation via `config.local.h` (ignoré par git), généré en CI à partir d'un secret GitHub.

## Tests

Tests unitaires Qt Test sur la logique pure des ViewModels (ex: `ExerciseViewModel::labelDate()`), exécutés automatiquement en CI (GitHub Actions) à chaque push/PR sur `main`.

## Évolutions envisagées

- Extraction de la logique métier des ViewModels vers `services/` (séparation accès données / présentation)
- DB de test isolée (SQLite en mémoire) pour découpler les tests unitaires de la base de données de développement
