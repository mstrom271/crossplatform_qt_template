#pragma once

#include <QEvent>
#include <QTranslator>

class LanguageChangeEvent : public QEvent {
  public:
    static const QEvent::Type type =
        static_cast<QEvent::Type>(QEvent::User + 201);
    LanguageChangeEvent() : QEvent(static_cast<QEvent::Type>(type)) {}
};

class Language {
    QTranslator translator;

    Language();
    Language(const Language &other) = delete;
    Language &operator=(const Language &other) = delete;

  public:
    static Language &getInstance();

    static void applyLanguage(QString lang);
    static QString getSystemLanguage();
    static void notifyAll();
    static QString correct(QString language);
};
