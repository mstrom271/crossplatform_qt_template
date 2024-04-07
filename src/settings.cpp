#include "settings.h"
#include "config.h"
#include <QApplication>
#include <QDataStream>
#include <QIODevice>

QByteArray serializeFontToByteArray(const QFont &font) {
    QByteArray byteArray;
    QDataStream stream(&byteArray, QIODevice::WriteOnly);
    stream << font;
    return byteArray;
}

QFont deserializeFontFromByteArray(QByteArray byteArray) {
    QDataStream stream(&byteArray, QIODevice::ReadOnly);
    QFont font;
    stream >> font;
    return font;
}

Settings::Settings() {
    settings.setValue("/Version", PROJECT_VERSION);

    FirstRun = settings.value("/FirstRun", true).toBool();
    if (FirstRun)
        settings.setValue("/FirstRun", false);

    Language = settings.value("/Language", "System").toString();
    Theme = settings.value("/Theme", "System").toString();

    Param1 = settings.value("/Param1", 0).toUInt();
    Param2 = settings.value("/Param2", false).toBool();

    MainFont = deserializeFontFromByteArray(
        settings
            .value("/MainFont",
                   serializeFontToByteArray(QFont("Arial", 20, QFont::Normal)))
            .toByteArray());
}

Settings &Settings::getInstance() {
    static Settings instance;
    return instance;
}

bool Settings::getFirstRun() { return Settings::getInstance().FirstRun; }

QString Settings::getLanguage() { return Settings::getInstance().Language; }
void Settings::setLanguage(QString newLanguage) {
    Settings::getInstance().settings.setValue("/Language", newLanguage);
    Settings::getInstance().Language = newLanguage;
};

QString Settings::getTheme() { return Settings::getInstance().Theme; }
void Settings::setTheme(QString newTheme) {
    Settings::getInstance().settings.setValue("/Theme", newTheme);
    Settings::getInstance().Theme = newTheme;
};

uint Settings::getParam1() { return Settings::getInstance().Param1; }
void Settings::setParam1(uint newParam1) {
    Settings::getInstance().settings.setValue("/Param1", newParam1);
    Settings::getInstance().Param1 = newParam1;
};

bool Settings::getParam2() { return Settings::getInstance().Param2; }
void Settings::setParam2(bool newParam2) {
    Settings::getInstance().settings.setValue("/Param2", newParam2);
    Settings::getInstance().Param2 = newParam2;
};

QFont Settings::getMainFont() { return Settings::getInstance().MainFont; }
void Settings::setMainFont(QFont newMainFont) {
    Settings::getInstance().settings.setValue("/MainFont", newMainFont);
    Settings::getInstance().MainFont = newMainFont;
};