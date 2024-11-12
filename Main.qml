import QtQuick 2.15
import SddmComponents 2.0
import QtMultimediaQuick 6.0 // Updated for Qt6 multimedia
import "components"

Rectangle {
    id: container

    LayoutMirroring.enabled: Qt.locale().textDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants {
        id: textConstants
    }

    Connections {
        target: sddm
        function onLoginSucceeded() {
        }

        function onLoginFailed() {
            error_message.color = config.errorMsgFontColor
            error_message.text = textConstants.loginFailed
        }
    }

    FontLoader {
        id: textFont; name: config.displayFont
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    // Set Background Image
    Image {
        id: image1
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
    }

    // Set Animated GIF Background Image
    AnimatedImage {
        id: animatedGIF1
        anchors.fill: parent
        fillMode: AnimatedImage.PreserveAspectCrop
    }

    // Set Background Video1
    MediaPlayer {
        id: mediaplayer1
        autoPlay: true; muted: true
        playlist: Playlist {
            id: playlist1
            playbackMode: Playlist.Random
            onLoaded: { mediaplayer1.play() }
        }
    }

    VideoOutput {
        id: video1
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent; source: mediaplayer1
        MouseArea {
            id: mouseArea1
            anchors.fill: parent;
            onPressed: {
                fader1.state = fader1.state === "off" ? "on" : "off" ;
                if (config.autofocusInput === "true") {
                    if (username_input_box.text === "")
                        username_input_box.focus = true
                    else
                        password_input_box.focus = true
                }
            }
        }
        Keys.onPressed: {
            fader1.state = "on";
            if (username_input_box.text === "")
                username_input_box.focus = true
            else
                password_input_box.focus = true
        }
    }

    WallpaperFader {
        id: fader1
        visible: true
        anchors.fill: parent
        state: "off"
        source: video1
        mainStack: login_container
        footer: login_container
    }

    // Set Background Video2
    MediaPlayer {
        id: mediaplayer2
        autoPlay: true; muted: true
        playlist: Playlist {
            id: playlist2; playbackMode: Playlist.Random
        }
    }

    VideoOutput {
        id: video2
        fillMode: VideoOutput.PreserveAspectCrop
        anchors.fill: parent; source: mediaplayer2
        opacity: 0
        MouseArea {
            id: mouseArea2
            enabled: false
            anchors.fill: parent;
            onPressed: {
                fader1.state = fader1.state === "off" ? "on" : "off" ;
                if (config.autofocusInput === "true") {
                    if (username_input_box.text === "")
                        username_input_box.focus = true
                    else
                        password_input_box.focus = true
                }
            }
        }
        Behavior on opacity {
            enabled: true
            NumberAnimation { easing.type: Easing.InOutQuad; duration: 3000 }
        }
        Keys.onPressed: {
            fader2.state = "on";
            if (username_input_box.text === "")
                username_input_box.focus = true
            else
                password_input_box.focus = true
        }
    }

    WallpaperFader {
        id: fader2
        visible: true
        anchors.fill: parent
        state: "off"
        source: video2
        mainStack: login_container
        footer: login_container
    }

    property MediaPlayer currentPlayer: mediaplayer1

    Timer {
        interval: 1000;
        running: true; repeat: true
        onTriggered: {
            if (currentPlayer.duration !== -1 && currentPlayer.position > currentPlayer.duration - 10000) {
                if (video2.opacity === 0) {
                    mediaplayer2.play()
                } else {
                    mediaplayer1.play()
                }
            }
            if (currentPlayer.duration !== -1 && currentPlayer.position > currentPlayer.duration - 3000) {
                if (video2.opacity === 0) {
                    mouseArea1.enabled = false
                    currentPlayer = mediaplayer2
                    video2.opacity = 1
                    triggerTimer.start()
                    mouseArea2.enabled = true
                } else {
                    mouseArea2.enabled = false
                    currentPlayer = mediaplayer1
                    video2.opacity = 0
                    triggerTimer.start()
                    mouseArea1.enabled = true
                }
            }
        }
    }

    Timer {
        id: triggerTimer
        interval: 4000; running: false; repeat: false
        onTriggered: {
            if (video2.opacity === 1)
                mediaplayer1.stop()
            else
                mediaplayer2.stop()
        }
    }

    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: "transparent"

        Column {
            id: clock
            property date dateTime: new Date()
            property color color: config.clockFontColor
            y: parent.height * config.relativePositionY - clock.height / 2
            x: parent.width * config.relativePositionX - clock.width / 2

            Timer {
                interval: 100; running: true; repeat: true;
                onTriggered: clock.dateTime = new Date()
            }

            Text {
                id: time
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text: Qt.formatTime(clock.dateTime, config.timeFormat || "hh:mm")
                font.pointSize: config.clockFontSize
                font.family: textFont.name
                font.bold: true
            }

            Text {
                id: date
                anchors.horizontalCenter: parent.horizontalCenter
                color: clock.color
                text: Qt.formatDate(clock.dateTime, config.dateFormat || "dddd, dd MMMM yyyy")
                font.family: textFont.name
                font.pointSize: config.dateFontSize
                font.bold: true
            }
        }

        Rectangle {
            id: login_container
            y: clock.y + clock.height + 30
            width: clock.width
            height: parent.height * 0.08
            color: "transparent"
            anchors.left: clock.left

            Rectangle {
                id: username_row
                height: parent.height * 0.36
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                transformOrigin: Item.Center
                anchors.margins: 10

                Text {
                    id: username_label
                    width: parent.width * 0.27
                    height: parent.height * 0.66
                    horizontalAlignment: Text.AlignLeft
                    font.family: textFont.name
                    font.bold: true
                    font.pixelSize: config.labelFontSize
                    color: config.labelFontColor
                    text: "Username"
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextBox {
                    id: username_input_box
                    height: parent.height
                    text: userModel.lastUser
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: username_label.right
                    anchors.leftMargin: config.usernameLeftMargin
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    font: textFont.name
                    color: "#25000000"
                    borderColor: "transparent"
                    focus: true
                }
            }
        }
    }
}
