#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;
    engine.load(QUrl("qrc:/qt/qml/MysticGroove/main.qml"));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
