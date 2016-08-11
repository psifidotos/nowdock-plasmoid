import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 as KQuickControlAddons


//I am using  KQuickControlAddons.QIconItem even though onExit it triggers the following error
//QObject::~QObject: Timers cannot be stopped from another thread
//but it increases performance almost to double during animation

Item{
    id: centralItem

    width: wrapper.regulatorWidth
    height: wrapper.regulatorHeight

    property int doubleSize : 2 * panel.iconSize;
    //big interval to show shadows only after all the crappy adds and removes of tasks
    //have happened
    property int shadowInterval: 300
    property int normalIconInterval: 40

    Image {
        id: iconImageBuffer

        //property real newTempSize: panel.iconSize * wrapper.scale
        property real newTempSize: Math.min(wrapper.basicScalingWidth, wrapper.basicScalingHeight)
        width: newTempSize
        height: newTempSize

        anchors.centerIn: parent

        visible: panel.enableShadows

        opacity: 0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        Image{
            id: iconHoveredBuffer
            anchors.fill: parent

            opacity: wrapper.containsMouse ? 1 : 0

            visible: ((activateTaskAnimation.running == false) &&
                      (launcherAnimation.running == false) )

            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }

    }

    BrightnessContrast {
        id: brightnessTaskEffect
        anchors.fill: iconImageBuffer
        source: iconImageBuffer

        visible: activateTaskAnimation.running
    }


    //Something to show until the buffers are updated

    KQuickControlAddons.QIconItem{
        id: iconImageBackground

        property real relatedSize: panel.iconSize  *  ( (doubleSize  - 7) / doubleSize );

        width: (visible) ? relatedSize * wrapper.scale : panel.iconSize
        height: width
        anchors.centerIn: parent

        state: wrapper.containsMouse ? KQuickControlAddons.QIconItem.ActiveState : KQuickControlAddons.QIconItem.DefaultState
        icon: decoration

        visible: ((iconImageBuffer.opacity == 1) && (panel.enableShadows)) ? false : true

        Component{
            id:hideBackTimer

            Timer{
                id:hideBackgroundTimer
                repeat:false
                interval: centralItem.shadowInterval

                onTriggered: {
                    // iconImageBackground.visible = false;
                    iconImageBuffer.opacity = 1;
                    hideBackgroundTimer.destroy();
                    //   iconImageBuffer.visible = false;
                }

                Component.onCompleted: hideBackgroundTimer.start();
            }
        }
    }

    Loader{
        id:defaultWithShadow
        sourceComponent: component
        active: (IsStartup && (!panel.enableShadows) ) ? false : true
    }

    /*
    Loader{
        id:activeLoader
        sourceComponent: component2
    }*/

    ///////Activate animation/////

    SequentialAnimation{
        id: activateTaskAnimation
        property int speed: 120

        SequentialAnimation{

            ParallelAnimation{
                PropertyAnimation {
                    target: brightnessTaskEffect
                    property: "brightness"
                    to: -0.5
                    duration: activateTaskAnimation.speed
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: wrapper
                    property: "scale"
                    to: wrapper.scale - 0.3
                    duration: activateTaskAnimation.speed
                    easing.type: Easing.OutQuad
                }
            }

            ParallelAnimation{
                PropertyAnimation {
                    target: brightnessTaskEffect
                    property: "brightness"
                    to: 0
                    duration: activateTaskAnimation.speed
                    easing.type: Easing.OutQuad
                }
                PropertyAnimation {
                    target: wrapper
                    property: "scale"
                    to: panel.zoomFactor
                    duration: activateTaskAnimation.speed
                    easing.type: Easing.OutQuad
                }
            }

        }
        onStopped: {
            wrapper.animationEnded();
        }

        function startAnimation(){
            start();
        }

        Component.onCompleted: {
            wrapper.runActivateAnimation.connect(startAnimation);
        }
    }
    ////end of activate animation////

    SequentialAnimation{
        id:launcherAnimation
        property int speed: 300

        SequentialAnimation{
            ParallelAnimation{
                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: panel.zoomFactor + 0.3
                    duration: launcherAnimation.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Horizontal) ? "tempScaleWidth" : "tempScaleHeight"
                    to: 1
                    duration: launcherAnimation.speed
                    easing.type: Easing.OutQuad
                }
            }

            PropertyAnimation {
                target: wrapper
                property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                to: 1
                duration: 3 * launcherAnimation.speed
                easing.type: Easing.OutBounce
            }
        }


        onStopped: {
            wrapper.animationEnded();
        }

        function init(){
            wrapper.tempScaleWidth = wrapper.scale;
            wrapper.tempScaleHeight = wrapper.scale;

            iconImageBuffer.anchors.centerIn = undefined;

            if(panel.position === PlasmaCore.Types.LeftPositioned)
                iconImageBuffer.anchors.right = iconImageBuffer.parent.right;
            else if(panel.position === PlasmaCore.Types.RightPositioned)
                iconImageBuffer.anchors.left = iconImageBuffer.parent.left;
            else if(panel.position === PlasmaCore.Types.TopPositioned)
                iconImageBuffer.anchors.bottom = iconImageBuffer.parent.bottom;
            else if(panel.position === PlasmaCore.Types.BottomPositioned)
                iconImageBuffer.anchors.top = iconImageBuffer.parent.top;

            icList.hoveredIndex = -1;
        }

        function bounceLauncher(){
            init();
            start();
        }

        Component.onCompleted: {wrapper.runLauncherAnimation.connect(bounceLauncher);}
    }



    ////

    function updateImages(){
        if(panel){
            //   if(activeLoader.item)
            //   activeLoader.item.updateImage();
            if(defaultWithShadow.item){
                defaultWithShadow.item.updateImage();
            }
        }
    }


    ///////////////Buffering

    Component {
        id: component
        Item {
            id: yourImageWithLoadedIconContainer
            anchors.fill: parent

            visible: false

            function updateImage(){
                tttTimer.createObject(iconImage);
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

                    // too many draws must be disabled, instead
                    // we can blacklist the application which creates
                    // drawing errors (libreoffice writer)
                    property int counter:0;

                    onIconChanged: {
                        centralItem.updateImages();
                    }

                    // use this when using Image instead of Rectangle

                    Component{
                        id:tttTimer

                        Timer{
                            id:ttt
                            repeat:false
                            interval: centralItem.shadowInterval

                            //   property int counter2: 0;

                            onTriggered: {
                                if(index !== -1){
                                    if(panel.enableShadows == true){
                                        shadowImageNoActive.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            iconImageBuffer.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon.width,fixedIcon.height) );
                                    }
                                    else{
                                        fixedIcon.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            iconImageBuffer.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon.width,fixedIcon.height) );
                                    }

                                    hoveredImage.grabToImage(function(result) {
                                        iconHoveredBuffer.source.destroy();
                                        iconHoveredBuffer.source = result.url;
                                        result.destroy();
                                    }, Qt.size(fixedIcon.width,fixedIcon.height) );


                                    hideBackTimer.createObject(iconImageBackground);
                                    // ttt.destroy();
                                }
                            }

                            Component.onCompleted: ttt.start();
                        }// end of timer

                    }//end of component of timer

                    Component.onCompleted: {
                        tttTimer.createObject(iconImage);
                    }
                }
            }

            DropShadow {
                id:shadowImageNoActive
                visible: false
                width: fixedIcon.width
                height: fixedIcon.height
                anchors.centerIn: fixedIcon

                radius: 4
                samples: 7
                color: "#cc080808"
                source: fixedIcon
            }

            BrightnessContrast{
                id:hoveredImage
                visible: false
                width: fixedIcon.width
                height: fixedIcon.height
                anchors.centerIn: fixedIcon

                brightness: 0.4
                source: fixedIcon
            }
        }
    }

}// Icon Item
