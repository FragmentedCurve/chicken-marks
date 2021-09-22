EGGS      := openssl http-client srfi-1 linenoise ansi-escape-sequences
CSC_FLAGS := -static -O3 $(foreach egg,$(EGGS),-link $(egg))
SSL_FLAGS := -L "-lssl -lcrypto"

include config.mk

CHICKEN_CSC      ?= csc
CHICKEN_INSTALL  ?= chicken-install

SOURCES := main.scm do-actions.scm bookie.scm config.scm subshell.scm key.scm utils.scm browser.scm
OBJECTS := $(SOURCES:.scm=.o)

MARKSEXE := marks

%.o: %.scm
	$(CHICKEN_CSC) $(CSC_FLAGS) -c $(basename $@).scm

$(MARKSEXE): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

eggs:
	$(CHICKEN_INSTALL) $(EGGS)

clean:
	$(RM) $(OBJECTS:.o=.link) $(OBJECTS) $(MARKSEXE)
