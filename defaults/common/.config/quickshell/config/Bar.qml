pragma Singleton

import QtQuick

QtObject {
    property int openSize: Style.barWorkspaceSize + Style.barWorkspacePadding + Style.containerPadding
    property int closeSize: 0
}
