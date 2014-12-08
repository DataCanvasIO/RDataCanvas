

tar:
	git archive --format=tar --prefix=RDataCanvas-0.1/ HEAD | gzip >RDataCanvas-0.1.tar.gz

clean:
	rm -f RDataCanvas*.tar.gz

