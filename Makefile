CHICKEN_CSC ?= chicken-csc
EGGS := openssl http-client
CSC_FLAGS := -static -O3  $(foreach egg, $(EGGS), -link $(egg) -R $(egg))
SSL_FLAGS :=  -L "$(shell pkg-config --libs openssl)"


SOURCES=main.scm do-actions.scm bookie.scm config.scm subshell.scm key.scm utils.scm

all: marks

marks: $(SOURCES)
	$(CHICKEN_CSC) $(CSC_FLAGS) $(SSL_FLAGS) -o $@ $(SOURCES)

clean:
	rm -f *.link *.o marks
