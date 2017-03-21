OCB_FLAGS = -use-ocamlfind -I src
OCB = 		ocamlbuild $(OCB_FLAGS)

all: 		native byte

clean:
			$(OCB) -clean

native: 	sanity
			$(OCB) main.native

byte:		sanity
			$(OCB) main.byte

profile: 	sanity
			$(OCB) -tag profile main.native

debug: 		sanity
			$(OCB) -tag debug main.byte

sanity:
			ocamlfind query core


.PHONY: 	all clean byte native profile debug sanity
