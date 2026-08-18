#include "SessionViewModel.h"
#include "../database/DatabaseManager.h"


SessionViewModel::SessionViewModel(QObject* parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_dureeTimer(new QTimer(this))
{
    m_timer->setInterval(1000);
    connect(m_timer, &QTimer::timeout, this, &SessionViewModel::onTimerTick);

    m_dureeTimer->setInterval(1000);
    connect(m_dureeTimer, &QTimer::timeout, this, &SessionViewModel::onDureeTick);
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

int SessionViewModel::setsFaits() const {
    if (m_exerciceIndex < m_exercices.size()) {
        int count = 0;
        for (bool b : m_exercices[m_exerciceIndex].seriesFaites)
            if (b) count++;
        return count;
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

void SessionViewModel::demarrerSession(int workoutId)
{
    m_workoutId = workoutId;
    m_exercices.clear();
    m_exerciceIndex = 0;
    m_dureeSeance   = 0;
    m_actif         = true;

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id, nom, sets, reps, poids FROM workout_exercises "
        "WHERE workout_id = ? ORDER BY id ASC",
        { workoutId }
        );

    while (q.next()) {
        SessionExercice ex;
        ex.id    = q.value(0).toInt();
        ex.nom   = q.value(1).toString();
        ex.sets  = q.value(2).toInt();
        ex.reps  = q.value(3).toInt();
        ex.poids = q.value(4).toDouble();
        ex.seriesFaites = QList<bool>(ex.sets, false);
        m_exercices.append(ex);
    }

    m_dureeTimer->start();
    emit sessionChanged();
    qDebug() << "✅ Session démarrée avec" << m_exercices.size() << "exercices";
}

void SessionViewModel::terminerSerie()
{
    if (m_exerciceIndex >= m_exercices.size()) return;

    auto& ex = m_exercices[m_exerciceIndex];

    // Coche la prochaine série non faite
    for (int i = 0; i < ex.seriesFaites.size(); i++) {
        if (!ex.seriesFaites[i]) {
            ex.seriesFaites[i] = true;

            // Met à jour en BDD
            DatabaseManager::instance().execQuery(
                "UPDATE workout_exercises SET fait = 1 WHERE id = ?",
                { ex.id }
                );

            // Démarre le timer de repos si pas la dernière série
            bool toutFait = true;
            for (bool b : ex.seriesFaites)
                if (!b) { toutFait = false; break; }

            if (!toutFait)
                demarrerTimer();

            emit sessionChanged();
            return;
        }
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
    m_timerDuree = secondes;
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
    m_timerRestant--;
    emit timerChanged();

    if (m_timerRestant <= 0) {
        m_timer->stop();
        m_timerActif = false;
        emit timerChanged();
        emit timerTermine();
    }
}

void SessionViewModel::onDureeTick()
{
    m_dureeSeance++;
    emit dureeChanged();
}

void SessionViewModel::terminerSession()
{
    m_timer->stop();
    m_dureeTimer->stop();
    m_actif = false;

    int dureeMin = m_dureeSeance / 60;
    emit sessionTerminee(m_workoutId, dureeMin);
    emit sessionChanged();
}

void SessionViewModel::annulerSession()
{
    m_timer->stop();
    m_dureeTimer->stop();
    m_actif         = false;
    m_exercices.clear();
    m_workoutId     = -1;
    m_dureeSeance   = 0;
    emit sessionChanged();
}