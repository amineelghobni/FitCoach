#pragma once
#include <QObject>
#include <QAbstractListModel>
#include <QList>
#include <QDate>

struct Meal {
    int     id;
    QString nom;
    int     calories;
    double  proteines;
    double  glucides;
    double  lipides;
    QString moment;
    QString heure;
};

class MealModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole        = Qt::UserRole + 1,
        NomRole,
        CaloriesRole,
        ProteinesRole,
        GlucidesRole,
        LipidesRole,
        MomentRole,
        HeureRole
    };

    explicit MealModel(QObject* parent = nullptr);

    int      rowCount(const QModelIndex& parent = {}) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void loadFromDb(const QString& date);
    void clear();

private:
    QList<Meal> m_meals;
};

class NutritionViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(MealModel* meals             READ meals             CONSTANT)
    Q_PROPERTY(int        totalCalories     READ totalCalories     NOTIFY totalsChanged)
    Q_PROPERTY(double     totalProteines    READ totalProteines    NOTIFY totalsChanged)
    Q_PROPERTY(double     totalGlucides     READ totalGlucides     NOTIFY totalsChanged)
    Q_PROPERTY(double     totalLipides      READ totalLipides      NOTIFY totalsChanged)
    Q_PROPERTY(QString    currentDate       READ currentDate       NOTIFY dateChanged)
    Q_PROPERTY(QString    currentDateDisplay READ currentDateDisplay NOTIFY dateChanged)
    Q_PROPERTY(bool       isToday          READ isToday           NOTIFY dateChanged)

public:
    explicit NutritionViewModel(QObject* parent = nullptr);

    MealModel* meals()              const;
    int        totalCalories()      const;
    double     totalProteines()     const;
    double     totalGlucides()      const;
    double     totalLipides()       const;
    QString    currentDate()        const;
    QString    currentDateDisplay() const;
    bool       isToday()            const;

    Q_INVOKABLE void ajouterRepas(const QString& nom, int calories,
                                  double proteines, double glucides,
                                  double lipides, const QString& moment);
    Q_INVOKABLE void supprimerRepas(int id);
    Q_INVOKABLE void modifierRepas(int id, const QString& nom, int calories,
                                   double proteines, double glucides,
                                   double lipides, const QString& moment);
    Q_INVOKABLE void previousDay();
    Q_INVOKABLE void nextDay();
    Q_INVOKABLE void goToToday();
    Q_INVOKABLE void refresh();

signals:
    void totalsChanged();
    void dateChanged();

private:
    MealModel* m_mealModel;
    QDate      m_currentDate;
};