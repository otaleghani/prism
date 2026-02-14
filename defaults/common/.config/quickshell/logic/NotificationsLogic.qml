pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

NotificationServer {
    bodySupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: notification => {
        notification.tracked = true;
    }
}
