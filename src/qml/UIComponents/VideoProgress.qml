import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import Qt.labs.settings 1.0
import Qt.labs.platform 1.0 as LabsPlatform
import player 1.0

Slider {
    id: progressBar
    objectName: "progressBar"
    property string currentMediaURL: ""
    property bool playing: false
    property bool center: false
    to: 1
    value: 0.0

    Rectangle {
        id: timestampBox
        visible: false
        width: hoverProgressLabel.width
        height: hoverProgressLabel.height
        z: 100
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "mainBackground")
        Text {
            id: hoverProgressLabel
            text: "0:00"
            color: "white"
            font.family: appearance.fontName
            font.pixelSize: mainWindow.virtualHeight / 50
            horizontalAlignment: Text.AlignHCenter
            renderType: Text.NativeRendering
        }
    }

    Connections {
        target: player
        onPlayStatusChanged: function (status) {
            if (status == Enums.PlayStatus.Playing) {
                progressBar.playing = true
            } else if (status == status == Enums.PlayStatus.Paused) {
                progressBar.playing = false
            }
        }
        onPositionChanged: function (position) {
            if (!pressed) {
                progressBar.value = position
            }
        }
        onDurationChanged: function (duration) {
            progressBar.to = duration
        }
        onCachedDurationChanged: function (duration) {
            cachedLength.duration = duration
        }
    }
    onMoved: {
        player.playerCommand(Enums.Commands.SeekAbsolute, value)
    }

    function getProgressBarHeight(nyan, isMouse) {
        var x = fun.nyanCat ? mainWindow.virtualHeight / 64 : mainWindow.virtualHeight / 380
        if (appearance.themeName == "Niconico" && !fun.nyanCat) {
            return x * 2
        } else if (isMouse & !fun.nyanCat) {
            return x * 2
        } else {
            return x
        }
    }
    function getHandleVisibility(themeName, isMouse) {
        if (fun.nyanCat) {
            return true
        }

        if (appearance.themeName == "Niconico" && isMouse) {
            return true
        } else if (appearance.themeName == "Niconico") {
            return false
        } else {
            return true
        }
    }
    MouseArea {
        id: mouseAreaProgressBar
        width: progressBar.width
        height: parent.height
        anchors.fill: parent

        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: 100
        property string currentTime: ""

        onEntered: timestampBox.visible = true
        onExited: timestampBox.visible = false

        onPositionChanged: {
            var a = (progressBar.to / progressBar.availableWidth)
                    * (mouseAreaProgressBar.mapToItem(
                           progressBar, mouseAreaProgressBar.mouseX, 0).x - 2)
            hoverProgressLabel.text = utils.createTimestamp(a)
            timestampBox.x = mouseAreaProgressBar.mouseX - (timestampBox.width / 2)
            timestampBox.y = progressBackground.y - timestampBox.height * 2
        }
    }

    background: Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: progressBar.center ? (progressBar.height / 2) - (height / 2) : 0
        id: progressBackground
        z: 30
        width: progressBar.availableWidth
        height: progressBar.getProgressBarHeight(
                    fun.nyanCat, mouseAreaProgressBar.containsMouse)
        color: getAppearanceValueForTheme(appearance.themeName,
                                          "progressBackgroundColor")

        ProgressBar {
            id: cachedLength
            background: Item {}
            contentItem: Item {
                Rectangle {
                    width: cachedLength.visualPosition * parent.width
                    height: parent.height
                    color: getAppearanceValueForTheme(appearance.themeName,
                                                      "progressCachedColor")
                }
            }
            z: 40
            to: progressBar.to
            property int duration
            value: progressBar.value + duration
            anchors.fill: parent
        }

        Item {
            anchors.fill: parent
            id: chapterMarkers
            Connections {
                target: player
                onChaptersChanged: function (chapters) {
                    for (var i = 0, len = chapters.length; i < len; i++) {
                        var component = Qt.createComponent("ChapterMarker.qml")
                        var marker = component.createObject(chapterMarkers, {
                                                                "time": chapters[i]["time"]
                                                            })
                    }
                }
            }
        }

        Rectangle {
            id: progressLength
            z: 50
            anchors.left: progressBackground.left
            width: progressBar.visualPosition * parent.width
            height: parent.height
            color: getAppearanceValueForTheme(appearance.themeName,
                                              "progressSliderColor")
            Image {
                visible: fun.nyanCat
                id: rainbow
                anchors.fill: parent
                height: parent.height
                width: parent.width
                source: "qrc:/icons/rainbow.png"
                fillMode: Image.TileHorizontally
            }
        }
    }

    handle: Rectangle {
        z: 70
        id: handleRect
        x: progressBar.visualPosition * (progressBar.availableWidth - width)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: progressBar.center ? (progressBar.height / 2)
                                                   - (height / 2) : -height / 4
        implicitHeight: radius
        implicitWidth: radius
        radius: mainWindow.virtualHeight / 59
        color: appearance.themeName
               == "RoosterTeeth" ? "white" : fun.nyanCat ? "transparent" : getAppearanceValueForTheme(
                                                               appearance.themeName,
                                                               "progressSliderColor")
        visible: getHandleVisibility(appearance.themeName,
                                     mouseAreaProgressBar.containsMouse)
        AnimatedImage {
            z: 80
            visible: fun.nyanCat
            paused: progressBar.pressed
            height: mainWindow.virtualHeight / 28
            id: nyanimation
            anchors.centerIn: parent
            source: "qrc:/icons/nyancat.gif"
            fillMode: Image.PreserveAspectFit
        }
    }
}
