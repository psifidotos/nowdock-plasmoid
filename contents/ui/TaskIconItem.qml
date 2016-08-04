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

    property int shadowInterval: 100
    property int normalIconInterval: 40

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
        if(panel.enableShadows === true){
            component.createObject(this);
            component2.createObject(this);
        }
        else{
            componentns.createObject(this);
            component2ns.createObject(this);
        }
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

            Item{
                id:fixedIcon
                width: 2*panel.iconSize
                height: width

                visible:false

                PlasmaCore.IconItem {
                    id: iconImage
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    active: false
                    enabled: true
                    usesPlasmaTheme: true

                    source: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            shadowImageNoActive.grabToImage(function(result) {
                                simpleIcon.source = result.url;
                                //    yourImageWithLoadedIconContainer.destroy()
                            }, Qt.size(fixedIcon.width,fixedIcon.height) );
                            ttt2.start();
                        }
                    }
                    Timer{
                        id:ttt2
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            yourImageWithLoadedIconContainer.destroy();
                        }
                    }

                    Component.onCompleted: {
                        ttt.start();
                    }
                }
            }
            DropShadow {
                id:shadowImageNoActive
                visible:false
                width: fixedIcon.width
                height: fixedIcon.height
                anchors.centerIn: fixedIcon


                radius: 8.0
                samples: 14
                color: "#ff080808"
                source: fixedIcon
            }
        }
    }

    Component {
        id: component2
        Item {
            id: yourImageWithLoadedIconContainer2
            anchors.fill: parent

            Item{
                id:fixedIcon2
                width: 2*panel.iconSize
                height: width

                visible:false

                PlasmaCore.IconItem {
                    id: iconImage2
                    width: parent.width -  16
                    height: parent.height - 16

                    anchors.centerIn: parent

                    active: true
                    enabled: true
                    usesPlasmaTheme: true

                    source: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt11
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            shadowImageNoActive2.grabToImage(function(result) {
                                activeIcon.source = result.url;
                                //    yourImageWithLoadedIconContainer.destroy()
                            }, Qt.size(fixedIcon2.width,fixedIcon2.height) );
                            ttt22.start();
                        }
                    }
                    Timer{
                        id:ttt22
                        repeat:false
                        interval: centralItem.shadowInterval
                        onTriggered: {
                            yourImageWithLoadedIconContainer2.destroy();
                        }
                    }

                    Component.onCompleted: {
                        ttt11.start();
                    }
                }
            }

            DropShadow {
                id:shadowImageNoActive2
                visible:false
                width: fixedIcon2.width
                height: fixedIcon2.height
                anchors.centerIn: fixedIcon2


                radius: 8
                samples: 14
                color: "#ff080808"
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

            Item{
                id:fixedIconns
                width: 2*panel.iconSize
                height: width

                visible:false

                PlasmaCore.IconItem {
                    id: iconImagens
                    width: parent.width - 16
                    height: parent.height - 16
                    anchors.centerIn: parent

                    active: false
                    enabled: true
                    usesPlasmaTheme: true

                    source: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:tttns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            fixedIconns.grabToImage(function(result) {
                                simpleIcon.source = result.url;
                                //    yourImageWithLoadedIconContainer.destroy()
                            }, Qt.size(fixedIconns.width,fixedIconns.height) );
                            ttt2ns.start();
                        }
                    }
                    Timer{
                        id:ttt2ns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            yourImageWithLoadedIconContainerns.destroy();
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

            Item{
                id:fixedIcon2ns
                width: 2*panel.iconSize
                height: width

                visible:false

                PlasmaCore.IconItem {
                    id: iconImage2ns
                    width: parent.width -  16
                    height: parent.height - 16

                    anchors.centerIn: parent

                    active: true
                    enabled: true
                    usesPlasmaTheme: true

                    source: decoration

                    visible: true

                    // use this when using Image instead of Rectangle
                    Timer{
                        id:ttt11ns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            fixedIcon2ns.grabToImage(function(result) {
                                activeIcon.source = result.url;
                                //    yourImageWithLoadedIconContainer.destroy()
                            }, Qt.size(fixedIcon2ns.width,fixedIcon2ns.height) );
                            ttt22ns.start();
                        }
                    }
                    Timer{
                        id:ttt22ns
                        repeat:false
                        interval: centralItem.normalIconInterval
                        onTriggered: {
                            yourImageWithLoadedIconContainer2ns.destroy();
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
