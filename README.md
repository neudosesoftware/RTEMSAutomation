# RTEMSAutomation

Download the zip file, unzip all files to the home directory.

Use the following commands to run the script:

$ chmod 755 rtems.sh

$ sudo ./rtems.sh

After it stops running: 
1. Unlock the directories using the following command:

    $ sudo chown -R $USER: $HOME

2. Modify the PATH variable in .profile:

    $ cd

    $ vim .profile

Press 'i' on keyboard to enable the user to insert text.

Using arrow keys, navigate to the $PATH variable and add
$HOME/development/u-boot/dtc:$HOME/development/rtems/compiler/4.12/bin: to the path. ADD it don't REPLACE it! (colon is used to separate each path)

Press ESC to leave insert mode.

To save and quit, type ':wq'

Log out then log back in.
