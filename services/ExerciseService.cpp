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
        "    w.date, "
        "    we.sets "
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
    result["sets"] = q.value(4).toInt();

    return result;
}
QVariantMap ExerciseService::statistiquesExercice(
    const QString& nomExercice) const
{
    QVariantMap result;

    if (nomExercice.trimmed().isEmpty())
        return result;

    // Nombre de séances distinctes
    auto qSeances = DatabaseManager::instance().execQuery(
        "SELECT COUNT(DISTINCT w.id) "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "JOIN workouts w "
        "    ON w.id = we.workout_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?))",
        { nomExercice }
        );

    int nombreSeances = 0;
    if (qSeances.next())
        nombreSeances = qSeances.value(0).toInt();

    // Meilleur poids
    auto qPoids = DatabaseManager::instance().execQuery(
        "SELECT MAX(ws.poids) "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?))",
        { nomExercice }
        );

    double meilleurPoids = 0.0;
    if (qPoids.next())
        meilleurPoids = qPoids.value(0).toDouble();

    // Meilleures répétitions sur une série
    auto qReps = DatabaseManager::instance().execQuery(
        "SELECT MAX(ws.reps) "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?))",
        { nomExercice }
        );

    int meilleuresReps = 0;
    if (qReps.next())
        meilleuresReps = qReps.value(0).toInt();

    // Meilleur volume réalisé sur une séance
    auto qVolume = DatabaseManager::instance().execQuery(
        "SELECT MAX(volume) "
        "FROM ("
        "    SELECT w.id, SUM(ws.poids * ws.reps) AS volume "
        "    FROM workout_sets ws "
        "    JOIN workout_exercises we "
        "        ON we.id = ws.workout_exercise_id "
        "    JOIN workouts w "
        "        ON w.id = we.workout_id "
        "    WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?)) "
        "    GROUP BY w.id"
        ")",
        { nomExercice }
        );

    double meilleurVolume = 0.0;
    if (qVolume.next())
        meilleurVolume = qVolume.value(0).toDouble();

    result["nombreSeances"] = nombreSeances;
    result["meilleurPoids"] = meilleurPoids;
    result["meilleuresReps"] = meilleuresReps;
    result["meilleurVolume"] = meilleurVolume;

    return result;
}

QVariantList ExerciseService::progressionExercice(
    const QString& nomExercice) const
{
    QVariantList result;

    if (nomExercice.trimmed().isEmpty())
        return result;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT "
        "    w.id, "
        "    w.date, "
        "    MAX(ws.poids) AS meilleur_poids, "
        "    MAX(ws.reps) AS meilleures_reps, "
        "    SUM(ws.poids * ws.reps) AS volume "
        "FROM workout_sets ws "
        "JOIN workout_exercises we "
        "    ON we.id = ws.workout_exercise_id "
        "JOIN workouts w "
        "    ON w.id = we.workout_id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?)) "
        "GROUP BY w.id, w.date "
        "ORDER BY w.date ASC, w.id ASC",
        { nomExercice }
        );

    while (q.next()) {
        QVariantMap point;

        point["workoutId"] = q.value(0).toInt();
        point["date"] = q.value(1).toString();
        point["meilleurPoids"] = q.value(2).toDouble();
        point["meilleuresReps"] = q.value(3).toInt();
        point["volume"] = q.value(4).toDouble();

        result.append(point);
    }

    return result;
}
QVariantMap ExerciseService::suggestionProgression(
    const QString& nomExercice) const
{
    QVariantMap result;

    if (nomExercice.trimmed().isEmpty())
        return result;

    // Dernière séance réellement enregistrée pour cet exercice.
    auto q = DatabaseManager::instance().execQuery(
        "SELECT "
        "    w.id, "
        "    w.date, "
        "    we.sets, "
        "    we.reps, "
        "    we.poids, "
        "    COUNT(ws.id) AS series_realisees, "
        "    MIN(ws.reps) AS min_reps, "
        "    MAX(ws.poids) AS max_poids "
        "FROM workout_exercises we "
        "JOIN workouts w "
        "    ON w.id = we.workout_id "
        "JOIN workout_sets ws "
        "    ON ws.workout_exercise_id = we.id "
        "WHERE LOWER(TRIM(we.nom)) = LOWER(TRIM(?)) "
        "GROUP BY w.id, w.date, we.id, we.sets, we.reps, we.poids "
        "ORDER BY w.date DESC, w.id DESC "
        "LIMIT 1",
        { nomExercice }
        );

    if (!q.next()) {
        result["disponible"] = false;
        result["type"] = "aucune_donnee";
        result["titre"] = "Pas encore de recommandation";
        result["message"] =
            "Termine une première séance pour obtenir une suggestion.";
        return result;
    }

    const int setsPrevus = q.value(2).toInt();
    const int repsCible = q.value(3).toInt();
    const double poidsActuel = q.value(4).toDouble();
    const int seriesRealisees = q.value(5).toInt();
    const int minReps = q.value(6).toInt();
    const double maxPoids = q.value(7).toDouble();

    result["disponible"] = true;
    result["date"] = q.value(1).toString();
    result["poidsActuel"] = poidsActuel;
    result["repsCible"] = repsCible;
    result["setsPrevus"] = setsPrevus;
    result["seriesRealisees"] = seriesRealisees;
    result["minReps"] = minReps;

    // Séance incomplète : on ne pousse pas la charge.
    if (setsPrevus <= 0 || seriesRealisees < setsPrevus) {
        result["type"] = "maintien";
        result["titre"] = "Consolide ta charge";
        result["message"] =
            "Toutes les séries prévues n'ont pas été enregistrées. "
            "Garde la même charge à la prochaine séance.";
        result["chargeProposee"] = poidsActuel;
        return result;
    }

    // Les séries sont complètes, mais la cible de répétitions
    // n'est pas encore atteinte sur toute la séance.
    if (repsCible > 0 && minReps < repsCible) {
        result["type"] = "maintien";
        result["titre"] = "Garde la même charge";
        result["message"] =
            "La charge est encore à consolider. "
            "Essaie d'atteindre " +
            QString::number(repsCible) +
            " reps sur toutes les séries.";
        result["chargeProposee"] = poidsActuel;
        return result;
    }

    // Exercice au poids du corps / sans charge.
    if (maxPoids <= 0.0) {
        result["type"] = "reps";
        result["titre"] = "Augmente légèrement les reps";
        result["message"] =
            "La séance cible est maîtrisée. "
            "Ajoute 1 répétition par série à la prochaine séance.";
        result["chargeProposee"] = 0.0;
        result["repsProposees"] = repsCible + 1;
        return result;
    }

    // Progression prudente de 2,5 kg.
    double augmentation = 2.5;

    if (maxPoids < 20.0)
        augmentation = 1.0;
    else if (maxPoids < 50.0)
        augmentation = 2.0;
    else if (maxPoids >= 100.0)
        augmentation = 5.0;

    const double nouvelleCharge = maxPoids + augmentation;

    result["type"] = "charge";
    result["titre"] = "Tu peux progresser";
    result["message"] =
        "Toutes les séries atteignent la cible. "
        "Essaie " +
        QString::number(nouvelleCharge, 'f', 1) +
        " kg à la prochaine séance.";

    result["chargeProposee"] = nouvelleCharge;
    result["repsProposees"] = repsCible;

    return result;
}