# gas-hexprint-example

Example program to print hexadecimal values x86-64 GAS assembler

# Description

A friend was trying the GNU Assembler (gas).
Our discussion inspired me to try the GAS assembler at the same time.
I have previously used NASM assembler, but the gas assembler.
This was my first time with gas and x86-64. I found gas syntax is quite different from NASM.

In this example, some 64 bit registers are printed in hexadecimal and 
base 10 decimal using pure assembly language.

No external libraries were used. This was a learning exercise so there could be beginner errors.

# To clone the repo

This was written in Debian 11 running in a 64 bit virtual machine
that was on a laptop with an i7 processor.
If you are missing the assembler or make, you can probably
install those using `apt-get install build-essential`.
I recommend setup Debian or Ubuntu in a isolated VM.

- 1) Clone the repository and change the working directory to the repository folder.

```
git clone https://github.com/cotarr/gas-hexprint-example.git
cd gas-hexprint-example
```

- 2) Compile the program by typing `make`. Check the output for errors

```
$ make
as --64 -g -o example.o example.asm -a=example.lst
as --64 -g -o io.o io.asm -a=io.lst
as --64 -g -o util.o util.asm -a=util.lst
ld -melf_x86_64 -o example example.o io.o util.o
$
```

- 3) Run the example by typing `./example`. The following output should print to stdout.

```
$ ./example
Print one character:
M
Print null terminated string:
Hello world!
Print one byte (0x55) in hexadecimal:
55
Print one 64 bit word (0x0123456789ABCDEF) in hexadecimal:
0123456789ABCDEF
Convert 64 bit unsigned word (0x000000000000FFFF) to base 10 decimal and print:
65535
Print 0xFFFFFFFFFFFFFFFF in hexadecimal (prepend "0x"), then in base 10 decimal
0xFFFFFFFFFFFFFFFF
18446744073709551615
$
```

That's all, some hex is printed...
