# remote_mouse_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

for build in mac
pip install pyinstaller pyqt5 pynput
rm -rf build dist mouse_server.spec    
pyinstaller --windowed --onefile --icon=remote.png --name "Remote Mouse Server" mouse_server.py

for build in windows
convert your remote.png into an .ico file.
pip install pyqt5 pynput pyinstaller
pyinstaller --windowed --onefile --icon=remote.ico --name "Remote Mouse Server" mouse_server.py
