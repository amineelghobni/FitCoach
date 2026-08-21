#include <QtTest>
#include <QDate>

#include "../services/ExerciseService.h"
#include "../database/DatabaseManager.h"

class TestExerciseService : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanupTestCase();

    void historiqueExercice_vide();
    void historiqueExercice_retourneUneSeance();
    void historiqueExercice_retournePlusieursSeancesDansOrdre();
    void dernierePerformance_retourneLaPremiereSerie();
    void statistiquesExercice_retourneLesMeilleuresValeurs();
    void progressionExercice_retourneUneEntreeParSeance();
    void suggestionProgression_charge();
    void suggestionProgression_maintienSiRepsInsuffisantes();
    void suggestionProgression_maintienSiSeanceIncomplete();
    void suggestionProgression_augmentationAdapteeALaCharge();
};

void TestExerciseService::initTestCase()
{
    QVERIFY(DatabaseManager::instance().openTestDatabase());
}

void TestExerciseService::init()
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_sets"
    );

    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_exercises"
    );

    DatabaseManager::instance().execQuery(
        "DELETE FROM workouts"
    );
}

void TestExerciseService::cleanupTestCase()
{
    DatabaseManager::instance().closeTestDatabase();
}

void TestExerciseService::historiqueExercice_vide()
{
    ExerciseService service;

    const QVariantList historique =
        service.historiqueExercice("Squat", -1);

    QVERIFY(historique.isEmpty());
}

void TestExerciseService::historiqueExercice_retourneUneSeance()
{
    ExerciseService service;

    const QString date =
        QDate::currentDate().addDays(-1).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Push", date }
    );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
    );

    QVERIFY(qWorkout.next());

    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 10, 95.0 }
    );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
    );

    QVERIFY(qExercise.next());

    const int exerciseId = qExercise.value(0).toInt();

    for (int serie = 1; serie <= 3; ++serie) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            {
                exerciseId,
                serie,
                95.0,
                serie == 3 ? 8 : 10
            }
        );
    }

    const QVariantList historique =
        service.historiqueExercice("Squat", workoutId + 1000);

    QCOMPARE(historique.size(), 1);

    const QVariantMap seance =
        historique.first().toMap();

    QCOMPARE(seance["date"].toString(), date);

    const QVariantList series =
        seance["series"].toList();

    QCOMPARE(series.size(), 3);

    const QVariantMap premiereSerie =
        series.first().toMap();

    QCOMPARE(premiereSerie["numero"].toInt(), 1);
    QCOMPARE(premiereSerie["poids"].toDouble(), 95.0);
    QCOMPARE(premiereSerie["reps"].toInt(), 10);
}

void TestExerciseService::historiqueExercice_retournePlusieursSeancesDansOrdre()
{
    ExerciseService service;

    const QDate today = QDate::currentDate();

    const QString date1 =
        today.addDays(-1).toString("yyyy-MM-dd");

    const QString date2 =
        today.addDays(-3).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Séance récente", date1 }
    );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Séance ancienne", date2 }
    );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id ASC"
    );

    QVERIFY(q.next());
    const int workoutAncien = q.value(0).toInt();

    QVERIFY(q.next());
    const int workoutRecent = q.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutAncien, "Développé couché", 3, 10, 90.0 }
    );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutRecent, "Développé couché", 3, 8, 95.0 }
    );

    auto qExercises = DatabaseManager::instance().execQuery(
        "SELECT id, workout_id "
        "FROM workout_exercises "
        "ORDER BY id ASC"
    );

    QVERIFY(qExercises.next());
    const int exerciseAncien = qExercises.value(0).toInt();

    QVERIFY(qExercises.next());
    const int exerciseRecent = qExercises.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, 1, ?, ?)",
        { exerciseAncien, 90.0, 10 }
    );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, 1, ?, ?)",
        { exerciseRecent, 95.0, 8 }
    );

    const QVariantList historique =
        service.historiqueExercice(
            "Développé couché",
            -1
        );

    QCOMPARE(historique.size(), 2);

    const QVariantMap recent =
        historique.at(0).toMap();

    const QVariantMap ancien =
        historique.at(1).toMap();

    QCOMPARE(recent["date"].toString(), date1);
    QCOMPARE(ancien["date"].toString(), date2);
}

void TestExerciseService::dernierePerformance_retourneLaPremiereSerie()
{
    ExerciseService service;

    const QString date =
        QDate::currentDate().addDays(-2).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Leg Day", date }
    );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
    );

    QVERIFY(qWorkout.next());

    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 8, 100.0 }
    );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
    );

    QVERIFY(qExercise.next());

    const int exerciseId = qExercise.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, 1, 100, 8)",
        { exerciseId }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, 2, 100, 8)",
        { exerciseId }
        );

    const QVariantMap performance =
        service.dernierePerformance("Squat", workoutId + 1000);

    QVERIFY(!performance.isEmpty());
    QCOMPARE(performance["poids"].toDouble(), 100.0);
    QCOMPARE(performance["reps"].toInt(), 8);
    QCOMPARE(performance["numero"].toInt(), 1);
    QCOMPARE(performance["date"].toString(), date);
}
void TestExerciseService::statistiquesExercice_retourneLesMeilleuresValeurs()
{
    ExerciseService service;

    const QString date1 =
        QDate::currentDate().addDays(-5).toString("yyyy-MM-dd");

    const QString date2 =
        QDate::currentDate().addDays(-2).toString("yyyy-MM-dd");

    // ── Séance 1 ─────────────────────────────────────────
    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Push 1", date1 }
        );

    auto q1 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    QVERIFY(q1.next());
    const int workout1 = q1.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workout1, "Développé couché", 3, 8, 80.0 }
        );

    auto qe1 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id DESC LIMIT 1",
        { workout1 }
        );
    QVERIFY(qe1.next());
    const int exercise1 = qe1.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise1, 1, 80.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise1, 2, 80.0, 10 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise1, 3, 80.0, 9 }
        );

    // ── Séance 2 ─────────────────────────────────────────
    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Push 2", date2 }
        );

    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    QVERIFY(q2.next());
    const int workout2 = q2.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workout2, "Développé couché", 3, 8, 85.0 }
        );

    auto qe2 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id DESC LIMIT 1",
        { workout2 }
        );
    QVERIFY(qe2.next());
    const int exercise2 = qe2.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise2, 1, 85.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise2, 2, 85.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise2, 3, 85.0, 7 }
        );

    const QVariantMap stats =
        service.statistiquesExercice("Développé couché");

    QCOMPARE(stats["nombreSeances"].toInt(), 2);
    QCOMPARE(stats["meilleurPoids"].toDouble(), 85.0);
    QCOMPARE(stats["meilleuresReps"].toInt(), 10);

    // Séance 1 = 80*8 + 80*10 + 80*9 = 2160
    // Séance 2 = 85*8 + 85*8 + 85*7 = 1955
    QCOMPARE(stats["meilleurVolume"].toDouble(), 2160.0);
}

void TestExerciseService::progressionExercice_retourneUneEntreeParSeance()
{
    ExerciseService service;

    const QString date1 =
        QDate::currentDate().addDays(-6).toString("yyyy-MM-dd");

    const QString date2 =
        QDate::currentDate().addDays(-3).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Jambes 1", date1 }
        );

    auto q1 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    QVERIFY(q1.next());
    const int workout1 = q1.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workout1, "Squat", 3, 8, 100.0 }
        );

    auto qe1 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id DESC LIMIT 1",
        { workout1 }
        );
    QVERIFY(qe1.next());
    const int exercise1 = qe1.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise1, 1, 100.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise1, 2, 100.0, 10 }
        );

    // ── Deuxième séance ─────────────────────────────────
    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Jambes 2", date2 }
        );

    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    QVERIFY(q2.next());
    const int workout2 = q2.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workout2, "Squat", 3, 8, 105.0 }
        );

    auto qe2 = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id DESC LIMIT 1",
        { workout2 }
        );
    QVERIFY(qe2.next());
    const int exercise2 = qe2.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise2, 1, 105.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exercise2, 2, 105.0, 8 }
        );

    const QVariantList progression =
        service.progressionExercice("Squat");

    QCOMPARE(progression.size(), 2);

    const QVariantMap first =
        progression.at(0).toMap();

    const QVariantMap second =
        progression.at(1).toMap();

    QCOMPARE(first["date"].toString(), date1);
    QCOMPARE(first["meilleurPoids"].toDouble(), 100.0);
    QCOMPARE(first["meilleuresReps"].toInt(), 10);
    QCOMPARE(first["volume"].toDouble(), 1800.0);

    QCOMPARE(second["date"].toString(), date2);
    QCOMPARE(second["meilleurPoids"].toDouble(), 105.0);
    QCOMPARE(second["meilleuresReps"].toInt(), 8);
    QCOMPARE(second["volume"].toDouble(), 1680.0);
}

void TestExerciseService::suggestionProgression_charge()
{
    ExerciseService service;

    const QString date =
        QDate::currentDate().addDays(-1).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Push", date }
        );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qWorkout.next());
    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Développé couché", 3, 10, 80.0 }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(qExercise.next());
    const int exerciseId = qExercise.value(0).toInt();

    for (int i = 1; i <= 3; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            { exerciseId, i, 80.0, 10 }
            );
    }

    const QVariantMap suggestion =
        service.suggestionProgression("Développé couché");

    QVERIFY(suggestion["disponible"].toBool());
    QCOMPARE(suggestion["type"].toString(), QString("charge"));
    QCOMPARE(suggestion["chargeProposee"].toDouble(), 82.5);
    QCOMPARE(suggestion["repsProposees"].toInt(), 10);
}

void TestExerciseService::suggestionProgression_maintienSiRepsInsuffisantes()
{
    ExerciseService service;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Push" }
        );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qWorkout.next());
    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 10, 100.0 }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(qExercise.next());
    const int exerciseId = qExercise.value(0).toInt();

    for (int i = 1; i <= 3; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            { exerciseId, i, 100.0, 8 }
            );
    }

    const QVariantMap suggestion =
        service.suggestionProgression("Squat");

    QCOMPARE(suggestion["type"].toString(), QString("maintien"));
    QCOMPARE(suggestion["chargeProposee"].toDouble(), 100.0);
}

void TestExerciseService::suggestionProgression_maintienSiSeanceIncomplete()
{
    ExerciseService service;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Leg Day" }
        );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qWorkout.next());
    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Leg press", 4, 10, 120.0 }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(qExercise.next());
    const int exerciseId = qExercise.value(0).toInt();

    // Seulement 2 séries enregistrées sur 4.
    for (int i = 1; i <= 2; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            { exerciseId, i, 120.0, 10 }
            );
    }

    const QVariantMap suggestion =
        service.suggestionProgression("Leg press");

    QCOMPARE(suggestion["type"].toString(), QString("maintien"));
    QCOMPARE(suggestion["chargeProposee"].toDouble(), 120.0);
}
void TestExerciseService::suggestionProgression_augmentationAdapteeALaCharge()
{
    ExerciseService service;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Test progression" }
        );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qWorkout.next());
    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 10, 100.0 }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(qExercise.next());
    const int exerciseId = qExercise.value(0).toInt();

    for (int i = 1; i <= 3; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            { exerciseId, i, 100.0, 10 }
            );
    }

    const QVariantMap suggestion =
        service.suggestionProgression("Squat");

    QCOMPARE(suggestion["type"].toString(), QString("charge"));
    QCOMPARE(suggestion["chargeProposee"].toDouble(), 105.0);
}
QTEST_MAIN(TestExerciseService)
#include "tst_exerciseservice.moc"