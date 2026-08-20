#include <QtTest>
#include "../viewmodels/SessionViewModel.h"
#include "../database/DatabaseManager.h"

class TestSessionViewModel : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanupTestCase();

    void sessionVide_refuseDemarrage();
    void uneSerieSurTrois_exerciceNonTermine();
    void troisSeriesSurTrois_exerciceTermine();
    void timer_neDescendPasSousZero();
    void historique_exercice_retourneDernierePerformance();
    void serie_terminee_est_enregistree();
    void historique_exercice_retourne_les_series();
};

void TestSessionViewModel::initTestCase()
{
    QVERIFY(DatabaseManager::instance().openTestDatabase());
}

void TestSessionViewModel::init()
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_exercises"
    );

    DatabaseManager::instance().execQuery(
        "DELETE FROM workouts"
    );
}

void TestSessionViewModel::cleanupTestCase()
{
    DatabaseManager::instance().closeTestDatabase();
}

void TestSessionViewModel::sessionVide_refuseDemarrage()
{
    SessionViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Workout vide" }
    );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
    );

    QVERIFY(q.next());

    const int workoutId = q.value(0).toInt();

    vm.demarrerSession(workoutId);

    QVERIFY(!vm.actif());
    QCOMPARE(vm.totalExercices(), 0);
    QCOMPARE(vm.workoutId(), -1);
}

void TestSessionViewModel::uneSerieSurTrois_exerciceNonTermine()
{
    SessionViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Workout test" }
    );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
    );

    QVERIFY(qWorkout.next());

    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids, fait) "
        "VALUES (?, ?, ?, ?, ?, 0)",
        {
            workoutId,
            "Squat",
            3,
            10,
            50.0
        }
    );

    vm.demarrerSession(workoutId);

    QVERIFY(vm.actif());
    QCOMPARE(vm.setsTotal(), 3);
    QCOMPARE(vm.setsFaits(), 0);

    vm.terminerSerie();

    QCOMPARE(vm.setsFaits(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT fait FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
    );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 0);
}

void TestSessionViewModel::troisSeriesSurTrois_exerciceTermine()
{
    SessionViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Workout test" }
    );

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
    );

    QVERIFY(qWorkout.next());

    const int workoutId = qWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids, fait) "
        "VALUES (?, ?, ?, ?, ?, 0)",
        {
            workoutId,
            "Développé couché",
            3,
            8,
            60.0
        }
    );

    vm.demarrerSession(workoutId);

    QCOMPARE(vm.setsTotal(), 3);

    vm.terminerSerie();
    vm.terminerSerie();
    vm.terminerSerie();

    QCOMPARE(vm.setsFaits(), 3);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT fait FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
    );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}

void TestSessionViewModel::timer_neDescendPasSousZero()
{
    SessionViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Timer test" }
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
        {
            workoutId,
            "Curl haltères",
            2,
            10,
            10.0
        }
        );

    vm.demarrerSession(workoutId);

    vm.setTimerDuree(1);

    // La première série déclenche le timer de repos.
    vm.terminerSerie();

    QCOMPARE(vm.timerRestant(), 1);
    QVERIFY(vm.timerActif());

    // Attend suffisamment longtemps pour que le timer se termine.
    QTest::qWait(1200);

    // Le timer doit être arrêté et ne doit jamais devenir négatif.
    QCOMPARE(vm.timerRestant(), 0);
    QVERIFY(!vm.timerActif());
}
void TestSessionViewModel::historique_exercice_retourneDernierePerformance()
{
    SessionViewModel vm;

    const QDate today = QDate::currentDate();
    const QString yesterday = today.addDays(-1).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Ancienne séance", yesterday }
        );

    auto qOldWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qOldWorkout.next());

    const int oldWorkoutId = qOldWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        {
            oldWorkoutId,
            "Squat",
            3,
            10,
            95.0
        }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Nouvelle séance", today.toString("yyyy-MM-dd") }
        );

    auto qNewWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qNewWorkout.next());

    const int newWorkoutId = qNewWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        {
            newWorkoutId,
            "Squat",
            3,
            8,
            100.0
        }
        );

    vm.demarrerSession(newWorkoutId);

    QVERIFY(vm.actif());
    QVERIFY(vm.aHistorique());

    QCOMPARE(vm.dernierSets(), 3);
    QCOMPARE(vm.dernieresReps(), 10);
    QCOMPARE(vm.dernierPoids(), 95.0);
}
void TestSessionViewModel::serie_terminee_est_enregistree()
{
    SessionViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Workout historique" }
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
        {
            workoutId,
            "Squat",
            3,
            10,
            100.0
        }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? "
        "LIMIT 1",
        { workoutId }
        );

    QVERIFY(qExercise.next());

    vm.demarrerSession(workoutId);
    vm.terminerSerie();

    auto qSet = DatabaseManager::instance().execQuery(
        "SELECT numero_serie, poids, reps "
        "FROM workout_sets "
        "WHERE workout_exercise_id = ?",
        { qExercise.value(0).toInt() }
        );

    QVERIFY(qSet.next());

    QCOMPARE(qSet.value(0).toInt(), 1);
    QCOMPARE(qSet.value(1).toDouble(), 100.0);
    QCOMPARE(qSet.value(2).toInt(), 10);
}

void TestSessionViewModel::historique_exercice_retourne_les_series()
{
    SessionViewModel vm;

    const QDate today = QDate::currentDate();
    const QString previousDate =
        today.addDays(-1).toString("yyyy-MM-dd");

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Ancienne séance", previousDate }
        );

    auto qOldWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qOldWorkout.next());

    const int oldWorkoutId = qOldWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        {
            oldWorkoutId,
            "Squat",
            3,
            10,
            95.0
        }
        );

    auto qExercise = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ?",
        { oldWorkoutId }
        );

    QVERIFY(qExercise.next());

    const int exerciseId = qExercise.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exerciseId, 1, 95.0, 10 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exerciseId, 2, 95.0, 10 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_sets "
        "(workout_exercise_id, numero_serie, poids, reps) "
        "VALUES (?, ?, ?, ?)",
        { exerciseId, 3, 95.0, 8 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Séance actuelle", today.toString("yyyy-MM-dd") }
        );

    auto qNewWorkout = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(qNewWorkout.next());

    const int newWorkoutId = qNewWorkout.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        {
            newWorkoutId,
            "Squat",
            3,
            8,
            100.0
        }
        );

    vm.demarrerSession(newWorkoutId);

    const QVariantList historique = vm.historiqueExercice();

    QCOMPARE(historique.size(), 1);

    const QVariantMap workout = historique.first().toMap();

    QCOMPARE(
        workout["date"].toString(),
        previousDate
        );

    const QVariantList series =
        workout["series"].toList();

    QCOMPARE(series.size(), 3);

    const QVariantMap premiereSerie =
        series.first().toMap();

    QCOMPARE(premiereSerie["numero"].toInt(), 1);
    QCOMPARE(premiereSerie["poids"].toDouble(), 95.0);
    QCOMPARE(premiereSerie["reps"].toInt(), 10);
}

QTEST_MAIN(TestSessionViewModel)
#include "tst_sessionviewmodel.moc"