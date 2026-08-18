#pragma once
#include <QObject>
#include <QString>

class ProfileViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString nom          READ nom          NOTIFY dataChanged)
    Q_PROPERTY(int     age          READ age          NOTIFY dataChanged)
    Q_PROPERTY(double  poids        READ poids        NOTIFY dataChanged)
    Q_PROPERTY(int     taille       READ taille       NOTIFY dataChanged)
    Q_PROPERTY(QString objectif     READ objectif     NOTIFY dataChanged)
    Q_PROPERTY(QString niveau       READ niveau       NOTIFY dataChanged)
    Q_PROPERTY(int     joursSemaine READ joursSemaine NOTIFY dataChanged)
    Q_PROPERTY(QString equipement   READ equipement   NOTIFY dataChanged)

public:
    explicit ProfileViewModel(QObject* parent = nullptr);

    QString nom()          const;
    int     age()          const;
    double  poids()        const;
    int     taille()       const;
    QString objectif()     const;
    QString niveau()       const;
    int     joursSemaine() const;
    QString equipement()   const;

    Q_INVOKABLE void sauvegarder(const QString& nom, int age,
                                 double poids, int taille,
                                 const QString& objectif,
                                 const QString& niveau,
                                 int joursSemaine,
                                 const QString& equipement);

signals:
    void dataChanged();
};