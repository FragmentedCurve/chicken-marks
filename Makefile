sources=main.scm do-actions.scm bookie.scm config.scm subshell.scm

marks: $(sources)
	chicken-csc -o marks $(sources)

clean:
	rm -f *.link marks
