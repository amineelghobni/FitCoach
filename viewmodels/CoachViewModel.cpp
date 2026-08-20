#include "CoachViewModel.h"
#include "../database/DatabaseManager.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkRequest>
#include <QTime>
#include <QFile>
#include <QFileInfo>
#include <QDate>
#include "config.local.h"

// ── ChatModel ─────────────────────────────────────────────

ChatModel::ChatModel(QObject* parent)
    : QAbstractListModel(parent) {}

int ChatModel::rowCount(const QModelIndex& parent) const {
    if (parent.isValid()) return 0;
    return m_messages.size();
}

QVariant ChatModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_messages.size()) return {};
    const ChatMessage& m = m_messages[index.row()];
    switch (role) {
    case RoleRole:    return m.role;
    case ContenuRole: return m.contenu;
    case HeureRole:   return m.heure;
    }
    return {};
}

QHash<int, QByteArray> ChatModel::roleNames() const {
    return {
        { RoleRole,    "msgRole"  },
        { ContenuRole, "contenu"  },
        { HeureRole,   "heure"    }
    };
}

void ChatModel::ajouterMessage(const QString& role, const QString& contenu) {
    beginInsertRows({}, m_messages.size(), m_messages.size());
    m_messages.append({
        role,
        contenu,
        QTime::currentTime().toString("HH:mm")
    });
    endInsertRows();
}

void ChatModel::clear() {
    beginResetModel();
    m_messages.clear();
    endResetModel();
}

QList<ChatMessage> ChatModel::messages() const {
    return m_messages;
}

// ── CoachViewModel ────────────────────────────────────────

CoachViewModel::CoachViewModel(QObject* parent)
    : QObject(parent)
    , m_chatModel(new ChatModel(this))
    , m_network(new QNetworkAccessManager(this))
{
    // ── Charge l'historique depuis la BDD ─────
    auto q = DatabaseManager::instance().execQuery(
        "SELECT role, contenu, date FROM coach_messages "
        "ORDER BY id ASC"
        );

    bool hasHistory = false;
    while (q.next()) {
        hasHistory = true;
        m_chatModel->ajouterMessage(
            q.value(0).toString(),
            q.value(1).toString()
            );
    }

    // Message de bienvenue seulement si pas d'historique
    if (!hasHistory) {
        QString welcome = "Bonjour ! Je suis ton coach IA personnel. "
                          "Je connais ton profil, tes repas et tes séances. "
                          "Comment puis-je t'aider aujourd'hui ? 💪";

        m_chatModel->ajouterMessage("assistant", welcome);

        DatabaseManager::instance().execQuery(
            "INSERT INTO coach_messages (role, contenu) VALUES (?, ?)",
            { "assistant", welcome }
            );
    }
}

ChatModel* CoachViewModel::messages() const { return m_chatModel; }
bool       CoachViewModel::loading()  const { return m_loading;   }

QString CoachViewModel::construireContexte() const
{
    QString contexte = "Tu es un coach fitness et nutrition personnel. ";
    contexte += "Tu es motivant, bienveillant et professionnel. ";
    contexte += "Réponds toujours en français. ";
    contexte += "Voici les données de l'utilisateur :\n\n";

    // Profil
    auto qUser = DatabaseManager::instance().execQuery(
        "SELECT nom, age, poids, taille, objectif, niveau FROM users LIMIT 1"
        );
    if (qUser.next()) {
        contexte += "PROFIL:\n";
        contexte += "- Nom: "      + qUser.value(0).toString() + "\n";
        contexte += "- Âge: "      + qUser.value(1).toString() + " ans\n";
        contexte += "- Poids: "    + qUser.value(2).toString() + " kg\n";
        contexte += "- Taille: "   + qUser.value(3).toString() + " cm\n";
        contexte += "- Objectif: " + qUser.value(4).toString() + "\n";
        contexte += "- Niveau: "   + qUser.value(5).toString() + "\n\n";
    }

    // Repas du jour
    // NOUVEAU
    auto qMeals = DatabaseManager::instance().execQuery(
        "SELECT nom, calories, proteines, glucides, lipides, moment "
        "FROM meals WHERE date = ? ORDER BY heure ASC",
        { QDate::currentDate().toString("yyyy-MM-dd") }
        );
    contexte += "REPAS D'AUJOURD'HUI:\n";
    bool hasMeals = false;
    while (qMeals.next()) {
        hasMeals = true;
        contexte += "- " + qMeals.value(0).toString()
                    + " (" + qMeals.value(5).toString() + ")"
                    + " : " + qMeals.value(1).toString() + " kcal"
                    + " | P:" + qMeals.value(2).toString() + "g"
                    + " G:" + qMeals.value(3).toString() + "g"
                    + " L:" + qMeals.value(4).toString() + "g\n";
    }
    if (!hasMeals) contexte += "- Aucun repas enregistré\n";
    contexte += "\n";

    // Séances récentes
    auto qWorkouts = DatabaseManager::instance().execQuery(
        "SELECT nom, date FROM workouts ORDER BY date DESC LIMIT 5"
        );
    contexte += "SÉANCES RÉCENTES:\n";
    bool hasWorkouts = false;
    while (qWorkouts.next()) {
        hasWorkouts = true;
        contexte += "- " + qWorkouts.value(0).toString()
                    + " (" + qWorkouts.value(1).toString() + ")\n";
    }
    if (!hasWorkouts) contexte += "- Aucune séance enregistrée\n";
    contexte += "\n";

    // Poids actuel
    auto qPoids = DatabaseManager::instance().execQuery(
        "SELECT poids, date FROM weight_history ORDER BY date DESC LIMIT 1"
        );
    if (qPoids.next()) {
        contexte += "POIDS ACTUEL: " + qPoids.value(0).toString()
        + " kg (le " + qPoids.value(1).toString() + ")\n";
    }

    return contexte;
}

void CoachViewModel::envoyerMessage(const QString& texte)
{
    if (texte.trimmed().isEmpty() || m_loading) return;

    m_chatModel->ajouterMessage("user", texte);
    emit messageRecu();

    // Sauvegarde message user en BDD
    DatabaseManager::instance().execQuery(
        "INSERT INTO coach_messages (role, contenu) VALUES (?, ?)",
        { "user", texte }
        );

    appelAPI(texte);
}

void CoachViewModel::appelAPI(const QString& userMessage)
{
    m_loading = true;
    emit loadingChanged();

    QJsonArray messagesArray;

    // Système
    QJsonObject systemMsg;
    systemMsg["role"]    = "system";
    systemMsg["content"] = construireContexte();
    messagesArray.append(systemMsg);

    // Historique — max 20 derniers messages
    QList<ChatMessage> allMessages = m_chatModel->messages();
    int start = qMax(0, allMessages.size() - 20);
    for (int i = start; i < allMessages.size(); i++) {
        const ChatMessage& msg = allMessages[i];
        if (msg.role == "assistant" &&
            msg.contenu.startsWith("Bonjour ! Je suis ton coach"))
            continue;

        QJsonObject m;
        m["role"]    = msg.role;
        m["content"] = msg.contenu;
        messagesArray.append(m);
    }

    QJsonObject body;
    body["model"]       = "openai/gpt-oss-120b";
    body["messages"]    = messagesArray;
    body["max_tokens"]  = 1024;
    body["temperature"] = 0.7;

    QString apiKey = GROQ_API_KEY;

    QUrl apiUrl("https://api.groq.com/openai/v1/chat/completions");
    QNetworkRequest request(apiUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer " + apiKey).toUtf8());

    auto* reply = m_network->post(request, QJsonDocument(body).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        m_loading = false;
        emit loadingChanged();

        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Erreur réseau:" << reply->errorString();
            m_chatModel->ajouterMessage("assistant",
                                        "Désolé, je n'arrive pas à me connecter. "
                                        "Vérifie ta connexion internet. 🔌"
                                        );
            emit messageRecu();
            reply->deleteLater();
            return;
        }

        auto responseData = reply->readAll();
        auto doc          = QJsonDocument::fromJson(responseData);
        auto choices      = doc["choices"].toArray();

        if (!choices.isEmpty()) {
            QString reponse = choices[0].toObject()
            ["message"].toObject()
                ["content"].toString();

            m_chatModel->ajouterMessage("assistant", reponse);
            emit messageRecu();

            // Sauvegarde réponse IA en BDD
            DatabaseManager::instance().execQuery(
                "INSERT INTO coach_messages (role, contenu) VALUES (?, ?)",
                { "assistant", reponse }
                );
        } else {
            m_chatModel->ajouterMessage("assistant",
                                        "Je n'ai pas pu générer de réponse. Réessaie ! 🤔"
                                        );
            emit messageRecu();
        }

        reply->deleteLater();
    });
}

void CoachViewModel::clearChat()
{
    m_chatModel->clear();

    // Efface aussi la BDD
    DatabaseManager::instance().execQuery("DELETE FROM coach_messages");

    QString welcome = "Chat réinitialisé ! Comment puis-je t'aider ? 💪";
    m_chatModel->ajouterMessage("assistant", welcome);

    DatabaseManager::instance().execQuery(
        "INSERT INTO coach_messages (role, contenu) VALUES (?, ?)",
        { "assistant", welcome }
        );
}

bool    CoachViewModel::analyzing()   const { return m_analyzing;   }
QString CoachViewModel::photoResult() const { return m_photoResult; }
int     CoachViewModel::photoCal()    const { return m_photoCal;    }
double  CoachViewModel::photoProt()   const { return m_photoProt;   }
double  CoachViewModel::photoGluc()   const { return m_photoGluc;   }
double  CoachViewModel::photoLip()    const { return m_photoLip;    }
QString CoachViewModel::photoNom()    const { return m_photoNom;    }

void CoachViewModel::resetPhoto() {
    m_photoResult = "";
    m_photoCal    = 0;
    m_photoProt   = 0;
    m_photoGluc   = 0;
    m_photoLip    = 0;
    m_photoNom    = "";
    emit photoResultChanged();
}

void CoachViewModel::analyserPhoto(const QString& imagePath)
{
    QString path = imagePath;
    if (path.startsWith("file:///"))
        path = path.mid(8);
    else if (path.startsWith("file://"))
        path = path.mid(7);

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "❌ Impossible d'ouvrir l'image:" << path;
        return;
    }

    QByteArray imageData   = file.readAll();
    QString    base64Image = imageData.toBase64();
    file.close();

    QString ext = QFileInfo(path).suffix().toLower();
    QString mimeType = "image/jpeg";
    if (ext == "png")  mimeType = "image/png";
    if (ext == "webp") mimeType = "image/webp";

    m_analyzing = true;
    emit analyzingChanged();

    QJsonObject imageUrl;
    imageUrl["url"] = "data:" + mimeType + ";base64," + base64Image;

    QJsonObject imageContent;
    imageContent["type"]      = "image_url";
    imageContent["image_url"] = imageUrl;

    QJsonObject textContent;
    textContent["type"] = "text";
    textContent["text"] = R"(
Analyse cette photo de repas et retourne UNIQUEMENT un JSON valide sans markdown, sans ```json, juste le JSON brut :
{
  "nom": "nom du repas en français",
  "calories": nombre entier,
  "proteines": nombre décimal,
  "glucides": nombre décimal,
  "lipides": nombre décimal,
  "description": "courte description en français"
}
Estime les quantités visuellement. Sois précis.
)";

    QJsonArray contentArray;
    contentArray.append(textContent);
    contentArray.append(imageContent);

    QJsonObject userMessage;
    userMessage["role"]    = "user";
    userMessage["content"] = contentArray;

    QJsonArray messages;
    messages.append(userMessage);

    QJsonObject body;
    body["model"]      = "qwen/qwen3.6-27b";
    body["messages"]   = messages;
    body["max_tokens"] = 300;

    QString apiKey = GROQ_API_KEY;

    QUrl apiUrl("https://api.groq.com/openai/v1/chat/completions");
    QNetworkRequest request(apiUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", QString("Bearer " + apiKey).toUtf8());

    auto* reply = m_network->post(request, QJsonDocument(body).toJson());

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        m_analyzing = false;
        emit analyzingChanged();

        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "❌ Erreur:" << reply->errorString();
            reply->deleteLater();
            return;
        }

        auto responseData = reply->readAll();
        qDebug() << "Réponse photo:" << responseData;

        auto doc     = QJsonDocument::fromJson(responseData);
        auto choices = doc["choices"].toArray();

        if (!choices.isEmpty()) {
            QString content = choices[0].toObject()
            ["message"].toObject()
                ["content"].toString();

            auto parsed = QJsonDocument::fromJson(content.toUtf8());
            if (!parsed.isNull() && parsed.isObject()) {
                auto obj      = parsed.object();
                m_photoNom    = obj["nom"].toString();
                m_photoCal    = obj["calories"].toInt();
                m_photoProt   = obj["proteines"].toDouble();
                m_photoGluc   = obj["glucides"].toDouble();
                m_photoLip    = obj["lipides"].toDouble();
                m_photoResult = obj["description"].toString();
                emit photoResultChanged();
            } else {
                qDebug() << "❌ JSON invalide:" << content;
            }
        }

        reply->deleteLater();
    });
}
void CoachViewModel::envoyerMessageAuto(const QString& texte)
{
    // Sauvegarde en BDD
    DatabaseManager::instance().execQuery(
        "INSERT INTO coach_messages (role, contenu) VALUES (?, ?)",
        { "user", texte }
        );

    m_chatModel->ajouterMessage("user", texte);
    emit messageRecu();

    appelAPI(texte);
}