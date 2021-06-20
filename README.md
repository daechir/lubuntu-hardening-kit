# Author
Author: Daechir <br/>
Author URL: https://github.com/daechir <br/>
License: GNU GPL <br/>
Modified Date: 06/20/21 <br/>
Version: v1q1


## Changelog
+ v1q
  * S1.sh
    + Refractoring.
    + Update brave installation method.
    + Fix NetworkManager mac address randomization race condition.
    + Add isolation for the following services:
      * Ufw.service
      * Cups.service
    + Add dbus hardening.
    + Add randomize_kstack_offset=1 parameter for upcoming linux kernel 5.13 security feature.
    + bashrc:
      * Add automatic system.map cleanup.
    + 00_control_multicast.sh:
      * Add additional tweaks for wireless devices.
    + lubuntu-control-defaults.sh:
      * Refractoring.
      * Add control_suid().
  * S2.sh
    + Refractoring.
+ v1q1
  * S1.sh
    + Fix a few missed changes.
    + Regress dbus hardening.
      * This type of hardening under Ubuntu based distributions actually makes apt and apt-get fail if it touches a immutable file.
    + bashrc:
      * Add a mechanism to enable temporary suid permissions on certain binaries for supleave() to run successfully.


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

