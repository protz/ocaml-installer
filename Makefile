NSIS=/c/Program\ Files\ \(x86\)/NSIS/Unicode/makensisw.exe
NSIS=/c/Program\ Files\ \(x86\)/NSIS/makensisw.exe
SCRIPT=install.nis
OCAMLROOT=/c/ocamlmgw

all:
	$(NSIS) $(SCRIPT)

util: gen_files.ml
	ocamlbuild gen_files.byte
	./gen_files.byte $(OCAMLROOT)

