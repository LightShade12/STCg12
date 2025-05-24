# STCg12 - STatistical Calculator from Group 12
COA group 12 software project repository

## STCg12

## Introduction:
The STCg12 (Statistical Calculator from Group 12) is a calculator program oriented to very basic statistical computations.
The program specifically computes various statistical interpretations, of a specific population as specified by the program user.

The various statistical data computed by our program include:
- Count
- Mean
- Median
- Mode
- Min value
- Max value
- Standard deviation
- Variance

Our program collects population data from the user, then computes the 8 basic statistical dimensions of a population and displays the 
output (on supported languages).

## Technical:
The program has implementations in 3 languages:
- C 17
- ARMv4T Assembly (WIP)
- x86-16 Assembly

### Platforms:
The C17 implementation can be compiled to any target platform via a suitable compiler. It is tested on AMD64 platform on an Intel Core i7 10750H CPU on Windows 10, built by clang 18.1.8.

The x86-16 ISA assembly implementation is tailored for the Intel 8086 microprocessor.

The ARMv4T ISA assembly implementation is tailored for the ARM7TDMI microprocessor.
