pragma Singleton
import QtQuick
import "../theme/"

QtObject {
    // GENERAL - COLORS
    property color fg: Theme.foreground
    property color fgDim: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.75)
    property color fgDimmer: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.5)
    property color fgDimmest: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.25)
    property color bg: Theme.background
    property color surface: Theme.surface
    property color overlay: Theme.overlay
    property color accent: Theme.accent
    property color urgent: Theme.urgent
    property color success: Theme.success

    // GENERAL - TEXT
    property int textXsSize: 10
    property font textXsNormal: {
        let f = Qt.font(barFont);
        f.pixelSize = textXsSize;
        f.bold = false;
        return f;
    }
    property font textXsBold: {
        let f = Qt.font(barFont);
        f.pixelSize = textXsSize;
        f.bold = true;
        return f;
    }
    property int textSmSize: 14
    property font textSmNormal: {
        let f = Qt.font(barFont);
        f.pixelSize = textSmSize;
        f.bold = false;
        return f;
    }
    property font textSmBold: {
        let f = Qt.font(barFont);
        f.pixelSize = textSmSize;
        f.bold = true;
        return f;
    }
    property int textMdSize: 18
    property font textMdNormal: {
        let f = Qt.font(barFont);
        f.pixelSize = textMdSize;
        f.bold = false;
        return f;
    }
    property font textMdBold: {
        let f = Qt.font(barFont);
        f.pixelSize = textMdSize;
        f.bold = true;
        return f;
    }
    property int textLgSize: 24
    property font textLgNormal: {
        let f = Qt.font(barFont);
        f.pixelSize = textLgSize;
        f.bold = false;
        return f;
    }
    property font textLgBold: {
        let f = Qt.font(barFont);
        f.pixelSize = textLgSize;
        f.bold = true;
        return f;
    }
    property int textXlSize: 48
    property font textXlNormal: {
        let f = Qt.font(barFont);
        f.pixelSize = textXlSize;
        f.bold = false;
        return f;
    }
    property font textXlBold: {
        let f = Qt.font(barFont);
        f.pixelSize = textXlSize;
        f.bold = true;
        return f;
    }

    // GENERAL - SLIDE
    property int sliderKnobSize: 20
    property int sliderKnobRadius: 99
    property int sliderBarHeight: 8
    property int sliderBarWidth: 400
    property int sliderBarRadius: 4
    property int sliderHeaderHeight: 44

    // GENERAL - BUTTON
    property int btnRadius: 99
    property int btnSize: 32
    property color btnBg: surface
    property color btnBgActive: accent
    property color btnBgHovered: Qt.rgba(overlay.r, overlay.g, overlay.b, 0.55)
    property color btnText: fg
    property color btnTextActive: bg
    property color btnTextHovered: fg
    property font btnTextFont: {
        let f = Qt.font(Theme.fontFace);
        f.pixelSize = textSmSize;
        f.bold = false;
        return f;
    }

    // GENERAL - OVERLAY
    property color overlayBg: Qt.rgba(overlay.r, overlay.g, overlay.b, 0.25)
    property color overlayBorderColor: Qt.rgba(fg.r, fg.g, fg.b, 0.075)
    property int overlayBorderWidth: 2
    property int overlayRadius: 16

    // GENERAL - SPACING, PADDING, MARGIN,
    property int spacingSm: 8
    property int spacingMd: 16
    property int spacingLg: 24

    // CONTAINERS
    property color containerBackground: bg
    property color containerBorderColor: overlay
    property color containerOverlay: Qt.rgba(fg.r, fg.g, fg.b, 0.1)
    property int containerBorderWidth: 2
    property int containerPadding: 16
    property int containerRadius: 16

    // BAR - FONT
    property int barFontSize: 14
    property font barFont: {
        let f = Qt.font(Theme.fontFace);
        f.pixelSize = barFontSize;
        f.bold = false;
        return f;
    }
    // BAR - BACKGROUND
    property color barBackground: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.05)
    // BAR - FOREGROUND
    property color barForeground: Theme.foreground
    property color barForegroundDim: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.8)
    // BAR - BORDER
    property int barBorderWidth: 1
    property int barBorderRadius: 8
    property color barBorderColor: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)
    // BAR - WORKSPACES
    property color barWorkspaceBackgroundActive: Theme.accent
    property color barWorkspaceBackground: Theme.surface
    property color barWorkspaceForegroundActive: Theme.background
    property color barWorkspaceForeground: Theme.foreground
    property int barWorkspaceSize: 32
    property int barWorkspaceRadius: 12
    property int barWorkspacePadding: 12
    // BAR - CLOCK
    property font barClockMinutes: {
        let f = Qt.font(barFont);
        f.pixelSize = barFontSize;
        f.bold = false;
        return f;
    }
    property font barClockHours: {
        let f = Qt.font(barFont);
        f.pixelSize = barFontSize;
        f.bold = true;
        return f;
    }

    // DRAWER - CALENDAR
    property int calendarWidth: (Style.btnSize + Style.spacingSm) * 7 + Style.spacingMd * 2 // 7 cols in total
    property int calendarHeight: (Style.btnSize + Style.spacingSm) * 8 + Style.spacingMd * 2 // 8 rows in total
    property int calendarClockWidth: calendarWidth
    property int calendarClockHeight: calendarHeight
    // DRAWER - CALENDAR - GAUGES
    property int gaugeSize: 96
    property int gaugeStroke: 8
    property int gaugeContainerSize: (Style.gaugeSize * 2) + Style.spacingMd + (Style.spacingLg * 2)

    // DRAWER - VOLUME
    property color volumeActiveOutputColor: accent
    property color volumeInactiveOutputColor: overlay
    property color volumeSubHeaderColor: fg
    property color volumeDividerColor: fgDimmer

    // DRAWER - WALLPAPERS
    property int wallHeight: 180
    property int wallWidth: 320

    // DRAWER - THEMES
    property int themeWidth: 200
    property int themeHeight: 100

    // PANEL - SESSION
    property int sessionBtnSize: 96
    property int sessionBtnRadius: 12
    property int sessionBtnSpacing: 8

    // NOTIFICATION CARD
    property int notifContainerWidth: 388
    property int notifContainerHeight: 84
    property int notifImageSize: notifContainerHeight - spacingMd

    // Fonts
    property font fontText: Theme.fontFace
}
