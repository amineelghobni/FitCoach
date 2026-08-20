#pragma once

#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QVariantList>
#include <QVariantMap>

// ─────────────────────────────────────────────────────────────
// Exercise
// ─────────────────────────────────────────────────────────────

struct Exercise
{
    int     id = -1;
    int     workoutId = -1;
    QString nom;
    int     sets = 0;
    int     reps = 0;
    double  poids = 0.0;
    bool    fait = false;
};

// ─────────────────────────────────────────────────────────────
// Workout
// ─────────────────────────────────────────────────────────────

struct Workout
{
    int     id = -1;
    QString nom;
    int     duree = 0;
    QString date;
};

// ─────────────────────────────────────────────────────────────
// ExerciseListModel
// ─────────────────────────────────────────────────────────────

class ExerciseListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles
    {
        IdRole = Qt::UserRole + 1,
        WorkoutIdRole,
        NomRole,
        SetsRole,
        RepsRole,
        PoidsRole,
        FaitRole
    };

    explicit ExerciseListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void loadFromDb(int workoutId);
    void clear();

private:
    QList<Exercise> m_exercises;
};

// ─────────────────────────────────────────────────────────────
// WorkoutListModel
// ─────────────────────────────────────────────────────────────

class WorkoutListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles
    {
        IdRole = Qt::UserRole + 1,
        NomRole,
        DureeRole,
        DateRole
    };

    explicit WorkoutListModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void loadFromDb();

private:
    QList<Workout> m_workouts;
};

// ─────────────────────────────────────────────────────────────
// ExerciseViewModel
// ─────────────────────────────────────────────────────────────

class ExerciseViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        WorkoutListModel* workouts
            READ workouts
                CONSTANT
        )

    Q_PROPERTY(
        ExerciseListModel* exercises
            READ exercises
                CONSTANT
        )

    Q_PROPERTY(
        int currentWorkoutId
            READ currentWorkoutId
                NOTIFY currentWorkoutChanged
        )

    Q_PROPERTY(
        int totalSeances
            READ totalSeances
                NOTIFY currentWorkoutChanged
        )

    Q_PROPERTY(
        int seancesSemaine
            READ seancesSemaine
                NOTIFY currentWorkoutChanged
        )

    Q_PROPERTY(
        int streakExercices
            READ streakExercices
                NOTIFY currentWorkoutChanged
        )

    Q_PROPERTY(
        bool seanceTerminee
            READ seanceTerminee
                NOTIFY seanceTermineeChanged
        )

    Q_PROPERTY(
        int nombreExercicesFaits
            READ nombreExercicesFaits
                NOTIFY currentWorkoutChanged
        )

    Q_PROPERTY(
        int dernieresCalories
            READ dernieresCalories
                NOTIFY seanceTermineeChanged
        )

    Q_PROPERTY(
        bool nouveauPR
            READ nouveauPR
                NOTIFY prChanged
        )

    Q_PROPERTY(
        QString nomPR
            READ nomPR
                NOTIFY prChanged
        )

    Q_PROPERTY(
        double poidsPR
            READ poidsPR
                NOTIFY prChanged
        )

public:
    explicit ExerciseViewModel(QObject* parent = nullptr);

    // ────────────────────────────────────────────────────────
    // Models
    // ────────────────────────────────────────────────────────

    WorkoutListModel* workouts() const;
    ExerciseListModel* exercises() const;

    // ────────────────────────────────────────────────────────
    // Workout state
    // ────────────────────────────────────────────────────────

    int currentWorkoutId() const;
    int totalSeances() const;
    int seancesSemaine() const;
    int streakExercices() const;

    // ────────────────────────────────────────────────────────
    // Session state
    // ────────────────────────────────────────────────────────

    bool seanceTerminee() const;
    int nombreExercicesFaits() const;
    int dernieresCalories() const;

    // ────────────────────────────────────────────────────────
    // Workout / exercise actions
    // ────────────────────────────────────────────────────────

    Q_INVOKABLE void ajouterWorkout(const QString& nom);

    Q_INVOKABLE void ajouterExercice(
        int workoutId,
        const QString& nom,
        int sets,
        int reps,
        double poids
        );

    Q_INVOKABLE void toggleFait(int exerciceId);

    Q_INVOKABLE void supprimerWorkout(int workoutId);

    Q_INVOKABLE void selectWorkout(int workoutId);

    Q_INVOKABLE void refresh();

    Q_INVOKABLE void modifierExercice(
        int exerciceId,
        const QString& nom,
        int sets,
        int reps,
        double poids
        );

    Q_INVOKABLE void supprimerExercice(int exerciceId);

    // ────────────────────────────────────────────────────────
    // Session
    // ────────────────────────────────────────────────────────

    Q_INVOKABLE void setSeanceTerminee(bool val);
    Q_INVOKABLE void setDernieresCalories(int cal);

    // ────────────────────────────────────────────────────────
    // Calculations
    // ────────────────────────────────────────────────────────

    Q_INVOKABLE int calculerCaloriesBrulees(int workoutId) const;
    Q_INVOKABLE QString labelDate(const QString& date) const;
    Q_INVOKABLE int calculerVolume(int workoutId) const;

    // ────────────────────────────────────────────────────────
    // Personal records
    // ────────────────────────────────────────────────────────

    bool nouveauPR() const;
    const QString& nomPR() const;
    double poidsPR() const;

    Q_INVOKABLE void resetPR();

    Q_INVOKABLE bool verifierEtSauvegarderPR(
        int workoutId,
        const QString& nom,
        int reps,
        double poids
        );

signals:
    // ────────────────────────────────────────────────────────
    // General state
    // ────────────────────────────────────────────────────────

    void currentWorkoutChanged();
    void seanceTermineeChanged();
    void prChanged();

    // ────────────────────────────────────────────────────────
    // Achievement / badge system
    //
    // Emitted only when one or more NEW badges are actually
    // unlocked. The QVariantList contains QVariantMap objects:
    //
    // {
    //     "nom": "...",
    //     "description": "..."
    // }
    //
    // This allows QML to display a single notification for
    // one or multiple unlocked badges.
    // ────────────────────────────────────────────────────────

    void badgesDebloques(const QVariantList& badges);

private:
    // ────────────────────────────────────────────────────────
    // Achievement checks
    //
    // Each function returns only the badges unlocked during
    // the current action. Existing badges are never returned.
    // ────────────────────────────────────────────────────────

    QVariantList verifierBadgesSeances();
    QVariantList verifierBadgesPR();
    QVariantList verifierBadgesStreak();

    // ────────────────────────────────────────────────────────
    // Models
    // ────────────────────────────────────────────────────────

    WorkoutListModel* m_workouts = nullptr;
    ExerciseListModel* m_exercises = nullptr;

    // ────────────────────────────────────────────────────────
    // Current workout
    // ────────────────────────────────────────────────────────

    int m_currentWorkoutId = -1;

    // ────────────────────────────────────────────────────────
    // Session state
    // ────────────────────────────────────────────────────────

    bool m_seanceTerminee = false;
    int m_dernieresCalories = 0;

    // ────────────────────────────────────────────────────────
    // Personal record state
    // ────────────────────────────────────────────────────────

    bool m_nouveauPR = false;
    QString m_nomPR;
    double m_poidsPR = 0.0;
};