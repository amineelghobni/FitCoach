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
        "VALUES (?, 1, 100, 8)"
    );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, 2, 100, 8)"
    );

    const QVariantMap performance =
        service.dernierePerformance("Squat", workoutId + 1000);

    QVERIFY(!performance.isEmpty());
    QCOMPARE(performance["poids"].toDouble(), 100.0);
    QCOMPARE(performance["reps"].toInt(), 8);
    QCOMPARE(performance["numero"].toInt(), 1);
    QCOMPARE(performance["date"].toString(), date);
}

QTEST_MAIN(TestExerciseService)
#include "tst_exerciseservice.moc"