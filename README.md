The OCaml Installer for Windows
===============================

These are the source files if you want to rebuild the installer. If you just
want to download the installer, see the "website" link near the top of the
page.

Requirements
------------

* MinGW/MSYS (__not__ Cygwin)
* FlexDLL
* NSIS
* the NSISunz plugin for NSIS, that lives somewhere on the NSIS wiki

Instructions
------------

As of 2011-09-14, the OCaml sources require patching in order to build properly.
This is mostly Makefile tweaking and should be integrated soon on trunk.

The instructions above sometimes use the `c:\...`-style paths, sometimes the
`/c/...`-style paths. This is significant, and you cannot blindly replace one
for another.

1. Install FlexDLL from Alain's website, and
    * `export PATH=/path/to/flexdll:$PATH`
    * `export FLEXLINKFLAGS="-L/mingw/lib -L/mingw/lib/gcc/mingw32/N.N.N"` where
      `N.N.N` is the version of GCC that ships with your MinGW/MSYS setup.
2. Grab a copy of ActiveTCL and install it, leave the default path (`c:\tcl`).
2. Grab a copy of the OCaml sources, and keep the default install path
   (`c:\ocamlmgw`), this will make your life easier.
3. Follow the instructions in `README.Win32`, section "MinGW/Cygwin" (but of
   course you're not using Cygwin, nevermind). Try to compile OCaml. Swear. Try
   again. Grab a tea. Succeed. Be happy.
3. Go into the `emacs/` directory.
    * Make sure there's an `emacs.exe` in your path (install Emacs if you have to).
    * Configure the Makefile so that the output directory is
      `/c/ocamlmgw/emacsfiles`.
    * Run `make` in that directory.
4. Install NSIS, grab `nsisunz.dll` somewhere on the interwebs and put it NSIS's
   `Plugins` directory.
5. Make sure `/c/ocamlmgw/bin` is in your path.
5. In the `ocaml-installer` directory (i.e. this repo), run `make`. This should
   create a variety of files:
    * `version.nsh`, a NSIS header file that is generated to contain the freshly
      compiled OCaml's version number,
    * `uninstall_lines.nsi`, an OCaml-generated list of files to remove from the
      install directory.
6. Make should also launch NSIS with the main script file, and hopefully it
   should all generate an installer. The installer is quite big (thank you
   camlp4).

Bugs, issues
------------

All patches should be submitted using GitHub pull requests. All issues should be
filed using the GitHug issue tracker.
