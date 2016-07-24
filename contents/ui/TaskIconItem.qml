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

        property int newTempSize: panel.iconSize * wrapper.scale * wrapper.appearScale
        width: newTempSize
        height: newTempSize

        anchors.centerIn: parent

        active: wrapper.containsMouse
        enabled: true
        usesPlasmaTheme: false

        source: decoration

        /*transform: Scale {
            origin.x: width/2
            origin.y: height
            xScale:( wrapper.scale * wrapper.appearScale / 2)
            yScale:( wrapper.scale * wrapper.appearScale / 2 )
        }*/
    }

    // Another way for the shadow must be found it increases the cpu cycles x2 alsmost,
    // even with the following caching mechanism.
    // it would be must better if we could create an image
    // the first time and use the DropShadow mechanism and then
    // just use that image for the animations

    /*DropShadow {
        id:shadowImage
        width: panel.iconSize * wrapper.scale * wrapper.appearScale;
        height: panel.iconSize * wrapper.scale * wrapper.appearScale;
        anchors.centerIn: parent

        radius: 4.0
        samples: 10
        color: "#75080808"
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
    }*/

}// Icon Item
