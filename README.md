# FitCoach 🏋️‍♂️

Application desktop fitness & nutrition avec coach IA intégré, développée en **Qt 6 / QML / C++20**.

![Qt](https://img.shields.io/badge/Qt-6.11-41CD52?logo=qt&logoColor=white)
![C++](https://img.shields.io/badge/C++-20-00599C?logo=cplusplus&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

## 📋 Description

FitCoach est une application de suivi fitness et nutrition qui combine :
- un **coach IA conversationnel** (via l'API Groq) capable d'analyser les repas en photo,
- un **générateur de programme d'entraînement** personnalisé selon le profil et l'historique de l'utilisateur,
- un **mode séance active** avec minuteur de repos, suivi des séries et calcul des calories brûlées,
- un **suivi de progression** (poids, calories, statistiques) avec graphiques animés.

Ce projet a été développé comme projet personnel pour explorer l'architecture **MVVM** avec Qt/QML et l'intégration d'API IA dans une application desktop native.

## ✨ Fonctionnalités

- **Onboarding** en 6 étapes pour configurer le profil utilisateur
- **Suivi nutritionnel** : ajout de repas, analyse photo par IA (vision), calcul macros
- **Suivi d'entraînement** : CRUD séances/exercices, bibliothèque de ~75 exercices
- **Mode séance active** : minuteur de repos configurable, séries cochables, calcul calories brûlées
- **Programme IA** : génération de séances personnalisées (rotation Push/Pull/Legs/Core) selon profil et historique
- **Coach IA** : chat contextuel avec historique persistant, messages automatiques post-séance
- **Suivi de progression** : graphiques animés (calories hebdo, courbe de poids)

## 🛠️ Stack technique

| Composant | Technologie |
|---|---|
| Framework UI | Qt 6.11 (Widgets + QML) |
| Langage | C++20 |
| Architecture | MVVM |
| Base de données | SQLite |
| Build system | CMake |
| API IA | Groq (chat + vision) — `llama-3.3-70b-versatile`, `llama-4-scout` |

## 🏗️ Architecture

```
FitCoach/
├── main.cpp
├── CMakeLists.txt
├── Main.qml
├── ui/
│   ├── theme/          # Thème visuel centralisé
│   └── pages/           # Écrans de l'application
├── database/
│   └── DatabaseManager  # Couche d'accès SQLite
├── services/
│   ├── NutritionService
│   ├── ExerciseService
│   └── AICoachService    # Intégration API Groq
└── viewmodels/           # Logique métier (pattern MVVM)
```

## 🚀 Installation

### Prérequis
- Qt 6.11 ou supérieur
- CMake 3.16+
- Compilateur compatible C++20 (MinGW 64-bit recommandé sous Windows)
- Une clé API [Groq](https://console.groq.com/keys) (gratuite)

### Étapes

```bash
git clone https://github.com/amineelghobni/FitCoach.git
cd FitCoach
```

Configure ta clé API :
```bash
cp config.local.h.example config.local.h
# Édite config.local.h et renseigne ta clé Groq
```

Compile avec Qt Creator (ouvre `CMakeLists.txt`) ou en ligne de commande :
```bash
cmake -S . -B build
cmake --build build
```

## 📸 Aperçu

*(à compléter avec quelques captures d'écran de l'application)*

## 📝 Roadmap

- [ ] Système de records personnels (PR) et badges
- [ ] Plan nutritionnel hebdomadaire généré par IA
- [ ] Export PDF/CSV des rapports mensuels
- [ ] Intégrations Garmin / Apple Watch

## 👤 Auteur

**Amine El Ghobni**
Ingénieur logiciel C++ — [LinkedIn](https://www.linkedin.com/in/amine-el-ghobni-61a2021b6/)

## 📄 Licence

Ce projet est sous licence MIT — voir le fichier [LICENSE](LICENSE) pour plus de détails.
