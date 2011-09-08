; NSIS Installer script for OCaml
;
; Original Author:
;   Jonathan Protzenko <jonathan.protzenko@ens-lyon.org>

; -------------
!define MUI_PRODUCT "OCaml"
!define MUI_VERSION "3.13pre"
!define MUI_UI_HEADERIMAGE "ocaml-icon.png"
!define MUI_ICON "ocaml-icon.ico"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh"

Name "OCaml"
OutFile "OCaml Setup.exe"
InstallDir "$PROGRAMFILES32\${MUI_PRODUCT}"
RequestExecutionLevel admin

; -------------
; Generate zillions of pages to look professional

  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

; -------------
; Main entry point

Section "OCaml" SecOcaml

  SetOutPath "$INSTDIR"

  File ocaml-icon.ico
  File c:\ocamlmgw\Changes.txt
  ;File c:\ocamlmgw\License.txt
  ;File c:\ocamlmgw\OCamlWin.exe
  ;File /r c:\ocamlmgw\bin
  ;File /r c:\ocamlmgw\lib
  ;File /r c:\ocamlmgw\man
  
  WriteRegStr SHCTX "Software\OCaml" "" $INSTDIR
  ; We want to overwrite that one anyway for the new setup to work properly.
  WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "OCAMLLIB" "$INSTDIR\lib"
  ${EnvVarUpdate} $0 "PATH" "P" "HKLM" "$INSTDIR\bin"

  FileOpen $0 "$INSTDIR\ld.conf" w
  FileWrite $0 "$INSTDIR\lib"
  FileClose $0

  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegExpandStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "InstallLocation" "$INSTDIR"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayName" "OCaml"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayIcon" "$INSTDIR\ocaml-icon.ico"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "DisplayVersion" "${MUI_VERSION}"
  WriteRegStr SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml" "Publisher" "Inria"

  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd

; -------------
; The semantics are: if the section is named "Uninstall", then this is used to
; generate the uninstaller

Section "Uninstall"

  ; The rationale is that idiots^W users might install this in their Program
  ; Files directory, so we can't blindy remove the INSTDIR...
  Delete "$INSTDIR\ocaml-icon.ico"
  Delete "$INSTDIR\uninstall.exe"
  ;!include uninstall_lines.nsi
  Delete "$INSTDIR\Changes.txt" ; just for debug...
  RMDir "$INSTDIR"

  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"
  ; Using EnvVarUpdate makes sure we do *not* alter OCAMLLIB in case it has
  ; changed in the meanwhile.
  ${un.EnvVarUpdate} $0 "OCAMLLIB" "R" "HKLM" "$INSTDIR\lib"
  ; Same logic, without using the wrapper above.
  ReadRegStr $1 SHCTX "SOFTWARE\OCaml" ""
  ${Unless} $1 != $INSTDIR
    DeleteRegKey /ifempty SHCTX "SOFTWARE\OCaml"
  ${EndUnless}

  DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml"

SectionEnd
