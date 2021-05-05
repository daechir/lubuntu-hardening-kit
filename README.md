# Author
Author: Daechir <br/>
Author URL: https://github.com/daechir <br/>
License: GNU GPL <br/>
Modified Date: 05/05/21 <br/>
Version: v1p1


## Changelog
+ v1p
  * S1.sh
    + Add new ctls.
    + Add apparmor fix.
    + Deprecate /etc/environment (Its variable's are now set in /etc/profile and */*bashrc).
    + Add console and tty restrictions.
    + /etc/modprobe.d/* upstream version update.
    + Ship /etc/profile as a file instead of modifying the existing one.
    + Ship /etc/systemd/resolved.conf as a file instead of modifying the existing one.
    + bashrc:
      * Update to match /etc/profile.
      * Add an automatic mainline kernel cleanup method.
+ v1p1
  * README.md
    + Update Supported Versions table.
    + Add Regarding Version Deprecation section.
  * S1.sh
    + Fix various typos and unwanted bits.
    + Update systemd services to match the ones shipped in 21.04.
    + Improve isolation of all existing systemd services.
    + Also add isolation for dbus.service (More service isolation will come later).
    + bashrc:
      * Add a syntax check to prevent kernel updates from applying everytime supleave is run.
      * Fix supleaves automatic mainline kernel cleanup method.
        + When on a kernel < the latest it would automatically purge it after installation (oops).
  * S2.sh
    + Config file updates (again).


## Purpose
The Lubuntu Hardening Kit serves as a custom automated hardening script to further lockdown Lubuntu systems by:
+ Turning on the firewall
+ Forcing the use of the newest mainline kernel
+ Reducing the attack surface by:
	* Removing unused or generally exploitable features (avahi, cups-browsed, snapd, etc).
	* Masking unused or generally exploitable services (accounts-daemon, whoopsie, etc).
+ Enforcing kernel CPU mitigations
+ Enforcing kernel module restrictions
+ Enforcing kernel hardening and optimizations
+ Isolating or sandboxing systemd services

And much much more. Audit the scripts to find out more. <br/>
Btw, this script isn't intended to make your Lubuntu system bulletproof, if you want that it's best to move to something like Arch Linux and customize it yourself.


## Usage
In the live cd or usb install Lubuntu on a single partition (i.e. automatic).<br/>
Then merely execute this command in terminal inside the newly installed Lubuntu:<br/>
`bash S1.sh`


## Supported Versions
| Version | Supported |
| --- | --- |
| 21.04* | Y |
| Any version < 21.04* | N, Deprecated |


## Regarding Version Deprecation
With v1p1 any Lubuntu version preceeding 21.04 is no longer supported.<br/>
This was purposefully done because Linux kernel 5.12 or higher now requires a newer version of glibc which isn't shipped in those versions.

