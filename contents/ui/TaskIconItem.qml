/*
 *  Copyright 2013 Michail Vourlakos <mvourlakos@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

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
    property bool toBeDestroyed: false

    // three intervals in order to create the necessarty buffers from the
    // PlasmaCore.IconItem, one big interval for the first creation of the
    // plasmoid, a second one for the first creation of a task and a small one
    // for simple updates.
    // This is done before especially on initialization stage some visuals
    // are not ready and empty buffers are created

    //property int firstDrawedInterval: panel.initializationStep ? 2000 : 1000
    // property int shadowInterval: firstDrawed ? firstDrawedInterval : 250
    property int shadowInterval: firstDrawed ? 1000 : 250

    property int shadowSize : Math.ceil(panel.iconSize / 20)

    readonly property bool smartLauncherEnabled: ((mainItemContainer.isStartup === false) && (plasmoid.configuration.smartLaunchersEnabled))
    readonly property variant iconDecoration: decoration
    property QtObject buffers: null
    property QtObject smartLauncherItem: null

    Connections{
        target: panel
        onZoomFactorChanged: updateImages()
        onIconSizeChanged: updateImages()
        onEnableShadowsChanged: updateImages()
    }

    onIconDecorationChanged: {
        updateImages();
    }

    Rectangle{
        id: draggedRectangle
        width: iconImageBuffer.width+1
        height: iconImageBuffer.height+1
        anchors.centerIn: iconImageBuffer
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
    // Image{id:zoomedImage; visible:false}
    //  Image{id:normalImage; visible:false}
    Image{
        id:shadowedImage
        anchors.centerIn:iconImageBuffer

        width:iconImageBuffer.width+2*shadowSize
        height:iconImageBuffer.height+2*shadowSize

        visible: plasmoid.configuration.showShadows

        states: State {
            name: "reparented"
            ParentChange { target: shadowedImage; parent: panel; }
        }

        //Corize to use when a window is removed....
        Colorize{
            id: removeImageColorizer
            source: parent
            anchors.fill: parent

            enabled: false
            visible: false

            hue: 0
            saturation: 0
            lightness: 0
        }
    }

    KQuickControlAddons.QIconItem{
        id: iconImageBuffer

        anchors.centerIn: parent

        width: newTempSize //+ 2*centralItem.shadowSize
        height: width
        icon: decoration

        property int zoomedSize: panel.zoomFactor * panel.iconSize

        property real basicScalingWidth : wrapper.inTempScaling ? (panel.iconSize * wrapper.scaleWidth) :
                                                                  panel.iconSize * wrapper.scale
        property real basicScalingHeight : wrapper.inTempScaling ? (panel.iconSize * wrapper.scaleHeight) :
                                                                   panel.iconSize * wrapper.scale

        property real newTempSize: (wrapper.opacity == 1) ?  Math.min(basicScalingWidth, basicScalingHeight) :
                                                            Math.max(basicScalingWidth, basicScalingHeight)
    }

    BrightnessContrast{
        id:hoveredImage
        opacity: mainItemContainer.containsMouse ? 1 : 0
        anchors.fill: iconImageBuffer

        brightness: 0.25
        source: iconImageBuffer

        Behavior on opacity {
            NumberAnimation { duration: plasmoid.configuration.durationTime*units.longDuration }
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
        //sourceComponent: imageBufferingComponent
        sourceComponent: TaskIconBuffers{}
        active: mainItemContainer.isStartup ? false : true
    }

    Loader {
        anchors.fill: iconImageBuffer
        asynchronous: true
        source: "TaskProgressOverlay.qml"
        active: (centralItem.smartLauncherEnabled && centralItem.smartLauncherItem
                 && centralItem.smartLauncherItem.progressVisible)
    }

    ///////Activate animation/////
    SequentialAnimation{
        id: clickedAnimation
        property bool pressed: mainItemContainer.pressed
        property int speed: plasmoid.configuration.durationTime*units.longDuration

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
                to: panel.taskInAnimation ? 0.9 : wrapper.scale - (panel.zoomFactor - 1) / 2
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
                to: panel.taskInAnimation ? 1 : panel.zoomFactor
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


    Component.onCompleted: {
        if (smartLauncherEnabled && !smartLauncherItem) {
            var smartLauncher = Qt.createQmlObject("
    import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet;
    TaskManagerApplet.SmartLauncherItem { }", centralItem);

            smartLauncher.launcherUrl = Qt.binding(function() { return model.LauncherUrlWithoutIcon; });

            smartLauncherItem = smartLauncher;
        }

        //start up sequence....
        /*  if(panel.initializationStep){
            panel.initializationStep = false;
        }

        centralItem.firstDrawed = true;

        mainItemContainer.buffersAreReady = true;
        if(!panel.initializatedBuffers)
            panel.noInitCreatedBuffers++;

        iconImageBuffer.opacity = 1;*/
    }

    Component.onDestruction: {
        centralItem.toBeDestroyed = true;
        /*   if(normalImage.source)
            normalImage.source.destroy();
        if(zoomedImage.source)
            zoomedImage.source.destroy();
        if(iconImageBuffer.source)
            iconImageBuffer.source.destroy();*/

        if(shadowedImage && shadowedImage.source)
            shadowedImage.source.destroy();

        //  if(iconHoveredBuffer.source)
        // iconHoveredBuffer.source.destroy();

        if(removingAnimation.removingItem)
            removingAnimation.removingItem.destroy();

        gc();
    }
    ////end of activate animation////

    ////bouncing task, e.g. on launcher activating and when a new window is
    ////added in a group task
    SequentialAnimation{
        id:launcherAnimation

        property int speed: plasmoid.configuration.durationTime * 0.8 * units.longDuration

        SequentialAnimation{
            ParallelAnimation{
                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: panel.zoomFactor
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
                duration: 3*plasmoid.configuration.durationTime*launcherAnimation.speed
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
            panel.noTasksInAnimation--;
        }

        function init(){
            panel.noTasksInAnimation++;
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

        property int speed: plasmoid.configuration.durationTime*units.longDuration
        property bool isDemandingAttention: (IsDemandingAttention === true) ? true : false
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
                duration: 3*plasmoid.configuration.durationTime*newWindowAnimation.speed
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

        property int speed: 2*plasmoid.configuration.durationTime*units.longDuration
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
            if(shadowedImage){
                var relavantPoint = panel.mapFromItem(shadowedImage,0,0);
                shadowedImage.x = relavantPoint.x;
                shadowedImage.y = relavantPoint.y;
                removeImageColorizer.enabled = true;
                removeImageColorizer.visible = true;

                //  removeImageColorizer.opacity = 1;
                removingItem = shadowedImage;
                shadowedImage.state = "reparented";
                shadowedImage.visible = true;

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
        }

        function removeTask(){
            if(centralItem.firstDrawed && !centralItem.toBeDestroyed &&
                    mainItemContainer.buffersAreReady){
                removingAnimation.init();
                start();
            }
        }

        onStopped: {
            if(removingItem)
                removingItem.destroy();

            gc();
        }

        Component.onCompleted: {
            mainItemContainer.groupWindowRemoved.connect(removeTask);
        }
    }
    ////////////////////////////

    ////////////////////////////Release Dragged Animation

    SequentialAnimation{
        id: releaseDraggedAnimation

        property bool inHalf: false

        property int speed: plasmoid.configuration.durationTime*units.longDuration

        SequentialAnimation{

            PropertyAnimation {
                target: wrapper
                property: "scale"
                to: 0.6;
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
                panel.updateScale(index-1, halfZoom, 0);
                panel.updateScale(index+1, halfZoom, 0);
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
            PropertyChanges { target: wrapper; scale:1 + ((panel.zoomFactor - 1) / 2)}
        }
    ]

    //////////// Transitions //////////////

    transitions: [
        Transition{
            id: isDraggedTransition
            to: "isDragged"
            property int speed: plasmoid.configuration.durationTime*units.longDuration

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
            property int speed: plasmoid.configuration.durationTime*units.longDuration

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


}// Icon Item
