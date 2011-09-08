NSIS=/c/Program\ Files\ \(x86\)/NSIS/Unicode/makensisw.exe
NSIS=/c/Program\ Files\ \(x86\)/NSIS/makensisw.exe
SCRIPT=install.nsi
OCAMLROOT=/c/ocamlmgw

all: util
	$(NSIS) $(SCRIPT)

util: gen_files.ml
	rm -f gen_files.byte
	ocamlbuild gen_files.byte
	./gen_files.byte $(OCAMLROOT)

