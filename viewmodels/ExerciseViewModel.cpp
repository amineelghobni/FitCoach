#include "ExerciseViewModel.h"
#include "../database/DatabaseManager.h"
#include <QDate>

// ── ExerciseListModel ─────────────────────────────────────

ExerciseListModel::ExerciseListModel(QObject* parent)
    : QAbstractListModel(parent) {}

int ExerciseListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_exercises.size();
}

QVariant ExerciseListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_exercises.size()) return {};
    const Exercise& e = m_exercises[index.row()];
    switch (role) {
    case IdRole:        return e.id;
    case WorkoutIdRole: return e.workoutId;
    case NomRole:       return e.nom;
    case SetsRole:      return e.sets;
    case RepsRole:      return e.reps;
    case PoidsRole:     return e.poids;
    case FaitRole:      return e.fait;
    }
    return {};
}

QHash<int, QByteArray> ExerciseListModel::roleNames() const {
    return {
        { IdRole,        "exerciceId" },
        { WorkoutIdRole, "workoutId"  },
        { NomRole,       "nom"        },
        { SetsRole,      "sets"       },
        { RepsRole,      "reps"       },
        { PoidsRole,     "poids"      },
        { FaitRole,      "fait"       }
    };
}

void ExerciseListModel::loadFromDb(int workoutId) {
    beginResetModel();
    m_exercises.clear();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, workout_id, nom, sets, reps, poids, fait "
        "FROM workout_exercises WHERE workout_id = ? ORDER BY id ASC",
        { workoutId }
        );

    while (q.next()) {
        m_exercises.append({
            q.value(0).toInt(),
            q.value(1).toInt(),
            q.value(2).toString(),
            q.value(3).toInt(),
            q.value(4).toInt(),
            q.value(5).toDouble(),
            q.value(6).toBool()
        });
    }

    endResetModel();
}

void ExerciseListModel::clear() {
    beginResetModel();
    m_exercises.clear();
    endResetModel();
}

// ── WorkoutListModel ──────────────────────────────────────

WorkoutListModel::WorkoutListModel(QObject* parent)
    : QAbstractListModel(parent) {}

int WorkoutListModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_workouts.size();
}

QVariant WorkoutListModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_workouts.size()) return {};
    const Workout& w = m_workouts[index.row()];
    switch (role) {
    case IdRole:    return w.id;
    case NomRole:   return w.nom;
    case DureeRole: return w.duree;
    case DateRole:  return w.date;
    }
    return {};
}

QHash<int, QByteArray> WorkoutListModel::roleNames() const {
    return {
        { IdRole,    "workoutId" },
        { NomRole,   "nom"       },
        { DureeRole, "duree"     },
        { DateRole,  "date"      }
    };
}

void WorkoutListModel::loadFromDb() {
    beginResetModel();
    m_workouts.clear();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, nom, duree, date FROM workouts "
        "ORDER BY date DESC, id DESC LIMIT 20"
        );

    while (q.next()) {
        m_workouts.append({
            q.value(0).toInt(),
            q.value(1).toString(),
            q.value(2).toInt(),
            q.value(3).toString()
        });
    }

    endResetModel();
}

// ── ExerciseViewModel ─────────────────────────────────────

ExerciseViewModel::ExerciseViewModel(QObject* parent)
    : QObject(parent)
    , m_workouts(new WorkoutListModel(this))
    , m_exercises(new ExerciseListModel(this))
{
    m_workouts->loadFromDb();
}

WorkoutListModel*  ExerciseViewModel::workouts()  const { return m_workouts;  }
ExerciseListModel* ExerciseViewModel::exercises() const { return m_exercises; }
int  ExerciseViewModel::currentWorkoutId()        const { return m_currentWorkoutId; }
bool ExerciseViewModel::nouveauPR()               const { return m_nouveauPR; }
QString ExerciseViewModel::nomPR()                const { return m_nomPR; }
double ExerciseViewModel::poidsPR()               const { return m_poidsPR; }

void ExerciseViewModel::ajouterWorkout(const QString& nom)
{
    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom) VALUES (?)", { nom }
        );
    auto qFirstWorkoutBadge = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM badges WHERE code = 'FIRST_WORKOUT'"
        );

    if (qFirstWorkoutBadge.next() && qFirstWorkoutBadge.value(0).toInt() == 0) {
        DatabaseManager::instance().execQuery(
            "INSERT INTO badges (code, nom, description) "
            "VALUES (?, ?, ?)",
            {
                "FIRST_WORKOUT",
                "🥇 Première Séance",
                "Première séance créée"
            }
            );
    }
    m_workouts->loadFromDb();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    if (q.next()) {
        m_currentWorkoutId = q.value(0).toInt();
        m_exercises->loadFromDb(m_currentWorkoutId);
        auto qCount = DatabaseManager::instance().execQuery(
            "SELECT COUNT(*) FROM workouts"
            );

        if (qCount.next() && qCount.value(0).toInt() >= 10) {

            auto qTenWorkoutBadge = DatabaseManager::instance().execQuery(
                "SELECT COUNT(*) FROM badges WHERE code = 'TEN_WORKOUTS'"
                );

            if (qTenWorkoutBadge.next() && qTenWorkoutBadge.value(0).toInt() == 0) {

                DatabaseManager::instance().execQuery(
                    "INSERT INTO badges (code, nom, description) "
                    "VALUES (?, ?, ?)",
                    {
                        "TEN_WORKOUTS",
                        "💪 10 Séances",
                        "10 séances enregistrées"
                    }
                    );
            }
        }
        emit currentWorkoutChanged();
    }
}

void ExerciseViewModel::ajouterExercice(int workoutId, const QString& nom,
                                        int sets, int reps, double poids)
{
    // 1. Essai exact
    auto qCat = DatabaseManager::instance().execQuery(
        "SELECT categorie FROM exercises_library WHERE LOWER(nom) = LOWER(?) LIMIT 1",
        { nom }
        );

    QString categorie = "";
    if (qCat.next()) {
        categorie = qCat.value(0).toString();
    } else {
        // 2. Fallback fuzzy
        categorie = DatabaseManager::instance().trouverCategorieFuzzy(nom);
    }

    // (étape 3 : fallback IA, à ajouter plus tard si le fuzzy ne suffit pas)

    DatabaseManager::instance().execQuery(
        "INSERT INTO workout_exercises "
        "(workout_id, nom, categorie, sets, reps, poids) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        { workoutId, nom, categorie, sets, reps, poids }
        );

    m_exercises->loadFromDb(workoutId);
    emit currentWorkoutChanged();
}
void ExerciseViewModel::toggleFait(int exerciceId)
{
    DatabaseManager::instance().execQuery(
        "UPDATE workout_exercises SET fait = NOT fait WHERE id = ?",
        { exerciceId }
        );
    if (m_currentWorkoutId != -1)
        m_exercises->loadFromDb(m_currentWorkoutId);

    emit currentWorkoutChanged();
}

void ExerciseViewModel::supprimerWorkout(int workoutId)
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_exercises WHERE workout_id = ?", { workoutId }
        );
    DatabaseManager::instance().execQuery(
        "DELETE FROM workouts WHERE id = ?", { workoutId }
        );
    m_workouts->loadFromDb();
    if (m_currentWorkoutId == workoutId) {
        m_currentWorkoutId = -1;
        m_exercises->clear();
        emit currentWorkoutChanged();
    }
    emit currentWorkoutChanged();
}

void ExerciseViewModel::selectWorkout(int workoutId)
{
    m_currentWorkoutId = workoutId;
    m_exercises->loadFromDb(workoutId);
    emit currentWorkoutChanged();
}

void ExerciseViewModel::refresh()
{
    m_workouts->loadFromDb();
    if (m_currentWorkoutId != -1)
        m_exercises->loadFromDb(m_currentWorkoutId);
    emit currentWorkoutChanged();
}

int ExerciseViewModel::totalSeances() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workouts"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

int ExerciseViewModel::seancesSemaine() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workouts "
        "WHERE date >= date('now', '-6 days')"
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

int ExerciseViewModel::streakExercices() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT DISTINCT date FROM workouts ORDER BY date DESC"
        );

    int streak = 0;
    QDate expected = QDate::currentDate();

    while (q.next()) {
        QDate d = QDate::fromString(q.value(0).toString(), "yyyy-MM-dd");
        if (d == expected) {
            streak++;
            expected = expected.addDays(-1);
        } else {
            break;
        }
    }
    if (streak >= 7) {

        auto qBadge = DatabaseManager::instance().execQuery(
            "SELECT COUNT(*) FROM badges WHERE code = 'STREAK_7'"
            );

        if (qBadge.next() && qBadge.value(0).toInt() == 0) {

            DatabaseManager::instance().execQuery(
                "INSERT INTO badges (code, nom, description) "
                "VALUES (?, ?, ?)",
                {
                    "STREAK_7",
                    "🔥 Streak 7 jours",
                    "7 jours consécutifs d'entraînement"
                }
                );
        }
    }
    return streak;
}

void ExerciseViewModel::modifierExercice(int exerciceId, const QString& nom,
                                         int sets, int reps, double poids)
{
    DatabaseManager::instance().execQuery(
        "UPDATE workout_exercises SET nom=?, sets=?, reps=?, poids=? WHERE id=?",
        { nom, sets, reps, poids, exerciceId }
        );
    if (m_currentWorkoutId != -1)
        m_exercises->loadFromDb(m_currentWorkoutId);
    emit currentWorkoutChanged();
}

void ExerciseViewModel::supprimerExercice(int exerciceId)
{
    DatabaseManager::instance().execQuery(
        "DELETE FROM workout_exercises WHERE id=?", { exerciceId }
        );
    if (m_currentWorkoutId != -1)
        m_exercises->loadFromDb(m_currentWorkoutId);
    emit currentWorkoutChanged();
}

bool ExerciseViewModel::seanceTerminee() const { return m_seanceTerminee; }

void ExerciseViewModel::setSeanceTerminee(bool val) {
    m_seanceTerminee = val;
    emit seanceTermineeChanged();
}

int ExerciseViewModel::dernieresCalories() const { return m_dernieresCalories; }

void ExerciseViewModel::setDernieresCalories(int cal) {
    m_dernieresCalories = cal;
}

int ExerciseViewModel::calculerCaloriesBrulees(int workoutId) const
{
    auto qUser = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    double poids = 75.0;
    if (qUser.next()) poids = qUser.value(0).toDouble();

    auto q = DatabaseManager::instance().execQuery(
        "SELECT we.sets, we.reps, COALESCE(el.met_value, 5.0) "
        "FROM workout_exercises we "
        "LEFT JOIN exercises_library el ON el.nom = we.nom "
        "WHERE we.workout_id = ?",
        { workoutId }
        );

    double total = 0;
    while (q.next()) {
        int    sets = q.value(0).toInt();
        int    reps = q.value(1).toInt();
        double met  = q.value(2).isNull() ? 5.0 : q.value(2).toDouble();
        double dureeMin = (sets * reps * 3.0 + sets * 60.0) / 60.0;
        total += met * poids * dureeMin / 60.0;
    }

    return static_cast<int>(total * 1.1);
}

int ExerciseViewModel::nombreExercicesFaits() const {
    auto q = DatabaseManager::instance().execQuery(
        "SELECT COUNT(*) FROM workout_exercises WHERE workout_id = ? AND fait = 1",
        { m_currentWorkoutId }
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

QString ExerciseViewModel::labelDate(const QString& date) const
{
    QDate d = QDate::fromString(date, "yyyy-MM-dd");
    QDate today = QDate::currentDate();
    if (d == today)              return "Aujourd'hui";
    if (d == today.addDays(-1)) return "Hier";
    if (d == today.addDays(-2)) return "Il y a 2 jours";
    return d.toString("dddd dd MMMM");
}

int ExerciseViewModel::calculerVolume(int workoutId) const
{
    auto q = DatabaseManager::instance().execQuery(
        "SELECT SUM(sets * reps * poids) FROM workout_exercises WHERE workout_id = ?",
        { workoutId }
        );
    if (q.next()) return q.value(0).toInt();
    return 0;
}

// ── Records personnels (PR) ───────────────────────────────

bool ExerciseViewModel::verifierEtSauvegarderPR(int workoutId,
                                                const QString& nom,
                                                int reps, double poids)
{
    auto qSets = DatabaseManager::instance().execQuery(
        "SELECT sets FROM workout_exercises "
        "WHERE workout_id = ? AND nom = ? "
        "ORDER BY id DESC LIMIT 1",
        { workoutId, nom }
        );

    int sets = 1;

    if (qSets.next())
        sets = qSets.value(0).toInt();

    double volumeSerie = sets * reps * poids;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids, reps, volume FROM personal_records "
        "WHERE exercice_nom = ? "
        "ORDER BY volume DESC LIMIT 1",
        { nom }
        );

    bool estNouveauPR = false;

    if (!q.next()) {
        estNouveauPR = true;
    } else {
        double ancienVolume = q.value(2).toDouble();
        double ancienPoids  = q.value(0).toDouble();

        if (volumeSerie > ancienVolume || poids > ancienPoids)
            estNouveauPR = true;
    }

    if (estNouveauPR) {

        DatabaseManager::instance().execQuery(
            "INSERT INTO personal_records "
            "(exercice_nom, poids, reps, volume, date, workout_id) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            { nom, poids, reps, volumeSerie,
             QDate::currentDate().toString("yyyy-MM-dd"),
             workoutId }
            );

        auto qBadge = DatabaseManager::instance().execQuery(
            "SELECT COUNT(*) FROM badges WHERE code = 'FIRST_PR'"
            );

        if (qBadge.next() && qBadge.value(0).toInt() == 0) {
            DatabaseManager::instance().execQuery(
                "INSERT INTO badges (code, nom, description) "
                "VALUES (?, ?, ?)",
                {
                    "FIRST_PR",
                    "🏆 Premier Record",
                    "Premier record personnel obtenu"
                }
                );
        }

        m_nouveauPR = true;
        m_nomPR     = nom;
        m_poidsPR   = poids;

        emit prChanged();

        qDebug() << "🏆 Nouveau PR !" << nom
                 << poids << "kg ×" << reps;
    }

    return estNouveauPR;
}

void ExerciseViewModel::resetPR()
{
    m_nouveauPR = false;
    m_nomPR     = "";
    m_poidsPR   = 0;
    emit prChanged();
}