The OCaml Installer for Windows
===============================

These are the source files if you want to rebuild the installer. If you just
want to download the installer, see the "website" link near the top of the
page.

The installer now uses the "official" toolchain, namely Mingw64 living in a
Cygwin environment. The current version of this installer works with OCaml 4.0;
if you want to compile an older version of OCaml, you need to switch to and older
revision.

Requirements
------------

* Cygwin with the mingw64 compiler suite, 32bit version (i686-w64-mingw32).
* FlexDLL (at least 0.29)
* NSIS
* the NSISunz plugin for NSIS, that lives somewhere on the NSIS wiki

Instructions for building an new version of the installer
---------------------------------------------------------

The instructions above sometimes use the `c:\...`-style paths, sometimes the
`/c/...`-style paths. This is significant, and you cannot blindly replace one
for another.

1. Install FlexDLL from Alain's website, and
    * `export PATH=/cygdrive/c/path/to/flexdll:$PATH`
2. Refresh the files in the `flexdll/` directory of the installer, so that the
   resulting installer ships the right version of flexdll (optional,
   recommended).
2. Grab a copy of ActiveTCL and install it, leave the default path (`c:\tcl`).
2. Grab a copy of the OCaml sources, and keep the default install path
   (`c:\ocamlmgw`), this will make your life easier.
3. Follow the instructions in `README.Win32`, section "MinGW/Cygwin". Try to
   compile OCaml. Swear. Try again. Grab a tea. Succeed. Be happy.
3. Go into the `emacs/` directory.
    * Make sure there's an `emacs.exe` in your path (install Emacs if you have to).
    * Configure the Makefile so that the output directory is
      `/c/ocamlmgw/emacsfiles`.
    * Run `make` in that directory.
3. Checkout a copy of OCamlWin from the OCaml forge, edit Makefile.local and
   `make && make install`.
3. Add `c:\ocamlmgw\bin` to your path, `configure` and `make` findlib.
3. Copy findlib's `src/findlib/topfind.p` to `topfind` in the OCaml Installer
   directory.
4. Install NSIS, grab `nsisunz.dll` somewhere on the interwebs and put it NSIS's
   `Plugins` directory.
5. Make sure `/cygdrive/c/ocamlmgw/bin` is in your path.
5. In the `ocaml-installer` directory (i.e. this repo), run `make`. This should
   create a variety of files:
    * `version.nsh`, a NSIS header file that is generated to contain the freshly
      compiled OCaml's version number,
    * `uninstall_lines.nsi`, an OCaml-generated list of files to remove from the
      install directory.
6. Make should also launch NSIS with the main script file, and hopefully it
   should all generate an installer. The installer is quite big (thank you
   camlp4).

Things to test for
------------------

1. `rlwrap ocaml`, then `#use "topfind";;`
2. `ocamlfind ocamlc -package unix -linkpkg test.ml` where `test.ml` uses the
   `Unix` module, of course.
3. `odb` on a sample package (e.g. `lwt`)

Bugs, issues
------------

All patches should be submitted using GitHub pull requests. All issues should be
filed using the GitHug issue tracker.
