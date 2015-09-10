; NSIS Installer script for OCaml
;
; Original Author:
;   Jonathan Protzenko <jonathan.protzenko@ens-lyon.org>
;
; This file is part of the OCaml Installer for Windows.
;
; --------
;
; The MIT License (MIT)
;
; Copyright (c) 2015 Jonathan Protzenko
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in
; all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
; THE SOFTWARE.

; -------------
!define INSTALLER_VERSION "3"
!define MUI_PRODUCT "OCaml"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "installer-logo.bmp"
!define MUI_ICON "ocaml-icon.ico"
!define CYGWIN_URL "http://cygwin.com/setup-x86.exe"
!define ROOT_DIR "c:\ocamlmgw" ; the directory where your binary dist of ocaml lives

!define MULTIUSER_EXECUTIONLEVEL Highest

!include "version.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh"
!include "IfKeyExists.nsh"
!include "MultiUser.nsh"
!include "ReplaceInFile.nsh"

Name "OCaml"
OutFile "ocaml-${MUI_VERSION}-i686-mingw64-installer${INSTALLER_VERSION}.exe"
InstallDir "C:\${MUI_PRODUCT}"

!define MUI_WELCOMEPAGE_TITLE "Welcome to the OCaml setup for windows."
!define MUI_WELCOMEPAGE_TEXT "This wizard will install OCaml ${MUI_VERSION}, \
as well as findlib (package management tool) and flexdll (prerequisite for \
compiling native code).$\n$\n\
The installer can install Cygwin, a Unix layer on top of windows. This is required if you want to \
perform native compilation or use opam. If you already have Cygwin, this wizard \
will just launch Cygwin's setup.exe with the right packages pre-checked, so \
that all you have to do is click through the wizard."
!define MUI_LICENSEPAGE_TEXT_TOP "OCaml is distributed under a modified QPL license."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "You must agree with the terms of the license below before installing OCaml."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "All the components below will be downloaded off the internet, and their own installers will be launched."
!define MUI_FINISHPAGE_TITLE "Congratulations! You have installed OCaml"
!define MUI_FINISHPAGE_TEXT "You can now play with OCaml. Start menu entries and \
  desktop shortcuts have been created. $\n$\n\
  - If you installed Cygwin, there should be a $\"Cygwin Terminal$\" shortcut on your \
    desktop. You can open up a shell, and use opam, or ocamlopt from the \
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
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE "DirectoryLeave"
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

Function CheckForSpaces
 Exch $R0
 Push $R1
 Push $R2
 Push $R3
 StrCpy $R1 -1
 StrCpy $R3 $R0
 StrCpy $R0 0
 loop:
   StrCpy $R2 $R3 1 $R1
   IntOp $R1 $R1 - 1
   StrCmp $R2 "" done
   StrCmp $R2 " " 0 loop
   IntOp $R0 $R0 + 1
 Goto loop
 done:
 Pop $R3
 Pop $R2
 Pop $R1
 Exch $R0
FunctionEnd

Function DirectoryLeave

 # Call the CheckForSpaces function.
 Push $INSTDIR # Input string (install path).
  Call CheckForSpaces
 Pop $R0 # The function returns the number of spaces found in the input string.

 # Check if any spaces exist in $INSTDIR.
 StrCmp $R0 0 NoSpaces

   # Plural if more than 1 space in $INSTDIR.
   StrCmp $R0 1 0 +3
     StrCpy $R1 ""
   Goto +2
     StrCpy $R1 "s"

   # Show message box then take the user back to the Directory page.
   MessageBox MB_YESNO "The installation directory contains spaces. This is \
     likely to cause problem with third-party packages.$\n\
     Proceed anyway?" IDYES NoSpaces
   Abort

 NoSpaces:

FunctionEnd

Section "OCaml" SecOCaml

  ReadRegStr $1 SHCTX "SOFTWARE\OCaml" ""

  ${If} $1 != ""
    MessageBox MB_YESNO "There seems to be a previous version of OCaml \
      installed. It is strongly recommended you uninstall it before proceeding.$\n\
      Proceed anyway?" IDNO end
  ${EndIf}

  SetOutPath "$INSTDIR\bin"

  File "flexlink\flexlink.exe"
  File "flexlink\flexdll_mingw.o"
  File "flexlink\flexdll_initer_mingw.o"

  SetOutPath "$INSTDIR"

  File ocaml-icon.ico
  File onlinedoc.url
  File ${ROOT_DIR}\License.txt
  File /r ${ROOT_DIR}\bin
  File /r ${ROOT_DIR}\etc
  File /r ${ROOT_DIR}\lib

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

  ; Use the topfind template that's present in the ocaml-installer directory.
  Delete "$INSTDIR\lib\topfind"
  SetOutPath "$INSTDIR\lib"
  File topfind

  ; Escape the install directory with the OCaml syntax (fingers crossed)
  ${StrRep} $0 "$INSTDIR" "\" "\\"
  ; Replace the template with the right directory
  !insertmacro _ReplaceInFile "$INSTDIR\lib\topfind" "@SITELIB@" "$0/lib/site-lib"

  Delete "$INSTDIR\etc\findlib.conf"
  FileOpen  $1 "$INSTDIR\etc\findlib.conf" w
  FileWrite $1 "destdir=$\"$0\\lib\\site-lib$\"$\n"
  FileWrite $1 "path=$\"$0\\lib\\site-lib$\"$\n"
  FileWrite $1 "stdlib=$\"$0\\lib$\"$\n"
  FileWrite $1 "ldconf=$\"$0\\lib\\ld.conf$\"$\n"
  FileWrite $1 "ocamlc=$\"ocamlc.opt$\"$\n"
  FileWrite $1 "ocamlopt=$\"ocamlopt.opt$\"$\n"
  FileWrite $1 "ocamldep=$\"ocamldep.opt$\"$\n"
  FileWrite $1 "ocamldoc=$\"ocamldoc.opt$\"$\n"
  FileClose $1

  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "InstallLocation" "$INSTDIR"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayName" "OCaml"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayIcon" "$INSTDIR\ocaml-icon.ico"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayVersion" "${MUI_VERSION}"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "Publisher" "Inria"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\$STARTMENUFOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    CreateShortCut "$SMPROGRAMS\$STARTMENUFOLDER\Online Documentation.lnk" "$INSTDIR\onlinedoc.url"
  !insertmacro MUI_STARTMENU_WRITE_END

  WriteUninstaller $INSTDIR\uninstall.exe

  end:

SectionEnd

Section "Cygwin" SecCygwin
  ${If} ${FileExists} "$DESKTOP\cygwin-setup.exe"
    MessageBox MB_YESNO "There already is a file called cygwin-setup.exe on your \
      desktop.$\nOverwrite?" IDNO end
  ${EndIf}

  NSISdl::download ${CYGWIN_URL} "$DESKTOP\cygwin-setup.exe"

  Pop $0
  StrCmp $0 "success" ok
    MessageBox MB_OK "Couldn't download cygwin's setup.exe: $0"
    SetErrors
    DetailPrint "$0"
  ok:

  ; We used to have --site=http://cygwin.cict.fr but since the mirror list
  ; changes quite often, it's safer to let the user pick their preferred mirror.
  ExecWait "$DESKTOP\cygwin-setup.exe --quiet-mode \
    --local-package-dir=$TEMP\cygwin\ \
    --packages=curl,make,mingw64-i686-gcc-g++,mingw64-i686-gcc-core,mingw64-i686-gcc,patch,rlwrap,libreadline6,diffutils,wget,vim \
    >NUL 2>&1"

  end:

SectionEnd

LangString DESC_SecOCaml ${LANG_ENGLISH} "This contains the main OCaml \
  distribution, including all OCaml compilers, ocamlbuild, ocamldoc, \
  findlib, and flexlink for the mingw toolchain."
LangString DESC_SecCygwin ${LANG_ENGLISH} "Cygwin provides a Unix-like layer. \
  This is required if you want to run scripts such as odb, or perform \
  native-code compilation. This will download Cygwin's setup.exe to your desktop \
  as cygwin-setup.exe"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecOCaml} $(DESC_SecOCaml)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCygwin} $(DESC_SecCygwin)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; -------------
; The semantics are: if the section is named "Uninstall", then this is used to
; generate the uninstaller

Function un.onInit
  !insertmacro MULTIUSER_UNINIT
FunctionEnd

Section "Uninstall"

  ; The rationale is that users might install this in their Program Files
  ; directory, so we can't blindy remove the INSTDIR...
  Delete "$INSTDIR\bin\flexlink.exe"
  Delete "$INSTDIR\bin\flexdll_initer_mingw.o"
  Delete "$INSTDIR\bin\flexdll_mingw.o"
  ; Will remove only if the directory is empty
  RMDir "$INSTDIR\bin"

  Delete "$INSTDIR\ocaml-icon.ico"
  Delete "$INSTDIR\onlinedoc.url"
  Delete "$INSTDIR\License.txt"
  Delete "$INSTDIR\ld.conf"
  Delete "$INSTDIR\uninstall.exe"
  !include uninstall_lines.nsi
  RMDir "$INSTDIR"

  !insertmacro MUI_STARTMENU_GETFOLDER Application $STARTMENUFOLDER
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
