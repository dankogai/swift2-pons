MOD=PONS
BIN=main
MODSRC=pons/*.swift
BINSRC=$(MODSRC) test/*.swift
MODULE=$(MOD).swiftmodule $(MOD).swiftdoc
SWIFTC=swiftc
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
	-rm $(BIN) $(MODULE) lib$(MOD).*
$(BIN): $(BINSRC)
	$(SWIFTC) $(BINSRC)
test: $(BIN)
	prove ./$(BIN)
$(MODULE): $(MODSRC)
	$(SWIFTC) -emit-library -emit-module $(MODSRC) -module-name $(MOD)
repl: $(MODULE)
	$(SWIFT) -I. -L. -l$(MOD)
