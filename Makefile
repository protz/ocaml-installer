NSIS=/cygdrive/c/Program\ Files\ \(x86\)/NSIS/makensis.exe
SCRIPT=install.nsi
OCAMLROOT=/cygdrive/c/ocamlmgw64/
OCAMLROOTW=c:/ocamlmgw64/
OCAMLSRC=../ocaml

.PHONY: version

all: util version topfind files
	$(NSIS) $(SCRIPT)

# Regenerate if gen_files.ml changed or there's a new ocaml version (and
# potentially new files to bundle).
util: gen_files.ml $(OCAMLROOT)/bin/ocaml.exe
	rm -f gen_files.byte
	ocamlbuild gen_files.byte
	./gen_files.byte $(OCAMLROOTW)

files: $(OCAMLROOT)/License.txt

$(OCAMLROOT)/License.txt: $(OCAMLSRC)/LICENSE
	cp $< $@

version: $(OCAMLROOT)/bin/ocaml.exe
	$(shell echo "!define MUI_VERSION \""`$(OCAMLROOT)/bin/ocaml.exe -version | sed 's/.*version \([^ ]\+\).*/\1/g'`"\"" > version.nsh)
