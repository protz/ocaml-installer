NSIS=/c/Program\ Files\ \(x86\)/NSIS/makensisw.exe
SCRIPT=install.nsi
OCAMLROOT=/c/ocamlmgw

all: util
	$(NSIS) $(SCRIPT)

# Regenerate if gen_files.ml changed or there's a new ocaml version (and
# potentially new files to bundle).
util: gen_files.ml $(OCAMLROOT)/bin/ocaml.exe
	rm -f gen_files.byte
	ocamlbuild gen_files.byte
	./gen_files.byte $(OCAMLROOT)

version: $(OCAMLROOT)/bin/ocaml.exe 
	$(shell echo "!define MUI_VERSION \""`ocaml -version | sed 's/.*version \([^ ]\+\).*/\1/g'`"\"" > version.nsh)
