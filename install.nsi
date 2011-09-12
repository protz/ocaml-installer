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
!define ACTIVETCL_URL "http://downloads.activestate.com/ActiveTcl/releases/8.5.10.1/ActiveTcl8.5.10.1.295062-win32-ix86-threaded.exe"
!define ROOT_DIR "c:\ocamlmgw" ; the directory where your binary dist of ocaml lives

!include "version.nsh"
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
  !insertmacro MUI_PAGE_LICENSE ${ROOT_DIR}\License.txt
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
    MessageBox MB_YESNO "There seems to be a previous version of OCaml installed. It is strongly recommended you uninstall it before proceeding. Proceed anyway?" IDNO end
  ${EndIf}

  SetOutPath "$INSTDIR\bin"

  File "flexlink\flexlink.exe"
  File "flexlink\flexdll_mingw.o"
  File "flexlink\flexdll_initer_mingw.o"

  SetOutPath "$INSTDIR"

  File ocaml-icon.ico
  ;File ${ROOT_DIR}\Changes.txt
  ;File ${ROOT_DIR}\License.txt
  ;File ${ROOT_DIR}\OCamlWin.exe
  ;File /r ${ROOT_DIR}\bin
  ;File /r ${ROOT_DIR}\lib
  ;File /r ${ROOT_DIR}\man
  
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
    MessageBox MB_YESNO "You already seem to have ActiveTcl ${ACTIVETCL_VERSION} installed. Download and install ActiveTcl anyway?" IDNO end
  ${EndIf}
  

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

  Delete "$INSTDIR\ocaml-icon.ico"
  Delete "$INSTDIR\Changes.txt"
  Delete "$INSTDIR\License.txt"
  Delete "$INSTDIR\OCamlWin.exe"
  Delete "$INSTDIR\ld.conf"
  Delete "$INSTDIR\uninstall.exe"
  !include uninstall_lines.nsi
  RMDir "$INSTDIR"

  ${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\bin"
  ; Using EnvVarUpdate makes sure we do *not* alter OCAMLLIB in case it has
  ; changed in the meanwhile.
  ${un.EnvVarUpdate} $0 "OCAMLLIB" "R" "HKLM" "$INSTDIR\lib"
  ReadRegStr $1 SHCTX "SOFTWARE\OCaml" ""
  ${Unless} $1 != $INSTDIR
    DeleteRegKey /ifempty SHCTX "SOFTWARE\OCaml"
  ${EndUnless}

  DeleteRegKey SHCTX "Software\Microsoft\Windows\CurrentVersion\Uninstall\OCaml"

SectionEnd
