#include "language.h"
#include <QApplication>
#include <QWidget>

Language::Language() {}

Language &Language::getInstance() {
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
void Language::applyLanguage(QString lang) {
    bool isOk = Language::getInstance().translator.load(":rcc/translation_" +
                                                        correct(lang) + ".qm");
    if (isOk)
        QApplication::instance()->installTranslator(
            &Language::getInstance().translator);
}

QString Language::getSystemLanguage() {
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

    return correct(lang);
}

// check if lang is allowed. Return default, if lang is incorrect
QString Language::correct(QString lang) {
    if (lang != "ru" && lang != "en")
        lang = "en";
    return lang;
}
