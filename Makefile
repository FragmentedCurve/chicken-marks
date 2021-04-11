CHICKEN_CSC ?= chicken-csc
EGGS := openssl,http-client
CSC_FLAGS := -static -O3 -link $(EGGS)
#SSL_FLAGS :=  -L "$(shell pkg-config --libs openssl)"
SSL_FLAGS := -L "-lssl -lcrypto"
CSC_STATIC_FLAGS := -L "-static"

SOURCES := main.scm do-actions.scm bookie.scm config.scm subshell.scm key.scm utils.scm browser.scm
OBJECTS := $(SOURCES:.scm=.o)

MARKSEXE := marks
MARKS_STATIC := marks-static
MARKS_DOCKER := marks-docker

DOCKER := docker
STRIP := strip -s

.PHONY: static docker help

all: help

static: $(MARKS_STATIC)
docker: $(MARKS_DOCKER)

$(MARKSEXE): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

$(MARKS_STATIC): $(OBJECTS)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(CSC_STATIC_FLAGS) $(SSL_FLAGS) $(OBJECTS) -o $@

$(OBJECTS): $(SOURCES)
	$(CHICKEN_CSC) $(CSC_FLAGS) -c $(basename $@).scm

$(MARKS_DOCKER): $(SOURCES)
	$(DOCKER) build -t $(MARKS_DOCKER) .
	$(DOCKER) create --name $(MARKS_DOCKER) $(MARKS_DOCKER)
	$(DOCKER) cp $(MARKS_DOCKER):/marks/$(MARKS_STATIC) ./$(MARKS_DOCKER)
	$(DOCKER) rm $(MARKS_DOCKER)
	$(STRIP) $(MARKS_DOCKER)

help:
	@echo "Targets:"
	@echo "  marks         The default target which builds a dynamically linked executable."
	@echo "  static        Build a statically linked executable. (Might not work on some distros.)"
	@echo "  docker        Use Docker to build a statically linked executable instead of the host OS."
	@echo "  help          Print this."

clean:
	$(RM) $(OBJECTS:.o=.link) $(OBJECTS) $(MARKSEXE) $(MARKS_STATIC) $(MARKS_DOCKER)
