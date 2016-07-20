import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

import QtGraphicalEffects 1.0

Item{
    //   property string color
    Rectangle {
        id: smallCircle
        width: Math.round(parent.width / 1.8)
        height: Math.round(parent.height / 1.8)
        color: theme.highlightColor
        radius: width*0.5
        anchors.centerIn: parent
    }

    RectangularGlow {
        id: effect
        anchors.fill: smallCircle
        glowRadius: 9
        spread: 0.3
        color: theme.highlightColor
        cornerRadius: smallCircle.radius + glowRadius
        opacity: 0.5
        visible: panel.glow
    }

    BrightnessContrast {
        anchors.fill: smallCircle
        source: smallCircle
        anchors.margins: 1
        brightness: 0.4
        contrast: 0.4
    }

}
