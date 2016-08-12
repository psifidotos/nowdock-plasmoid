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

    property int doubleSize : 2 * panel.iconSize
    property int shadowSize : (panel.iconSize / 7)

    //big interval to show shadows only after all the crappy adds and removes of tasks
    //have happened
    property bool firstDrawed: false
    property int shadowInterval: firstDrawed ? 400 : 80
    property int normalIconInterval: 40

    ///just for catching the signals
    property int tempIconSize: panel.iconSize
    property bool tempEnableShadows: panel.enableShadows

    onTempIconSizeChanged: {
        if (panel.enableShadows)
            updateImages();
    }

    onTempEnableShadowsChanged: {
        if(tempEnableShadows){
            updateImages();
        }
        else{
            iconImageBuffer.source.destroy();
            iconHoveredBuffer.source.destroy();
        }
    }

    Image {
        id: iconImageBuffer

        //property real newTempSize: panel.iconSize * wrapper.scale
        property real newTempSize: (wrapper.opacity == 1) ?  Math.min(wrapper.basicScalingWidth, wrapper.basicScalingHeight) :
                                                            Math.max(wrapper.basicScalingWidth, wrapper.basicScalingHeight)
        width: newTempSize + (centralItem.shadowSize/2)
        height: newTempSize + (centralItem.shadowSize/2)

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

    //KQuickControlAddons.QIconItem{
    PlasmaCore.IconItem{
        id: iconImageBackground

        //property real relatedSize: panel.iconSize  *  ( (doubleSize  - 7) / doubleSize );

        //    width: (visible) ? relatedSize * wrapper.scale : panel.iconSize
        width: (visible) ? panel.iconSize * wrapper.scale : panel.iconSize
        height: width
        anchors.centerIn: parent

        //        state: wrapper.containsMouse ? KQuickControlAddons.QIconItem.ActiveState : KQuickControlAddons.QIconItem.DefaultState
        //       icon: decoration
        active: wrapper.containsMouse
        enabled: true
        source: decoration

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

    ////bouncing task, e.g. on launcher activating and when a new window is
    ////added in a group task
    SequentialAnimation{
        id:launcherAnimation

        property int speed: 300

        SequentialAnimation{
            ParallelAnimation{
                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: panel.zoomFactor + 0.1
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


        Component.onCompleted: {
            wrapper.runLauncherAnimation.connect(bounceLauncher);
        }
    }
    /////////////////// end of launcher animation


    ////////////////// new window and needs attention animation
    SequentialAnimation{
        id:newWindowAnimation

        property int speed: 300
        property bool isDemandingAttention: IsDemandingAttention ? true : false
        property bool entered: wrapper.mouseEntered

        SequentialAnimation{
            ParallelAnimation{
                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: 0.8 * panel.zoomFactor
                    duration: newWindowAnimation.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Horizontal) ? "tempScaleWidth" : "tempScaleHeight"
                    to: 1
                    duration: newWindowAnimation.speed
                    easing.type: Easing.OutQuad
                }
            }

            PropertyAnimation {
                target: wrapper
                property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                to: 1
                duration: 3 * newWindowAnimation.speed
                easing.type: Easing.OutBounce
            }
        }

        function clear(){
            loops = 1;
            newWindowAnimation.stop();
            iconImageBuffer.anchors.centerIn = iconImageBuffer.parent;

            wrapper.tempScaleWidth = 1;
            wrapper.tempScaleHeight = 1;
        }

        onStopped: {
            clear();
        }

        onIsDemandingAttentionChanged: {
            if( (!isDemandingAttention)&&(running)){
                clear();
                wrapper.animationEnded();
            }
        }

        onEnteredChanged: {
            //    if(entered){
            //  clear();
            //  }
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

            if(!isDemandingAttention)
                loops = 2;
            else
                loops = 100;

            // icList.hoveredIndex = -1;
        }

        function bounceNewWindow(){
            wrapper.inAnimation = false;

            init();
            start();
        }

        Component.onCompleted: {
            mainItemContainer.groupWindowAdded.connect(bounceNewWindow);
        }
    }

    /////Removing a Window from a group////

    ParallelAnimation{
        id:removingAnimation

        property int speed: 600
        property Item removingItem
        property int toPoint: 0

        PropertyAnimation {
            target: removingAnimation.removingItem
            property: "opacity"
            to: 0
            duration: removingAnimation.speed
            easing.type: Easing.InQuad
        }

        PropertyAnimation {
            target: removingAnimation.removingItem
            property: (icList.orientation == Qt.Horizontal) ? "y" : "x"
            to: removingAnimation.toPoint
            duration: removingAnimation.speed
            easing.type: Easing.InQuad
        }

        function init(){
            var relavantPoint = icList.mapFromItem(iconImageBuffer,0,0);
            removingItem = removeTaskComponent.createObject(icList);
            removingItem.x = relavantPoint.x;
            removingItem.y = relavantPoint.y;

            var tempPoint = 0;

            if(icList.orientation == Qt.Horizontal)
                tempPoint = relavantPoint.y;
            else
                tempPoint = relavantPoint.x;

            if( (panel.position === PlasmaCore.Types.BottomPositioned) ||
                    (panel.position === PlasmaCore.Types.RightPositioned) ){
                toPoint = tempPoint + panel.iconSize;
            }
            else{
                toPoint = tempPoint - panel.iconSize;
            }

            removingItem.visible = true;
        }

        function removeTask(){
            if(panel.enableShadows){
                init();
                start();
            }
        }

        onStopped: {
            removingItem.destroy();
        }

        Component.onCompleted: {
            mainItemContainer.groupWindowRemoved.connect(removeTask);
        }

    }

    ////

    function updateImages(){
        if(panel){
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
                width: (panel.zoomFactor/2)*(centralItem.doubleSize+(2*shadowImageNoActive.radius) )
                height: width

                visible:false

                //KQuickControlAddons.QIconItem{
                PlasmaCore.IconItem{
                    id: iconImage
                    //width: parent.width - (shadowImageNoActive.radius)
                    // height: parent.height - (shadowImageNoActive.radius)
                    width: (panel.zoomFactor/2)*centralItem.doubleSize
                    height: width
                    anchors.centerIn: parent

                    // state: KQuickControlAddons.QIconItem.DefaultState
                    //icon: decoration
                    active: false
                    enabled: true
                    source: decoration

                    visible: true

                    // too many draws must be disabled, instead
                    // we can blacklist the application which creates
                    // drawing errors (libreoffice writer)
                    property int counter:0;

                    onSourceChanged: {
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
                                    centralItem.firstDrawed = true;

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

                                    ttt.destroy(100);
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

                radius: centralItem.shadowSize
                samples: 1.8 * radius
                color: "#cc080808"
                source: fixedIcon

                verticalOffset: 2
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


    ///////////// Component for animating removing window from group

    Component {
        id: removeTaskComponent
        Item{
            width: iconImageBuffer.width
            height: iconImageBuffer.height

            visible: false

            Image {
                id: tempRemoveIcon
                source: iconImageBuffer.source
                anchors.fill: parent
            }

            Colorize{
                source: tempRemoveIcon
                anchors.fill: tempRemoveIcon

                hue: 0
                saturation: 0
                lightness: 0
            }
        }
    }

}// Icon Item
