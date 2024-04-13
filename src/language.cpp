#include "language.h"
#include "settings.h"
#include <QApplication>
#include <QWidget>

Language::Language() {}

Language &Language::instance() {
    static Language instance;
    return instance;
}

// notify all widgets to change a language
void Language::notifyAll() {
    const QWidgetList allWidgets = QApplication::allWidgets();
    for (auto widget : allWidgets) {
        QApplication::instance()->postEvent(widget, new LanguageChangeEvent);
    }
}

// load translation for relative language
void Language::applyLanguage() {
    bool isOk = instance().translator.load(":rcc/translation_" +
                                           getEffectiveLanguage() + ".qm");
    if (isOk)
        QApplication::instance()->installTranslator(&instance().translator);

    notifyAll();
}

QString Language::getSystemLanguage() {
    // TODO: multilingual support
    QString lang;
    switch (QLocale::system().language()) {
    case QLocale::Russian:
        lang = "ru";
        break;
    case QLocale::English:
        lang = "en";
        break;
    default:
        lang = "en";
        break;
    }

    return lang;
}

// sustitutes System language for a real one
QString Language::getEffectiveLanguage() {
    QString lang = Settings::getLanguage();
    lang = correct(lang);
    if (lang == "System")
        return getSystemLanguage();
    return lang;
}

QStringList Language::getLanguageList() { return {"System", "en", "ru"}; }

// check if lang is allowed. Return default, if lang is incorrect
QString Language::correct(QString lang) {
    QStringList langAllowed = getLanguageList();
    if (!langAllowed.contains(lang))
        return langAllowed.front();
    return lang;
}
