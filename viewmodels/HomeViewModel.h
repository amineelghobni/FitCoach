#pragma once
#include <QObject>
#include <QString>

class HomeViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool   isFirstLaunch READ isFirstLaunch CONSTANT)
    Q_PROPERTY(QString userNom      READ userNom      NOTIFY userNomChanged)
    Q_PROPERTY(int    calories      READ calories     NOTIFY dataChanged)
    Q_PROPERTY(int    caloriesMax   READ caloriesMax  NOTIFY dataChanged)
    Q_PROPERTY(double proteines     READ proteines    NOTIFY dataChanged)
    Q_PROPERTY(double glucides      READ glucides     NOTIFY dataChanged)
    Q_PROPERTY(double lipides       READ lipides      NOTIFY dataChanged)
    Q_PROPERTY(int caloriesObjectif READ caloriesObjectif NOTIFY dataChanged)
    Q_INVOKABLE void setCaloriesObjectif(int objectif);
    int caloriesObjectif() const;
    Q_PROPERTY(int caloriesBrulees READ caloriesBrulees NOTIFY dataChanged)

public:
    explicit HomeViewModel(QObject* parent = nullptr);

    bool    isFirstLaunch() const;
    QString userNom()       const;
    int     calories()      const;
    int     caloriesMax()   const;
    double  proteines()     const;
    double  glucides()      const;
    double  lipides()       const;
    int caloriesBrulees() const;

    Q_INVOKABLE void completeOnboarding(const QString& nom, int age,
                                        double poids, int taille,
                                        const QString& objectif,
                                        const QString& niveau,
                                        int joursSemaine,
                                        const QString& equipement);
    Q_INVOKABLE void refresh();

signals:
    void userNomChanged();
    void dataChanged();
};