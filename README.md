# Kickon: An alternative design of KDE Plasma's Application Launcher (Kickoff)

## Features

### Move "All Applications" and categories to the second page, leaving all space of the front page for Favorites and other optional sections.
### Optional "Recent Apps", "Frequent Files" and "Recent Files" sections, each can be turn on/off and specify number of rows.
### Icon size customizable.
### A new option "None" for "Show power buttons".

## Known Problems

* Scrolling doesn't work in the front page (conflicts with Drag&Drop).
* Keyboard navigation only partially works.

## Installation

```bash
git clone https://github.com/jinliu/plasma-applet-kickon.git
cd plasma-applet-kickon/src/package
kpackagetool6 -t Plasma/Applet --install .
```

Please report bugs to [Github](https://github.com/jinliu/plasma-applet-kickon/issues)
