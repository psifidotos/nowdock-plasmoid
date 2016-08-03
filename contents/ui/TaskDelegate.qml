import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Component {
    id: iconDelegate
    MouseArea{
        id: wrapper
        anchors.bottom: (panel.position === PlasmaCore.Types.BottomPositioned) ? parent.bottom : undefined
        anchors.top: (panel.position === PlasmaCore.Types.TopPositioned) ? parent.top : undefined
        anchors.left: (panel.position === PlasmaCore.Types.LeftPositioned) ? parent.left : undefined
        anchors.right: (panel.position === PlasmaCore.Types.RightPositioned) ? parent.right : undefined

        ///Dont use Math.floor it adds one pixel in animations and creates glitches
        width: (icList.orientation === Qt.Vertical ) ? (panel.iconSize+iconMargin)*scale+addedSpace :
                                                       (panel.iconSize+iconMargin)*scale
        height: (icList.orientation === Qt.Vertical ) ? (panel.iconSize+iconMargin)*scale :
                                                        (panel.iconSize+iconMargin)*scale + addedSpace

        acceptedButtons: Qt.LeftButton | Qt.MidButton | Qt.RightButton

        property QtObject contextMenu: null

        property int addedSpace: 12

        readonly property var m: model
        property int itemIndex: index

        property bool pressed: false
        property int iconMargin: panel.iconMargin

        property real scale: 1;

        property real appearScale: 1;

        property int curIndex: icList.hoveredIndex
        property int center: Math.floor(width / 2)

        ///Dont use Math.floor it adds one pixel in animations and creates glitches
        property int regulatorSize: (panel.iconSize + panel.iconMargin) * wrapper.scale * wrapper.appearScale - 2;

        Behavior on scale {
            NumberAnimation { duration: 80 }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: panel; property: "inAnimation"; value: true }
            PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
            ParallelAnimation{
                //    NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
                NumberAnimation { target: wrapper; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
            }
            PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
            PropertyAction { target: panel; property: "inAnimation"; value: false }
        }

        Flow{
            visible: (panel.position === PlasmaCore.Types.TopPositioned) ? false : true
            width: parent.width
            height: parent.height

            flow: Flow.LeftToRight
            layoutDirection: (panel.position === PlasmaCore.Types.LeftPositioned) ? Qt.RightToLeft : Qt.LeftToRight

            TaskIconItem{}
            TaskActiveItem{}
            TaskGroupItem{}
        }//Flow

        //Flow which is used only when the listview is on Top and we are hiding the main one
        Flow{
            visible: (panel.position === PlasmaCore.Types.TopPositioned) ? true : false
            width: parent.width
            height: parent.height

            flow: Flow.LeftToRight
            layoutDirection: (panel.position === PlasmaCore.Types.LeftPositioned) ? Qt.RightToLeft : Qt.LeftToRight

            TaskGroupItem{}
            TaskActiveItem{}
            TaskIconItem{}
        } //Flow Element

        hoverEnabled: true


        ////IMPORTANT: This shouldnt been calculated so many times for every task even those
        ////that arent going to alter their scale, plus could be calculated with differences
        ////instead of every step even 1px to calculate every 3 or 4
        ////maybe a new algorithm is needed ... one that reduces flickering
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
                if(index < icList.contentItem.children.length - 1){
                    icList.updateScale(index+1, rightScale);
                }

                if(index > 0){
                    icList.updateScale(index-1,leftScale);
                }


                //testing shadowboxes
              //  if(index === 0 ){
                //    scale =panel.zoomFactor+(leftScale-1);
               // }
               // else
                    scale = panel.zoomFactor;

                //debugging code
             /*   if (index >=1 ){
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
            checkListHovered.start();
        }

        onPositionChanged: {
            var animationStep = 3;

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

        onPressed: {
            if ((mouse.button == Qt.LeftButton)||(mouse.button == Qt.MidButton)) {
                pressed = true;
            }
            else if (mouse.button == Qt.RightButton){
                contextMenu = panel.contextMenuComponent.createObject(wrapper);
                contextMenu.visualParent = wrapper;
                contextMenu.show();
            }
        }

        onReleased: {
            if(pressed){
                if (mouse.button == Qt.MidButton){
                    tasksModel.requestNewInstance(modelIndex());
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

            pressed = false;
        }

        function modelIndex(){
            return tasksModel.makeModelIndex(index);
        }


        function signalUpdateScale(nIndex, nScale){
            if( index === nIndex){
                scale = nScale;
            }
        }

        Component.onCompleted: {
            icList.updateScale.connect(signalUpdateScale);
        }
    }
}
