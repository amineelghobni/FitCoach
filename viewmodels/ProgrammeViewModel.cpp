#include "ProgrammeViewModel.h"
#include "../database/DatabaseManager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QDate>
#include "config.local.h"

ProgrammeViewModel::ProgrammeViewModel(QObject* parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
{}

bool        ProgrammeViewModel::loading()         const { return m_loading; }
bool        ProgrammeViewModel::hasProgramme()    const { return !m_seance.nom.isEmpty(); }
QString     ProgrammeViewModel::nomSeance()       const { return m_seance.nom; }
QString     ProgrammeViewModel::categorieSeance() const { return m_seance.categorie; }

QVariantList ProgrammeViewModel::exercices() const {
    QVariantList list;
    for (const auto& ex : m_seance.exercices) {
        QVariantMap map;
        map["nom"]       = ex.nom;
        map["muscle"]    = ex.muscle;
        map["sets"]      = ex.sets;
        map["reps"]      = ex.reps;
        map["poids"]     = ex.poids;
        map["met"]       = ex.met;
        list.append(map);
    }
    return list;
}

int ProgrammeViewModel::caloriesEstimees() const {
    // Profil utilisateur
    auto q = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    double poids = 75.0;
    if (q.next()) poids = q.value(0).toDouble();

    double total = 0;
    for (const auto& ex : m_seance.exercices) {
        // Durée estimée : sets × reps × 3 secondes + repos 60s
        double dureeMin = (ex.sets * ex.reps * 3.0 + ex.sets * 60.0) / 60.0;
        total += ex.met * poids * dureeMin / 60.0;
    }
    return static_cast<int>(total * 1.1); // +10% pour l'échauffement
}

QString ProgrammeViewModel::determinerProchaineMuscle() const
{
    // Regarde les séances des 3 derniers jours
    auto q = DatabaseManager::instance().execQuery(
        "SELECT w.nom FROM workouts w "
        "WHERE w.date >= date('now', '-3 days') "
        "ORDER BY w.date DESC LIMIT 5"
        );

    QStringList muscles_faits;
    while (q.next()) {
        QString nom = q.value(0).toString().toLower();
        if (nom.contains("push") || nom.contains("poitrine") || nom.contains("épaule"))
            muscles_faits << "Push";
        else if (nom.contains("pull") || nom.contains("dos") || nom.contains("bicep"))
            muscles_faits << "Pull";
        else if (nom.contains("leg") || nom.contains("jambe") || nom.contains("squat"))
            muscles_faits << "Legs";
        else if (nom.contains("core") || nom.contains("abdo"))
            muscles_faits << "Core";
    }

    // Rotation Push → Pull → Legs → Core
    QStringList rotation = {"Push", "Pull", "Legs", "Core"};
    for (const QString& cat : rotation) {
        if (!muscles_faits.contains(cat)) return cat;
    }

    // Si tout fait récemment, reprend Push
    return "Push";
}

QString ProgrammeViewModel::construirePrompt() const
{
    auto qUser = DatabaseManager::instance().execQuery(
        "SELECT niveau, equipement, objectif, poids FROM users LIMIT 1"
        );

    QString niveau = "debutant";
    QString equipement = "aucun";
    QString objectif = "maintien";
    double poids = 75.0;

    if (qUser.next()) {
        niveau     = qUser.value(0).toString();
        equipement = qUser.value(1).toString();
        objectif   = qUser.value(2).toString();
        poids      = qUser.value(3).toDouble();
    }

    QString categorie = determinerProchaineMuscle();

    // Récupère les exercices disponibles selon équipement et niveau
    QString niveauFilter;
    if (niveau == "debutant")
        niveauFilter = "'debutant'";
    else if (niveau == "intermediaire")
        niveauFilter = "'debutant','intermediaire'";
    else
        niveauFilter = "'debutant','intermediaire','avance'";

    auto qEx = DatabaseManager::instance().execQuery(
        "SELECT nom, muscle_principal, met_value "   // ← retire sets_recommandes
        "FROM exercises_library "
        "WHERE (equipement = ? OR equipement = 'aucun') "
        "AND niveau IN (" + niveauFilter + ") "
                             "AND categorie = ? "
                             "LIMIT 20",
        { equipement, categorie }
        );

    QStringList exercicesDisponibles;
    while (qEx.next()) {
        exercicesDisponibles << qEx.value(0).toString()
        + " (" + qEx.value(1).toString() + ")";
    }

    QString prompt = "Tu es un coach fitness expert. "
                     "Génère une séance d'entraînement en JSON. "
                     "Réponds UNIQUEMENT avec le JSON brut, sans markdown.\n\n"
                     "Profil:\n"
                     "- Niveau: " + niveau + "\n"
                                "- Équipement: " + equipement + "\n"
                                    "- Objectif: " + objectif + "\n"
                                  "- Poids: " + QString::number(poids) + " kg\n"
                                                "- Type de séance: " + categorie + "\n\n"
                                   "Exercices disponibles (utilise UNIQUEMENT le nom avant la parenthèse, sans le muscle):\n"
                                    + exercicesDisponibles.join("\n") + "\n\n"
                                                         "Format JSON exact:\n"
                                                         "{\n"
                                                         "  \"nom\": \"nom de la séance\",\n"
                                                         "  \"categorie\": \"" + categorie + "\",\n"
                                   "  \"exercices\": [\n"
                                   "    {\n"
                                   "      \"nom\": \"nom exact de l'exercice\",\n"
                                   "      \"sets\": 3,\n"
                                   "      \"reps\": 10,\n"
                                   "      \"poids\": 0\n"
                                   "    }\n"
                                   "  ]\n"
                                   "}\n"
                                   "Inclus 4-6 exercices adaptés au niveau et à l'objectif.";

    return prompt;
}

void ProgrammeViewModel::genererProgramme()
{
    m_loading = true;
    emit loadingChanged();

    QString apiKey = GROQ_API_KEY;

    QJsonObject userMsg;
    userMsg["role"]    = "user";
    userMsg["content"] = construirePrompt();

    QJsonArray messages;
    messages.append(userMsg);

    QJsonObject body;
    body["model"]       = "openai/gpt-oss-120b";
    body["messages"]    = messages;
    body["max_tokens"]  = 1000;
    body["temperature"] = 0.7;

    QUrl apiUrl("https://api.groq.com/openai/v1/chat/completions");
    QNetworkRequest request(apiUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer " + apiKey).toUtf8());

    auto* reply = m_network->post(request, QJsonDocument(body).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        m_loading = false;
        emit loadingChanged();

        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "❌ Erreur:" << reply->errorString();
            reply->deleteLater();
            return;
        }

        auto doc     = QJsonDocument::fromJson(reply->readAll());
        auto choices = doc["choices"].toArray();

        if (!choices.isEmpty()) {
            QString content = choices[0].toObject()
            ["message"].toObject()
                ["content"].toString();

            // Nettoie le JSON
            content = content.trimmed();
            if (content.startsWith("```")) {
                content = content.mid(content.indexOf('\n') + 1);
                content = content.left(content.lastIndexOf("```"));
            }

            parserReponseIA(content);
        }

        reply->deleteLater();
    });
}

void ProgrammeViewModel::parserReponseIA(const QString& json)
{
    auto doc = QJsonDocument::fromJson(json.toUtf8());
    if (doc.isNull() || !doc.isObject()) {
        qDebug() << "❌ JSON invalide:" << json;
        return;
    }

    auto obj = doc.object();
    m_seance.nom       = obj["nom"].toString();
    m_seance.categorie = obj["categorie"].toString();
    m_seance.exercices.clear();

    auto exercices = obj["exercices"].toArray();
    for (const auto& ex : exercices) {
        auto exObj = ex.toObject();
        QString nomEx = exObj["nom"].toString();

        // Récupère le MET depuis la BDD
        auto qMet = DatabaseManager::instance().execQuery(
            "SELECT met_value, muscle_principal FROM exercises_library "
            "WHERE nom = ? LIMIT 1",
            { nomEx }
            );

        double met    = 5.0;
        QString muscle = "";
        if (qMet.next()) {
            met    = qMet.value(0).toDouble();
            muscle = qMet.value(1).toString();
        }

        m_seance.exercices.append({
            0,
            nomEx,
            muscle,
            "",
            exObj["sets"].toInt(3),
            exObj["reps"].toInt(10),
            exObj["poids"].toDouble(0),
            met
        });
    }

    emit programmeChanged();
    qDebug() << "✅ Programme généré:" << m_seance.nom
             << "avec" << m_seance.exercices.size() << "exercices";
}

void ProgrammeViewModel::adopterSeance()
{
    if (m_seance.nom.isEmpty()) return;

    DatabaseManager::instance().execQuery(
        "INSERT INTO workouts (nom, date) VALUES (?, ?)",
        { m_seance.nom, QDate::currentDate().toString("yyyy-MM-dd") }
        );

    auto q = DatabaseManager::instance().execQuery(
        "SELECT id FROM workouts ORDER BY id DESC LIMIT 1"
        );
    if (!q.next()) return;
    int workoutId = q.value(0).toInt();

    for (const auto& ex : m_seance.exercices) {
        auto qCat = DatabaseManager::instance().execQuery(
            "SELECT categorie FROM exercises_library WHERE LOWER(nom) = LOWER(?) LIMIT 1",
            { ex.nom }
            );
        QString categorie = "";
        if (qCat.next()) categorie = qCat.value(0).toString();

        DatabaseManager::instance().execQuery(
            "INSERT INTO workout_exercises "
            "(workout_id, nom, categorie, sets, reps, poids) VALUES (?, ?, ?, ?, ?, ?)",
            { workoutId, ex.nom, categorie, ex.sets, ex.reps, ex.poids }
            );
    }

    emit seanceAdoptee(workoutId);
    qDebug() << "✅ Séance adoptée ! ID:" << workoutId;
}

void ProgrammeViewModel::modifierExercice(int index, int sets, int reps, double poids)
{
    if (index < 0 || index >= m_seance.exercices.size()) return;
    m_seance.exercices[index].sets  = sets;
    m_seance.exercices[index].reps  = reps;
    m_seance.exercices[index].poids = poids;
    emit programmeChanged();
}

void ProgrammeViewModel::supprimerExercice(int index)
{
    if (index < 0 || index >= m_seance.exercices.size()) return;
    m_seance.exercices.removeAt(index);
    emit programmeChanged();
}

void ProgrammeViewModel::terminerSeance(int workoutId, int dureeMinutes)
{
    // Calcule calories brûlées
    auto qUser = DatabaseManager::instance().execQuery(
        "SELECT poids FROM users LIMIT 1"
        );
    double poids = 75.0;
    if (qUser.next()) poids = qUser.value(0).toDouble();

    double totalCalories = 0;
    auto qEx = DatabaseManager::instance().execQuery(
        "SELECT we.sets, we.reps, el.met_value "
        "FROM workout_exercises we "
        "LEFT JOIN exercises_library el ON el.nom = we.nom "
        "WHERE we.workout_id = ?",
        { workoutId }
        );

    while (qEx.next()) {
        int    sets = qEx.value(0).toInt();
        int    reps = qEx.value(1).toInt();
        double met = qEx.value(2).isNull() ? 5.0 : qEx.value(2).toDouble();

        double dureeExMin = (sets * reps * 3.0 + sets * 60.0) / 60.0;
        totalCalories += met * poids * dureeExMin / 60.0;
    }

    int calories = static_cast<int>(totalCalories * 1.1);

    // Met à jour la durée et les calories dans workouts
    DatabaseManager::instance().execQuery(
        "UPDATE workouts SET duree = ?, calories_brulees = ? WHERE id = ?",
        { dureeMinutes, calories, workoutId }
        );

    qDebug() << "✅ Séance terminée ! Calories brûlées:" << calories;
}