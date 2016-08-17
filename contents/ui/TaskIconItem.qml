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



    //big interval to show shadows only after all the crappy adds and removes of tasks
    //have happened
    property bool firstDrawed: true

    // three intervals in order to create the necessarty buffers from the
    // PlasmaCore.IconItem, one big interval for the first creation of the
    // plasmoid, a second one for the first creation of a task and a small one
    // for simple updates.
    // This is done before especially on initialization stage some visuals
    // are not ready and empty buffers are created
    property int firstDrawedInterval: panel.initializationStep ? 1000 : 500
    property int shadowInterval: firstDrawed ? firstDrawedInterval : 150
    property int shadowSize : Math.ceil(panel.iconSize / 20)


    Connections{
        target: panel
        onIconSizeChanged: updateImages()
        onEnableShadowsChanged: updateImages()
    }


    Rectangle{
        id: draggedRectangle
        anchors.fill: iconImageBuffer
        opacity: 0
        radius: 3
        anchors.margins: 5

        property color tempColor: theme.highlightColor
        color: tempColor
        border.width: 1
        border.color: theme.highlightColor

        onTempColorChanged: tempColor.a = 0.35;
    }

    //temporary buffers containing the normal Image icon and the zoomed Image icon
    Image{id:zoomedImage; visible:false}
    Image{id:normalImage; visible:false}

    Image {
        id: iconImageBuffer

        width: newTempSize + 2*centralItem.shadowSize
        height: width
        anchors.centerIn: parent

        property real basicScalingWidth : (wrapper.inTempScaling == true) ? (panel.iconSize * wrapper.scaleWidth) :
                                                                            panel.iconSize * wrapper.scale
        property real basicScalingHeight : (wrapper.inTempScaling == true) ? (panel.iconSize * wrapper.scaleHeight) :
                                                                             panel.iconSize * wrapper.scale

        property real newTempSize: (wrapper.opacity == 1) ?  Math.min(basicScalingWidth, basicScalingHeight) :
                                                            Math.max(basicScalingWidth, basicScalingHeight)

        property real internalLimit: 1 + ((panel.zoomFactor-1)/2)
        source: (((iconHoveredBuffer.opacity>0)||(wrapper.scale>internalLimit))&&(panel.iconSize >= 48)) ?
                    zoomedImage.source : normalImage.source
       // source: normalImage.source

    }

    Image{
        id: iconHoveredBuffer
        anchors.fill: iconImageBuffer

        opacity: mainItemContainer.containsMouse ? 1 : 0

        visible: ((!clickedAnimation.running) &&
                  (!launcherAnimation.running) )

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
    }

    BrightnessContrast {
        id: brightnessTaskEffect
        anchors.fill: iconImageBuffer
        source: iconImageBuffer

        visible: clickedAnimation.running
    }

    Colorize{
        id: stateColorizer
        source: iconImageBuffer
        anchors.fill: iconImageBuffer
        visible: false
        hue:1
        saturation:1
        lightness:1
    }

    //Something to show until the buffers are updated

    //KQuickControlAddons.QIconItem{
    /*
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
        usesPlasmaTheme: false

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
    }*/

    Loader{
        id:defaultWithShadow
        sourceComponent: component
        active: (IsStartup) ? false : true
    }

    ///////Activate animation/////
    SequentialAnimation{
        id: clickedAnimation
        property bool pressed: mainItemContainer.pressed
        property int speed: 120

        ParallelAnimation{
            PropertyAnimation {
                target: brightnessTaskEffect
                property: "brightness"
                to: -0.5
                duration: clickedAnimation.speed
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: wrapper.scale - 0.3
                duration: clickedAnimation.speed
                easing.type: Easing.OutQuad
            }
        }

        ParallelAnimation{
            PropertyAnimation {
                target: brightnessTaskEffect
                property: "brightness"
                to: 0
                duration: clickedAnimation.speed
                easing.type: Easing.OutQuad
            }
            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: panel.zoomFactor
                duration: clickedAnimation.speed
                easing.type: Easing.OutQuad
            }
        }


        onPressedChanged: {
            if( (pressed)&&
                    ((mainItemContainer.lastButtonClicked == Qt.LeftButton)||(mainItemContainer.lastButtonClicked == Qt.MidButton)) ){
                start();
            }
        }
    }

    /*Component.onCompleted: {
        wrapper.runActivateAnimation.connect(startAnimation);
    }*/
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

            //for some reason the wrapper.scale goes to zoomFactor just a little before the end of the animation
            //this animation makes it 1 before the end of the animation
            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: 1
                duration: 1
            }
        }


        onStopped: {
            wrapper.scale = 1;

            mainItemContainer.animationEnded();
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
        property bool entered: mainItemContainer.mouseEntered

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
                //  wrapper.animationEnded();
            }
            else if(isDemandingAttention){
                bounceNewWindow();
            }
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
                loops = 45;

            // icList.hoveredIndex = -1;
        }

        function bounceNewWindow(){
            newWindowAnimation.init();
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
            removingAnimation.init();
            start();
        }

        onStopped: {
            removingItem.destroy();
        }

        Component.onCompleted: {
            mainItemContainer.groupWindowRemoved.connect(removeTask);
        }

    }
    ////////////////////////////

    ////////////////////////////Release Dragged Animation

    SequentialAnimation{
        id: releaseDraggedAnimation

        property int speed: 300

        property bool inHalf: false

        SequentialAnimation{

            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: 0.6
                duration: releaseDraggedAnimation.speed
                easing.type: Easing.OutQuad
            }

            PropertyAnimation {
                target: releaseDraggedAnimation
                property: "inHalf"
                to: true
                duration: 1
            }

            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: panel.zoomFactor
                duration: releaseDraggedAnimation.speed
                easing.type: Easing.OutQuad
            }
        }

        onInHalfChanged: {
            if(inHalf){
                var halfZoom = 1 + ((panel.zoomFactor - 1) / 2);
                icList.updateScale(index-1, halfZoom, 0);
                icList.updateScale(index+1, halfZoom, 0);
            }
        }

        onStopped: {
            inHalf = false;

            mainItemContainer.inAnimation = false;
            checkListHovered.start();
        }

        function init(){
            mainItemContainer.inAnimation = true;
        }

        function execute(){
            if(mainItemContainer){
                if(mainItemContainer.isDragged){
                    init();
                    start();
                }
            }
        }


        Component.onCompleted: {
            panel.draggingFinished.connect(execute);
        }
    }
    /////////////////// end of release dragged animation

    //////////// States ////////////////////

    states: [
        State{
            name: "*"
            when:  !mainItemContainer.isDragged||(panel.dragSource==null)
            PropertyChanges { target: stateColorizer; visible:false }
        },

        State{
            name: "isDragged"
            when: ( (mainItemContainer.isDragged)&&(panel.dragSource!=null)
                   && (plasmoid.immutable) )
            PropertyChanges { target: stateColorizer; visible:true }
        }
    ]

    //////////// Transitions //////////////

    transitions: [
        Transition{
            id: isDraggedTransition
            to: "isDragged"
            property int speed: 300

            ParallelAnimation{
                PropertyAnimation {
                    target: draggedRectangle
                    property: "opacity"
                    to: 1
                    duration: isDraggedTransition.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: iconImageBuffer
                    property: "opacity"
                    to: 0
                    duration: isDraggedTransition.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: stateColorizer
                    properties: "hue,saturation,lightness"
                    to: 0
                    duration: isDraggedTransition.speed
                    easing.type: Easing.OutQuad
                }
            }
        },
        Transition{
            id: defaultTransition
            to: "*"
            property int speed: 300

            ParallelAnimation{
                PropertyAnimation {
                    target: draggedRectangle
                    property: "opacity"
                    to: 0
                    duration: defaultTransition.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: iconImageBuffer
                    property: "opacity"
                    to: 1
                    duration: defaultTransition.speed
                    easing.type: Easing.OutQuad
                }

                PropertyAnimation {
                    target: stateColorizer
                    properties: "hue,saturation,lightness"
                    to: 1
                    duration: isDraggedTransition.speed
                    easing.type: Easing.OutQuad
                }
            }
        }
    ]


    //////////////////////////

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
                id:fixedIcon2

                width: panel.zoomFactor * (panel.iconSize + 2*shadowImageNoActive.radius)
                height: width
                visible:false

                PlasmaCore.IconItem{
                    id: iconImage2

                    width: panel.zoomFactor * panel.iconSize
                    height: width
                    anchors.centerIn: parent

                    active: false
                    enabled: true
                    source: decoration
                    usesPlasmaTheme: false

                    visible: true
                }
            }


            Item{
                id:fixedIcon

                width: panel.iconSize + 2*shadowImageNoActive.radius
                height: width

                visible:false

                PlasmaCore.IconItem{
                    id: iconImage

                    width: panel.iconSize
                    height: width
                    anchors.centerIn: parent

                    active: false
                    enabled: true
                    source: decoration
                    usesPlasmaTheme: false

                    visible: true

                    onSourceChanged: {
                        centralItem.updateImages();
                    }

                    Component{
                        id:tttTimer

                        Timer{
                            id:ttt
                            repeat:false
                            interval: centralItem.shadowInterval

                            //   property int counter2: 0;

                            onTriggered: {
                                if(index !== -1){                                   
                                    if(panel.initializationStep){
                                        panel.initializationStep = false;
                                    }

                                    centralItem.firstDrawed = true;

                                    if(panel.enableShadows == true){
                                        shadowImageNoActive.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            normalImage.source.destroy();
                                            normalImage.source = result.url;
                                            //iconImageBuffer.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon.width,fixedIcon.height) );

                                        shadowImageNoActive2.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            zoomedImage.source.destroy();
                                            zoomedImage.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon2.width,fixedIcon2.height) );
                                    }
                                    else{
                                        /*if(AppId=="yarock"){
                                            console.log(panel.iconSize);
                                            fixedIcon.grabToImage(function(result){
                                                result.saveToFile("/home/michail/yarockscreen.png");
                                            });
                                        }
                                        if(AppId=="writer"){
                                            fixedIcon.grabToImage(function(result){
                                                result.saveToFile("/home/michail/writerscreen.png");
                                            });
                                        }*/

                                        fixedIcon.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            normalImage.source.destroy();
                                            normalImage.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon.width,fixedIcon.height) );

                                        fixedIcon2.grabToImage(function(result) {
                                            iconImageBuffer.source.destroy();
                                            zoomedImage.source.destroy();
                                            zoomedImage.source = result.url;
                                            result.destroy();
                                        }, Qt.size(fixedIcon2.width,fixedIcon2.height) );
                                    }

                                    hoveredImage.grabToImage(function(result) {
                                        iconHoveredBuffer.source.destroy();
                                        iconHoveredBuffer.source = result.url;
                                        result.destroy();
                                    }, Qt.size(fixedIcon2.width,fixedIcon2.height) );


                                    mainItemContainer.buffersAreReady = true;
                                    iconImageBuffer.opacity = 1;

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
                samples: 2 * radius
                color: "#cc080808"
                source: fixedIcon

                verticalOffset: 2
            }

            DropShadow {
                id:shadowImageNoActive2
                visible: false
                width: fixedIcon2.width
                height: fixedIcon2.height
                anchors.centerIn: fixedIcon2

                radius: Math.ceil(panel.zoomFactor*centralItem.shadowSize)
                samples: 2 * radius
                color: "#cc080808"
                source: fixedIcon2

                verticalOffset: 2
            }

            BrightnessContrast{
                id:hoveredImage
                visible: false
                width: fixedIcon2.width
                height: fixedIcon2.height
                anchors.centerIn: fixedIcon2

                brightness: 0.25
                source: fixedIcon2
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
