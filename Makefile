ASFLAGS=
LDFLAGS=--nostd
AS=as
LD=ld

run: test
build: quine

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

quine: quine.o
	$(LD) $(LDFLAGS) $< -o $@
	chmod +x $@

.PHONY: test clean build run
test: quine
	./quine | diff quine.s - && echo "Both are equal!"

clean:
	rm *.o
	rm quine
