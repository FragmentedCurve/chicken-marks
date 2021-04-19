CHICKEN_CSC      := csc
EGGS             := openssl http-client
_EGGS            := $(foreach egg, $(EGGS), $(eval _EGGS=$(egg),$(_EGGS)))$(_EGGS:,=)
CSC_FLAGS        := -static -O3 -link $(_EGGS)
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
SSL_FLAGS   :=  -L "$(shell pkg-config --libs openssl)"
endif

ifeq ($(PLATFORM),macos)
CHICKEN_CSC := csc
SSL_FLAGS := -L "-L$(shell brew --prefix openssl)/lib -lssl -lcrypto"
endif

%.o: %.scm
	$(CHICKEN_CSC) $(CSC_FLAGS) -c $(basename $@).scm

$(MARKSEXE): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

help:
	@echo "Platforms:"
	@echo "  linux"
	@echo "  macos"
	@echo
	@echo "Examples:"
	@echo "  make PLATFORM=linux"
	@echo "  make PLATFORM=macos"

clean:
	$(RM) $(OBJECTS:.o=.link) $(OBJECTS) $(MARKSEXE) $(MARKS_STATIC) $(MARKS_DOCKER)
