import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.taskmanager 0.1 as TaskManagerApplet

Component {
    id: iconDelegate
    Item{
        id: mainItemContainer

        visible: (opacity > 0)
        opacity: 0

        property bool containsMouse : wrapper.containsMouse
        readonly property var m: model
        property bool isWindow: model.IsWindow ? true : false

        anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
        anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
        anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
        anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

        width: (icList.orientation === Qt.Horizontal) ? hiddenSpacerLeft.width+wrapper.width+hiddenSpacerRight.width : wrapper.width
        height: (icList.orientation === Qt.Horizontal) ? wrapper.height : hiddenSpacerLeft.height + wrapper.height + hiddenSpacerRight.height

        property QtObject contextMenu: null

        property int animationTime: 60

        /*Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: "red"
            color: "transparent"
            visible: IsStartup ? true : false
        }*/

        Behavior on opacity {
            NumberAnimation { duration: (IsStartup || (IsLauncher) ) ? 0 : 400 }
        }

        onIsWindowChanged: {
            if (isWindow) {
                taskInitComponent.createObject(mainItemContainer);
            }
        }

        /*    ListView.onRemove: SequentialAnimation {
            PropertyAction { target: panel; property: "inAnimation"; value: true }
            PropertyAction { target: mainItemContainer; property: "ListView.delayRemove"; value: true }
            ParallelAnimation{
                //    NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                NumberAnimation { target: wrapper; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
            }
            PropertyAction { target: mainItemContainer; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: panel; property: "inAnimation"; value: false }
        }*/

        Flow{
            width: parent.width
            height: parent.height

            // a hidden spacer for the first element to add stability
            // IMPORTANT: hidden spacers must be tested on vertical !!!
            Item{
                id: hiddenSpacerLeft
                visible: (index === 0)

                property real nHiddenSize: (nScale > 0) ? (panel.realSize * nScale) : 0

                //we add one missing pixel from calculations
                width: (icList.orientation === Qt.Horizontal) ? nHiddenSize : wrapper.width
                height: (icList.orientation === Qt.Vertical) ? nHiddenSize : wrapper.height


                property real nScale: 0

                Behavior on nScale {
                    NumberAnimation { duration: mainItemContainer.animationTime }
                }

                /*   Rectangle{
                    width:parent.width
                    height:1
                    y:parent.height / 2
                    border.width: 1
                    border.color: "red"
                    color: "transparent"
                }*/
            }

            MouseArea{
                id: wrapper

                signal runActivateAnimation();
                signal runLauncherAnimation();

                width: (icList.orientation === Qt.Vertical ) ? basicScalingWidth+addedSpace :
                                                               basicScalingWidth
                height: (icList.orientation === Qt.Vertical ) ? basicScalingHeight :
                                                                basicScalingHeight + addedSpace

                acceptedButtons: Qt.LeftButton | Qt.MidButton | Qt.RightButton

                hoverEnabled: (inAnimation !== true)
                property int addedSpace: 12

                property bool pressed: false

                //scales which are used mainly for activating InLauncher
                ////Scalers///////

                property real scale: 1;
                property real tempScaleWidth: 1
                property real tempScaleHeight: 1
                property bool inTempScaling: ((tempScaleWidth !== 1) || (tempScaleHeight !== 1) )

                property real scaleWidth: (inTempScaling == true) ? tempScaleWidth : scale
                property real scaleHeight: (inTempScaling == true) ? tempScaleHeight : scale

                ///Dont use Math.floor it adds one pixel in animations and creates glitches
                property real cleanScaling: panel.realSize * scale

                property real basicScalingWidth : (inTempScaling == true) ? (panel.realSize * scaleWidth) : cleanScaling
                property real basicScalingHeight : (inTempScaling == true) ? (panel.realSize * scaleHeight) : cleanScaling

                property real regulatorWidth: basicScalingWidth - 2;
                property real regulatorHeight: basicScalingHeight - 2;
                /// end of Scalers///////

                property int curIndex: icList.hoveredIndex
              //  property int index: mainItemContainer.Positioner.index
                property real center: Math.floor(width / 2)
                property real animationStep: panel.iconSize / 8  ;

                property bool inAnimation: false

                /* Rectangle{
                    anchors.fill: parent
                    border.width: 1
                    border.color: "red"
                    color: "transparent"
                } */

                Behavior on scale {
                    NumberAnimation { duration: mainItemContainer.animationTime }
                }

                Loader{
                    active: (panel.position !== PlasmaCore.Types.TopPositioned)
                    sourceComponent: states3Flow

                    Component{
                        id: states3Flow
                        Flow{
                            //    visible: (panel.position === PlasmaCore.Types.TopPositioned) ? false : true
                            width: wrapper.width
                            height: wrapper.height

                            flow: (panel.position === PlasmaCore.Types.BottomPositioned) ? Flow.TopToBottom : Flow.LeftToRight
                            layoutDirection: (panel.position === PlasmaCore.Types.LeftPositioned) ? Qt.RightToLeft : Qt.LeftToRight

                            TaskIconItem{}
                            TaskActiveItem{}
                            TaskGroupItem{}

                        }//Flow
                    }
                }

                Loader{
                    active: (panel.position === PlasmaCore.Types.TopPositioned)
                    sourceComponent: topStateFlow

                    Component{
                        id: topStateFlow
                        //Flow which is used only when the listview is on Top and we are hiding the main one
                        Flow{
                            visible: (panel.position === PlasmaCore.Types.TopPositioned) ? true : false
                            width: wrapper.width
                            height: wrapper.height

                            flow: Flow.TopToBottom
                            layoutDirection: (panel.position === PlasmaCore.Types.LeftPositioned) ? Qt.RightToLeft : Qt.LeftToRight

                            TaskGroupItem{}
                            TaskActiveItem{}
                            TaskIconItem{}
                        } //Flow Element
                    }
                }


                function calculateScales( currentMousePosition ){
                    var distanceFromHovered = Math.abs(index - icList.hoveredIndex);

                    // A new algorithm tryig to make the zoom calculation only once
                    // and at the same time fixing glitches
                    if ((distanceFromHovered == 0)&&(currentMousePosition  > 0) ){

                        var rDistance = Math.abs(currentMousePosition  - center);

                        //check if the mouse goes right or down according to the center
                        var positiveDirection =  ((currentMousePosition  - center) >= 0 );


                        //finding the zoom center e.g. for zoom:1.7, calculates 0.35
                        var zoomCenter = (panel.zoomFactor - 1) / 2

                        //computes the in the scale e.g. 0...0.35 according to the mouse distance
                        //0.35 on the edge and 0 in the center
                        var firstComputation = (rDistance / center) * zoomCenter;

                        //calculates the scaling for the neighbour tasks
                        var bigNeighbourZoom = Math.min(1 + zoomCenter + firstComputation, panel.zoomFactor);
                        var smallNeighbourZoom = Math.max(1 + zoomCenter - firstComputation, 1);

                        bigNeighbourZoom = Number(bigNeighbourZoom.toFixed(2));
                        smallNeighbourZoom = Number(smallNeighbourZoom.toFixed(2));

                        var leftScale;
                        var rightScale;

                        if(positiveDirection === true){
                            rightScale = bigNeighbourZoom;
                            leftScale = smallNeighbourZoom;
                        }
                        else {
                            rightScale = smallNeighbourZoom;
                            leftScale = bigNeighbourZoom;
                        }

                        //    console.debug(leftScale + "  " + rightScale + " " + index);


                        //activate messages to update the the neighbour scales
                        // if(index < icList.children.length - 1){
                        icList.updateScale(index+1, rightScale, 0);
                        //   }

                        //   if(index > 0){
                        icList.updateScale(index-1,leftScale, 0);
                        //  }

                        //Left hiddenSpacer


                        if((index === 0 )&&(icList.count > 1)){
                            hiddenSpacerLeft.nScale = leftScale - 1;
                        }

                        //Right hiddenSpacer
                        if((index === icList.count - 1 )&&(icList.count>1)){
                            hiddenSpacerRight.nScale =  rightScale - 1;
                        }

                        scale = panel.zoomFactor;


                        //debugging code
                        /*    if (index === 1 ){
                            var left = icList.contentItem.children[index-1];
                            var right = icList.contentItem.children[index+1];
                            console.debug("LW: "+left.width+" C: "+width+" RW:"+right.width);
                            console.debug("Total Width: "+(width+left.width+right.width));
                        } */
                    }

                    //if( (distanceFromHovered > 1)||(icList.currentSpot < 0)){
                    // scale = 1;
                    //  }

                } //scale


                //restore scales when there is no zoom factor for that item or
                //the mouse is out of the ListView
                onCurIndexChanged: {
                    var distanceFromHovered = Math.abs(index - icList.hoveredIndex);

                    if( (distanceFromHovered > 1) || (curIndex < 0)){
                        scale = 1;
                        hiddenSpacerLeft.nScale = 0;
                        hiddenSpacerRight.nScale = 0;
                    }
                }

                onEntered: {
                    icList.hoveredIndex = index;

                    if (icList.orientation == Qt.Horizontal){
                        icList.currentSpot = mouseX;
                        calculateScales(mouseX);
                    }
                    else{
                        icList.currentSpot = mouseY;
                        calculateScales(mouseY);
                    }
                }

                // IMPORTANT: This must be improved ! even for small miliseconds  it reduces performance
                onExited: {
                    if(mainItemContainer.contextMenu && mainItemContainer.contextMenu.status == PlasmaComponents.DialogStatus.Open){
                        ///dont check to restore zooms
                    }
                    else{
                        checkListHovered.start();
                    }
                }

                onPositionChanged: {

                    if(inAnimation == false){
                        if (icList.orientation == Qt.Horizontal){
                            var step = Math.abs(icList.currentSpot-mouse.x);
                            if (step >= animationStep){
                                icList.hoveredIndex = index;
                                icList.currentSpot = mouse.x;
                                calculateScales(mouse.x);
                            }
                        }
                        else{
                            var step = Math.abs(icList.currentSpot-mouse.y);
                            if (step >= animationStep){
                                icList.hoveredIndex = index;
                                icList.currentSpot = mouse.y;
                                calculateScales(mouse.y);
                            }
                        }
                    }
                }

                property int lastButtonClicked: -1;

                function animationEnded(){
                    if (lastButtonClicked == Qt.MidButton){
                        if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.NewInstance) {
                            tasksModel.requestNewInstance(modelIndex());
                        } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.Close) {
                            tasksModel.requestClose(modelIndex());
                        } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.ToggleMinimized) {
                            tasksModel.requestToggleMinimized(modelIndex());
                        }
                    }
                    else if (lastButtonClicked == Qt.LeftButton) {
                        if (model.IsGroupParent)
                            panel.presentWindows(model.LegacyWinIdList);
                        else {
                            if (IsMinimized === true) {
                                var i = modelIndex();
                                tasksModel.requestToggleMinimized(i);
                                tasksModel.requestActivate(i);
                            } else if (IsActive === true) {
                                tasksModel.requestToggleMinimized(modelIndex());
                            } else {
                                tasksModel.requestActivate(modelIndex());
                            }
                        }
                    }

                    pressed = false;
                    inAnimation = false;
                }

                onPressed: {
                    if ((mouse.button == Qt.LeftButton)||(mouse.button == Qt.MidButton)) {
                        pressed = true;
                        inAnimation = true;
                        lastButtonClicked = mouse.button;

                        if( model.IsLauncher )
                            runLauncherAnimation();
                        else
                            runActivateAnimation();
                    }
                    else if (mouse.button == Qt.RightButton){
                        mainItemContainer.contextMenu = panel.contextMenuComponent.createObject(mainItemContainer);
                        mainItemContainer.contextMenu.visualParent = mainItemContainer;
                        mainItemContainer.contextMenu.show();
                    }
                }

          /*      onReleased: {
                    if(pressed){
                        if (mouse.button == Qt.MidButton){
                            if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.NewInstance) {
                                tasksModel.requestNewInstance(modelIndex());
                            } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.Close) {
                                tasksModel.requestClose(modelIndex());
                            } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.ToggleMinimized) {
                                tasksModel.requestToggleMinimized(modelIndex());
                            }

                            pressed = false;
                        } else if (mouse.button == Qt.LeftButton) {
                                 if (model.IsGroupParent)
                                panel.presentWindows(model.LegacyWinIdList);
                            else {
                                if (IsMinimized === true) {
                                    var i = modelIndex();
                                    tasksModel.requestToggleMinimized(i);
                                    tasksModel.requestActivate(i);
                                } else if (IsActive === true) {
                                    tasksModel.requestToggleMinimized(modelIndex());
                                } else {
                                    tasksModel.requestActivate(modelIndex());
                                }
                            }
                        }
                    }

                } */

                function modelIndex(){
                    return tasksModel.makeModelIndex(index);
                }


                function signalUpdateScale(nIndex, nScale, step){
                    if( index === nIndex){
                        if(nScale >= 0)
                            scale = nScale + step;
                        else
                            scale = scale + step;
                    }
                }

                property string oldAppId: ""

                Component.onCompleted: {
                    icList.updateScale.connect(signalUpdateScale);
                    //     console.log(AppId+ " ,"+AppName+" ,"+LauncherUrlWithoutIcon);
                    oldAppId = AppId;
                }
            }// MouseArea

            // a hidden spacer on the right for the last item to add stability
            Item{
                id: hiddenSpacerRight
                visible: (index === icList.count - 1)

                property real nHiddenSize: (nScale > 0) ? (panel.realSize * nScale) : 0

                //we add one missing pixel from calculations
                width: (icList.orientation === Qt.Horizontal) ? nHiddenSize : wrapper.width
                height: (icList.orientation === Qt.Vertical) ? nHiddenSize : wrapper.height

                property real nScale: 0

                Behavior on nScale {
                    NumberAnimation { duration: mainItemContainer.animationTime }
                }

                /*     Rectangle{
                         width:parent.width
                         height:1
                         y:parent.height / 2
                         border.width: 1
                         border.color: "red"
                         color: "transparent"
                     }*/
            }

        }// Flow with hidden spacers inside

        Component {
            id: taskInitComponent
            Timer {
                id: timer

                interval: units.longDuration * 2
                repeat: false

                onTriggered: {
                    wrapper.hoverEnabled = true;

                    if (parent.isWindow) {
                        tasksModel.requestPublishDelegateGeometry(wrapper.modelIndex(),
                                                                  backend.globalRect(mainItemContainer), mainItemContainer);
                    }

                    timer.destroy();
                }

                Component.onCompleted: timer.start()
            }
        }

        Component.onCompleted: {

            if (model.IsWindow !== true) {
                taskInitComponent.createObject(wrapper);
            }
            else{
                showWindowAnimation.showWindow();
            }

            opacity = 1;
        }

        Component.onDestruction: {
            //    console.log("Destroying... "+index);
        }


        /////Animations
        SequentialAnimation{
            id:showWindowAnimation
            property int speed: 400

            PropertyAnimation {
                target: wrapper
                property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                to: 1
                duration: showWindowAnimation.speed
                easing.type: Easing.OutQuad
            }

            function init(){
                if (icList.orientation == Qt.Vertical)
                    wrapper.tempScaleWidth = 0;
                else
                    wrapper.tempScaleHeight = 0;
            }

            function showWindow(){
                init();
                start();
            }

            //  Component.onCompleted: {wrapper.runLauncherAnimation.connect(bounceLauncher);}
        }



    }// main Item
}
