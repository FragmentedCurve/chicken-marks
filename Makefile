CHICKEN_CSC      := csc
EGGS             := openssl http-client srfi-1 linenoise ansi-escape-sequences
CSC_FLAGS        := -static -O3 $(foreach egg,$(EGGS),-link $(egg))
SSL_FLAGS        := -L "-lssl -lcrypto"

SOURCES := main.scm do-actions.scm bookie.scm config.scm subshell.scm key.scm utils.scm browser.scm
OBJECTS := $(SOURCES:.scm=.o)

MARKSEXE := marks

.PHONY: help

ifndef PLATFORM
all: help
else
all: $(MARKSEXE)
endif

ifeq ($(PLATFORM),linux)
CHICKEN_CSC := chicken-csc
CHICKEN_INSTALL := chicken-install
endif

ifeq ($(PLATFORM),freebsd)
CHICKEN_CSC := csc5
CHICKEN_INSTALL := chicken-install5
endif

ifeq ($(PLATFORM),macos)
CHICKEN_CSC := csc
CHICKEN_INSTALL := chicken-install
SSL_FLAGS := -L "-L$(shell brew --prefix openssl)/lib -lssl -lcrypto"
endif

%.o: %.scm
	$(CHICKEN_CSC) $(CSC_FLAGS) -c $(basename $@).scm

$(MARKSEXE): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

eggs:
	$(CHICKEN_INSTALL) $(EGGS)

help:
	@echo "Platforms:"
	@echo "  linux"
	@echo "  freebsd"
	@echo "  macos"
	@echo
	@echo "Examples:"
	@echo "  make PLATFORM=linux"
	@echo "  make PLATFORM=macos"

clean:
	$(RM) $(OBJECTS:.o=.link) $(OBJECTS) $(MARKSEXE)
