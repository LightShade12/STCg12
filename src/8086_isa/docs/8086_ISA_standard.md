
Please write comments on top of functions that mention:
    method of argument passing (stack/register) (if any)
    return value (if any)
    registers for the caller to save (if any) (these are called 'scratch registers')

e.g:

cdecl int computeMean(data, size) <br>
returns 16-bit mean value <br>
args: data: 16-bit array start index from DS; pass in AX <br>
        size: 16-bit array length value; pass in BX <br>
scratch registers: AX, BX, DX <br>


Just to note,
we will use "cdecl" order of argument passing to functions for the sake of consistency. Find cdecl below if you are unsure of what cdecl convention is.

//==================================================================================================================================

# Function calling conventions:

Calling conventions in 8086 assembly language define the standardized way that procedures (or functions) exchange information with the code that calls them. This includes how arguments are passed to the procedure, how return values are sent back, and how registers and the stack are managed to ensure proper execution and avoid conflicts.

While there wasn't a single, universally mandated calling convention across all 8086 development environments and compilers, some common practices and conventions emerged, particularly in the context of DOS programming.

Here are the key aspects of typical 8086 calling conventions:

## 1. Argument Passing:

### Via the Stack:

 This is the most common method for passing multiple arguments.

Arguments are typically pushed onto the stack by the caller before the CALL instruction.
The order of pushing arguments can vary depending on the convention. Common orders include:

#### Right-to-Left (like C's cdecl):
 The last argument is pushed first, and the first argument is pushed last. This allows functions with a variable number of arguments.
#### Left-to-Right (like Pascal):
 The first argument is pushed first, and the last argument is pushed last.
Within the called procedure, arguments are accessed from the stack relative to the stack pointer (SP) or the base pointer (BP), which is often used to establish a stable frame pointer for accessing parameters and local variables.

### Via Registers:
 For a small number of arguments, passing them directly in registers is the fastest method. The specific registers used can vary by convention or the procedure's design. Common registers used for passing arguments include AX, BX, CX, and DX.


## 2. Return Value:

Return values are typically placed in the AX register for 8-bit or 16-bit values.
For 32-bit return values, the DX:AX pair is commonly used, with the higher 16 bits in DX and the lower 16 bits in AX.

Larger return values or structures might be returned via a pointer passed as an argument on the stack.


## 3. Stack Management:

The CALL instruction automatically pushes the return address (the address of the instruction immediately following the CALL) onto the stack before transferring control to the called procedure.

The RET instruction at the end of the procedure pops the return address from the stack and transfers control back to the caller.

### Stack Cleanup:
 This is a crucial part of the convention and determines who is responsible for removing the arguments from the stack after the procedure returns:
Caller Cleanup (cdecl): The caller is responsible for adjusting the stack pointer after the CALL returns to remove the arguments that were pushed. This is necessary for variable-argument functions.

### Callee Cleanup (Pascal, stdcall):
 The called procedure is responsible for removing the arguments from the stack before executing the RET instruction, often by using a variant of RET with an immediate value indicating the number of bytes to pop from the stack. This results in slightly smaller calling code but requires the callee to know the size of the arguments.

## 4. Register Preservation:

Calling conventions often define which registers a called procedure must preserve (keep unchanged) and which it is allowed to modify ("scratch" registers).

### Caller-Save Registers: 
These are registers whose values the caller must save (usually by pushing them onto the stack) before making a call if the caller needs their values after the call returns. AX, CX, and DX are often considered caller-save registers.
### Callee-Save Registers:
 These are registers whose values the called procedure must save upon entry (by pushing them onto the stack) and restore before returning if it intends to modify them. BX, BP, SI, and DI are typically considered callee-save registers. The stack pointer (SP) and base pointer (BP) are almost always preserved by the callee to maintain the integrity of the stack frame.

In the context of simple 8086 .COM programs written purely in assembly, the calling convention might be less rigid and more dependent on the programmer's design choices. However, when interfacing with libraries, the operating system (DOS), or code written in higher-level languages compiled for 8086, adhering to a defined calling convention becomes essential for interoperability. The cdecl and Pascal conventions were common influences in the 8086 era.