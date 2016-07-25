import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item{
    id: centralItem

    width: wrapper.regulatorSize
    height: wrapper.regulatorSize
    property int doubleSize : 2 * panel.iconSize;

    Image {
        id: iconImageBuffer

        property int newTempSize: Math.floor(panel.iconSize * wrapper.scale * wrapper.appearScale)
        width: newTempSize
        height: newTempSize

        anchors.centerIn: parent

        source: (wrapper.containsMouse === true)  ? activeIcon.source : simpleIcon.source
        opacity: 0

        onSourceChanged: {
            opacity = 1;
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

    }

    Image{
        id:activeIcon
        visible:false
    }

    Image{
        id:simpleIcon
        visible:false
    }

    Component.onCompleted: {
        component.createObject(this);
        component2.createObject(this);
    }

    // Another way for the shadow must be found it increases the cpu cycles x2 alsmost,
    // even with the following caching mechanism.
    // it would be must better if we could create an image
    // the first time and use the DropShadow mechanism and then
    // just use that image for the animations
  /*  PlasmaCore.IconItem {
        id: iconImage

        property int newTempSize: Math.floor(panel.iconSize * wrapper.scale * wrapper.appearScale)
        width: newTempSize
        height: newTempSize

        anchors.centerIn: parent

        active: active
        enabled: true
        usesPlasmaTheme: false

        source: decoration
    }

    DropShadow {
        id:shadowImageNoActive
     //   visible:false
        anchors.fill: iconImage

        radius: 7.0
        samples: 10
        color: "#90080808"
        source: iconImage
        /*ShaderEffectSource {
            id:effectSource
            anchors.fill: parent
            sourceItem: iconImage
            hideSource: true
        }*/


   // }

///////////////Buffering

    Component {
         id: component
         Item {
             id: yourImageWithLoadedIconContainer
             anchors.fill: parent

             PlasmaCore.IconItem {
                 id: iconImage
                 width: 2 * panel.iconSize - 8
                 height: 2 * panel.iconSize - 8

                 active: false
                 enabled: true
                 usesPlasmaTheme: false

                 source: decoration

                 visible: false

                 // use this when using Image instead of Rectangle
                 Timer{
                     id:ttt
                     repeat:false
                     interval: 1
                     onTriggered: {
                         shadowImageNoActive.grabToImage(function(result) {
                             simpleIcon.source = result.url;
                         //    yourImageWithLoadedIconContainer.destroy()
                         }, Qt.size(iconImage.width,iconImage.height) );
                         ttt2.start();
                     }
                 }
                 Timer{
                     id:ttt2
                     repeat:false
                     interval: 100
                     onTriggered: {
                         yourImageWithLoadedIconContainer.destroy();
                     }
                 }

                 onVisibleChanged:{
                     console.debug ("asdfasdf");
                 }

                Component.onCompleted: {
                     ttt.start();
                 }
             }
             DropShadow {
                 id:shadowImageNoActive
                 visible:false
                 width: 2 * panel.iconSize
                 height: 2 * panel.iconSize
                 anchors.centerIn: iconImage


                 radius: 7.0
                 samples: 10
                 color: "#aa080808"
                 source: iconImage
             }
         }
     }

    Component {
         id: component2
         Item {
             id: yourImageWithLoadedIconContainer2
             anchors.fill: parent

             PlasmaCore.IconItem {
                 id: iconImage2
                 width: 2 * panel.iconSize - 8
                 height: 2 * panel.iconSize - 8

                 active: true
                 enabled: true
                 usesPlasmaTheme: false

                 source: decoration

                 visible: false

                 // use this when using Image instead of Rectangle
                 Timer{
                     id:ttt11
                     repeat:false
                     interval: 1
                     onTriggered: {
                         shadowImageNoActive2.grabToImage(function(result) {
                             activeIcon.source = result.url;
                         //    yourImageWithLoadedIconContainer.destroy()
                         }, Qt.size(iconImage2.width,iconImage2.height) );
                         ttt22.start();
                     }
                 }
                 Timer{
                     id:ttt22
                     repeat:false
                     interval: 100
                     onTriggered: {
                         yourImageWithLoadedIconContainer2.destroy();
                     }
                 }

                 onVisibleChanged:{
                     console.debug ("asdfasdf");
                 }

                Component.onCompleted: {
                     ttt11.start();
                 }
             }
             DropShadow {
                 id:shadowImageNoActive2
                 visible:false
                 width: 2 * panel.iconSize
                 height: 2 * panel.iconSize
                 anchors.centerIn: iconImage2


                 radius: 7.0
                 samples: 10
                 color: "#aa080808"
                 source: iconImage2
             }
         }
     }

}// Icon Item
