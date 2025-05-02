/*
 *    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 *    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.coreaddons as KCoreAddons

PlasmaExtras.PlasmoidHeading {
    id: root

    property real preferredTabBarWidth: 0
    readonly property alias leaveButtons: leaveButtons

    contentWidth: tabBar.implicitWidth + spacing
    contentHeight: leaveButtons.implicitHeight

    // We use an increased vertical padding to improve touch usability
    leftPadding: kickoff.backgroundMetrics.leftPadding
    rightPadding: kickoff.backgroundMetrics.rightPadding
    topPadding: Kirigami.Units.smallSpacing * 2
    bottomPadding: Kirigami.Units.smallSpacing * 2

    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    spacing: kickoff.backgroundMetrics.spacing
    position: PC3.ToolBar.Footer

    KCoreAddons.KUser {
        id: kuser
    }

    RowLayout {
        id: nameAndIcon
        spacing: root.spacing
        anchors.left: parent.left
        LayoutMirroring.enabled: kickoff.sideBarOnRight
        height: parent.height
        width: root.preferredNameAndIconWidth - layoutContainer.anchors.leftMargin

        KirigamiComponents.AvatarButton {
            id: avatar
            visible: KConfig.KAuthorized.authorizeControlModule("kcm_users")

            Layout.fillHeight: true
            Layout.minimumWidth: height
            Layout.maximumWidth: height

            text: i18n("Open user settings")
            name: kuser.fullName

            // The icon property emits two signals in a row during which it
            // changes to an empty URL and probably back to the same
            // static file path, so we need QtQuick.Image not to cache it.
            cache: false
            source: kuser.faceIconUrl

            Keys.onTabPressed: event => {
                tabSetFocus(event, kickoff.firstCentralPane);
            }
            Keys.onBacktabPressed: event => {
                tabSetFocus(event, nextItemInFocusChain());
            }
            Keys.onLeftPressed: event => {
                if (kickoff.sideBarOnRight) {
                    searchField.forceActiveFocus(Qt.application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                }
            }
            Keys.onRightPressed: event => {
                if (!kickoff.sideBarOnRight) {
                    searchField.forceActiveFocus(Qt.application.layoutDirection == Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                }
            }
            Keys.onDownPressed: event => {
                if (kickoff.sideBar) {
                    kickoff.sideBar.forceActiveFocus(Qt.TabFocusReason)
                } else {
                    kickoff.contentArea.forceActiveFocus(Qt.TabFocusReason)
                }
            }

            onClicked: KCM.KCMLauncher.openSystemSettings("kcm_users")
        }

        MouseArea {
            id: nameAndInfoMouseArea
            hoverEnabled: true

            Layout.fillHeight: true
            Layout.fillWidth: true

            Kirigami.Heading {
                id: nameLabel
                anchors.fill: parent
                opacity: parent.containsMouse ? 0 : 1
                color: Kirigami.Theme.textColor
                level: 4
                text: kuser.fullName
                textFormat: Text.PlainText
                elide: Text.ElideRight
                horizontalAlignment: kickoff.paneSwap ? Text.AlignRight : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Kirigami.Heading {
                id: infoLabel
                anchors.fill: parent
                level: 5
                opacity: parent.containsMouse ? 1 : 0
                color: Kirigami.Theme.textColor
                text: kuser.os !== "" ? `${kuser.loginName}@${kuser.host} (${kuser.os})` : `${kuser.loginName}@${kuser.host}`
                textFormat: Text.PlainText
                elide: Text.ElideRight
                horizontalAlignment: kickoff.paneSwap ? Text.AlignRight : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter

                Behavior on opacity {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            PC3.ToolTip.text: infoLabel.text
            PC3.ToolTip.delay: Kirigami.Units.toolTipDelay
            PC3.ToolTip.visible: infoLabel.truncated && containsMouse
        }
    }

    LeaveButtons {
        id: leaveButtons

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        // available width for leaveButtons
        maximumWidth: root.availableWidth - tabBar.width - root.spacing

        Keys.onUpPressed: event => {
            kickoff.lastCentralPane.forceActiveFocus(Qt.BacktabFocusReason);
        }
    }

    Behavior on height {
        enabled: kickoff.expanded
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }
    }

    // Using item containing WheelHandler instead of MouseArea because
    // MouseArea doesn't keep track to the total amount of rotation.
    // Keeping track of the total amount of rotation makes it work
    // better for touch pads.
    Item {
        id: mouseItem
        parent: root
        anchors.left: parent.left
        height: root.height
        width: tabBar.width
        z: 1 // Has to be above contentItem to receive mouse wheel events
        WheelHandler {
            id: tabScrollHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: {
                const shouldDec = rotation >= 15
                const shouldInc = rotation <= -15
                const shouldReset = (rotation > 0 && tabBar.currentIndex === 0) || (rotation < 0 && tabBar.currentIndex === tabBar.count - 1)
                if (shouldDec) {
                    tabBar.decrementCurrentIndex();
                    rotation = 0
                } else if (shouldInc) {
                    tabBar.incrementCurrentIndex();
                    rotation = 0
                } else if (shouldReset) {
                    rotation = 0
                }
            }
        }
    }

    Shortcut {
        sequences: ["Ctrl+Tab", "Ctrl+Shift+Tab", StandardKey.NextChild, StandardKey.PreviousChild]
        onActivated: {
            tabBar.currentIndex = (tabBar.currentIndex === 0) ? 1 : 0;
        }
    }
}
