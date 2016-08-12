import QtQuick 2.0

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

    VisualDataModel {
        id: windowsLocalModel
        model: icList.model
        rootIndex: tasksModel.makeModelIndex(index)
        delegate: Item{}

        onCountChanged:{
            windowsContainer.updateCounter();
        }
    }

    Component.onCompleted: {
        updateCounter();
    }

    function updateCounter(){
    //    console.log("--------- "+ index+" -------");
        if(index>=0){
            if(IsGroupParent){
         //       console.log("group");
                var tempC = windowsLocalModel.count;

                if (tempC == 0){
                    if(isLauncher){
             //           console.log("launcher");
                        windowsCount = 0;
                    }
                    else if(isWindow || isStartup){
             //           console.log("win, start");
                        windowsCount = 1;
                    }
                }
                else{
                    windowsCount = tempC;
                }
            }
            else{
                if(isLauncher){
              //      console.log("launcher");
                    windowsCount = 0;
                }
                else if(isWindow || isStartup){
             //       console.log("win, start");
                    windowsCount = 1;
                }
            }

    //        console.log(index+" - "+windowsCount);
        }
    }

}
