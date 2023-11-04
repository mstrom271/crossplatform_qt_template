
#include "myclass.h"
#include <QApplication>

int main(int argc, char **argv) {
    QApplication app(argc, argv);

    MyClass myClass;
    myClass.setFixedSize(800, 600);
    myClass.show();

    return app.exec();
}
