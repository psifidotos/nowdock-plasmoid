/*
 *  Copyright 2013 Michail Vourlakos <mvourlakos@gmail.org>
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
import QtQml.Models 2.2

//trying to do a very simple thing to count how many windows does
//a task instace has...
//Workaround the mess with launchers, startups, windows etc.

Item{
    id: windowsContainer
    property int windowsCount: 0

    property bool isLauncher: IsLauncher ? true : false
    property bool isStartup: IsStartup ? true : false
    property bool isWindow: IsWindow ? true : false

    onIsLauncherChanged: updateCounter();
  //  onIsStartupChanged: updateCounter();
//    onIsWindowChanged: updateCounter();

    //states that exist in windows in a Group of windows
    property bool hasMinimized: false;
    property bool hasShown: false;
    property bool hasActive: false;


    DelegateModel {
        id: windowsLocalModel
        model: icList.model
        rootIndex: tasksModel.makeModelIndex(index)
        delegate: Item{}

        onCountChanged:{
            windowsContainer.updateCounter();
        }
    }

    function initializeStates(){
        hasMinimized = false;
        hasShown = false;
        hasActive = false;

        if(IsGroupParent){
            checkInternalStates();
        }
        else{
            if(mainItemContainer.isMinimized){
                hasMinimized = true;
            }
            else if(mainItemContainer.isActive)
                hasActive = true;
            else
                hasShown = true;
        }
    }

    function checkInternalStates(){
        var childs = windowsLocalModel.items;

        for(var i=0; i<childs.count; ++i){
            var kid = childs.get(i);

            if(kid.model.IsMinimized)
                hasMinimized = true;
            else if (kid.model.IsActive)
                hasActive = true;
            else
                hasShown = true;
        }
    }

    Component.onCompleted: {
        mainItemContainer.checkWindowsStates.connect(initializeStates);
        updateCounter();
    }

    function updateCounter(){
    //    console.log("--------- "+ index+" -------");
        if(index>=0){
            if(IsGroupParent){
                var tempC = windowsLocalModel.count;

                if (tempC == 0){
                    if(isLauncher){
                        windowsCount = 0;
                    }
                    else if(isWindow || isStartup){
                        windowsCount = 1;
                    }
                }
                else{
                    windowsCount = tempC;
                }
            }
            else{
                if(isLauncher){
                    windowsCount = 0;
                }
                else if(isWindow || isStartup){
                    windowsCount = 1;
                }
            }

            initializeStates();
        }

   }

}
