CHICKEN_CSC ?= chicken-csc
EGGS := openssl,http-client
CSC_FLAGS := -static -O3 -link $(EGGS)
SSL_FLAGS :=  -L "$(shell pkg-config --libs openssl)"

SOURCES := main.scm do-actions.scm bookie.scm config.scm subshell.scm key.scm utils.scm browser.scm
OBJECTS := $(SOURCES:.scm=.o)
MARKSEXE := marks

all: $(MARKSEXE)

$(MARKSEXE): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

$(OBJECTS): $(SOURCES)
	$(CHICKEN_CSC) $(CSC_FLAGS) -c $(basename $@).scm

clean:
	$(RM) $(OBJECTS:.o=.link) $(OBJECTS) $(MARKSEXE)
