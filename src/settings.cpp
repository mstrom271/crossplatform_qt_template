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

Settings &Settings::instance() {
    static Settings instance;
    return instance;
}

bool Settings::getFirstRun() { return instance().FirstRun; }

QString Settings::getLanguage() { return instance().Language; }
void Settings::setLanguage(QString newLanguage) {
    instance().settings.setValue("/Language", newLanguage);
    instance().Language = newLanguage;
};

QString Settings::getTheme() { return instance().Theme; }
void Settings::setTheme(QString newTheme) {
    instance().settings.setValue("/Theme", newTheme);
    instance().Theme = newTheme;
};

uint Settings::getParam1() { return instance().Param1; }
void Settings::setParam1(uint newParam1) {
    instance().settings.setValue("/Param1", newParam1);
    instance().Param1 = newParam1;
};

bool Settings::getParam2() { return instance().Param2; }
void Settings::setParam2(bool newParam2) {
    instance().settings.setValue("/Param2", newParam2);
    instance().Param2 = newParam2;
};

QFont Settings::getMainFont() { return instance().MainFont; }
void Settings::setMainFont(QFont newMainFont) {
    instance().settings.setValue("/MainFont", newMainFont);
    instance().MainFont = newMainFont;
};