#pragma once

#include <QObject>
#include <QVariantList>

class ExerciseService : public QObject
{
    Q_OBJECT

public:
    explicit ExerciseService(QObject* parent = nullptr);

    Q_INVOKABLE QVariantList historiqueExercice(
        const QString& nomExercice,
        int workoutId
        ) const;

    Q_INVOKABLE QVariantMap dernierePerformance(
        const QString& nomExercice,
        int workoutId
        ) const;
    Q_INVOKABLE QVariantMap statistiquesExercice(
        const QString& nomExercice
        ) const;

    Q_INVOKABLE QVariantList progressionExercice(
        const QString& nomExercice
        ) const;
    Q_INVOKABLE QVariantMap suggestionProgression(
        const QString& nomExercice
        ) const;
};