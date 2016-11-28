The OCaml Installer for Windows
===============================

These are the source files if you want to rebuild the installer. If you just
want to download the installer, see the "website" link near the top of the
page.

The installer now uses the "official" toolchain, namely 64-bit Mingw64 living in a
Cygwin environment. The current version of this installer works with OCaml 4.0;
if you want to compile an older version of OCaml, you need to switch to and older
revision.

Requirements
------------

* Cygwin with the mingw64 compiler suite, 64bit version (x86_64-w64-mingw32).
* FlexDLL (at least 0.29)
* NSIS (the special build that uses 8k strings)

Instructions for building an new version of the installer
---------------------------------------------------------

The instructions above sometimes use the `c:\...`-style paths, sometimes the
`/c/...`-style paths. This is significant, and you cannot blindly replace one
for another.

Simplified instructions.

1. Install FlexDLL from Alain's website, and
    * `export PATH=/cygdrive/c/path/to/flexdll:$PATH`
2. Refresh the files in the `flexlink/` directory of the installer, so that the
   resulting installer ships the right version of flexdll (optional,
   recommended).
2. Grab a copy of the OCaml sources, and keep the default install path
   (`c:\ocamlmgw64`), this will make your life easier.
3. Follow the instructions in `README.Win32`, section "MinGW64/Cygwin". Try to
   compile OCaml. Swear. Try again. Grab a tea. Succeed. Be happy.
4. Make sure `/cygdrive/c/ocamlmgw64/bin` is in your path.
3. Clone camlp4, apply the
   [patch](https://github.com/ocaml/camlp4/issues/41#issuecomment-55229048) for
   Windows, `configure` `make all` and `make install`
3. `cp -R ocamlmgw64 ocamlmgw64-fresh`.
6. Checkout [David Allsop's OPAM fork](https://github.com/dra27/opam/tree/windows);
   cherry-pick the `windows-temp` commit (single commit). Apply the
   `patch-opam-dra27` file (forces wget + and makes opam init point to
   https://github.com/fdopen/opam-repository-mingw by default).
6. All the dependencies can be installed via opam. For `jsonm`: do `rm
   ~/.opam/~/.opam/repo/default/packages/jsonm/jsonm.0.9.1/files/jsonm.install`.
   Use [Thomas' script](https://github.com/braibant/ocaml-windows-bootstrap)
   just for `dose3`; manually move things from `c:/ocamlmgw64/` to
   `~/.opam/system/lib`. Note to self: Thomas' script hardcodes i686 instead of
   x86_64 in quite a few places. Do a search-and-replace for that and also
   `s/ocamlmgw/ocamlmgw64`.
6. Look into Thomas' script to figure out which variables to export to build
   opam correctly. Build opam.
6. Move `ocamlmgw64-fresh` to `ocamlmgw64` and `make install`. Now `ocamlmgw64`
   only contains OCaml and the OPAM executables (NOT the build dependencies for
   OPAM).
6. In the `ocaml-installer` directory (i.e. this repo), run `make`. This should
   create a variety of files:
    * `version.nsh`, a NSIS header file that is generated to contain the freshly
      compiled OCaml's version number,
    * `uninstall_lines.nsi`, an OCaml-generated list of files to remove from the
      install directory.
6. This will also launch nsis.

Things to test for
------------------

1. `opam init`, `opam install mezzo`, `ocamlfind list`, etc.

Bugs, issues
------------

All patches should be submitted using GitHub pull requests. All issues should be
filed using the GitHub issue tracker.

License
-------

The MIT License (MIT)

Copyright (c) 2015 Jonathan Protzenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
