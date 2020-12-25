# Author
Author: Daechir <br/>
Author URL: https://github.com/daechir <br/>
License: GNU GPL <br/>
Modified Date: 12/24/20 <br/>
Version: v1l


## Changelog
+ v1l
  * S1.sh
    + Add superlite variable to install_setup.
      * Write any value to this variable to use it.
    + Add other variable logic to install_setup.
    + Add apt-mark hold to prevent reinstallation of removed packages.
    + Deprecate cleanup_defaults.
      * See below for more info.
    + Deprecate rc.local usage.
    + Add lubuntu-control-defaults.service and lubuntu-control-defaults.sh.
      * lubuntu-control-defaults* will ensure that:
        + Misc Lubuntu customization files are removed consistently and automatically.
        + Downstream kernel modprobe.d files will be automatically removed.
          * They generally aren't very useful and get shipped continuously.
        + Kernel hardening / optimizations remain in place on each boot and across updates.
          * No more annoying /usr/lib/sysctl.d files appearing and overriding our defaults.


## Purpose
The Lubuntu Hardening Kit serves as a custom automated hardening script to further lockdown Lubuntu systems by:
+ Turning on the firewall
+ Reducing the attack surface by:
	* Removing unused or generally exploitable features (avahi, cups-browsed, snapd, etc).
	* Masking unused or generally exploitable services (accounts-daemon, whoopsie, etc).
+ Enforcing kernel CPU mitigations
+ Enforcing kernel module restrictions
+ Enforcing kernel hardening and optimizations

And much much more. Audit the scripts to find out more. <br/>
Btw, this script isn't intended to make your Lubuntu system bulletproof, if you want that it's best to move to something like Arch Linux and customize it yourself.


## Usage
In the live cd or usb install Lubuntu on a single partition (i.e. automatic).<br/>
Then merely execute this command in terminal inside the newly installed Lubuntu:<br/>
`bash S1.sh`


## Supported Versions
| Version | Supported |
| --- | --- |
| 20.04* LTS | Y |
| 18.04* LTS | N, Deprecated |

