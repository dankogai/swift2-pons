MOD=PONS
BIN=main
BINSRC=test/*.swift
GRAPH=typetree
MODSRC=pons/*.swift
MODULE=$(MOD).swiftmodule
DOC=$(MOD).swiftdoc
SWIFTC=swiftc
SWIFTCFLAGS=
SWIFT=swift
ifdef SWIFTPATH
	SWIFTC=$(SWIFTPATH)/swiftc
	SWIFT=$(SWIFTPATH)/swift
endif
OS := $(shell uname)
ifeq ($(OS),Darwin)
	SWIFTC=xcrun -sdk macosx swiftc
endif

all: $(BIN)
module: $(MODULE)
clean:
	-rm $(BIN) $(MODULE) $(DOC) lib$(MOD).*
$(BIN): $(BINSRC) $(MODSRC)
	$(SWIFTC) $(SWIFTCFLAGS) $(MODSRC) $(BINSRC)
test: $(BIN)
	prove ./$(BIN)
$(MODULE): $(MODSRC)
	$(SWIFTC) -emit-library -emit-module $(MODSRC) -module-name $(MOD)
repl: $(MODULE)
	$(SWIFT) -I. -L. -l$(MOD)
graph:$(GRAPH).png
$(GRAPH).png: $(GRAPH).dot
	dot -Tpng $(GRAPH).dot -o $(GRAPH).png
