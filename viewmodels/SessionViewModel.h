#pragma once
#include <QObject>
#include <QTimer>
#include <QList>
#include <QVariantList>

struct SessionExercice {
    int     id;
    QString nom;
    int     sets;
    int     reps;
    double  poids;
    QList<bool> seriesFaites;
};

class SessionViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool    actif            READ actif            NOTIFY sessionChanged)
    Q_PROPERTY(int     exerciceIndex    READ exerciceIndex    NOTIFY sessionChanged)
    Q_PROPERTY(int     totalExercices   READ totalExercices   NOTIFY sessionChanged)
    Q_PROPERTY(QString nomExercice      READ nomExercice      NOTIFY sessionChanged)
    Q_PROPERTY(int     setsTotal        READ setsTotal        NOTIFY sessionChanged)
    Q_PROPERTY(int     setsFaits        READ setsFaits        NOTIFY sessionChanged)
    Q_PROPERTY(int     reps             READ reps             NOTIFY sessionChanged)
    Q_PROPERTY(double  poids            READ poids            NOTIFY sessionChanged)
    Q_PROPERTY(QVariantList seriesFaites READ seriesFaites   NOTIFY sessionChanged)

    Q_PROPERTY(bool    timerActif       READ timerActif       NOTIFY timerChanged)
    Q_PROPERTY(int     timerRestant     READ timerRestant     NOTIFY timerChanged)
    Q_PROPERTY(int     timerDuree       READ timerDuree       NOTIFY timerChanged)

    Q_PROPERTY(int     dureeSeance      READ dureeSeance      NOTIFY dureeChanged)
    Q_PROPERTY(int     workoutId        READ workoutId        NOTIFY sessionChanged)

public:
    explicit SessionViewModel(QObject* parent = nullptr);

    bool        actif()          const;
    int         exerciceIndex()  const;
    int         totalExercices() const;
    QString     nomExercice()    const;
    int         setsTotal()      const;
    int         setsFaits()      const;
    int         reps()           const;
    double      poids()          const;
    QVariantList seriesFaites()  const;
    bool        timerActif()     const;
    int         timerRestant()   const;
    int         timerDuree()     const;
    int         dureeSeance()    const;
    int         workoutId()      const;

    Q_INVOKABLE void demarrerSession(int workoutId);
    Q_INVOKABLE void terminerSerie();
    Q_INVOKABLE void exerciceSuivant();
    Q_INVOKABLE void exercicePrecedent();
    Q_INVOKABLE void setTimerDuree(int secondes);
    Q_INVOKABLE void stopperTimer();
    Q_INVOKABLE void terminerSession();
    Q_INVOKABLE void annulerSession();

signals:
    void sessionChanged();
    void timerChanged();
    void dureeChanged();
    void timerTermine();
    void sessionTerminee(int workoutId, int dureeMinutes);

private slots:
    void onTimerTick();
    void onDureeTick();

private:
    void chargerExercice(int index);
    void demarrerTimer();

    QList<SessionExercice> m_exercices;
    int     m_exerciceIndex  = 0;
    int     m_workoutId      = -1;
    bool    m_actif          = false;

    // Timer repos
    QTimer* m_timer;
    int     m_timerRestant   = 0;
    int     m_timerDuree     = 90;
    bool    m_timerActif     = false;

    // Durée séance
    QTimer* m_dureeTimer;
    int     m_dureeSeance    = 0;
};