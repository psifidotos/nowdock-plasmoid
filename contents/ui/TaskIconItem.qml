import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{
    width: wrapper.regulatorSize
    height: wrapper.regulatorSize

    PlasmaCore.IconItem {
        id: iconImage

        width: panel.iconSize * wrapper.scale * wrapper.appearScale;
        height: panel.iconSize * wrapper.scale * wrapper.appearScale;

        anchors.centerIn: parent

        active: wrapper.containsMouse
        enabled: true
        usesPlasmaTheme: false

        source: decoration
    }
    DropShadow {
        anchors.fill: iconImage
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: iconImage
    }
}// Icon Item
