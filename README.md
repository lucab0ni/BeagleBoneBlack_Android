BeagleBone Black with Android
=======================

####This repository contains the installer script file for installing the latest version of Android on the new BeagleBone Black board with touchscreen support.
=======================

The following scripts are tested on Ubuntu 13.04 64-bit Desktop version.

###Start reading
[Initializing a Build Environment](http://source.android.com/source/initializing.html)

###Getting started
```
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get safe-upgrade
sudo apt-get install git
git clone https://github.com/lucab0ni/BeagleBoneBlack_Android
cd BeagleBoneBlack_Android
./setup_buildenv.sh
./Install.sh
```




