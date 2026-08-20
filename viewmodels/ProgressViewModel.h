#pragma once
#include <QObject>
#include <QVariantList>

class ProgressViewModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double poidsActuel      READ poidsActuel      NOTIFY dataChanged)
    Q_PROPERTY(double poidsInitial     READ poidsInitial     NOTIFY dataChanged)
    Q_PROPERTY(double poidsDiff        READ poidsDiff        NOTIFY dataChanged)
    Q_PROPERTY(int    totalSeances     READ totalSeances     NOTIFY dataChanged)
    Q_PROPERTY(int    streakJours      READ streakJours      NOTIFY dataChanged)
    Q_PROPERTY(int    totalRepas       READ totalRepas       NOTIFY dataChanged)
    Q_PROPERTY(QVariantList poidsHistory   READ poidsHistory   NOTIFY dataChanged)
    Q_PROPERTY(QVariantList caloriesWeek  READ caloriesWeek   NOTIFY dataChanged)
    Q_PROPERTY(QVariantList topPRs        READ topPRs         NOTIFY dataChanged)
    Q_PROPERTY(QVariantList badges READ badges NOTIFY dataChanged)
    Q_PROPERTY(QVariantList progressionBadges READ progressionBadges NOTIFY dataChanged)
    Q_PROPERTY(QVariantList repartitionMusculaire READ repartitionMusculaire NOTIFY dataChanged)

public:
    explicit ProgressViewModel(QObject* parent = nullptr);

    double       poidsActuel()             const;
    double       poidsInitial()            const;
    double       poidsDiff()               const;
    int          totalSeances()            const;
    int          streakJours()             const;
    int          totalRepas()              const;
    QVariantList poidsHistory()            const;
    QVariantList caloriesWeek()            const;
    QVariantList topPRs()                  const;
    QVariantList repartitionMusculaire()   const;
    QVariantList badges() const;
    QVariantList progressionBadges() const;

    Q_INVOKABLE void ajouterPoids(double poids);
    Q_INVOKABLE void refresh();

signals:
    void dataChanged();
};