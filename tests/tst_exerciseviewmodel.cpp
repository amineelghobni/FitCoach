#include <QtTest>
#include <QDate>
#include "../viewmodels/ExerciseViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDateTime>

class TestExerciseViewModel : public QObject
{
    Q_OBJECT

private slots:
    void labelDate_aujourdhui();
    void labelDate_hier();
    void labelDate_ilya2jours();
    void labelDate_dateAncienne();
    void labelDate_formatInvalide();
    void calculerVolume();
    void verifierEtSauvegarderPR_premierRecord();
    void calculerCaloriesBrulees();
    void streakExercices_aucunWorkout();
    void verifierEtSauvegarderPR_batRecord();
    void verifierEtSauvegarderPR_recordExistant();
    void calculerCaloriesBrulees_workoutVide();
    void calculerVolume_workoutVide();

};

void TestExerciseViewModel::labelDate_aujourdhui()
{
    ExerciseViewModel vm;
    QString today = QDate::currentDate().toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(today), QString("Aujourd'hui"));
}

void TestExerciseViewModel::labelDate_hier()
{
    ExerciseViewModel vm;
    QString yesterday = QDate::currentDate().addDays(-1).toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(yesterday), QString("Hier"));
}

void TestExerciseViewModel::labelDate_ilya2jours()
{
    ExerciseViewModel vm;
    QString twoDaysAgo = QDate::currentDate().addDays(-2).toString("yyyy-MM-dd");
    QCOMPARE(vm.labelDate(twoDaysAgo), QString("Il y a 2 jours"));
}

void TestExerciseViewModel::labelDate_dateAncienne()
{
    ExerciseViewModel vm;
    QDate old = QDate::currentDate().addDays(-10);
    QString expected = old.toString("dddd dd MMMM");
    QCOMPARE(vm.labelDate(old.toString("yyyy-MM-dd")), expected);
}

void TestExerciseViewModel::labelDate_formatInvalide()
{
    ExerciseViewModel vm;
    // Une date invalide donne un QDate invalide → toString() renvoie une chaîne vide
    QString result = vm.labelDate("pas-une-date");
    QVERIFY(result.isEmpty() || result != "Aujourd'hui");
}
void TestExerciseViewModel::calculerVolume()
{
    ExerciseViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Test Workout" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        {
            workoutId,
            "Squat",
            3,
            10,
            20
        }
        );

    QCOMPARE(vm.calculerVolume(workoutId), 600);
}
void TestExerciseViewModel::verifierEtSauvegarderPR_premierRecord()
{
    ExerciseViewModel vm;

    QString exerciceNom =
        "TEST_PR_" +
        QString::number(QDateTime::currentMSecsSinceEpoch());

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "PR Test Workout" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, exerciceNom, 3, 10, 20 }
        );

    QVERIFY(
        vm.verifierEtSauvegarderPR(
            workoutId,
            exerciceNom,
            10,
            20
            )
        );
}
void TestExerciseViewModel::calculerCaloriesBrulees()
{
    ExerciseViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO users (nom, poids) VALUES (?, ?)",
        { "TestUser", 80.0 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Calories Test" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 10, 20 }
        );

    QVERIFY(vm.calculerCaloriesBrulees(workoutId) > 0);
}
void TestExerciseViewModel::streakExercices_aucunWorkout()
{
    QSKIP("Requires isolated SQLite test database");
}
void TestExerciseViewModel::verifierEtSauvegarderPR_batRecord()
{
    ExerciseViewModel vm;

    QString exerciceNom =
        "TEST_NEW_PR_" +
        QString::number(QDateTime::currentMSecsSinceEpoch());

    DatabaseManager::instance().execQuery(
        "INSERT INTO personal_records "
        "(exercice_nom, poids, reps, volume) "
        "VALUES (?, ?, ?, ?)",
        { exerciceNom, 20, 10, 600 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "PR Workout" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, exerciceNom, 3, 10, 25 }
        );

    QVERIFY(
        vm.verifierEtSauvegarderPR(
            workoutId,
            exerciceNom,
            10,
            25
            )
        );
}
void TestExerciseViewModel::verifierEtSauvegarderPR_recordExistant()
{
    ExerciseViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO personal_records "
        "(exercice_nom, poids, reps, volume) "
        "VALUES (?, ?, ?, ?)",
        { "TEST_EXISTING_PR", 20, 10, 600 }
        );

    QVERIFY(
        !vm.verifierEtSauvegarderPR(
            1,
            "TEST_EXISTING_PR",
            10,
            20
            )
        );
}

void TestExerciseViewModel::calculerCaloriesBrulees_workoutVide()
{
    ExerciseViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Empty Calories Workout" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    QCOMPARE(vm.calculerCaloriesBrulees(workoutId), 0);
}
void TestExerciseViewModel::calculerVolume_workoutVide()
{
    ExerciseViewModel vm;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Empty Workout" }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );

    QVERIFY(q.next());

    int workoutId = q.value(0).toInt();

    QCOMPARE(vm.calculerVolume(workoutId), 0);
}

QTEST_MAIN(TestExerciseViewModel)
#include "tst_exerciseviewmodel.moc"