#pragma once
#include <QObject>
#include <QAbstractListModel>
#include <QList>

struct Exercise {
    int     id;
    int     workoutId;
    QString nom;
    int     sets;
    int     reps;
    double  poids;
    bool    fait;
};

struct Workout {
    int     id;
    QString nom;
    int     duree;
    QString date;
};

class ExerciseListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole       = Qt::UserRole + 1,
        WorkoutIdRole,
        NomRole,
        SetsRole,
        RepsRole,
        PoidsRole,
        FaitRole
    };
    explicit ExerciseListModel(QObject* parent = nullptr);
    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void loadFromDb(int workoutId);
    void clear();
private:
    QList<Exercise> m_exercises;
};

class WorkoutListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        IdRole   = Qt::UserRole + 1,
        NomRole,
        DureeRole,
        DateRole
    };
    explicit WorkoutListModel(QObject* parent = nullptr);
    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void loadFromDb();
private:
    QList<Workout> m_workouts;
};

class ExerciseViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(WorkoutListModel*  workouts          READ workouts          CONSTANT)
    Q_PROPERTY(ExerciseListModel* exercises         READ exercises         CONSTANT)
    Q_PROPERTY(int  currentWorkoutId                READ currentWorkoutId  NOTIFY currentWorkoutChanged)
    Q_PROPERTY(int  totalSeances                    READ totalSeances      NOTIFY currentWorkoutChanged)
    Q_PROPERTY(int  seancesSemaine                  READ seancesSemaine    NOTIFY currentWorkoutChanged)
    Q_PROPERTY(int  streakExercices                 READ streakExercices   NOTIFY currentWorkoutChanged)
    Q_PROPERTY(bool seanceTerminee                  READ seanceTerminee    NOTIFY seanceTermineeChanged)
    Q_PROPERTY(int  nombreExercicesFaits            READ nombreExercicesFaits NOTIFY currentWorkoutChanged)
    Q_PROPERTY(int  dernieresCalories               READ dernieresCalories NOTIFY seanceTermineeChanged)

public:
    explicit ExerciseViewModel(QObject* parent = nullptr);

    WorkoutListModel*  workouts()            const;
    ExerciseListModel* exercises()           const;
    int                currentWorkoutId()    const;
    int                totalSeances()        const;
    int                seancesSemaine()      const;
    int                streakExercices()     const;
    bool               seanceTerminee()      const;
    int                nombreExercicesFaits()const;
    int                dernieresCalories()   const;

    Q_INVOKABLE void ajouterWorkout(const QString& nom);
    Q_INVOKABLE void ajouterExercice(int workoutId, const QString& nom,
                                     int sets, int reps, double poids);
    Q_INVOKABLE void toggleFait(int exerciceId);
    Q_INVOKABLE void supprimerWorkout(int workoutId);
    Q_INVOKABLE void selectWorkout(int workoutId);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void modifierExercice(int exerciceId, const QString& nom,
                                      int sets, int reps, double poids);
    Q_INVOKABLE void supprimerExercice(int exerciceId);
    Q_INVOKABLE void setSeanceTerminee(bool val);
    Q_INVOKABLE void setDernieresCalories(int cal);
    Q_INVOKABLE int  calculerCaloriesBrulees(int workoutId) const;
    Q_INVOKABLE QString labelDate(const QString& date) const;
    Q_INVOKABLE int calculerVolume(int workoutId) const;
    Q_PROPERTY(bool   nouveauPR     READ nouveauPR     NOTIFY prChanged)
    Q_PROPERTY(QString nomPR        READ nomPR         NOTIFY prChanged)
    Q_PROPERTY(double poidsPR       READ poidsPR       NOTIFY prChanged)

    bool    nouveauPR() const;
    QString nomPR()     const;
    double  poidsPR()   const;

    Q_INVOKABLE void resetPR();
    Q_INVOKABLE bool verifierEtSauvegarderPR(int workoutId, const QString& nom,
                                             int reps, double poids);

signals:
    void prChanged();



signals:
    void currentWorkoutChanged();
    void seanceTermineeChanged();

private:
    WorkoutListModel*  m_workouts;
    ExerciseListModel* m_exercises;
    int                m_currentWorkoutId  = -1;
    bool               m_seanceTerminee    = false;
    int                m_dernieresCalories = 0;
private:
    bool    m_nouveauPR = false;
    QString m_nomPR     = "";
    double  m_poidsPR   = 0;
};