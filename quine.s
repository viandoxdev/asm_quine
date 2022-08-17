.macro k
movq $1,%rax
syscall
.endm
p:movq %rsi,%rdx
l:incq %rdx
cmpb $0,(%rdx)
jnz l
subq %rsi,%rdx
k
addq %rdx,%rsi
incq %rsi
ret
v:movq %rsi,%r8
movq %r9,%rsi
k
movq %r8,%rsi
ret
.globl _start
_start:movq $1,%rdi
leaq a(%rip),%rsi
c:call p
leaq n(%rip),%r9
movq $1,%rdx
call v
cmpb $0,(%rsi)
jne c
leaq b(%rip),%rsi
movq $8,%rdx
k
leaq a(%rip),%rsi
m:call p
leaq o(%rip),%r9
movq $2,%rdx
call v
cmpb $0,(%rsi)
jne m
leaq e(%rip),%rsi
movq $2,%rdx
k
movq $60,%rax
movq $0,%rdi
syscall
n:.byte 10
o:.byte 92,48
e:.byte 34,10
b:.byte 46,97,115,99,105,122,32,34
a:
.asciz ".macro k\0movq $1,%rax\0syscall\0.endm\0p:movq %rsi,%rdx\0l:incq %rdx\0cmpb $0,(%rdx)\0jnz l\0subq %rsi,%rdx\0k\0addq %rdx,%rsi\0incq %rsi\0ret\0v:movq %rsi,%r8\0movq %r9,%rsi\0k\0movq %r8,%rsi\0ret\0.globl _start\0_start:movq $1,%rdi\0leaq a(%rip),%rsi\0c:call p\0leaq n(%rip),%r9\0movq $1,%rdx\0call v\0cmpb $0,(%rsi)\0jne c\0leaq b(%rip),%rsi\0movq $8,%rdx\0k\0leaq a(%rip),%rsi\0m:call p\0leaq o(%rip),%r9\0movq $2,%rdx\0call v\0cmpb $0,(%rsi)\0jne m\0leaq e(%rip),%rsi\0movq $2,%rdx\0k\0movq $60,%rax\0movq $0,%rdi\0syscall\0n:.byte 10\0o:.byte 92,48\0e:.byte 34,10\0b:.byte 46,97,115,99,105,122,32,34\0a:\0"
