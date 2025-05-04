/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.components as PC3
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PlasmaExtras

EmptyPage {
    id: root

    // kickoff is Kickoff.qml
    leftPadding: -kickoff.backgroundMetrics.leftPadding
    rightPadding: -kickoff.backgroundMetrics.rightPadding
    topPadding: 0
    bottomPadding: -kickoff.backgroundMetrics.bottomPadding
    readonly property var appletInterface: kickoff

    Layout.minimumWidth: kickoff.defaultWidth
    Layout.minimumHeight: kickoff.defaultHeight
    Layout.preferredWidth: Math.max(kickoff.defaultWidth, width)
    Layout.preferredHeight: Math.max(kickoff.defaultHeight, height)

    property bool blockingHoverFocus: false

    /* NOTE: Important things to know about keyboard input handling:
     *
     * - Key events are passed up to parent items until the end is reached.
     * Be mindful of this when using `Keys.forwardTo`.
     *
     * - Keys defaults to BeforeItem while KeyNavigation defaults to AfterItem.
     *
     * - When Keys and KeyNavigation are using the same priority, it seems like
     * the one declared first in the QML file gets priority over the other.
     *
     * - Except for Keys.onPressed, all Keys.on*Pressed signals automatically
     * set `event.accepted = true`.
     *
     * - If you do `item.forceActiveFocus()` and `item` is a focus scope, the
     * children of `item` won't necessarily get focus. It seems like
     * `forceActiveFocus()` is better for forcing a specific thing to be focused
     * while KeyNavigation is better at passing focus down to children of the
     * thing you want to focus when dealing with focus scopes.
     *
     * - KeyNavigation uses BacktabFocusReason (TabFocusReason if mirrored) for left,
     * TabFocusReason (BacktabFocusReason if mirrored) for right,
     * BacktabFocusReason for up and TabFocusReason for down.
     *
     * - KeyNavigation does not seem to respect dynamic changes to focus chain
     * rules in the reverse direction, which can lead to confusing results.
     * It is therefore safer to use Keys for items whose position in the Tab
     * order must be changed on demand. (Tested with Qt 5.15.8 on X11.)
     */

    header: Header {
        id: header
        preferredNameAndIconWidth: kickoff.sideBarWidth
        Binding {
            target: kickoff
            property: "header"
            value: header
            restoreMode: Binding.RestoreBinding
        }
    }

    footer: Footer {
        id: footer
        Binding {
            target: kickoff
            property: "footer"
            value: footer
            restoreMode: Binding.RestoreBinding
        }
        // Eat down events to prevent them from reaching the contentArea or searchField
        Keys.onDownPressed: event => {}
    }


    contentItem: VerticalStackView {
        id: contentItemStackView
        Binding {
            target: kickoff
            property: "stackView"
            value: contentItemStackView
            restoreMode: Binding.RestoreBinding
        }
        focus: true
        movementTransitionsEnabled: false
        // Not using a component to prevent it from being destroyed
        // initialItem: QQC2.ScrollView { //FIXME: DnD not working in ScrollView
        initialItem: EmptyPage {
            id: scrollView
            anchors.fill: parent

            ColumnLayout {
                id: mainContentView
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: Kirigami.Units.largeSpacing
                width: scrollView.availableWidth - Kirigami.Units.largeSpacing * 2

                RowLayout {
                    id: favoritesHeader
                    visible: Plasmoid.configuration.showFavoritesSection

                    Text {
                        Layout.fillWidth: true
                        text: i18n("Favorites")
                        font.bold: true
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        flat: true
                        text: i18n("All Apps >")
                        onClicked: {
                            contentItemStackView.push(allAppsComponent)
                        }
                    }
                }

                DropAreaGridView {
                    id: favoriteAppsGridView
                    visible: Plasmoid.configuration.showFavoritesSection
                    Layout.alignment: Qt.AlignHCenter

                    model: kickoff.rootModel.favoritesModel
                    isOnFrontPage: true
                    parentAvailableWidth: parent.width
                }

                Binding {
                    target: kickoff
                    property: "frontPageSection1"
                    value: favoriteAppsGridView.view
                    restoreMode: Binding.RestoreBinding
                }

                RowLayout {
                    id: recentAppsHeader
                    visible: Plasmoid.configuration.showRecentAppsSection

                    Text {
                        Layout.fillWidth: true
                        text: i18n("Recent Apps")
                        font.bold: true
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        flat: true
                        text: i18n("More >")
                        onClicked: {
                            contentItemStackView.push(recentAppsComponent)
                        }
                    }
                }

                KickoffGridView {
                    id: recentAppsGridView
                    visible: Plasmoid.configuration.showRecentAppsSection
                    Layout.alignment: Qt.AlignHCenter

                    model: kickoff.recentAppsModel
                    isOnFrontPage: true
                    parentAvailableWidth: parent.width
                    maximumRows: Plasmoid.configuration.recentAppsRows
                }
        
                Binding {
                    target: kickoff
                    property: "frontPageSection2"
                    value: recentAppsGridView.view
                    restoreMode: Binding.RestoreBinding
                }

                RowLayout {
                    id: frequentFilesHeader
                    visible: Plasmoid.configuration.showFrequentFilesSection

                    Text {
                        Layout.fillWidth: true
                        text: i18n("Frequently Used Files")
                        font.bold: true
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        flat: true
                        text: i18n("More >")
                        onClicked: {
                            contentItemStackView.push(frequentFilesComponent)
                        }
                    }
                }

                KickoffListView {
                    id: frequentFilesListView
                    visible: Plasmoid.configuration.showFrequentFilesSection
                    Layout.fillWidth: true

                    model: kickoff.frequentUsageModel
                    isOnFrontPage: true
                    showSectionHeader: false
                    maximumRows: Plasmoid.configuration.frequentFilesRows
                }

                Binding {
                    target: kickoff
                    property: "frontPageSection3"
                    value: frequentFilesListView.view
                    restoreMode: Binding.RestoreBinding
                }

                RowLayout {
                    id: recentFilesHeader
                    visible: Plasmoid.configuration.showRecentFilesSection

                    Text {
                        Layout.fillWidth: true
                        text: i18n("Recently Used Files")
                        font.bold: true
                    }

                    QQC2.Button {
                        Layout.alignment: Qt.AlignRight
                        flat: true
                        text: i18n("More >")
                        onClicked: {
                            contentItemStackView.push(recentFilesComponent)
                        }
                    }
                }        

                KickoffListView {
                    id: recentFilesListView
                    visible: Plasmoid.configuration.showRecentFilesSection
                    Layout.fillWidth: true

                    model: kickoff.recentUsageModel
                    isOnFrontPage: true
                    showSectionHeader: false
                    maximumRows: Plasmoid.configuration.recentFilesRows
                }

                Binding {
                    target: kickoff
                    property: "frontPageSection4"
                    value: recentFilesListView.view
                    restoreMode: Binding.RestoreBinding
                }

                QQC2.Control {
                    height: Kirigami.Units.largeSpacing
                }
            }
        }
        
        Component {
            id: allAppsComponent
            ApplicationsPage {
                preferredSideBarWidth: kickoff.sideBarWidth
                id: applicationsPage
                objectName: "applicationsPage"
                visible: false
            }
        }

        Component {
            id: recentAppsComponent
            KickoffListView {
                id: contentArea
                mainContentView: true
                focus: true
                objectName: "recentAppsView"
                model: kickoff.recentAppsModel
                showSectionHeader: false
            }
        }

        Component {
            id: recentFilesComponent
            KickoffListView {
                id: contentArea
                mainContentView: true
                focus: true
                objectName: "recentFilesView"
                model: kickoff.recentUsageModel
                showSectionHeader: false
            }
        }

        Component {
            id: frequentFilesComponent
            KickoffListView {
                id: contentArea
                mainContentView: true
                focus: true
                objectName: "frequentFilesView"
                model: kickoff.frequentUsageModel
                showSectionHeader: false
            }
        }

        Component {
            id: searchViewComponent
            KickoffListView {
                id: searchView
                objectName: "searchView"
                mainContentView: true
                // Forces the function be re-run every time runnerModel.count changes.
                // This is absolutely necessary to make the search view work reliably.
                model: kickoff.runnerModel.count ? kickoff.runnerModel.modelForRow(0) : null
                delegate: KickoffListDelegate {
                    width: view.availableWidth
                    isSearchResult: true
                }
                section.property: "group"
                activeFocusOnTab: true
                property var interceptedPosition: null
                Keys.onTabPressed: event => {
                    kickoff.firstHeaderItem.forceActiveFocus(Qt.TabFocusReason);
                }
                Keys.onBacktabPressed: event => {
                    kickoff.lastHeaderItem.forceActiveFocus(Qt.BacktabFocusReason);
                }
                T.StackView.onActivated: {
                    kickoff.sideBar = null
                    kickoff.contentArea = searchView
                }

                T.StackView.onDeactivated: {
                    kickoff.searchField.clear()
                }

                Connections {
                    target: blockHoverFocusHandler
                    enabled: blockHoverFocusHandler.enabled && !searchView.interceptedPosition
                    function onPointChanged() {
                        searchView.interceptedPosition = blockHoverFocusHandler.point.position
                    }
                }

                Connections {
                    target: blockHoverFocusHandler
                    enabled: blockHoverFocusHandler.enabled && searchView.interceptedPosition && root.blockingHoverFocus
                    function onPointChanged() {
                        if (blockHoverFocusHandler.point.position === searchView.interceptedPosition) {
                            return;
                        }
                        root.blockingHoverFocus = false
                    }
                }

                HoverHandler {
                    id: blockHoverFocusHandler
                    enabled: !contentItemStackView.busy && (!searchView.interceptedPosition || root.blockingHoverFocus)
                }

                Loader {
                    anchors.centerIn: searchView.view
                    width: searchView.view.width - (Kirigami.Units.gridUnit * 4)

                    active: searchView.view.count === 0
                    visible: active
                    asynchronous: true

                    sourceComponent: PlasmaExtras.PlaceholderMessage {
                        id: emptyHint

                        iconName: "edit-none"
                        opacity: 0
                        text: i18nc("@info:status", "No matches")

                        Connections {
                            target: kickoff.runnerModel
                            function onQueryFinished() {
                                showAnimation.restart()
                            }
                        }

                        NumberAnimation {
                            id: showAnimation
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.OutCubic
                            property: "opacity"
                            target: emptyHint
                            to: 1
                        }
                    }
                }
            }
        }

        Keys.priority: Keys.AfterItem
        // This is here rather than root because events are implicitly forwarded
        // to parent items. Don't want to send multiple events to searchField.
        Keys.forwardTo: kickoff.searchField

        Connections {
            target: root.header
            function onSearchTextChanged() {
                if (root.header.searchText.length === 0 && contentItemStackView.currentItem.objectName === "searchView") {
                    root.blockingHoverFocus = false
                    contentItemStackView.reverseTransitions = true
                    contentItemStackView.pop()
                    kickoff.firstSection()?.forceActiveFocus();
                } else if (root.header.searchText.length > 0) {
                    if (contentItemStackView.currentItem.objectName !== "searchView") {
                        contentItemStackView.reverseTransitions = false
                        contentItemStackView.push(searchViewComponent)
                    } else {
                        root.blockingHoverFocus = true
                        contentItemStackView.contentItem.interceptedPosition = null
                        contentItemStackView.contentItem.currentIndex = 0
                    }
                }
            }
        }

        Connections {
            target: kickoff
            function onExpandedChanged() {
                if (!kickoff.expanded) {
                    while (contentItemStackView.depth > 1) {
                        contentItemStackView.pop();
                    }
                } else {
                    kickoff.firstSection()?.forceActiveFocus();
                }
            }
        }
    }

    Component.onCompleted: {
        rootModel.refresh();
    }
}
