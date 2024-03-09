# nushell
Contains script to build nushell rpm and deb files

```
Usage:
  > create_nushell_package.nu <platform> 

Flags:
  -h, --help - Display the help message for this command

Parameters:
  platform <string>: 

Input/output types:
  ╭───┬───────┬────────╮
  │ # │ input │ output │
  ├───┼───────┼────────┤
  │ 0 │ any   │ any    │
  ╰───┴───────┴────────╯
```

Supported platforms are el8, el9, bookworm and trixie.

- pre-requsite to run the build script
    - nushell
    - fpm

- el8 -> Built in Rockylinux 8.9. Hope it should would work with RHEL8 and Almalinux8.
- el9 -> Built in Rockylinux 9.3. Hope it should would work with RHEL9 and Almalinux9.
- bookworm -> Latest Debian stable. Should work with any latest Ubuntu.
- trixie -> Latest Debian testing. Should work with any latest Ubuntu.

Note:
  - For Debian/Ubuntu installations, `libssl-dev` is a pre-requisite for nushell.
  - For el8/el9 (RHEL/Rockylinux/Almalinux), `openssl-devel` is a pre-requisite for nushell.
  - Actual `nushell` code is maintained under https://github.com/nushell/nushell .
  - Please refer to the license under https://github.com/nushell/nushell/blob/main/LICENSE for nushell usage.
  - Documentation is maintained under https://www.nushell.sh/book/ .
