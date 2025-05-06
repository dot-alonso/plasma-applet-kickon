/*
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2025 Jin Liu <m.liu.jin@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

import org.kde.plasma.components as PC3
import org.kde.plasma.extras as PlasmaExtras

import org.kde.ksvg as KSvg
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels

// ScrollView makes it difficult to control implicit size using the contentItem.
// Using EmptyPage instead.
EmptyPage {
    id: root
    property alias model: view.model
    required property real parentAvailableWidth
    required property bool isAppMode
    property int maximumRows: -1

    property alias count: view.count
    property alias currentIndex: view.currentIndex
    property alias currentItem: view.currentItem
    property alias delegate: view.delegate
    property alias view: view

    clip: false

    /* Not setting GridView as the contentItem because GridView has no way to
     * set horizontal alignment. I don't want to use leftPadding/rightPadding
     * for that because I'd have to change the implicitWidth formula and use a
     * more complicated calculation to get the correct padding.
     */
    GridView {
        id: view

        readonly property int columns: Math.floor(root.parentAvailableWidth / (root.isAppMode ? kickoff.gridCellSize : kickoff.minimumFileGridWidth))
        readonly property int rows: root.maximumRows > 0 ? Math.min(root.maximumRows, Math.ceil(root.model.count / columns)) : Math.ceil(root.model.count / columns)
        // Note: This is the maximum number of items that can be displayed in the grid. We can't limit the number
        // of items in the model, because this number changes dynamically when the user resizes the applet.
        readonly property int maximumItems: columns * rows
        property bool movedWithKeyboard: false
        property bool movedWithWheel: false

        Accessible.description: i18n("Grid with %1 rows, %2 columns", rows, columns) // can't use i18np here

        implicitWidth: columns * cellWidth
        implicitHeight: rows * cellHeight

        leftMargin: 0
        rightMargin: 0
        topMargin: 0
        bottomMargin: 0

        cellHeight: root.isAppMode ? kickoff.gridCellSize : kickoff.listDelegateHeight
        cellWidth: root.isAppMode ? kickoff.gridCellSize : root.parentAvailableWidth / columns

        currentIndex: count > 0 ? 0 : -1
        interactive: false
        pixelAligned: true
        reuseItems: true
        // default keyboard navigation doesn't allow focus reasons to be used
        // and eats up/down key events when at the beginning or end of the list.
        keyNavigationEnabled: false
        keyNavigationWraps: false

        highlightMoveDuration: 0
        highlight: PlasmaExtras.Highlight {
            // The default Z value for delegates is 1. The default Z value for the section delegate is 2.
            // The highlight gets a value of 3 while the drag is active and then goes back to the default value of 0.
            z: (root.currentItem?.Drag.active ?? false) ? 3 : 0

            pressed: (view.currentItem as T.AbstractButton)?.down ?? false

            active: view.activeFocus
                || (kickoff.contentArea === root
                    && kickoff.searchField.activeFocus)

            width: view.cellWidth
            height: view.cellHeight
        }
        
        Component {
            id: appModeDelegate
            KickoffGridDelegate {
                visible: index < view.maximumItems
                width: view.cellWidth
                Accessible.role: Accessible.Cell
            }
        }

        Component {
            id: fileModeDelegate
            KickoffListDelegate {
                visible: index < view.maximumItems
                width: view.cellWidth
                compact: false
                Accessible.role: Accessible.Cell
            }
        }

        delegate: root.isAppMode ? appModeDelegate : fileModeDelegate

        move: normalTransition
        moveDisplaced: normalTransition

        Transition {
            id: normalTransition
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                properties: "x, y"
                easing.type: Easing.OutCubic
            }
        }

        Connections {
            target: kickoff
            function onExpandedChanged() {
                if (!kickoff.expanded) {
                    view.currentIndex = 0
                }
            }
        }

        // Used to block hover events temporarily after using keyboard navigation.
        // If you have one hand on the touch pad or mouse and another hand on the keyboard,
        // it's easy to accidentally reset the highlight/focus position to the mouse position.
        Timer {
            id: movedWithKeyboardTimer
            interval: 200
            onTriggered: view.movedWithKeyboard = false
        }

        Timer {
            id: movedWithWheelTimer
            interval: 200
            onTriggered: view.movedWithWheel = false
        }

        function focusCurrentItem(event, focusReason) {
            currentItem.forceActiveFocus(focusReason)
            event.accepted = true
        }

        function focusFirstItem() {
            forceActiveFocus(Qt.TabFocusReason)
            if (count > 0) {
                currentIndex = 0
            }
        }

        function focusLastItem() {
            forceActiveFocus(Qt.BacktabFocusReason)
            if (count > 0) {
                currentIndex = (rows - 1) * columns
            }
        }

        Keys.onMenuPressed: event => {
            const delegate = currentItem as AbstractKickoffItemDelegate;
            if (delegate !== null) {
                delegate.forceActiveFocus(Qt.ShortcutFocusReason)
                delegate.openActionMenu()
            }
        }

        Keys.onPressed: event => {
            const visibleCount = Math.min(count, maximumItems)
            const targetX = currentItem ? currentItem.x : contentX
            let targetY = currentItem ? currentItem.y : contentY
            let targetIndex = currentIndex
            // supports mirroring
            const atLeft = currentIndex % columns === (Qt.application.layoutDirection == Qt.RightToLeft ? columns - 1 : 0)
            // at the beginning of a line
            const isLeading = currentIndex % columns === 0
            // at the top of a given column and in the top row
            const atTop = currentIndex < columns
            // supports mirroring
            const atRight = currentIndex % columns === (Qt.application.layoutDirection == Qt.RightToLeft ? 0 : columns - 1)
            // at the end of a line
            const isTrailing = currentIndex % columns === columns - 1
            // at bottom of a given column, not necessarily in the last row
            let atBottom = currentIndex >= visibleCount - columns
            // Implements the keyboard navigation described in https://www.w3.org/TR/wai-aria-practices-1.2/#grid
            if (visibleCount > 0) {
                switch (event.key) {
                    case Qt.Key_Left: if (!atLeft && !kickoff.searchField.activeFocus) {
                        moveCurrentIndexLeft()
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_H: if (!atLeft && !kickoff.searchField.activeFocus && event.modifiers & Qt.ControlModifier) {
                        moveCurrentIndexLeft()
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_Up: if (!atTop) {
                        moveCurrentIndexUp()
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } else {
                        const previousSection = kickoff.previousSection(view)
                        if (previousSection !== null) {
                            previousSection.focusLastItem()
                        }
                    } break
                    case Qt.Key_K: if (!atTop && event.modifiers & Qt.ControlModifier) {
                        moveCurrentIndexUp()
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_Right: if (!atRight && !kickoff.searchField.activeFocus) {
                        moveCurrentIndexRight()
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_L: if (!atRight && !kickoff.searchField.activeFocus && event.modifiers & Qt.ControlModifier) {
                        moveCurrentIndexRight()
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_Down: if (!atBottom) {
                        moveCurrentIndexDown()
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } else {
                        const nextSection = kickoff.nextSection(view)
                        if (nextSection !== null) {
                            nextSection.focusFirstItem()
                        }
                    } break
                    case Qt.Key_J: if (!atBottom && event.modifiers & Qt.ControlModifier) {
                        moveCurrentIndexDown()
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_Home: if (event.modifiers === Qt.ControlModifier && currentIndex !== 0) {
                        currentIndex = 0
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } else if (!isLeading) {
                        targetIndex -= currentIndex % columns
                        currentIndex = Math.max(targetIndex, 0)
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_End: if (event.modifiers === Qt.ControlModifier && currentIndex !== visibleCount - 1) {
                        currentIndex = visibleCount - 1
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } else if (!isTrailing) {
                        targetIndex += columns - 1 - (currentIndex % columns)
                        currentIndex = Math.min(targetIndex, visibleCount - 1)
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_PageUp: if (!atTop) {
                        targetY = targetY - height + 1
                        targetIndex = indexAt(targetX, targetY)
                        // TODO: Find a more efficient, but accurate way to do this
                        while (targetIndex === -1) {
                            targetY += 1
                            targetIndex = indexAt(targetX, targetY)
                        }
                        currentIndex = Math.max(targetIndex, 0)
                        focusCurrentItem(event, Qt.BacktabFocusReason)
                    } break
                    case Qt.Key_PageDown: if (!atBottom) {
                        targetY = targetY + height - 1
                        targetIndex = indexAt(targetX, targetY)
                        // TODO: Find a more efficient, but accurate way to do this
                        while (targetIndex === -1) {
                            targetY -= 1
                            targetIndex = indexAt(targetX, targetY)
                        }
                        currentIndex = Math.min(targetIndex, visibleCount - 1)
                        focusCurrentItem(event, Qt.TabFocusReason)
                    } break
                    case Qt.Key_Return:
                        /* Fall through*/
                    case Qt.Key_Enter:
                        root.currentItem.action.triggered();
                        root.currentItem.forceActiveFocus(Qt.ShortcutFocusReason);
                        event.accepted = true;
                        break;
                }
            }
            movedWithKeyboard = event.accepted
            if (movedWithKeyboard) {
                movedWithKeyboardTimer.restart()
            }
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                kickoff.clearSelectionExcept(view)
            }
        }
    }
}
