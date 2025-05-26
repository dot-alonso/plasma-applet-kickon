# Translation

1. Translate in the "<your language>.ko" file.
2. Install `gettext`.
3. Run `./build.sh` to compile the translations.
4. `cd ..; kpackagetool6 -t Plasma/Applet --upgrade .; systemctl --user restart plasma-plasmashell.service` to test the translations.