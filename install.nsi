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

  WriteRegStr HKLM "Software\OCaml" "" $INSTDIR

  
  File c:\ocamlmgw\Changes.txt
  File c:\ocamlmgw\License.txt
  File c:\ocamlmgw\OCamlWin.exe
  File /r c:\ocamlmgw\bin
  File /r c:\ocamlmgw\lib
  File /r c:\ocamlmgw\man

  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd

; -------------
; The semantics are: if the section is named "Uninstall", then this is used to
; generate the uninstaller

Section "Uninstall"

  ; The rationale is that idiots^W users might install this in their Program
  ; Files directory, so we can't blindy remove the INSTDIR...
  Delete "$INSTDIR\uninstall.exe"
  !include uninstall_lines.nsi
  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKLM "Software\OCaml"

SectionEnd
