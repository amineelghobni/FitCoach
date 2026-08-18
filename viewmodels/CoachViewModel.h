#pragma once
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>

struct ChatMessage {
    QString role;
    QString contenu;
    QString heure;
};

class ChatModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        RoleRole    = Qt::UserRole + 1,
        ContenuRole,
        HeureRole
    };

    explicit ChatModel(QObject* parent = nullptr);

    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void ajouterMessage(const QString& role, const QString& contenu);
    void clear();
    QList<ChatMessage> messages() const;

private:
    QList<ChatMessage> m_messages;
};

class CoachViewModel : public QObject
{
    Q_OBJECT

    // ── Chat ──────────────────────────────────
    Q_PROPERTY(ChatModel* messages READ messages CONSTANT)
    Q_PROPERTY(bool       loading  READ loading  NOTIFY loadingChanged)

    // ── Photo IA ──────────────────────────────
    Q_PROPERTY(bool    analyzing   READ analyzing   NOTIFY analyzingChanged)
    Q_PROPERTY(QString photoResult READ photoResult NOTIFY photoResultChanged)
    Q_PROPERTY(int     photoCal    READ photoCal    NOTIFY photoResultChanged)
    Q_PROPERTY(double  photoProt   READ photoProt   NOTIFY photoResultChanged)
    Q_PROPERTY(double  photoGluc   READ photoGluc   NOTIFY photoResultChanged)
    Q_PROPERTY(double  photoLip    READ photoLip    NOTIFY photoResultChanged)
    Q_PROPERTY(QString photoNom    READ photoNom    NOTIFY photoResultChanged)
public:
    Q_INVOKABLE void envoyerMessageAuto(const QString& texte);

public:
    explicit CoachViewModel(QObject* parent = nullptr);

    // Chat
    ChatModel* messages() const;
    bool       loading()  const;

    Q_INVOKABLE void envoyerMessage(const QString& texte);
    Q_INVOKABLE void clearChat();

    // Photo IA
    bool    analyzing()   const;
    QString photoResult() const;
    int     photoCal()    const;
    double  photoProt()   const;
    double  photoGluc()   const;
    double  photoLip()    const;
    QString photoNom()    const;

    Q_INVOKABLE void analyserPhoto(const QString& imagePath);
    Q_INVOKABLE void resetPhoto();

signals:
    void loadingChanged();
    void messageRecu();
    void analyzingChanged();
    void photoResultChanged();

private:
    void    appelAPI(const QString& userMessage);
    QString construireContexte() const;

    ChatModel*             m_chatModel;
    QNetworkAccessManager* m_network;

    // Chat
    bool m_loading = false;

    // Photo
    bool    m_analyzing   = false;
    QString m_photoResult = "";
    int     m_photoCal    = 0;
    double  m_photoProt   = 0;
    double  m_photoGluc   = 0;
    double  m_photoLip    = 0;
    QString m_photoNom    = "";
};