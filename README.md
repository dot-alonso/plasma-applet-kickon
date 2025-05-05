# Kickon: An alternative design of KDE Plasma's Application Launcher (Kickoff)

## Features

### Move "All Applications" and categories to the second page, leaving all space of the front page for Favorites and other optional sections.
![Front page](https://github.com/user-attachments/assets/3174850f-b372-4801-90e7-533d7faca841)
![Second page](https://github.com/user-attachments/assets/b82340b5-6994-4e35-9d68-2e306e794e77)

### Optional "Recent Apps", "Frequent Files" and "Recent Files" sections, each can be turn on/off and specify number of rows.
![Screenshot_20250505_195053](https://github.com/user-attachments/assets/31fe1c17-6aaa-4b90-8ed3-e2ec53e19d53)
![Screenshot_20250505_194415](https://github.com/user-attachments/assets/ed89039f-7947-48cb-9529-b3dfb12c8acf)

### Icon size customizable.
![Screenshot_20250505_194443](https://github.com/user-attachments/assets/136ecf58-3e79-496d-80c8-eda63f0117d0)
![Screenshot_20250505_194841](https://github.com/user-attachments/assets/a50071d4-9a04-4801-b11c-b8c8e2bd7648)
![Screenshot_20250505_194909](https://github.com/user-attachments/assets/104a7124-5636-4328-a188-d4eb019eb740)

### A new option "None" for "Show power buttons".
![Screenshot_20250505_194459](https://github.com/user-attachments/assets/15ca7fec-ef19-4a18-962a-7d7be47d27f4)
![Screenshot_20250505_194530](https://github.com/user-attachments/assets/3e1f7848-027f-4b18-a94e-1385b3ed193e)

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
