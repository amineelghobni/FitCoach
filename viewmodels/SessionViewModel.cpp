#include "SessionViewModel.h"
#include "../database/DatabaseManager.h"
#include <algorithm>


SessionViewModel::SessionViewModel(QObject* parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_dureeTimer(new QTimer(this))
    , m_exerciseService(new ExerciseService(this))
{
    m_timer->setInterval(1000);
    connect(m_timer, &QTimer::timeout,
            this, &SessionViewModel::onTimerTick);

    m_dureeTimer->setInterval(1000);
    connect(m_dureeTimer, &QTimer::timeout,
            this, &SessionViewModel::onDureeTick);
}



bool        SessionViewModel::actif()         const { return m_actif; }
int         SessionViewModel::exerciceIndex() const { return m_exerciceIndex; }
int         SessionViewModel::totalExercices()const { return m_exercices.size(); }
int         SessionViewModel::workoutId()     const { return m_workoutId; }
bool        SessionViewModel::timerActif()    const { return m_timerActif; }
int         SessionViewModel::timerRestant()  const { return m_timerRestant; }
int         SessionViewModel::timerDuree()    const { return m_timerDuree; }
int         SessionViewModel::dureeSeance()   const { return m_dureeSeance; }

QString SessionViewModel::nomExercice() const {
    if (m_exerciceIndex < m_exercices.size())
        return m_exercices[m_exerciceIndex].nom;
    return "";
}

int SessionViewModel::setsTotal() const {
    if (m_exerciceIndex < m_exercices.size())
        return m_exercices[m_exerciceIndex].sets;
    return 0;
}

int SessionViewModel::setsFaits() const
{
    if (m_exerciceIndex < m_exercices.size()) {
        const auto& series = m_exercices[m_exerciceIndex].seriesFaites;

        return static_cast<int>(
            std::count_if(
                series.cbegin(),
                series.cend(),
                [](bool fait) {
                    return fait;
                }
                )
        );
    }

    return 0;
}

int SessionViewModel::reps() const {
    if (m_exerciceIndex < m_exercices.size())
        return m_exercices[m_exerciceIndex].reps;
    return 0;
}

double SessionViewModel::poids() const {
    if (m_exerciceIndex < m_exercices.size())
        return m_exercices[m_exerciceIndex].poids;
    return 0;
}

QVariantList SessionViewModel::seriesFaites() const {
    QVariantList list;
    if (m_exerciceIndex < m_exercices.size())
        for (bool b : m_exercices[m_exerciceIndex].seriesFaites)
            list.append(b);
    return list;
}

double SessionViewModel::dernierPoids() const
{
    if (m_exerciceIndex >= 0 &&
        m_exerciceIndex < m_exercices.size()) {
        return m_exercices[m_exerciceIndex].dernierPoids;
    }

    return 0.0;
}

int SessionViewModel::dernieresReps() const
{
    if (m_exerciceIndex >= 0 &&
        m_exerciceIndex < m_exercices.size()) {
        return m_exercices[m_exerciceIndex].dernieresReps;
    }

    return 0;
}

int SessionViewModel::dernierSets() const
{
    if (m_exerciceIndex >= 0 &&
        m_exerciceIndex < m_exercices.size()) {
        return m_exercices[m_exerciceIndex].dernierSets;
    }

    return 0;
}

bool SessionViewModel::aHistorique() const
{
    if (m_exerciceIndex >= 0 &&
        m_exerciceIndex < m_exercices.size()) {
        return m_exercices[m_exerciceIndex].aHistorique;
    }

    return false;
}

void SessionViewModel::demarrerSession(int workoutId)
{
    if (m_actif) {
        emit erreurSession("Une séance est déjà en cours.");
        return;
    }

    if (workoutId < 0) {
        emit erreurSession("Séance invalide.");
        return;
    }

    // Arrêt propre des timers précédents.
    stopperTimer();
    m_dureeTimer->stop();

    // Réinitialisation de la session.
    m_workoutId = workoutId;
    m_exercices.clear();
    m_exerciceIndex = 0;
    m_dureeSeance = 0;
    m_actif = false;

    // Charge les exercices de la séance.
    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, nom, sets, reps, poids "
        "FROM workout_exercises "
        "WHERE workout_id = ? "
        "ORDER BY id ASC",
        { workoutId }
        );

    while (q.next()) {
        SessionExercice ex;

        ex.id = q.value(0).toInt();
        ex.nom = q.value(1).toString();
        ex.sets = qMax(0, q.value(2).toInt());
        ex.reps = qMax(0, q.value(3).toInt());
        ex.poids = qMax(0.0, q.value(4).toDouble());

        // Toutes les séries commencent comme non réalisées.
        ex.seriesFaites = QList<bool>(ex.sets, false);

        // Récupère la dernière performance réelle
        // grâce au service dédié.
        const QVariantMap dernierePerformance =
            m_exerciseService->dernierePerformance(
                ex.nom,
                workoutId
                );

        if (!dernierePerformance.isEmpty()) {
            ex.dernierPoids =
                dernierePerformance.value("poids").toDouble();

            ex.dernieresReps =
                dernierePerformance.value("reps").toInt();

            // Le nombre exact de séries sera récupéré
            // depuis l'historique complet lorsque nécessaire.
            ex.dernierSets =
                dernierePerformance.value("sets").toInt();

            ex.aHistorique = true;
        }

        m_exercices.append(ex);
    }

    // Une séance sans exercice ne doit pas démarrer.
    if (m_exercices.isEmpty()) {
        m_workoutId = -1;
        m_exerciceIndex = 0;

        emit sessionChanged();

        emit erreurSession(
            "Impossible de démarrer cette séance : "
            "aucun exercice n'est enregistré."
            );

        return;
    }

    // La séance est maintenant active.
    m_actif = true;

    // Démarre le chronomètre de séance.
    m_dureeTimer->start();

    emit sessionChanged();
    emit dureeChanged();

    qDebug() << "✅ Session démarrée avec"
             << m_exercices.size()
             << "exercices";
}

void SessionViewModel::terminerSerie()
{
    if (!m_actif)
        return;

    if (m_exerciceIndex < 0 ||
        m_exerciceIndex >= m_exercices.size()) {
        return;
    }

    auto& ex = m_exercices[m_exerciceIndex];

    for (int i = 0; i < ex.seriesFaites.size(); ++i) {

        if (ex.seriesFaites[i])
            continue;

        // La série qui vient d'être réalisée.
        ex.seriesFaites[i] = true;

        const int numeroSerie = i + 1;

        // Enregistre la performance réellement réalisée.
        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_sets "
            "(workout_exercise_id, numero_serie, poids, reps) "
            "VALUES (?, ?, ?, ?)",
            {
                ex.id,
                numeroSerie,
                ex.poids,
                ex.reps
            }
            );

        // L'exercice n'est terminé que lorsque toutes
        // les séries ont été réalisées.
        const bool exerciceTermine = std::all_of(
            ex.seriesFaites.cbegin(),
            ex.seriesFaites.cend(),
            [](bool fait) {
                return fait;
            }
            );

        DatabaseManager::instance().execQuery(
            "UPDATE workout_exercises "
            "SET fait = ? "
            "WHERE id = ?",
            {
                exerciceTermine ? 1 : 0,
                ex.id
            }
            );

        if (!exerciceTermine)
            demarrerTimer();
        else
            stopperTimer();

        emit sessionChanged();
        return;
    }
}
void SessionViewModel::exerciceSuivant()
{
    if (m_exerciceIndex < m_exercices.size() - 1) {
        m_exerciceIndex++;
        stopperTimer();
        emit sessionChanged();
    }
}

void SessionViewModel::exercicePrecedent()
{
    if (m_exerciceIndex > 0) {
        m_exerciceIndex--;
        stopperTimer();
        emit sessionChanged();
    }
}

void SessionViewModel::setTimerDuree(int secondes)
{
    const int duree = qBound(1, secondes, 600);

    if (m_timerDuree == duree)
        return;

    m_timerDuree = duree;

    if (m_timerActif) {
        m_timerRestant = m_timerDuree;
    }

    emit timerChanged();
}
void SessionViewModel::demarrerTimer()
{
    m_timerRestant = m_timerDuree;
    m_timerActif   = true;
    m_timer->start();
    emit timerChanged();
}

void SessionViewModel::stopperTimer()
{
    m_timer->stop();
    m_timerActif   = false;
    m_timerRestant = 0;
    emit timerChanged();
}

void SessionViewModel::onTimerTick()
{
    if (!m_timerActif)
        return;

    if (m_timerRestant > 0)
        --m_timerRestant;

    if (m_timerRestant <= 0) {
        m_timerRestant = 0;
        m_timer->stop();
        m_timerActif = false;

        emit timerChanged();
        emit timerTermine();
        return;
    }

    emit timerChanged();
}

void SessionViewModel::onDureeTick()
{
    m_dureeSeance++;
    emit dureeChanged();
}

void SessionViewModel::terminerSession()
{
    if (!m_actif)
        return;

    m_timer->stop();
    m_dureeTimer->stop();

    m_timerActif = false;
    m_timerRestant = 0;
    m_actif = false;

    const int dureeMin = m_dureeSeance / 60;

    emit timerChanged();
    emit dureeChanged();
    emit sessionTerminee(m_workoutId, dureeMin);
    emit sessionChanged();
}

void SessionViewModel::annulerSession()
{
    m_timer->stop();
    m_dureeTimer->stop();

    m_timerActif = false;
    m_timerRestant = 0;

    m_actif = false;
    m_exercices.clear();
    m_workoutId = -1;
    m_exerciceIndex = 0;
    m_dureeSeance = 0;

    emit timerChanged();
    emit dureeChanged();
    emit sessionChanged();
}
QVariantList SessionViewModel::historiqueExercice() const
{
    if (m_exerciceIndex < 0 ||
        m_exerciceIndex >= m_exercices.size()) {
        return {};
    }

    const auto& ex = m_exercices[m_exerciceIndex];

    return m_exerciseService->historiqueExercice(
        ex.nom,
        m_workoutId
        );
}