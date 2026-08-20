#include "DatabaseManager.h"

DatabaseManager& DatabaseManager::instance()
{
    static DatabaseManager instance;
    return instance;
}

DatabaseManager::DatabaseManager(QObject* parent)
    : QObject(parent)
{
    if (openDatabase()) {
        createTables();
        qDebug() << "✅ Base de données ouverte";
    } else {
        qDebug() << "❌ Erreur ouverture BDD";
    }
}

bool DatabaseManager::openDatabase()
{
    QString path = QStandardPaths::writableLocation(
        QStandardPaths::AppDataLocation);
    QDir().mkpath(path);

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(path + "/fitcoach.db");

    return m_db.open();
}

void DatabaseManager::createTables()
{
    execQuery(R"(
        CREATE TABLE IF NOT EXISTS users (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            nom           TEXT    NOT NULL,
            age           INTEGER,
            poids         REAL,
            taille        INTEGER,
            objectif      TEXT,
            niveau        TEXT,
            jours_semaine INTEGER,
            equipement    TEXT,
            created_at    TEXT DEFAULT (datetime('now'))
        )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS meals (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            nom       TEXT    NOT NULL,
            calories  INTEGER DEFAULT 0,
            proteines REAL    DEFAULT 0,
            glucides  REAL    DEFAULT 0,
            lipides   REAL    DEFAULT 0,
            moment    TEXT,
            date      TEXT    DEFAULT (date('now')),
            heure     TEXT    DEFAULT (time('now'))
        )
    )");

    execQuery(R"(
    CREATE TABLE IF NOT EXISTS workouts (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        nom              TEXT    NOT NULL,
        duree            INTEGER DEFAULT 0,
        calories_brulees INTEGER DEFAULT 0,
        date             TEXT    DEFAULT (date('now'))
    )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS workout_exercises (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER REFERENCES workouts(id),
            nom        TEXT    NOT NULL,
            sets       INTEGER DEFAULT 3,
            reps       INTEGER DEFAULT 10,
            poids      REAL    DEFAULT 0,
            fait       INTEGER DEFAULT 0
        )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS weight_history (
            id    INTEGER PRIMARY KEY AUTOINCREMENT,
            poids REAL    NOT NULL,
            date  TEXT    DEFAULT (date('now'))
        )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS coach_messages (
            id      INTEGER PRIMARY KEY AUTOINCREMENT,
            role    TEXT    NOT NULL,
            contenu TEXT    NOT NULL,
            date    TEXT    DEFAULT (datetime('now'))
        )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS settings (
            key   TEXT PRIMARY KEY,
            value TEXT NOT NULL
        )
    )");
    execQuery(R"(
    CREATE TABLE IF NOT EXISTS exercises_library (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        nom              TEXT    NOT NULL,
        categorie        TEXT,
        muscle_principal TEXT,
        muscle_secondaire TEXT,
        equipement       TEXT,
        niveau           TEXT,
        met_value        REAL    DEFAULT 5.0,
        description      TEXT
    )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS programme_suggere (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            nom         TEXT,
            categorie   TEXT,
            jour        INTEGER,
            date        TEXT DEFAULT (date('now')),
            adopte      INTEGER DEFAULT 0
        )
    )");

    execQuery(R"(
        CREATE TABLE IF NOT EXISTS programme_exercices (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            programme_id    INTEGER REFERENCES programme_suggere(id),
            exercise_lib_id INTEGER REFERENCES exercises_library(id),
            nom             TEXT,
            sets            INTEGER DEFAULT 3,
            reps            INTEGER DEFAULT 10,
            poids           REAL    DEFAULT 0
        )
    )");

    execQuery(R"(
    CREATE TABLE IF NOT EXISTS personal_records (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        exercice_nom TEXT    NOT NULL,
        poids        REAL    DEFAULT 0,
        reps         INTEGER DEFAULT 0,
        volume       REAL    DEFAULT 0,
        date         TEXT    DEFAULT (date('now')),
        workout_id   INTEGER REFERENCES workouts(id)
    )
    )");

    execQuery(R"(
    CREATE TABLE IF NOT EXISTS badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE,
        nom TEXT,
        description TEXT,
        date_obtention TEXT DEFAULT (date('now'))
    )
    )");

    execQuery("ALTER TABLE workouts ADD COLUMN calories_brulees INTEGER DEFAULT 0");
    execQuery("ALTER TABLE workout_exercises ADD COLUMN categorie TEXT");
    seedExercisesLibrary();
}

bool DatabaseManager::isOpen() const
{
    return m_db.isOpen();
}

// ← const ajouté ici
QSqlQuery DatabaseManager::execQuery(const QString& sql) const
{
    QSqlQuery query(m_db);
    if (!query.exec(sql)) {
        qDebug() << "❌ SQL Error:" << query.lastError().text();
        qDebug() << "   Query:" << sql;
    }
    return query;
}

QSqlQuery DatabaseManager::execQuery(const QString& sql,
                                     const QVariantList& params) const
{
    QSqlQuery query(m_db);

    if (!query.prepare(sql)) {
        qDebug() << "❌ SQL Prepare Error:" << query.lastError().text();
        qDebug() << "   Query:" << sql;
        return query;
    }

    for (const QVariant& param : params)
        query.addBindValue(param);

    if (!query.exec()) {
        qDebug() << "❌ SQL Error:" << query.lastError().text();
        qDebug() << "   Query:" << sql;
    }

    return query;
}

bool DatabaseManager::isFirstLaunch() const
{
    QSqlQuery query(m_db);

    if (!query.exec("SELECT COUNT(*) FROM users")) {
        qDebug() << "❌ SQL Error:" << query.lastError().text();
        return true;
    }

    if (query.next())
        return query.value(0).toInt() == 0;

    return true;
}

void DatabaseManager::completeOnboarding(const QString& nom, int age,
                                         double poids, int taille,
                                         const QString& objectif,
                                         const QString& niveau,
                                         int joursSemaine,
                                         const QString& equipement)
{
    execQuery(
        "INSERT INTO users (nom, age, poids, taille, objectif, niveau, "
        "jours_semaine, equipement) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
        { nom, age, poids, taille, objectif, niveau, joursSemaine, equipement }
        );
}

QString DatabaseManager::getSetting(const QString& key,
                                    const QString& defaultValue) const
{
    auto q = execQuery(
        "SELECT value FROM settings WHERE key = ?", { key }
        );
    if (q.next()) return q.value(0).toString();
    return defaultValue;
}

void DatabaseManager::setSetting(const QString& key, const QString& value)
{
    execQuery(
        "INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)",
        { key, value }
        );
}
void DatabaseManager::seedExercisesLibrary()
{
    // Vérifie si déjà rempli
    auto q = execQuery("SELECT COUNT(*) FROM exercises_library");
    if (q.next() && q.value(0).toInt() > 0) return;

    // ── POITRINE ──────────────────────────────
    QList<QVariantList> exercises = {
                                     // nom, categorie, muscle_principal, muscle_secondaire, equipement, niveau, met
                                     {"Pompes",               "Push", "Poitrine", "Triceps,Épaules",  "aucun",    "debutant",      5.0},
                                     {"Pompes déclinées",     "Push", "Poitrine", "Triceps",          "aucun",    "debutant",      5.5},
                                     {"Pompes diamant",       "Push", "Triceps",  "Poitrine",         "aucun",    "intermediaire", 5.5},
                                     {"Pompes archer",        "Push", "Poitrine", "Triceps",          "aucun",    "avance",        6.0},
                                     {"Développé couché",     "Push", "Poitrine", "Triceps,Épaules",  "salle",    "intermediaire", 6.0},
                                     {"Développé incliné",    "Push", "Poitrine", "Épaules",          "salle",    "intermediaire", 6.0},
                                     {"Écarté haltères",      "Push", "Poitrine", "Épaules",          "halteres", "intermediaire", 5.0},
                                     {"Dips poitrine",        "Push", "Poitrine", "Triceps",          "salle",    "intermediaire", 6.5},
                                     {"Câble croisé",         "Push", "Poitrine", "Épaules",          "salle",    "intermediaire", 5.0},
                                     {"Pec deck",             "Push", "Poitrine", "",                 "salle",    "debutant",      4.5},

                                     // ── DOS ───────────────────────────────
                                     {"Traction",             "Pull", "Dos",      "Biceps",           "salle",    "intermediaire", 8.0},
                                     {"Traction prise large", "Pull", "Dos",      "Biceps",           "salle",    "avance",        8.5},
                                     {"Traction australienne","Pull", "Dos",      "Biceps",           "aucun",    "debutant",      6.0},
                                     {"Rowing haltère",       "Pull", "Dos",      "Biceps,Épaules",   "halteres", "intermediaire", 5.5},
                                     {"Rowing barre",         "Pull", "Dos",      "Biceps",           "salle",    "intermediaire", 6.0},
                                     {"Tirage poulie haute",  "Pull", "Dos",      "Biceps",           "salle",    "debutant",      5.5},
                                     {"Tirage horizontal",    "Pull", "Dos",      "Biceps",           "salle",    "debutant",      5.0},
                                     {"Superman",             "Pull", "Dos",      "Fessiers",         "aucun",    "debutant",      3.5},
                                     {"Good morning",         "Pull", "Dos",      "Ischio",           "salle",    "intermediaire", 5.0},
                                     {"Shrug haltères",       "Pull", "Trapèzes", "Épaules",          "halteres", "debutant",      4.0},

                                     // ── ÉPAULES ───────────────────────────
                                     {"Développé militaire",  "Push", "Épaules",  "Triceps",          "salle",    "intermediaire", 6.0},
                                     {"Développé Arnold",     "Push", "Épaules",  "Triceps",          "halteres", "intermediaire", 5.5},
                                     {"Élévation latérale",   "Push", "Épaules",  "",                 "halteres", "debutant",      4.0},
                                     {"Élévation frontale",   "Push", "Épaules",  "",                 "halteres", "debutant",      4.0},
                                     {"Oiseau haltères",      "Pull", "Épaules",  "Dos",              "halteres", "debutant",      4.0},
                                     {"Face pull",            "Pull", "Épaules",  "Dos",              "salle",    "debutant",      4.5},
                                     {"Pike push-up",         "Push", "Épaules",  "Triceps",          "aucun",    "intermediaire", 5.0},
                                     {"Handstand push-up",    "Push", "Épaules",  "Triceps",          "aucun",    "avance",        7.0},

                                     // ── BRAS ──────────────────────────────
                                     {"Curl haltères",        "Pull", "Biceps",   "",                 "halteres", "debutant",      4.0},
                                     {"Curl barre",           "Pull", "Biceps",   "",                 "salle",    "debutant",      4.5},
                                     {"Curl marteau",         "Pull", "Biceps",   "Avant-bras",       "halteres", "debutant",      4.0},
                                     {"Curl concentration",   "Pull", "Biceps",   "",                 "halteres", "debutant",      4.0},
                                     {"Curl câble",           "Pull", "Biceps",   "",                 "salle",    "debutant",      4.5},
                                     {"Extension triceps",    "Push", "Triceps",  "",                 "salle",    "debutant",      4.5},
                                     {"Skull crusher",        "Push", "Triceps",  "",                 "salle",    "intermediaire", 5.0},
                                     {"Dips banc",            "Push", "Triceps",  "Poitrine",         "aucun",    "debutant",      5.0},
                                     {"Kickback triceps",     "Push", "Triceps",  "",                 "halteres", "debutant",      4.0},
                                     {"Push-down câble",      "Push", "Triceps",  "",                 "salle",    "debutant",      4.5},

                                     // ── JAMBES ────────────────────────────
                                     {"Squat",                "Legs", "Quadriceps","Fessiers,Ischio", "aucun",    "debutant",      7.0},
                                     {"Squat bulgare",        "Legs", "Quadriceps","Fessiers",        "halteres", "intermediaire", 7.5},
                                     {"Squat barre",          "Legs", "Quadriceps","Fessiers,Ischio", "salle",    "intermediaire", 8.0},
                                     {"Fente avant",          "Legs", "Quadriceps","Fessiers",        "aucun",    "debutant",      6.5},
                                     {"Fente latérale",       "Legs", "Quadriceps","Fessiers",        "aucun",    "intermediaire", 6.5},
                                     {"Leg press",            "Legs", "Quadriceps","Fessiers",        "salle",    "debutant",      6.0},
                                     {"Leg extension",        "Legs", "Quadriceps","",                "salle",    "debutant",      4.5},
                                     {"Leg curl couché",      "Legs", "Ischio",   "",                 "salle",    "debutant",      4.5},
                                     {"Romanian deadlift",    "Legs", "Ischio",   "Fessiers",         "salle",    "intermediaire", 6.5},
                                     {"Hip thrust",           "Legs", "Fessiers", "Ischio",           "salle",    "intermediaire", 6.0},
                                     {"Hip thrust au sol",    "Legs", "Fessiers", "Ischio",           "aucun",    "debutant",      5.5},
                                     {"Soulevé de terre",     "Legs", "Dos",      "Fessiers,Ischio",  "salle",    "intermediaire", 8.0},
                                     {"Step up",              "Legs", "Quadriceps","Fessiers",        "aucun",    "debutant",      6.0},
                                     {"Mollet debout",        "Legs", "Mollets",  "",                 "aucun",    "debutant",      4.0},
                                     {"Mollet assis",         "Legs", "Mollets",  "",                 "salle",    "debutant",      4.0},
                                     {"Jump squat",           "Legs", "Quadriceps","Fessiers",        "aucun",    "intermediaire", 8.5},

                                     // ── ABDOS ─────────────────────────────
                                     {"Crunch",               "Core", "Abdos",    "",                 "aucun",    "debutant",      4.0},
                                     {"Crunch oblique",       "Core", "Obliques", "Abdos",            "aucun",    "debutant",      4.0},
                                     {"Planche",              "Core", "Abdos",    "Dos,Épaules",      "aucun",    "debutant",      4.5},
                                     {"Planche latérale",     "Core", "Obliques", "Abdos",            "aucun",    "intermediaire", 4.5},
                                     {"Mountain climber",     "Core", "Abdos",    "Épaules",          "aucun",    "intermediaire", 7.0},
                                     {"Russian twist",        "Core", "Obliques", "Abdos",            "aucun",    "debutant",      5.0},
                                     {"Leg raise",            "Core", "Abdos",    "",                 "aucun",    "intermediaire", 5.0},
                                     {"Ab wheel",             "Core", "Abdos",    "Dos,Épaules",      "aucun",    "avance",        6.0},
                                     {"Bicycle crunch",       "Core", "Abdos",    "Obliques",         "aucun",    "debutant",      5.0},
                                     {"Dragon flag",          "Core", "Abdos",    "",                 "salle",    "avance",        7.0},
                                     {"Hollow body",          "Core", "Abdos",    "",                 "aucun",    "intermediaire", 4.5},
                                     {"L-sit",                "Core", "Abdos",    "Triceps",          "aucun",    "avance",        5.0},

                                     // ── CARDIO ────────────────────────────
                                     {"Burpees",              "Cardio","Full body","",                 "aucun",    "intermediaire", 9.0},
                                     {"Jumping jacks",        "Cardio","Full body","",                 "aucun",    "debutant",      7.0},
                                     {"High knees",           "Cardio","Jambes",  "",                 "aucun",    "debutant",      8.0},
                                     {"Box jump",             "Cardio","Jambes",  "",                 "aucun",    "intermediaire", 8.5},
                                     {"Corde à sauter",       "Cardio","Full body","",                 "aucun",    "debutant",      9.5},
                                     {"Sprint sur place",     "Cardio","Jambes",  "",                 "aucun",    "debutant",      9.0},
                                     };

    for (const auto& ex : exercises) {
        execQuery(
            "INSERT INTO exercises_library "
            "(nom, categorie, muscle_principal, muscle_secondaire, "
            "equipement, niveau, met_value) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
            ex
            );
    }

    qDebug() << "✅ Bibliothèque exercices créée :" << exercises.size() << "exercices";
}

static int levenshtein(const QString& a, const QString& b) {
    int m = a.size(), n = b.size();
    QVector<QVector<int>> d(m + 1, QVector<int>(n + 1));
    for (int i = 0; i <= m; i++) d[i][0] = i;
    for (int j = 0; j <= n; j++) d[0][j] = j;
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            int cost = (a[i-1].toLower() == b[j-1].toLower()) ? 0 : 1;
            d[i][j] = std::min({ d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost });
        }
    }
    return d[m][n];
}

QString DatabaseManager::trouverCategorieFuzzy(const QString& nomExercice, int seuilMax) const
{
    auto q = execQuery("SELECT nom, categorie FROM exercises_library");

    QString meilleureCategorie;
    int meilleureDistance = seuilMax + 1;

    while (q.next()) {
        QString nomLib = q.value(0).toString();
        int dist = levenshtein(nomExercice.trimmed(), nomLib.trimmed());
        if (dist < meilleureDistance) {
            meilleureDistance = dist;
            meilleureCategorie = q.value(1).toString();
        }
    }

    if (meilleureDistance <= seuilMax) return meilleureCategorie;
    return "";  // rien d'assez proche
}