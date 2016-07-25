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

        width: (icList.orientation === Qt.Vertical ) ? Math.floor((panel.iconSize+iconMargin)*scale+addedSpace) :
                                                       Math.floor((panel.iconSize+iconMargin)*scale)
        height: (icList.orientation === Qt.Vertical ) ? Math.floor( (panel.iconSize+iconMargin)*scale ) :
                                                        Math.floor((panel.iconSize+iconMargin)*scale + addedSpace)

        acceptedButtons: Qt.LeftButton | Qt.MidButton | Qt.RightButton

        property QtObject contextMenu: null

        property int addedSpace: 12

        readonly property var m: model
        property int itemIndex: index

        property bool pressed: false
        property int iconMargin: panel.iconMargin

        property real scale: 1;
        property real appearScale: 1;

        property int curSpot: icList.currentSpot
        property int center: Math.floor(width / 2)

        property int regulatorSize: Math.floor ( (panel.iconSize + panel.iconMargin) * wrapper.scale * wrapper.appearScale - 2 );

        Behavior on scale {
            NumberAnimation { duration: 80 }
        }

        ListView.onRemove: SequentialAnimation {
            PropertyAction { target: panel; property: "inAnimation"; value: true }
            PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
            ParallelAnimation{
                NumberAnimation { target: wrapper; property: "scale"; to: 0; duration: 350; easing.type: Easing.InOutQuad }
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
        onCurSpotChanged: {
            var distanceFromHovered = Math.abs(index - icList.hoveredIndex);

            if (distanceFromHovered <= 1){
                var absCoords = mapToItem(icList, 0, 0);
                var zone = panel.zoomFactor * 100;
                var absCenter;

                if(icList.orientation === Qt.Horizontal)
                    absCenter = absCoords.x + center;
                else
                    absCenter = absCoords.y + center;

                var rDistance = Math.abs(curSpot - absCenter);

                //  if(index===0)
                //     console.debug(rDistance);
                var newScale = Math.max(1, panel.zoomFactor - ( (rDistance) / zone));
                if(Math.abs(newScale-scale) >= 0.03)
                    scale = newScale;
            }
        }

        onEntered: {
            var pos = mapToItem(icList, mouseX, mouseY);

            if (icList.orientation == Qt.Horizontal){
                var step = Math.abs(icList.currentSpot-pos.x);
                icList.currentSpot = pos.x;
            }
            else{
                var step = Math.abs(icList.currentSpot-pos.y);
                icList.currentSpot = pos.y;
            }
        }

        // IMPORTANT: This must be improved ! even for small miliseconds  it reduces performance
        onExited: {
            checkListHovered.start();
        }

        onPositionChanged: {
            var pos = mapToItem(icList, mouse.x, mouse.y);
            var animationStep = 4;

            if (icList.orientation == Qt.Horizontal){
                var step = Math.abs(icList.currentSpot-pos.x);
                if (step >= animationStep){
                    icList.hoveredIndex = index;
                    icList.currentSpot = pos.x;
                }
            }
            else{
                var step = Math.abs(icList.currentSpot-pos.y);
                if (step >= animationStep){
                    icList.hoveredIndex = index;
                    icList.currentSpot = pos.y;
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

    }
}
