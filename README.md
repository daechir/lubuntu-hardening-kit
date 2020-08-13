# Author
Author: Daechir <br/>
Author URL: https://github.com/daechir <br/>
License: GNU GPL <br/>
Modified Date: 08/13/20 <br/>
Version: v1


## Purpose
The Lubuntu Hardening Kit serves as a custom automated hardening script to further lockdown Lubuntu systems by:
+ Turning on the firewall
+ Reducing the attack surface by:
	* Removing unused or generally exploitable features (avahi, cups-browsed, snapd, etc).
	* Masking unused or generally exploitable services (accounts-daemon, whoopsie, etc).
+ Enforcing kernel CPU mitigations
+ Enforcing kernel module restrictions
+ Enforcing kernel hardening and optimizations via rc.local on each boot

And much much more. Audit the scripts to find out more. <br/>
Btw, this script isn't intended to make your Lubuntu system bulletproof, if you want that it's best to move to something like Arch Linux and customize it yourself.


## Usage
`chmod +x S1.sh` <br/>
`./S1.sh`


## Supported Versions
| Version | Supported |
| --- | --- |
| 20.04 LTS | Y |
| 18.04* LTS | N, Deprecated |