; NSIS Installer script for OCaml
;
; Original Author:
;   Jonathan Protzenko <jonathan.protzenko@ens-lyon.org>
;
; This file is part of the OCaml Installer for Windows.
;
; The OCaml Installer for Windows is free software: you can redistribute it
; and/or modify it under the terms of the GNU General Public License as
; published by the Free Software Foundation, either version 3 of the License,
; or (at your option) any later version.
;
; The OCaml Installer for Windows is distributed in the hope that it will be
; useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
; Public License for more details.
;
; You should have received a copy of the GNU General Public License along with
; the OCaml Installer for Windows.  If not, see <http://www.gnu.org/licenses/>.

; -------------
!define MUI_PRODUCT "OCaml"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "installer-logo.bmp"
!define MUI_ICON "ocaml-icon.ico"
; this must match the activetcl version ocaml was compiled against
!define ACTIVETCL_VERSION "8.5.11.1"
!define ACTIVETCL_URL "http://downloads.activestate.com/ActiveTcl/releases/8.5.11.1/ActiveTcl8.5.11.1.295590-win32-ix86-threaded.exe"
!define EMACS_URL "http://ftp.gnu.org/gnu/emacs/windows/emacs-23.3-bin-i386.zip"
;!define EMACS_URL "http://yquem/~protzenk/emacs-23.3-bin-i386.zip"
!define EMACS_VER "23.3"
!define CYGWIN_URL "http://cygwin.com/setup.exe"
!define ROOT_DIR "c:\ocamlmgw" ; the directory where your binary dist of ocaml lives

!define MULTIUSER_EXECUTIONLEVEL Highest

!include "version.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh"
!include "IfKeyExists.nsh"
!include "MultiUser.nsh"

Name "OCaml"
OutFile "ocaml-${MUI_VERSION}-i686-mingw64.exe"
InstallDir "$PROGRAMFILES32\${MUI_PRODUCT}"

!define MUI_WELCOMEPAGE_TITLE "Welcome to the OCaml setup for windows."
!define MUI_WELCOMEPAGE_TEXT "This wizard will install OCaml ${MUI_VERSION}, \
as well as findlib (package management tool) and flexdll (prerequisite for \
compiling native code).$\n$\n\
The installer can install the following extra components for you:$\n\
- Emacs, a text editor, with support for OCaml. This will also create the right \
associations in Window's file explorer.$\n\
- ActiveTCL, a GUI library that is required if you want to use OCamlBrowser, or \
create graphical user interfaces using the Tcl/Tk bindings (labltk).$\n\
- Cygwin, a Unix layer on top of windows. This is required if you want to \
perform native compilation. This wizard will launch Cygwin's setup.exe with the \
right packages pre-checked, so that all you have to do is click through the wizard."
!define MUI_LICENSEPAGE_TEXT_TOP "OCaml is distributed under a modified QPL license."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "You must agree with the terms of the license below before installing OCaml."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "All the components below will be downloaded off the internet, and their own installers will be launched."
!define MUI_FINISHPAGE_TITLE "Congratulations! You have installed OCaml"
!define MUI_FINISHPAGE_TEXT "You can now play with OCaml. Start menu entries and \
  desktop shortcuts have been created. $\n$\n\
  - You can run OCamlWin, which is old \
    and clunky.$\n\
  - You can also run Emacs, if you chose to install it. Once in Emacs, just hit \
    Alt-X, type run-caml, hit enter, and start playing with the toplevel.$\n\
  - If you installed Cygwin, there should be a $\"Cygwin Shell$\" shortcut on your \
    desktop. You can open up a shell, and use ocamlfind, or ocamlopt from the \
    command line.$\n$\n\
  Enjoy!"
!define MUI_WELCOMEFINISHPAGE_BITMAP "side.bmp"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "SHCTX"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\OCaml"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

Var STARTMENUFOLDER

; -------------
; Some constants

!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0

!define env_all     '"SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define env_current '"Environment"'

; -------------
; Generate zillions of pages to look professional

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_STARTMENU Application $STARTMENUFOLDER
  !insertmacro MUI_PAGE_LICENSE ${ROOT_DIR}\License.txt
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

  !insertmacro MUI_LANGUAGE "English"

; -------------
; Main entry point
Function .onInit
  !insertmacro MULTIUSER_INIT

  ${If} $MultiUser.InstallMode == "CurrentUser"
    StrCpy $INSTDIR "$APPDATA\${MUI_PRODUCT}"
  ${EndIf}

FunctionEnd

Section "OCaml" SecOCaml

  ReadRegStr $1 SHCTX "SOFTWARE\OCaml" ""

  ${If} $1 != ""
    MessageBox MB_YESNO "There seems to be a previous version of OCaml installed. It is strongly recommended you uninstall it before proceeding. Proceed anyway?" IDNO end
  ${EndIf}

  SetOutPath "$INSTDIR\bin"

  File "flexlink\flexlink.exe"
  File "flexlink\flexdll_mingw.o"
  File "flexlink\flexdll_initer_mingw.o"

  SetOutPath "$INSTDIR"

  File ocaml-icon.ico
  File onlinedoc.url
  File ${ROOT_DIR}\Changes.txt
  File ${ROOT_DIR}\License.txt
  File ${ROOT_DIR}\OCamlWin.exe
  File /r ${ROOT_DIR}\bin
  File /r ${ROOT_DIR}\etc
  File /r ${ROOT_DIR}\lib
  File /r ${ROOT_DIR}\man

  ${If} $MultiUser.InstallMode == "AllUsers"
    ; This is for the OCamlWin thing
    WriteRegStr HKLM "Software\Objective Caml" "InterpreterPath" "$INSTDIR\bin\ocaml.exe"

    WriteRegStr HKLM "Software\OCaml" "" $INSTDIR
    ; We want to overwrite that one anyway for the new setup to work properly.
    WriteRegStr HKLM ${env_all} "OCAMLLIB" "$INSTDIR\lib"
    WriteRegStr HKLM ${env_all} "OCAMLFIND_CONF" "$INSTDIR\etc\findlib.conf"
    ${EnvVarUpdate} $0 "PATH" "P" "HKLM" "$INSTDIR\bin"
  ${ElseIf} $MultiUser.InstallMode == "CurrentUser"
     ; This is for the OCamlWin thing
    WriteRegStr HKCU "Software\Objective Caml" "InterpreterPath" "$INSTDIR\bin\ocaml.exe"

    WriteRegStr HKCU "Software\OCaml" "" $INSTDIR
    ; We want to overwrite that one anyway for the new setup to work properly.
    WriteRegStr HKCU ${env_current} "OCAMLLIB" "$INSTDIR\lib"
    WriteRegStr HKCU ${env_current} "OCAMLFIND_CONF" "$INSTDIR\etc\findlib.conf"

    ; EnvVarUpdate won't work if PATH doesn't exist or is empty...
    !insertmacro IfKeyExists "HKLM" ${env_current} "PATH"
    Pop $R0
    ${If} $R0 == 1 ; PATH exists, update it (and hope it's not empty)
      ${EnvVarUpdate} $0 "PATH" "P" "HKCU" "$INSTDIR\bin"
    ${Else}
      WriteRegStr HKCU ${env_current} "PATH" "$INSTDIR\bin"
    ${EndIf}
  ${Else}
    SetErrors
    DetailPrint "Error: $MultiUser.InstallMode unexpected value"
  ${EndIf}

  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000


  ; There's already a file like that in the original directory, so remove it,
  ; and write the correct values
  Delete "$INSTDIR\lib\ld.conf"
  FileOpen  $1 "$INSTDIR\lib\ld.conf" w
  FileWrite $1 "$INSTDIR\lib$\n"
  FileWrite $1 "$INSTDIR\lib\stublibs$\n"
  FileClose $1

  ; Escape the install directory with the OCaml syntax (fingers crossed)
  ${StrRep} $0 "$INSTDIR" "\" "\\"

  Delete "$INSTDIR\lib\topfind"
  FileOpen  $1 "$INSTDIR\lib\topfind" w
  FileWrite $1 "#load $\"$0\\lib\\site-lib\\findlib\\findlib.cma$\";;$\n"
  FileWrite $1 "#load $\"$0\\lib\\site-lib\\findlib\\findlib_top.cma$\";;$\n"
  FileWrite $1 "#directory $\"$0\\lib\\site-lib\\findlib$\";;$\n"
  FileWrite $1 "Topfind.add_predicates [ $\"byte$\"; $\"toploop$\" ];$\n"
  FileWrite $1 "Topfind.don't_load [ $\"findlib$\" ];$\n"
  FileWrite $1 "Topfind.announce();;$\n"
  FileClose $1

  Delete "$INSTDIR\etc\findlib.conf"
  FileOpen  $1 "$INSTDIR\etc\findlib.conf" w
  FileWrite $1 "destdir=$\"$0\\lib\\site-lib$\"$\n"
  FileWrite $1 "path=$\"$0\\lib\\site-lib$\"$\n"
  FileWrite $1 "stdlib=$\"$0\\lib$\"$\n"
  FileWrite $1 "ldconf=$\"$0\\lib\\ld.conf$\"$\n"
  FileWrite $1 "ocamlc=$\"ocamlc.opt$\"$\n"
  FileWrite $1 "ocamlopt=$\"ocamlopt.opt$\"$\n"
  FileWrite $1 "ocamldep=$\"ocamldep.opt$\"$\n"
  FileClose $1

  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "InstallLocation" "$INSTDIR"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayName" "OCaml"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayIcon" "$INSTDIR\ocaml-icon.ico"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayVersion" "${MUI_VERSION}"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "Publisher" "Inria"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$STARTMENUFOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\OCamlWin.lnk" "$INSTDIR\OCamlWin.exe"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\OCamlBrowser.lnk" "$INSTDIR\bin\ocamlbrowser.exe"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\Online Documentation.lnk" "$INSTDIR\onlinedoc.url"
  !insertmacro MUI_STARTMENU_WRITE_END

  WriteUninstaller $INSTDIR\uninstall.exe

  end:

SectionEnd

Section "ActiveTcl ${ACTIVETCL_VERSION}" SecActiveTcl

  ReadRegStr $1 HKLM "SOFTWARE\ActiveState\ActiveTcl" "CurrentVersion"

  ${If} $1 == ${ACTIVETCL_VERSION}
    MessageBox MB_YESNO "You already seem to have ActiveTcl ${ACTIVETCL_VERSION} installed. Download and install ActiveTcl anyway?" IDNO end
  ${EndIf}

  NSISdl::download ${ACTIVETCL_URL} "$TEMP\activetcl.exe"

  Pop $R0
  StrCmp $R0 "success" ok
    MessageBox MB_OK "Couldn't download the ActiveTCL installer: $R0"
    SetErrors
    DetailPrint $R0
    DetailPrint "Please download the ActiveTCL installer from activestate.com. Just grab the latest free, 32-bit installer."
    goto end
  ok:

  ExecWait "$TEMP\activetcl.exe"

  end:

SectionEnd

Section "Emacs ${EMACS_VER}" SecEmacs

  ${If} ${FileExists} "$INSTDIR\emacs-${EMACS_VER}"
    MessageBox MB_YESNO "There seems to be an Emacs living in that directory already... overwrite?" IDNO end
  ${EndIf}

  NSISdl::download ${EMACS_URL} "$TEMP\emacs.zip"

  Pop $0
  StrCmp $0 "success" ok
    MessageBox MB_OK "Couldn't download the Emacs zip: $0"
    SetErrors
    DetailPrint "$0"
  ok:

  nsisunz::UnzipToLog "$TEMP\emacs.zip" "$INSTDIR"

  ; add the caml-mode in the emacs distribution

  SetOutPath "$INSTDIR\emacs-${EMACS_VER}\site-lisp\caml-mode"
  File ${ROOT_DIR}\emacsfiles\*
  SetOutPath "$INSTDIR\emacs-${EMACS_VER}\site-lisp"
  File site-start.el

  ; register file types, add emacs bin directory to the path

  ${If} $MultiUser.InstallMode == "AllUsers"
    ${EnvVarUpdate} $0 "PATH" "P" "HKLM" "$INSTDIR\emacs-${EMACS_VER}\bin"
  ${ElseIf} $MultiUser.InstallMode == "CurrentUser"
    ${EnvVarUpdate} $0 "PATH" "P" "HKCU" "$INSTDIR\emacs-${EMACS_VER}\bin"
  ${Else}
    SetErrors
    DetailPrint "Error: $MultiUser.InstallMode unexpected value"
  ${EndIf}


  WriteRegStr HKCR ".mli" "" "OCaml.mli"
  WriteRegStr HKCR "OCaml.mli" "" "OCaml Interface File"
  WriteRegStr HKCR "OCaml.mli\DefaultIcon" "" "$INSTDIR\ocaml-icon.ico"
  WriteRegStr HKCR "OCaml.mli\shell" "" "open"
  WriteRegStr HKCR "OCaml.mli\shell\open\command" "" '$INSTDIR\emacs-${EMACS_VER}\bin\runemacs.exe "%1"'

  WriteRegStr HKCR ".ml" "" "OCaml.ml"
  WriteRegStr HKCR "OCaml.ml" "" "OCaml Implementation File"
  WriteRegStr HKCR "OCaml.ml\DefaultIcon" "" "$INSTDIR\ocaml-icon.ico"
  WriteRegStr HKCR "OCaml.ml\shell" "" "open"
  WriteRegStr HKCR "OCaml.ml\shell\open\command" "" '$INSTDIR\emacs-${EMACS_VER}\bin\runemacs.exe "%1"'

  System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\Emacs.lnk" "$INSTDIR\emacs-${EMACS_VER}\bin\runemacs.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

  end:

SectionEnd

Section "Cygwin" SecCygwin
  ${If} ${FileExists} "$DESKTOP\cygwin-setup.exe"
    MessageBox MB_YESNO "There already is a file called cygwin-setup.exe on your desktop. Overwrite?" IDNO end
  ${EndIf}

  NSISdl::download ${CYGWIN_URL} "$DESKTOP\cygwin-setup.exe"

  Pop $0
  StrCmp $0 "success" ok
    MessageBox MB_OK "Couldn't download cygwin's setup.exe: $0"
    SetErrors
    DetailPrint "$0"
  ok:

  ExecWait "$DESKTOP\cygwin-setup.exe --quiet-mode \
    --local-package-dir=c:\cygtmp\ \
    --site=http://cygwin.cict.fr \
    --packages=make,mingw64-i686-gcc-g++,mingw64-i686-gcc,patch,rlwrap,libreadline6,diffutils,wget,vim \
    >NUL 2>&1"

  end:

SectionEnd

LangString DESC_SecOCaml ${LANG_ENGLISH} "This contains the main OCaml \
  distribution, including all OCaml compilers, ocamlbuild, ocamldoc, ocamlbrowser, \
  labltk, ocamlfind, and flexlink for the mingw toolchain."
LangString DESC_SecActiveTcl ${LANG_ENGLISH} "ActiveTcl is distributed by \
  ActiveState and provides the graphical required libraries to run ocamlbrowser, \
  as well as your own graphical programs if you choose so."
LangString DESC_SecEmacs ${LANG_ENGLISH} "Emacs is a text editor with excellent \
  OCaml support. This will download Emacs from the internet, and make sure the \
  OCaml specific scripts are properly installed."
LangString DESC_SecCygwin ${LANG_ENGLISH} "Cygwin provides a Unix-like layer on \
  top of the Windows API. This is required if you want to run scripts such as odb, \
  or perform native-code compilation. This will download Cygwin's setup.exe to \
  your desktop as cygwin-setup.exe"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecOCaml} $(DESC_SecOCaml)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecActiveTcl} $(DESC_SecActiveTcl)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecEmacs} $(DESC_SecEmacs)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCygwin} $(DESC_SecCygwin)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; -------------
; The semantics are: if the section is named "Uninstall", then this is used to
; generate the uninstaller

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
FunctionEnd

Section "Uninstall"

  ${If} ${FileExists} "$INSTDIR\emacs-${EMACS_VER}"
    MessageBox MB_YESNO "Also uninstall Emacs ${EMACS_VER}?" IDNO next

    ${If} $MultiUser.InstallMode == "AllUsers"
      ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\emacs-${EMACS_VER}\bin"
    ${ElseIf} $MultiUser.InstallMode == "CurrentUser"
      ${un.EnvVarUpdate} $0 "PATH" "R" "HKCU" "$INSTDIR\emacs-${EMACS_VER}\bin"
    ${Else}
      SetErrors
      DetailPrint "Error: $MultiUser.InstallMode unexpected value"
    ${EndIf}

    RMDir /r "$INSTDIR\emacs-${EMACS_VER}"

    ReadRegStr $R0 HKCR ".mli" ""
    StrCmp $R0 "OCaml.mli" 0 +2
      DeleteRegKey HKCR ".mli"

    ReadRegStr $R0 HKCR ".ml" ""
    StrCmp $R0 "OCaml.ml" 0 +2
      DeleteRegKey HKCR ".ml"

    DeleteRegKey HKCR "OCaml.ml"
    DeleteRegKey HKCR "OCaml.mli"

    System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'
  ${EndIf}

  next:

  ; The rationale is that users might install this in their Program Files
  ; directory, so we can't blindy remove the INSTDIR...
  Delete "$INSTDIR\bin\flexlink.exe"
  Delete "$INSTDIR\bin\flexdll_initer_mingw.o"
  Delete "$INSTDIR\bin\flexdll_mingw.o"
  ; Will remove only if the directory is empty
  RMDir "$INSTDIR\bin"

  Delete "$INSTDIR\ocaml-icon.ico"
  Delete "$INSTDIR\onlinedoc.url"
  Delete "$INSTDIR\Changes.txt"
  Delete "$INSTDIR\License.txt"
  Delete "$INSTDIR\OCamlWin.exe"
  Delete "$INSTDIR\ld.conf"
  Delete "$INSTDIR\uninstall.exe"
  !include uninstall_lines.nsi
  RMDir "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $STARTMENUFOLDER
  Delete "$SMPROGRAMS\$STARTMENUFOLDER\OCamlWin.lnk"
  Delete "$SMPROGRAMS\$STARTMENUFOLDER\OCamlBrowser.lnk"
  Delete "$SMPROGRAMS\$STARTMENUFOLDER\Emacs.lnk"
  Delete "$SMPROGRAMS\$STARTMENUFOLDER\Online Documentation.lnk"
  Delete "$SMPROGRAMS\$STARTMENUFOLDER\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$STARTMENUFOLDER"


  ${If} $MultiUser.InstallMode == "AllUsers"
    ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"

    ; This is for the OCamlWin thing
    ReadRegStr $R1 HKLM "Software\Objective Caml" "InterpreterPath"
    ${Unless} $R1 != "$INSTDIR\bin\ocaml.exe"
      DeleteRegValue HKLM "Software\Objective Caml" "InterpreterPath"
    ${EndUnless}

    ; OCAMLLIB
    ReadRegStr $R1 HKLM ${env_all} "OCAMLLIB"
    ${Unless} $R1 != "$INSTDIR\lib"
      DeleteRegValue HKLM ${env_all} "OCAMLLIB"
    ${EndUnless}

    ; OCAMLFIND_CONF
    ReadRegStr $R1 HKLM ${env_all} "OCAMLFIND_CONF"
    ${Unless} $R1 != "$INSTDIR\etc\findlib.conf"
      DeleteRegValue HKLM ${env_all} "OCAMLFIND_CONF"
    ${EndUnless}

    ReadRegStr $R1 HKLM "SOFTWARE\OCaml" ""
    ${Unless} $R1 != $INSTDIR
      DeleteRegKey /ifempty HKLM "SOFTWARE\OCaml"
    ${EndUnless}

    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml"
  ${ElseIf} $MultiUser.InstallMode == "CurrentUser"
    ; Completely blast the user-local PATH variable if we're the only ones to
    ; use it. That way, the installer has a chance to work properly next time...
    ReadRegStr $R1 HKCU ${env_current} "PATH"
    ${If} $R1 == "$INSTDIR\bin"
      DeleteRegValue HKCU ${env_current} "PATH"
    ${Else}
      ${un.EnvVarUpdate} $0 "PATH" "R" "HKCU" "$INSTDIR\bin"
    ${EndIf}

    ; This is for the OCamlWin thing
    ReadRegStr $R1 HKCU "Software\Objective Caml" "InterpreterPath"
    ${Unless} $R1 != "$INSTDIR\bin\ocaml.exe"
      DeleteRegValue HKCU "Software\Objective Caml" "InterpreterPath"
    ${EndUnless}

    ; OCAMLLIB
    ReadRegStr $R1 HKCU ${env_current} "OCAMLLIB"
    ${Unless} $R1 != "$INSTDIR\lib"
      DeleteRegValue HKCU ${env_current} "OCAMLLIB"
    ${EndUnless}

    ; OCAMLFIND_CONF
    ReadRegStr $R1 HKCU ${env_current} "OCAMLFIND_CONF"
    ${Unless} $R1 != "$INSTDIR\etc\findlib.conf"
      DeleteRegValue HKCU ${env_current} "OCAMLFIND_CONF"
    ${EndUnless}

    ReadRegStr $R1 HKCU "SOFTWARE\OCaml" ""
    ${Unless} $R1 != $INSTDIR
      DeleteRegKey /ifempty HKCU "SOFTWARE\OCaml"
    ${EndUnless}

    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml"
  ${Else}
    SetErrors
    DetailPrint "Error: $MultiUser.InstallMode unexpected value"
  ${EndIf}

  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

SectionEnd
