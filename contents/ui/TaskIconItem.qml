import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlAddons

Item{
    id: centralItem

    width: wrapper.regulatorSize
    height: wrapper.regulatorSize
    property int doubleSize : 2 * panel.iconSize;

    property int shadowInterval: 40
    property int normalIconInterval: 40


    function updateImages(){
        if(panel.enableShadows === true){
            if(activeWithShadow.item)
                activeWithShadow.item.updateImage();

            if(defaultWithShadow.item)
                defaultWithShadow.item.updateImage();
        }
        else{
            if(activeNoShadow.item)
                activeNoShadow.item.updateImage();

            if(defaultNoShadow.item)
                defaultNoShadow.item.updateImage();
        }
    }

    /* PlasmaCore.IconItem {
        id: iconImage
        property int newTempSize: panel.iconSize * wrapper.scale * wrapper.appearScale
        width: newTempSize
        height: newTempSize

        anchors.centerIn: parent

        active: wrapper.containsMouse
        enabled: true
        usesPlasmaTheme: false

        source: decoration

        visible: true
    } */

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
            NumberAnimation { duration: 80 }
        }

     /*   Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: "red"
            color: "transparent"

            visible: IsStartup ? true : false
        }*/
    }

    Image{
        id:activeIcon
        visible:false
    }

    Image{
        id:simpleIcon
        visible:false
    }

    Loader{
        id:activeWithShadow
        active: panel.enableShadows
        sourceComponent: component
    }

    Loader{
        id:defaultWithShadow
        active: panel.enableShadows
        sourceComponent: component2
    }

    Loader{
        id:activeNoShadow
        active: panel.enableShadows === false
        sourceComponent: componentns
    }

    Loader{
        id:defaultNoShadow
        active: panel.enableShadows === false
        sourceComponent: component2ns
    }

    // Another way for the shadow must be found it increases the cpu cycles x2 alsmost,
    // even with the following caching mechanism.
    // it would be must better if we could create an image
    // the first time and use the DropShadow mechanism and then
    // just use that image for the animations

    /*  PlasmaCore.IconItem {
        id: iconImage

        width:64
        height:64

        anchors.centerIn: parent

        active: true
        enabled: true
        usesPlasmaTheme: false

        source: decoration

    }*/

    /* Image{
        id:iconImage
        width: 64
        height: 64
        source: "firefox.png"
    }

    DropShadow {
        id:shadowImageNoActive

        width: 64
        height: 64

        scale: wrapper.scale * wrapper.appearScale

        anchors.centerIn: parent

        radius: 7.0
        samples: 10
        color: "#90080808"
        source: ShaderEffectSource {
            id:effectSource
            width: iconImage.width
            height: iconImage.height
            sourceItem: iconImage
            hideSource: true
            live: false
        }

    }*/

    ///////////////Buffering

    Component {
        id: component
        Item {
            id: yourImageWithLoadedIconContainer
            anchors.fill: parent

            function updateImage(){
                ttt.restart();
            }

            Item{
                id:fixedIcon
                width: 2*panel.iconSize
                height: width

                visible:false

                KQuickControlAddons.QIconItem{
                    id: iconImage
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    state: KQuickControlAddons.QIconItem.DefaultState
                    icon: decoration

                    visible: true

                    onIconChanged: centralItem.updateImages();

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            shadowImageNoActive.grabToImage(function(result) {
                                simpleIcon.source = result.url;
                            }, Qt.size(fixedIcon.width,fixedIcon.height) );
                        }
                    }

                    Component.onCompleted: {
                        ttt.restart();
                    }
                }
            }

            DropShadow {
                id:shadowImageNoActive
                visible:false
                width: fixedIcon.width
                height: fixedIcon.height
                anchors.centerIn: fixedIcon


                radius: 6
                samples: 8
                color: "#cc080808"
                source: fixedIcon
            }
        }
    }

    Component {
        id: component2
        Item {
            id: yourImageWithLoadedIconContainer2
            anchors.fill: parent
            function updateImage(){
                ttt11.restart();
            }

            Item{
                id:fixedIcon2
                width: 2*panel.iconSize
                height: width

                visible:false

                KQuickControlAddons.QIconItem{
                    id: iconImage2
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    state: KQuickControlAddons.QIconItem.ActiveState
                    icon: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt11
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            shadowImageNoActive2.grabToImage(function(result) {
                                activeIcon.source = result.url;
                            }, Qt.size(fixedIcon2.width,fixedIcon2.height) );
                        }
                    }

                    Component.onCompleted: {
                        ttt11.restart();
                    }
                }
            }

            DropShadow {
                id:shadowImageNoActive2
                visible:false
                width: fixedIcon2.width
                height: fixedIcon2.height
                anchors.centerIn: fixedIcon2


                radius: 6
                samples: 8
                color: "#cc080808"
                source: fixedIcon2
            }

        }
    }


    ////////Components with no shadows//////////////
    Component {
        id: componentns
        Item {
            id: yourImageWithLoadedIconContainerns
            anchors.fill: parent

            function updateImage(){
                tttns.restart();
            }

            Item{
                id:fixedIconns
                width: 2*panel.iconSize
                height: width

                visible:false

                KQuickControlAddons.QIconItem{
                    id: iconImagens
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    state: KQuickControlAddons.QIconItem.DefaultState
                    icon: decoration

                    visible: true

                    onIconChanged: centralItem.updateImages();

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:tttns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            fixedIconns.grabToImage(function(result) {
                                simpleIcon.source = result.url;
                            }, Qt.size(fixedIconns.width,fixedIconns.height) );
                        }
                    }

                    Component.onCompleted: {
                        tttns.start();
                    }
                }
            }
        }
    }

    Component {
        id: component2ns
        Item {
            id: yourImageWithLoadedIconContainer2ns
            anchors.fill: parent

            function updateImage(){
                ttt11ns.restart();
            }

            Item{
                id:fixedIcon2ns
                width: 2*panel.iconSize
                height: width

                visible:false

                KQuickControlAddons.QIconItem{
                    id: iconImage2ns
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    state: KQuickControlAddons.QIconItem.ActiveState
                    icon: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt11ns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            fixedIcon2ns.grabToImage(function(result) {
                                activeIcon.source = result.url;
                            }, Qt.size(fixedIcon2ns.width,fixedIcon2ns.height) );
                        }
                    }

                    Component.onCompleted: {
                        ttt11ns.start();
                    }
                }
            }
        }
    }


}// Icon Item
