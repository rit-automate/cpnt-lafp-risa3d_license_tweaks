# cpnt-lafp-risa3d_license_tweaks

## Source request

```
Michael / Binly / Jack

We have recently added licenses of the RISA 3D application to the cloud license server but we need to make a configuration change to workstations to properly access them across the board.

I believe the changes are similar to the ADAPT license change detailed below and should be made to the active workstations and in the conform scripts for new deployments.

[HKEY_CURRENT_USER\SOFTWARE\RISA Technologies\RISA-3D]
@=""
"License Type List"="Network,Cloud"

[HKEY_LOCAL_MACHINE\SOFTWARE\RISA Technologies\RISA-3D]
@=""
"License Type List"="Network,Cloud"

The faster we can get this in place, the better, because the natives are/were restless already.  Please let me know if you have any further questions.  Thank you!  

```

## Notes

- Use the hkeycu modifier from here [cpnt-vlk-newforma_vpn_fix](https://github.com/rit-automate/cpnt-vlk-newforma_vpn_fix)

