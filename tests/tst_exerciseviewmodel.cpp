#include <QtTest>
#include <QDate>
#include "../viewmodels/ExerciseViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDateTime>

class TestExerciseViewModel : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void init();
    void cleanupTestCase();

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
    void ajouterWorkout();
    void ajouterWorkout_badgeDejaExistant();
    void ajouterExercice();
    void ajouterExercice_fuzzy();
    void ajouterExercice_exerciceInconnu();
    void toggleFait();
    void modifierExercice();
    void supprimerExercice();
    void supprimerWorkout();
    void selectWorkout();
    void selectWorkout_aucuneSelection();
    void refresh();
    void setSeanceTerminee();
    void setDernieresCalories();
    void nombreExercicesFaits();
    void totalSeances();
    void seancesSemaine_aucuneSeance();
    void seancesSemaine_seancesRecentes();
    void streakExercices_unJour();
    void streakExercices_troisJoursConsecutifs();
    void streakExercices_trouDansLeStreak();
    void streakExercices_deuxWorkoutsMemeJour();
    void streakExercices_hierSeulement();
    void badgePR_premierRecord();
    void badgePR_cinqRecords();
    void badgePR_dixRecords();
    void badgeStreak_troisJours();
    void badgeStreak_septJours();
    void badgeStreak_trenteJours();
};

void TestExerciseViewModel::initTestCase()
{
    QVERIFY(DatabaseManager::instance().openTestDatabase());
}

void TestExerciseViewModel::cleanupTestCase()
{
    DatabaseManager::instance().closeTestDatabase();
}
void TestExerciseViewModel::init()
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_exercises"
        );

    DatabaseManager::instance().execQuery(
        "DELETE FROM workouts"
        );

    DatabaseManager::instance().execQuery(
        "DELETE FROM personal_records"
        );

    DatabaseManager::instance().execQuery(
        "DELETE FROM users"
        );

    DatabaseManager::instance().execQuery(
        "DELETE FROM meals"
        );

    DatabaseManager::instance().execQuery(
        "DELETE FROM weight_history"
        );
}

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
    ExerciseViewModel vm;

    QCOMPARE(vm.streakExercices(), 0);
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

void TestExerciseViewModel::ajouterWorkout()
{
    ExerciseViewModel vm;

    QCOMPARE(vm.totalSeances(), 0);
    QCOMPARE(vm.currentWorkoutId(), -1);

    vm.ajouterWorkout("Test Workout");

    QCOMPARE(vm.totalSeances(), 1);
    QVERIFY(vm.currentWorkoutId() > 0);
    QCOMPARE(vm.workouts()->rowCount(), 1);
    QCOMPARE(vm.exercises()->rowCount(), 0);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom FROM workouts WHERE id = ?",
        { vm.currentWorkoutId() }
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Test Workout"));

    auto qBadge = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'FIRST_WORKOUT'"
        );

    QVERIFY(qBadge.next());
    QCOMPARE(qBadge.value(0).toInt(), 1);
}

void TestExerciseViewModel::ajouterWorkout_badgeDejaExistant()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Premier Workout");
    vm.ajouterWorkout("Deuxieme Workout");

    QCOMPARE(vm.totalSeances(), 2);
    QCOMPARE(vm.workouts()->rowCount(), 2);

    auto qBadge = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'FIRST_WORKOUT'"
        );

    QVERIFY(qBadge.next());
    QCOMPARE(qBadge.value(0).toInt(), 1);

    QVERIFY(vm.currentWorkoutId() > 0);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom FROM workouts WHERE id = ?",
        { vm.currentWorkoutId() }
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Deuxieme Workout"));
}
void TestExerciseViewModel::ajouterExercice()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom, sets, reps, poids, categorie "
        "FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Squat"));
    QCOMPARE(q.value(1).toInt(), 3);
    QCOMPARE(q.value(2).toInt(), 10);
    QCOMPARE(q.value(3).toDouble(), 20.0);
    QCOMPARE(q.value(4).toString(), QString("Legs"));
}

void TestExerciseViewModel::ajouterExercice_fuzzy()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squatt",
        3,
        10,
        20.0
        );

    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom, categorie "
        "FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Squatt"));
    QCOMPARE(q.value(1).toString(), QString("Legs"));
}

void TestExerciseViewModel::ajouterExercice_exerciceInconnu()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "ExerciceTotalementInconnuXYZ",
        3,
        12,
        15.0
        );

    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom, categorie "
        "FROM workout_exercises "
        "WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());
    QCOMPARE(
        q.value(0).toString(),
        QString("ExerciceTotalementInconnuXYZ")
        );
    QVERIFY(q.value(1).toString().isEmpty());
}

void TestExerciseViewModel::toggleFait()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, fait FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());

    const int exerciceId = q.value(0).toInt();
    QCOMPARE(q.value(1).toInt(), 0);

    vm.toggleFait(exerciceId);

    auto qFait = DatabaseManager::instance().execQuery(
        "SELECT fait FROM workout_exercises WHERE id = ?",
        { exerciceId }
        );

    QVERIFY(qFait.next());
    QCOMPARE(qFait.value(0).toInt(), 1);
    QCOMPARE(vm.nombreExercicesFaits(), 1);

    vm.toggleFait(exerciceId);

    auto qNonFait = DatabaseManager::instance().execQuery(
        "SELECT fait FROM workout_exercises WHERE id = ?",
        { exerciceId }
        );

    QVERIFY(qNonFait.next());
    QCOMPARE(qNonFait.value(0).toInt(), 0);
    QCOMPARE(vm.nombreExercicesFaits(), 0);
}
void TestExerciseViewModel::modifierExercice()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());

    const int exerciceId = q.value(0).toInt();

    vm.modifierExercice(
        exerciceId,
        "Squat",
        4,
        12,
        25.0
        );

    auto qModified = DatabaseManager::instance().execQuery(
        "SELECT nom, sets, reps, poids "
        "FROM workout_exercises WHERE id = ?",
        { exerciceId }
        );

    QVERIFY(qModified.next());

    QCOMPARE(qModified.value(0).toString(), QString("Squat"));
    QCOMPARE(qModified.value(1).toInt(), 4);
    QCOMPARE(qModified.value(2).toInt(), 12);
    QCOMPARE(qModified.value(3).toDouble(), 25.0);

    QCOMPARE(vm.exercises()->rowCount(), 1);
}
void TestExerciseViewModel::supprimerExercice()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());

    const int exerciceId = q.value(0).toInt();

    vm.supprimerExercice(exerciceId);

    QCOMPARE(vm.exercises()->rowCount(), 0);

    auto qDeleted = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workout_exercises WHERE id = ?",
        { exerciceId }
        );

    QVERIFY(qDeleted.next());
    QCOMPARE(qDeleted.value(0).toInt(), 0);
}
void TestExerciseViewModel::supprimerWorkout()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    vm.ajouterExercice(
        workoutId,
        "Fente avant",
        3,
        12,
        15.0
        );

    QCOMPARE(vm.totalSeances(), 1);
    QCOMPARE(vm.exercises()->rowCount(), 2);
    QCOMPARE(vm.currentWorkoutId(), workoutId);

    vm.supprimerWorkout(workoutId);

    QCOMPARE(vm.totalSeances(), 0);
    QCOMPARE(vm.workouts()->rowCount(), 0);
    QCOMPARE(vm.exercises()->rowCount(), 0);
    QCOMPARE(vm.currentWorkoutId(), -1);

    auto qWorkout = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workouts WHERE id = ?",
        { workoutId }
        );

    QVERIFY(qWorkout.next());
    QCOMPARE(qWorkout.value(0).toInt(), 0);

    auto qExercises = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(qExercises.next());
    QCOMPARE(qExercises.value(0).toInt(), 0);
}
void TestExerciseViewModel::selectWorkout()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Workout Push");
    const int workout1 = vm.currentWorkoutId();
    QVERIFY(workout1 > 0);

    vm.ajouterExercice(
        workout1,
        "Pompes",
        3,
        12,
        0.0
        );

    vm.ajouterWorkout("Workout Legs");
    const int workout2 = vm.currentWorkoutId();
    QVERIFY(workout2 > 0);
    QVERIFY(workout2 != workout1);

    vm.ajouterExercice(
        workout2,
        "Squat",
        4,
        10,
        20.0
        );

    vm.selectWorkout(workout1);

    QCOMPARE(vm.currentWorkoutId(), workout1);
    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q1 = DatabaseManager::instance().execQuery(
        "SELECT nom FROM workout_exercises WHERE workout_id = ?",
        { workout1 }
        );

    QVERIFY(q1.next());
    QCOMPARE(q1.value(0).toString(), QString("Pompes"));

    vm.selectWorkout(workout2);

    QCOMPARE(vm.currentWorkoutId(), workout2);
    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q2 = DatabaseManager::instance().execQuery(
        "SELECT nom FROM workout_exercises WHERE workout_id = ?",
        { workout2 }
        );

    QVERIFY(q2.next());
    QCOMPARE(q2.value(0).toString(), QString("Squat"));
}
void TestExerciseViewModel::selectWorkout_aucuneSelection()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    QCOMPARE(vm.currentWorkoutId(), workoutId);
    QCOMPARE(vm.exercises()->rowCount(), 1);

    vm.selectWorkout(-1);

    QCOMPARE(vm.currentWorkoutId(), -1);
    QCOMPARE(vm.exercises()->rowCount(), 0);
}
void TestExerciseViewModel::refresh()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Test Workout");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    QCOMPARE(vm.workouts()->rowCount(), 1);
    QCOMPARE(vm.exercises()->rowCount(), 0);

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?)",
        { workoutId, "Squat", 3, 10, 20.0 }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)",
        { "Workout ajouté directement" }
        );

    QCOMPARE(vm.workouts()->rowCount(), 1);
    QCOMPARE(vm.exercises()->rowCount(), 0);

    vm.refresh();

    QCOMPARE(vm.workouts()->rowCount(), 2);
    QCOMPARE(vm.exercises()->rowCount(), 1);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT nom FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toString(), QString("Squat"));
}

void TestExerciseViewModel::setSeanceTerminee()
{
    ExerciseViewModel vm;

    QCOMPARE(vm.seanceTerminee(), false);

    vm.setSeanceTerminee(true);
    QCOMPARE(vm.seanceTerminee(), true);

    vm.setSeanceTerminee(false);
    QCOMPARE(vm.seanceTerminee(), false);
}
void TestExerciseViewModel::setDernieresCalories()
{
    ExerciseViewModel vm;

    QCOMPARE(vm.dernieresCalories(), 0);

    vm.setDernieresCalories(450);
    QCOMPARE(vm.dernieresCalories(), 450);

    vm.setDernieresCalories(725);
    QCOMPARE(vm.dernieresCalories(), 725);
}
void TestExerciseViewModel::nombreExercicesFaits()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("Workout Test");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(workoutId, "Squat", 3, 10, 20.0);
    vm.ajouterExercice(workoutId, "Pompes", 3, 12, 0.0);
    vm.ajouterExercice(workoutId, "Fente avant", 3, 10, 15.0);

    QCOMPARE(vm.exercises()->rowCount(), 3);
    QCOMPARE(vm.nombreExercicesFaits(), 0);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id",
        { workoutId }
        );

    QVERIFY(q.next());
    const int id1 = q.value(0).toInt();

    QVERIFY(q.next());
    const int id2 = q.value(0).toInt();

    vm.toggleFait(id1);
    QCOMPARE(vm.nombreExercicesFaits(), 1);

    vm.toggleFait(id2);
    QCOMPARE(vm.nombreExercicesFaits(), 2);

    vm.toggleFait(id1);
    QCOMPARE(vm.nombreExercicesFaits(), 1);
}
void TestExerciseViewModel::totalSeances()
{
    ExerciseViewModel vm;

    QCOMPARE(vm.totalSeances(), 0);

    vm.ajouterWorkout("Workout 1");
    QCOMPARE(vm.totalSeances(), 1);

    vm.ajouterWorkout("Workout 2");
    QCOMPARE(vm.totalSeances(), 2);

    vm.ajouterWorkout("Workout 3");
    QCOMPARE(vm.totalSeances(), 3);
}
void TestExerciseViewModel::seancesSemaine_aucuneSeance()
{
    ExerciseViewModel vm;

    QCOMPARE(vm.seancesSemaine(), 0);
}

void TestExerciseViewModel::seancesSemaine_seancesRecentes()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Aujourd'hui", today.toString("yyyy-MM-dd") }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Il y a 3 jours", today.addDays(-3).toString("yyyy-MM-dd") }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Il y a 10 jours", today.addDays(-10).toString("yyyy-MM-dd") }
        );

    QCOMPARE(vm.seancesSemaine(), 2);
}

void TestExerciseViewModel::streakExercices_unJour()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Workout du jour", today.toString("yyyy-MM-dd") }
        );

    QCOMPARE(vm.streakExercices(), 1);
}

void TestExerciseViewModel::streakExercices_troisJoursConsecutifs()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    for (int i = 0; i < 3; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workouts (nom, date) VALUES (?, ?)",
            {
                "Workout jour " + QString::number(i),
                today.addDays(-i).toString("yyyy-MM-dd")
            }
            );
    }

    QCOMPARE(vm.streakExercices(), 3);
}
void TestExerciseViewModel::streakExercices_trouDansLeStreak()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Aujourd'hui", today.toString("yyyy-MM-dd") }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Hier", today.addDays(-1).toString("yyyy-MM-dd") }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Il y a 3 jours", today.addDays(-3).toString("yyyy-MM-dd") }
        );

    QCOMPARE(vm.streakExercices(), 2);
}

void TestExerciseViewModel::streakExercices_deuxWorkoutsMemeJour()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Séance 1", today.toString("yyyy-MM-dd") }
        );

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Séance 2", today.toString("yyyy-MM-dd") }
        );

    QCOMPARE(vm.streakExercices(), 1);
}

void TestExerciseViewModel::streakExercices_hierSeulement()
{
    ExerciseViewModel vm;

    const QDate yesterday = QDate::currentDate().addDays(-1);

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { "Workout hier", yesterday.toString("yyyy-MM-dd") }
        );

    QCOMPARE(vm.streakExercices(), 0);
}
void TestExerciseViewModel::badgePR_premierRecord()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("PR Test");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    vm.ajouterExercice(
        workoutId,
        "Squat",
        3,
        10,
        20.0
        );

    QVERIFY(vm.verifierEtSauvegarderPR(
        workoutId,
        "Squat",
        10,
        20.0
        ));

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'FIRST_PR'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}
void TestExerciseViewModel::badgePR_cinqRecords()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("PR Test");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    for (int i = 0; i < 5; ++i) {
        const QString nom = "Test PR " + QString::number(i);

        vm.ajouterExercice(
            workoutId,
            nom,
            3,
            10,
            20.0
            );

        QVERIFY(vm.verifierEtSauvegarderPR(
            workoutId,
            nom,
            10,
            20.0
            ));
    }

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'FIVE_PR'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}
void TestExerciseViewModel::badgePR_dixRecords()
{
    ExerciseViewModel vm;

    vm.ajouterWorkout("PR Test");

    const int workoutId = vm.currentWorkoutId();
    QVERIFY(workoutId > 0);

    for (int i = 0; i < 10; ++i) {
        const QString nom = "Test PR " + QString::number(i);

        vm.ajouterExercice(
            workoutId,
            nom,
            3,
            10,
            20.0
            );

        QVERIFY(vm.verifierEtSauvegarderPR(
            workoutId,
            nom,
            10,
            20.0
            ));
    }

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'TEN_PR'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}
void TestExerciseViewModel::badgeStreak_troisJours()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    for (int i = 1; i <= 2; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workouts (nom, date) VALUES (?, ?)",
            {
                "Workout jour " + QString::number(i),
                today.addDays(-i).toString("yyyy-MM-dd")
            }
            );
    }

    vm.ajouterWorkout("Workout aujourd'hui");

    QCOMPARE(vm.streakExercices(), 3);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'STREAK_3'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}
void TestExerciseViewModel::badgeStreak_septJours()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    for (int i = 1; i <= 6; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workouts (nom, date) VALUES (?, ?)",
            {
                "Workout jour " + QString::number(i),
                today.addDays(-i).toString("yyyy-MM-dd")
            }
            );
    }

    vm.ajouterWorkout("Workout aujourd'hui");

    QCOMPARE(vm.streakExercices(), 7);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'STREAK_7'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}
void TestExerciseViewModel::badgeStreak_trenteJours()
{
    ExerciseViewModel vm;

    const QDate today = QDate::currentDate();

    for (int i = 1; i <= 29; ++i) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO workouts (nom, date) VALUES (?, ?)",
            {
                "Workout jour " + QString::number(i),
                today.addDays(-i).toString("yyyy-MM-dd")
            }
            );
    }

    vm.ajouterWorkout("Workout aujourd'hui");

    QCOMPARE(vm.streakExercices(), 30);

    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'STREAK_30'"
        );

    QVERIFY(q.next());
    QCOMPARE(q.value(0).toInt(), 1);
}

QTEST_MAIN(TestExerciseViewModel)
#include "tst_exerciseviewmodel.moc"