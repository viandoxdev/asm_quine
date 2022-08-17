# A quine in x86 asm, nostd, linux only

# Annotated

The quine works by having the code twice: once as code (that is assembled to opcodes), and once as a string with lines separated by null bytes.
The code then prints this string part by part once, printing a new line in between (symbol `n`). It then prints the string `.asciz "` (that you'll find at the begining of the last line)
(symbol `b`), continues by going over each part again, this time printing `\0` (symbol `o`) in between, and finishes by printing `"\n` (symbol `e`)
and exiting (calling SYS_EXIT with an error code of 0).

Some strings are encoded as decimal (with `.byte`) instead of as ascii (with `.ascii`/`.asciz`) because they contain caracters that would otherwise need escaping.
This is problematic since the printed code would be valid, but the printed string (the final one) wouldn't. For example the line:
```asm
b: .ascii ".asciz \""
```
would need to be put in the string as
```asm
"...\0b: .ascii \".asciz \\\"\"\0..."
```
which would print, on the first pass
```asm
b: .ascii ".asciz \""
```
but then on the second pass the string would be reconstructed as
```asm
"...\0b: .ascii ".asciz \""\0..."
```
which is wrong.

```asm
# a macro that sends a write syscall
# no need to set stdout as it is set at the begining of _start, and %rdi is never touched
.macro k
movq $1,%rax
syscall
.endm
# p is a function that simply prints the null terminated string in %rsi, advancing rsi to the
# next string
p:movq %rsi,%rdx
# l here is just the label for the loop that counts the length of the string
l:incq %rdx
cmpb $0,(%rdx)
jnz l
subq %rsi,%rdx
k
# length is added to rsi, which now points at the null terminator
addq %rdx,%rsi
# and now at the next string
incq %rsi
ret
# v is a function that calls a write syscall of the char* in %r9, with the lenght of %rdx
# without overwriting %rsi, which holds the pointer to the current line/part
v:movq %rsi,%r8
movq %r9,%rsi
k
movq %r8,%rsi
ret
# _start: the entry point
.globl _start
# move $1 (STDOUT) to %rdi once (stays for the entire lifetime of the process)
# we can't do the same with $1 (SYS_WRITE) in rax, since syscall cobblers it
_start:movq $1,%rdi
# put the pointer to the first line/part in rsi
leaq a(%rip),%rsi
# c is the loop for the first pass
c:call p # print the line
# print a new line
leaq n(%rip),%r9
movq $1,%rdx
call v
# the lines are terminated with '\0', and the entire buffer is terminated by `\0\0`
cmpb $0,(%rsi)
# loop until we're done
jne c
# print '.asciz "'
leaq b(%rip),%rsi
movq $8,%rdx
k
# go back to the first part/line
leaq a(%rip),%rsi
# m is the loop for the second pass
m:call p # print it
# this time we print '\0'
leaq o(%rip),%r9
movq $2,%rdx
call v
cmpb $0,(%rsi)
jne m
# print the the closing quote and a new line
leaq e(%rip),%rsi
movq $2,%rdx
k
# gracefully exit
movq $60,%rax
movq $0,%rdi
syscall
n:.byte 10 # .ascii "\n"
o:.byte 92,48 # .ascii "\\0"
e:.byte 34,10 # .ascii "\"\n"
b:.byte 46,97,115,99,105,122,32,34 # .ascii ".asciz \""
a: # the newline is needed here since the "a:" is the last part of the buffer, it will be finished by a newline after the first pass
.asciz ".macro k\0movq $1,%rax\0syscall\0.endm\0p:movq %rsi,%rdx\0l:incq %rdx\0cmpb $0,(%rdx)\0jnz l\0subq %rsi,%rdx\0k\0addq %rdx,%rsi\0incq %rsi\0ret\0v:movq %rsi,%r8\0movq %r9,%rsi\0k\0movq %r8,%rsi\0ret\0.globl _start\0_start:movq $1,%rdi\0leaq a(%rip),%rsi\0c:call p\0leaq n(%rip),%r9\0movq $1,%rdx\0call v\0cmpb $0,(%rsi)\0jne c\0leaq b(%rip),%rsi\0movq $8,%rdx\0k\0leaq a(%rip),%rsi\0m:call p\0leaq o(%rip),%r9\0movq $2,%rdx\0call v\0cmpb $0,(%rsi)\0jne m\0leaq e(%rip),%rsi\0movq $2,%rdx\0k\0movq $60,%rax\0movq $0,%rdi\0syscall\0n:.byte 10\0o:.byte 92,48\0e:.byte 34,10\0b:.byte 46,97,115,99,105,122,32,34\0a:\0"
```
