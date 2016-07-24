import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{
    width: wrapper.regulatorSize
    height: wrapper.regulatorSize

  /*  PlasmaCore.IconItem {
        id: iconImage

        width: panel.iconSize * wrapper.scale * wrapper.appearScale;
        height: panel.iconSize * wrapper.scale * wrapper.appearScale;

        anchors.centerIn: parent

        active: wrapper.containsMouse
        enabled: true
        usesPlasmaTheme: false

        source: decoration


    }*/
    // Another way for the shadow must be found it increases the cpu cycles x3 (probably)

    DropShadow {
        width: panel.iconSize * wrapper.scale * wrapper.appearScale;
        height: panel.iconSize * wrapper.scale * wrapper.appearScale;
        anchors.centerIn: parent

        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: effectSource

        ShaderEffectSource {
            id:effectSource
            anchors.fill: parent
            sourceItem: iconImage
            hideSource: true
        }

        PlasmaCore.IconItem {
            id: iconImage

            width: 2 * panel.iconSize
            height: 2 * panel.iconSize


            active: wrapper.containsMouse
            enabled: true
            usesPlasmaTheme: false

            source: decoration
        }

    }
}// Icon Item
