#pragma once

#include <QObject>
#include <QTimer>
#include <QList>
#include <QVariantList>
#include "../services/ExerciseService.h"

struct SessionExercice
{
    int id = -1;
    QString nom;
    int sets = 0;
    int reps = 0;
    double poids = 0.0;
    QList<bool> seriesFaites;

    double dernierPoids = 0.0;
    int dernieresReps = 0;
    int dernierSets = 0;
    bool aHistorique = false;
};

class SessionViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool actif
                   READ actif
                       NOTIFY sessionChanged)

    Q_PROPERTY(int exerciceIndex
                   READ exerciceIndex
                       NOTIFY sessionChanged)

    Q_PROPERTY(int totalExercices
                   READ totalExercices
                       NOTIFY sessionChanged)

    Q_PROPERTY(QString nomExercice
                   READ nomExercice
                       NOTIFY sessionChanged)

    Q_PROPERTY(int setsTotal
                   READ setsTotal
                       NOTIFY sessionChanged)

    Q_PROPERTY(int setsFaits
                   READ setsFaits
                       NOTIFY sessionChanged)

    Q_PROPERTY(int reps
                   READ reps
                       NOTIFY sessionChanged)

    Q_PROPERTY(double poids
                   READ poids
                       NOTIFY sessionChanged)

    Q_PROPERTY(QVariantList seriesFaites
                   READ seriesFaites
                       NOTIFY sessionChanged)

    Q_PROPERTY(bool timerActif
                   READ timerActif
                       NOTIFY timerChanged)

    Q_PROPERTY(int timerRestant
                   READ timerRestant
                       NOTIFY timerChanged)

    Q_PROPERTY(int timerDuree
                   READ timerDuree
                       NOTIFY timerChanged)

    Q_PROPERTY(int dureeSeance
                   READ dureeSeance
                       NOTIFY dureeChanged)

    Q_PROPERTY(int workoutId
                   READ workoutId
                       NOTIFY sessionChanged)
    Q_PROPERTY(double dernierPoids READ dernierPoids NOTIFY sessionChanged)
    Q_PROPERTY(int dernieresReps READ dernieresReps NOTIFY sessionChanged)
    Q_PROPERTY(int dernierSets READ dernierSets NOTIFY sessionChanged)
    Q_PROPERTY(bool aHistorique READ aHistorique NOTIFY sessionChanged)
    Q_PROPERTY(QVariantList historiqueExercice READ historiqueExercice NOTIFY sessionChanged)

public:
    explicit SessionViewModel(QObject* parent = nullptr);

    // ────────────────────────────────────────────────────────
    // Session state
    // ────────────────────────────────────────────────────────

    bool actif() const;
    int exerciceIndex() const;
    int totalExercices() const;
    QString nomExercice() const;
    int setsTotal() const;
    int setsFaits() const;
    int reps() const;
    double poids() const;
    QVariantList seriesFaites() const;
    int dureeSeance() const;
    int workoutId() const;

    double dernierPoids() const;
    int dernieresReps() const;
    int dernierSets() const;
    bool aHistorique() const;

    // ────────────────────────────────────────────────────────
    // Rest timer
    // ────────────────────────────────────────────────────────

    bool timerActif() const;
    int timerRestant() const;
    int timerDuree() const;

    // ────────────────────────────────────────────────────────
    // Session actions
    // ────────────────────────────────────────────────────────

    Q_INVOKABLE void demarrerSession(int workoutId);
    Q_INVOKABLE void terminerSerie();
    Q_INVOKABLE void exerciceSuivant();
    Q_INVOKABLE void exercicePrecedent();
    QVariantList historiqueExercice() const;

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

    // Message destiné à l'interface pour afficher
    // une erreur ou un avertissement non bloquant.
    void erreurSession(const QString& message);

private slots:
    void onTimerTick();
    void onDureeTick();

private:
    void demarrerTimer();

    QList<SessionExercice> m_exercices;

    int m_exerciceIndex = 0;
    int m_workoutId = -1;
    bool m_actif = false;

    // ────────────────────────────────────────────────────────
    // Rest timer
    // ────────────────────────────────────────────────────────

    QTimer* m_timer = nullptr;
    int m_timerRestant = 0;
    int m_timerDuree = 90;
    bool m_timerActif = false;

    // ────────────────────────────────────────────────────────
    // Session duration
    // ────────────────────────────────────────────────────────

    QTimer* m_dureeTimer = nullptr;
    int m_dureeSeance = 0;

    ExerciseService* m_exerciseService = nullptr;
};