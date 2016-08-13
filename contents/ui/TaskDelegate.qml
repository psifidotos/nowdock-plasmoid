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

        visible: (IsStartup) ? false : true

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
        property bool delayingRemove: ListView.delayRemove
        property bool buffersAreReady: false
        property int itemIndex: index

        property bool pressed: wrapper.pressed
        property int pressX: wrapper.pressX
        property int pressY: wrapper.pressY


        signal groupWindowAdded();
        signal groupWindowRemoved();


        onDelayingRemoveChanged: {
            if(delayingRemove && isWindow)
                groupWindowRemoved();
        }

        onContainsMouseChanged:{
            if(!containsMouse){
                hiddenSpacerLeft.nScale = 0;
                hiddenSpacerRight.nScale = 0;
            }
        }


        /*    onIsDemandingAttentionChanged: {
            if (isDemandingAttention)
                newWindowAdded();
        } */


        /*Rectangle{
            anchors.fill: parent
            border.width: 1
            border.color: "red"
            color: "transparent"
            visible: IsStartup ? true : false
        }*/

        Behavior on opacity {
            // NumberAnimation { duration: (IsStartup || (IsLauncher) ) ? 0 : 400 }
            NumberAnimation { duration: 400 }
        }

        onIsWindowChanged: {
            if (isWindow) {
                taskInitComponent.createObject(mainItemContainer);
            }
        }

        TaskWindows{
            id: tasksWindows

            property int previousCount: 0

            onWindowsCountChanged: {
                if ((windowsCount >= 2) && (windowsCount > previousCount)){
                    // if( ! wrapper.containsMouse){
                    mainItemContainer.groupWindowAdded();
                    //     }
                }
                else if ((windowsCount >=1) &&(windowsCount < previousCount)){
                    mainItemContainer.groupWindowRemoved();
                }

                previousCount = windowsCount;
            }
        }

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

                opacity: 0
                width: (IsStartup) ? 0 : showDelegateWidth
                height: (IsStartup) ? 0 : showDelegateheight

                acceptedButtons: Qt.LeftButton | Qt.MidButton | Qt.RightButton

                hoverEnabled: (inAnimation !== true)&& (!IsStartup)


                property real showDelegateWidth: (icList.orientation === Qt.Vertical ) ? basicScalingWidth+addedSpace :
                                                                                         basicScalingWidth

                property real showDelegateheight: (icList.orientation === Qt.Vertical ) ? basicScalingHeight :
                                                                                          basicScalingHeight + addedSpace

                property int addedSpace: 15

                property bool pressed: false
                property bool mouseEntered: false
                property bool isDragged: false
                property int pressX: -1
                property int pressY: -1

                property bool inAnimation: false

                property int lastButtonClicked: -1;

                //scales which are used mainly for activating InLauncher
                ////Scalers///////

                property real scale: 1;
                property real tempScaleWidth: 0
                property real tempScaleHeight: 0
                property bool inTempScaling: (((tempScaleWidth !== 1) || (tempScaleHeight !== 1) ) && (!mouseEntered) )

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

                signal runLauncherAnimation();

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

                        // console.debug(leftScale + "  " + rightScale + " " + index);


                        //activate messages to update the the neighbour scales
                        icList.updateScale(index+1, rightScale, 0);
                        icList.updateScale(index-1,leftScale, 0);


                        //Left hiddenSpacer
                        if((index === 0 )&&(icList.count > 1)){
                            hiddenSpacerLeft.nScale = leftScale - 1;
                        }

                        //Right hiddenSpacer
                        if((index === icList.count - 1 )&&(icList.count>1)){
                            hiddenSpacerRight.nScale =  rightScale - 1;
                        }

                        scale = panel.zoomFactor;
                    }

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
                    if(!inAnimation){
                        icList.hoveredIndex = index;
                        mouseEntered = true;
                        icList.mouseWasEntered(index-2, false);
                        icList.mouseWasEntered(index+2, false);
                        icList.mouseWasEntered(index-1, true);
                        icList.mouseWasEntered(index+1, true);

                        if (icList.orientation == Qt.Horizontal){
                            icList.currentSpot = mouseX;
                            calculateScales(mouseX);
                        }
                        else{
                            icList.currentSpot = mouseY;
                            calculateScales(mouseY);
                        }
                    }
                }

                // IMPORTANT: This must be improved ! even for small miliseconds  it reduces performance
                onExited: {
                    mouseEntered = false;
                    if(mainItemContainer.contextMenu && mainItemContainer.contextMenu.status == PlasmaComponents.DialogStatus.Open){
                        ///dont check to restore zooms
                    }
                    else{
                        if(!inAnimation){
                            checkListHovered.start();
                        }
                    }
                }

                onIsDraggedChanged: {
                    if(isDragged){
                        scale = 1.35;
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

                        // mouse.button is always 0 here, hence checking with mouse.buttons
                        if (pressX != -1 && mouse.buttons == Qt.LeftButton && dragHelper.isDrag(pressX, pressY, mouse.x, mouse.y)) {

//                            icList.hoveredIndex = -1;
                            icList.updateScale(index-1, 1, 0);
                            icList.updateScale(index+1, 1, 0);
                    //        icList.updateScale(index, 1, 0);

                            isDragged = true;

                            panel.dragSource = mainItemContainer;
                            dragHelper.startDrag(mainItemContainer, model.MimeType, model.MimeData,
                                                 model.LauncherUrlWithoutIcon, model.decoration);
                            pressX = -1;
                            pressY = -1;
                        }
                    }
                }

                function animationEnded(){
                    if(pressed){
                        if ((lastButtonClicked == Qt.LeftButton)||(lastButtonClicked == Qt.MidButton)){
                            tasksModel.requestActivate(modelIndex());
                        }
                    }

                    pressed = false;
                    inAnimation = false;
                }

                onPressed: {
                    if ((mouse.button == Qt.LeftButton)||(mouse.button == Qt.MidButton)) {
                        lastButtonClicked = mouse.button;
                        pressed = true;
                        pressX = mouse.x;
                        pressY = mouse.y;
                    }
                    else if (mouse.button == Qt.RightButton){
                        mainItemContainer.contextMenu = panel.contextMenuComponent.createObject(mainItemContainer);
                        mainItemContainer.contextMenu.visualParent = mainItemContainer;
                        mainItemContainer.contextMenu.show();
                    }
                }

                onReleased: {
                    if(pressed){
                        if (mouse.button == Qt.MidButton){
                            if( !model.IsLauncher){
                                if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.NewInstance) {
                                    tasksModel.requestNewInstance(modelIndex());
                                } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.Close) {
                                    tasksModel.requestClose(modelIndex());
                                } else if (plasmoid.configuration.middleClickAction == TaskManagerApplet.Backend.ToggleMinimized) {
                                    tasksModel.requestToggleMinimized(modelIndex());
                                }
                            }
                            else{
                                mouseEntered = false;
                                inAnimation = true;
                                runLauncherAnimation();
                            }
                        }
                        else if (mouse.button == Qt.LeftButton){
                            if( model.IsLauncher ){
                                mouseEntered = false;
                                inAnimation = true;
                                runLauncherAnimation();
                            }
                            else{
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
                    }

                    //have to wait first for the launcher animation to end
                    if(!IsLauncher)
                        pressed = false;
                }

                onContainsMouseChanged:{
                    if(!containsMouse){
                        if(!inAnimation)
                            pressed=false;
                    }
                }


                function modelIndex(){
                    return tasksModel.makeModelIndex(index);
                }

                function signalUpdateScale(nIndex, nScale, step){
                    if( index === nIndex){
                        if(nScale >= 0)
                            scale = nScale + step;
                        else
                            scale = scale + step;

                        //     console.log(index+ ", "+scale);
                    }
                }

                function signalMouseWasEntered(nIndex, value){
                    if( index === nIndex)
                        mouseEntered = value;
                }


                property string oldAppId: ""

                Component.onCompleted: {
                    icList.updateScale.connect(signalUpdateScale);
                    icList.mouseWasEntered.connect(signalMouseWasEntered);
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

                interval: 800
                repeat: false

                onTriggered: {
                    wrapper.hoverEnabled = true;
                    tasksModel.requestPublishDelegateGeometry(wrapper.modelIndex(),
                                                              backend.globalRect(mainItemContainer), mainItemContainer);
                    timer.destroy();
                }

                Component.onCompleted: timer.start()
            }
        }

        Component.onCompleted: {
            showWindowAnimation.showWindow();
        }

        Component.onDestruction: {
            //    console.log("Destroying... "+index);
        }


        /////Animations

        ///item's added Animation
        SequentialAnimation{
            id:showWindowAnimation
            property int speed: 400

            PropertyAnimation {
                target: wrapper
                property: (icList.orientation == Qt.Vertical) ? "tempScaleHeight" : "tempScaleWidth"
                to: 1
                duration: showWindowAnimation.speed
                easing.type: Easing.OutQuad
            }

            ParallelAnimation{

                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: 1
                    duration: showWindowAnimation.speed
                    easing.type: Easing.OutQuad
                }


                PropertyAnimation {
                    target: wrapper
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: showWindowAnimation.speed
                    easing.type: Easing.OutQuad
                }
            }

            onStopped: {
                if(IsWindow || IsStartup){
                    taskInitComponent.createObject(wrapper);
                    if (IsDemandingAttention){
                        mainItemContainer.groupWindowAdded();
                    }
                }
            }

            function init(){
                wrapper.tempScaleWidth = 0;
                wrapper.tempScaleHeight = 0;
            }

            function showWindow(){
                if(IsLauncher || IsStartup || icList.delayingRemoval){
                    delayShowWindow.createObject(mainItemContainer);
                }
                else{
                    execute();
                }
            }

            function execute(){
                init();
                start();
            }
        }

        ///trying to compete with the crazy situation in the tasksModel
        ///with launchers and startups... There are windows that stay
        ///startup mode e.g. chrome, libreoffice... not showing startups
        ///the user can lose windows...
        ///Based on the animations, windows are shown directly, startups
        ///are shown after 5secs of existence, and launchers after 200ms
        ///for launchers this is set in order to give to a window the time
        ///to desappear and then show the launcher...


        //   property int mainDelay: IsLauncher ? 800 : 400
        //   property int mainDelay: icList.delayingRemoval ? 2*showWindowAnimation.speed : 450

        //BE CAREFUL: this interval (e.g. 700ms) must be lower from the removal animation
        //duration e.g.(800ms) because there are situattions that because of this some
        //launchers delay A LOT to reappear, e.g google-chrome
        //I will blacklist google-chrome as I have not found any other case for this bug
        //to appear, but even this way there are cases that still appears...
        property int mainDelay: (AppId == "google-chrome") ? 0 : 2*showWindowAnimation.speed
        property int windowDelay: IsStartup ? 5000 : mainDelay

        Component {
            id: delayShowWindow
            Timer {
                id: timerWindow

                interval: windowDelay

                repeat: false

                onTriggered: {
                    //console.log("I am in here: "+mainItemContainer.windowDelay);
                    showWindowAnimation.execute();
                    timerWindow.destroy();
                }

                Component.onCompleted: timerWindow.start()
            }
        }

        ///Item's Removal Animation

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: mainItemContainer; property: "ListView.delayRemove"; value: true }
            PropertyAction { target: icList; property: "delayingRemoval"; value: true }
            PropertyAction { target: wrapper; property: "opacity"; value: isWindow ? 0 : 1 }
            //animation mainly for launchers removal and startups
            ParallelAnimation{
                id: removalAnimation

                // property int speed: (IsStartup && !mainItemContainer.visible)? 0 : 400
                //property int speed: 400

                NumberAnimation { target: wrapper; property: "opacity"; to: 0; duration: showWindowAnimation.speed; easing.type: Easing.InQuad }

                PropertyAnimation {
                    target: wrapper
                    property: (icList.orientation == Qt.Vertical) ? "tempScaleWidth" : "tempScaleHeight"
                    to: 0
                    duration: showWindowAnimation.speed
                    easing.type: Easing.InQuad
                }
            }

            //smooth move into place the surrounding tasks
            PropertyAnimation {
                target: wrapper
                property: (icList.orientation == Qt.Vertical) ? "tempScaleHeight" : "tempScaleWidth"
                to: 0
                duration: showWindowAnimation.speed
                easing.type: Easing.InQuad
            }

            PropertyAction { target: mainItemContainer; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: icList; property: "delayingRemoval"; value: false }
        }

    }// main Item
}
