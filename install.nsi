; NSIS Installer script for OCaml
;
; Original Author:
;   Jonathan Protzenko <jonathan.protzenko@ens-lyon.org>

; -------------
!define MUI_PRODUCT "OCaml"
!define MUI_UI_HEADERIMAGE "ocaml-icon.png"
!define MUI_ICON "ocaml-icon.ico"
; this must match the activetcl version ocaml was compiled against
!define ACTIVETCL_VERSION "8.5.10.1"

!include "version.nsh"
!include "urls.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "EnvVarUpdate.nsh"

Name "OCaml"
OutFile "OCaml Setup.exe"
InstallDir "$PROGRAMFILES32\${MUI_PRODUCT}"
RequestExecutionLevel admin

!define MUI_WELCOMEPAGE_TITLE "Welcome to the OCaml setup for windows."
!define MUI_WELCOMEPAGE_TEXT "This wizard will install OCaml ${MUI_VERSION}, as well as required tools and libraries for it to work properly."
!define MUI_LICENSEPAGE_TEXT_TOP "OCaml is distributed under a modified QPL license."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "You must agree with the terms of the license below before installing OCaml."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Tcl/Tk is a requirement, and Emacs is recommended to have a nice toplevel. This installer can download and install both."

; -------------
; Generate zillions of pages to look professional

  !insertmacro MUI_PAGE_WELCOME
  ;!insertmacro MUI_PAGE_STARTMENU 
  !insertmacro MUI_PAGE_LICENSE c:\ocamlmgw\License.txt
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

; -------------
; Main entry point

Section "OCaml" SecOCaml

  ReadRegStr $1 SHCTX "SOFTWARE\OCaml" ""
  
  ${If} $1 != ""
    MessageBox MB_OKCANCEL "There seems to be a previous version of OCaml installed. It is strongly recommended you uninstall it before proceeding." IDCANCEL end
  ${EndIf}

  SetOutPath "$INSTDIR\bin"

  File "flexlink\flexlink.exe"
  File "flexlink\flexdll_mingw.o"
  File "flexlink\flexdll_initer_mingw.o"

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

  end:

SectionEnd

Section "ActiveTcl ${ACTIVETCL_VERSION}" SecActiveTcl

  ReadRegStr $1 HKLM "SOFTWARE\ActiveState\ActiveTcl" "CurrentVersion"
  
  ${If} $1 == ${ACTIVETCL_VERSION}
    MessageBox MB_OKCANCEL "You already seem to have ActiveTcl ${ACTIVETCL_VERSION} installed. Download and install ActiveTcl anyway?" IDCANCEL end
  ${EndIf}
  

  SetOutPath "$INSTDIR"

  NSISdl::download ${ACTIVETCL_URL} "$TEMP\activetcl.exe"
  ExecWait "$TEMP\activetcl.exe"
  
  end:

SectionEnd

; -------------
; The semantics are: if the section is named "Uninstall", then this is used to
; generate the uninstaller

Section "Uninstall"

  ; The rationale is that idiots^W users might install this in their Program
  ; Files directory, so we can't blindy remove the INSTDIR...
  Delete "$INSTDIR\bin\flexlink.exe"
  Delete "$INSTDIR\bin\flexdll_initer_mingw.o"
  Delete "$INSTDIR\bin\flexdll_mingw.o"
  RMDir "$INSTDIR\bin"

  Delete "$INSTDIR\ld.conf"
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
