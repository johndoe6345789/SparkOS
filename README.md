# SparkOS
A single binary on top of Linux / Wayland that manages the OS, C++ CLI and Qt6/QML Full screen GUI. Android like design but more desktop orientated. A distribution that can be dd'ed to a USB flash drive. Root elevation powered by sudo. This project will need to set up a barebones distro (doesn't really need to be based on another, to keep things clean)

This OS is not designed to use any of the other window managers.

Example:

$ spark gui

$ spark install package mypackage

$ spark remove package mypackage

$ spark run mypackage

