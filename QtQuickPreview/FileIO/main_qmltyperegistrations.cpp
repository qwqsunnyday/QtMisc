/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#include <C:/Users/bobby/DATA/Git/QtMisc/QtQuickPreview/main.py>


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_FileIO()
{
    qmlRegisterTypesAndRevisions<Emulator>("FileIO", 1);
    qmlRegisterTypesAndRevisions<FileIO>("FileIO", 1);
    QMetaType::fromType<QObject *>().id();
    qmlRegisterModule("FileIO", 1, 0);
}

static const QQmlModuleRegistration fileIORegistration("FileIO", qml_register_types_FileIO);
