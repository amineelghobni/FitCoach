#include "ExerciseService.h"
#include "../database/DatabaseManager.h"

#include <QVariantMap>

ExerciseService::ExerciseService(QObject* parent)
    : QObject(parent)
{
}

QVariantList ExerciseService::historiqueExercice(
    const QString& nomExercice,
    int workoutId) const
{
    QVariantList result;

    if (nomExercice.trimmed().isEmpty())
        return result;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT "
        "    w.id, "
        "    w.date, "
        "    ws.numero_serie, "
        "    ws.poids, "
        "    ws.reps "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "JOIN workouts w "
        "    ON w.id = we.workout_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?)) "
        "AND w.id != ? "
        "ORDER BY w.date DESC, w.id DESC, ws.numero_serie ASC",
        { nomExercice, workoutId }
        );

    int currentWorkoutId = -1;
    QString currentDate;
    QVariantList series;

    while (q.next()) {
        const int rowWorkoutId = q.value(0).toInt();
        const QString date = q.value(1).toString();

        const bool nouvelleSeance =
            currentWorkoutId != -1 &&
            (rowWorkoutId != currentWorkoutId || date != currentDate);

        if (nouvelleSeance) {
            QVariantMap workout;
            workout["workoutId"] = currentWorkoutId;
            workout["date"] = currentDate;
            workout["series"] = series;

            result.append(workout);
            series.clear();
        }

        currentWorkoutId = rowWorkoutId;
        currentDate = date;

        QVariantMap serie;
        serie["numero"] = q.value(2).toInt();
        serie["poids"] = q.value(3).toDouble();
        serie["reps"] = q.value(4).toInt();

        series.append(serie);
    }

    if (currentWorkoutId != -1) {
        QVariantMap workout;
        workout["workoutId"] = currentWorkoutId;
        workout["date"] = currentDate;
        workout["series"] = series;

        result.append(workout);
    }

    return result;
}

QVariantMap ExerciseService::dernierePerformance(
    const QString& nomExercice,
    int workoutId) const
{
    QVariantMap result;

    if (nomExercice.trimmed().isEmpty())
        return result;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT "
        "    ws.poids, "
        "    ws.reps, "
        "    ws.numero_serie, "
        "    w.date "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "JOIN workouts w "
        "    ON w.id = we.workout_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?)) "
        "AND w.id != ? "
        "ORDER BY w.date DESC, w.id DESC, ws.numero_serie ASC "
        "LIMIT 1",
        { nomExercice, workoutId }
        );

    if (!q.next())
        return result;

    result["poids"] = q.value(0).toDouble();
    result["reps"] = q.value(1).toInt();
    result["numero"] = q.value(2).toInt();
    result["date"] = q.value(3).toString();

    return result;
}