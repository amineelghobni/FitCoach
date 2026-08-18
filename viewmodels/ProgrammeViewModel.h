#pragma once
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>

struct ExerciceSuggere {
    int     id;
    QString nom;
    QString muscle;
    QString equipement;
    int     sets;
    int     reps;
    double  poids;
    double  met;
};

struct SeanceSuggeree {
    int     id;
    QString nom;
    QString categorie;
    QList<ExerciceSuggere> exercices;
};

class ProgrammeViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool    loading       READ loading       NOTIFY loadingChanged)
    Q_PROPERTY(bool    hasProgramme  READ hasProgramme  NOTIFY programmeChanged)
    Q_PROPERTY(QString nomSeance     READ nomSeance     NOTIFY programmeChanged)
    Q_PROPERTY(QString categorieSeance READ categorieSeance NOTIFY programmeChanged)
    Q_PROPERTY(QVariantList exercices READ exercices    NOTIFY programmeChanged)
    Q_PROPERTY(int     caloriesEstimees READ caloriesEstimees NOTIFY programmeChanged)

public:
    explicit ProgrammeViewModel(QObject* parent = nullptr);

    bool        loading()           const;
    bool        hasProgramme()      const;
    QString     nomSeance()         const;
    QString     categorieSeance()   const;
    QVariantList exercices()        const;
    int         caloriesEstimees()  const;

    Q_INVOKABLE void genererProgramme();
    Q_INVOKABLE void adopterSeance();
    Q_INVOKABLE void modifierExercice(int index, int sets, int reps, double poids);
    Q_INVOKABLE void supprimerExercice(int index);
    Q_INVOKABLE void terminerSeance(int workoutId, int dureeMinutes);

signals:
    void loadingChanged();
    void programmeChanged();
    void seanceAdoptee(int workoutId);

private:
    QString determinerProchaineMuscle() const;
    QString construirePrompt() const;
    void    parserReponseIA(const QString& json);

    QNetworkAccessManager* m_network;
    bool                   m_loading = false;
    SeanceSuggeree         m_seance;
};