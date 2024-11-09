/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory  */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Jackson Adams"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
.global cipherText
.type cipherText,%gnu_unique_object

.align
 
@ NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
@ TODO: create a .h file that handles both C and assembly syntax for this definition
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

    
/********************************************************************
function name: asmEncrypt
function description:
     pointerToCipherText = asmEncrypt ( ptrToInputText , key )
     
where:
     input:
     ptrToInputText: location of first character in null-terminated
                     input string. Per calling convention, passed in via r0.
     key:            shift value (K). Range 0-25. Passed in via r1.
     
     output:
     pointerToCipherText: mem location (address) of first character of
                          encrypted text. Returned in r0
     
     function description: asmEncrypt reads each character of an input
                           string, uses a shifted alphabet to encrypt it,
                           and stores the new character value in memory
                           location beginning at "cipherText". After copying
                           a character to cipherText, a pointer is incremented 
                           so that the next letter is stored in the bext byte.
                           Only encrypt characters in the range [a-zA-Z].
                           Any other characters should just be copied as-is
                           without modifications
                           Stop processing the input string when a NULL (0)
                           byte is reached. Make sure to add the NULL at the
                           end of the cipherText string.
     
     notes:
        The return value will always be the mem location defined by
        the label "cipherText".
     
     
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
    
    LDR r5,=cipherText
    ADD r5,100
    LDR r6,=0x2A
    STR R6,[r5]
    
    
    /* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
    
    ldr r10, =cipherText /* get the mem address for where to store the value */
   

    
/* get the ascii value */
get_Ascii_Value:
    /* compare the value to other known values */
    ldr r4, =0 /* this is the null terminator value for ascii */
    ldr r5, =65 /* this is the lowest value of the upper case letters */
    ldr r6, =89 /* this is the second largest value of the upper case letters */
    ldr r7, =97 /* this is the lowest value of the lower case letters */
    ldr r8, =121 /* this is the largest value of the lower case letters */
    
    ldrb r9, [r0], #1 /* at the given mem address take the first byte of the input, post-increment the address by 1bit */
    /* if the value is between 65 and 89 then the value is an upper case letter and needs to be encrypted */
    cmp r9, r4 /* compare the the given value to the null terminator */
    beq end_Encryption /* if the value is the null terminator then leave the encryption */
    cmp r1, r4 /* checks if the 'K' is 0, if it is there is no need to encrypt */
    beq store_Value /* the 'K' is 0 so just store each value */
    cmp r9, r5 /* compare the value to 65 */
    blo store_Value /* the given value is not a upper case letter, so just store the value */
    cmp r9, r6 /* compare the value to 89 */
    bls encrypt_Upper_Value /* the value is at least 'Y', so it can be encrypted */
    add r6, #1 /* make r6 equal to 90 so that 'Z' can be compared to it */
    cmp r9, r6 /* compare the the given value to 90 */
    beq wrap_Upper
    /* the value was not one of the upper case ascii char */
    cmp r9, r7 /* compare the value to 97 */
    blo store_Value /* the value is lower than the lowest lower case value */
    cmp r9, r8 /* compare the value to the second lowest lower case value */
    bls encrypt_Lower_Value /* the value is at least 'y', so it can be encrypted */
    add r8, #1 /* make the r8 equal to 122 so that 'z' can be compared to it */
    cmp r9, r8 /* compate the given value to 122 */
    beq wrap_Lower
    
    
/* store the value */
store_Value:
    strb r9, [r10], #1 /* store encrypted value, post-increment the mem address */
    b get_Ascii_Value /* loop back and get the next ascii value */

    
/* encrypt the upper value */
encrypt_Upper_Value:
    add r9, r1 /* add the shift value to the given value, it is now encrypted */
    b store_Value /* now store the encrypted value */
    
    
/* encrypt the lower value */    
encrypt_Lower_Value:
    add r9, r1 /* add the shift value to the given value, it is now encrypted */
    b store_Value /* now store the encrypted value */

    
/* the given value was 'Z', so it needs to be wrapped back to the start of the alphebet */    
wrap_Upper:
    ldr r9, =64 /* return the value right before the start of the alphebet */
    add r9, r1 /* from the begining of the alphebet shift the value */
    b store_Value /* store the value */
    
    
/* the given value was 'z', so it needs to be wrapped back to the start of the alphebet */    
wrap_Lower:
    ldr r9, =96 /* return the value right before the start of the alphebet */
    add r9, r1 /* from the begining of the alphebet shift the value */
    b store_Value /* store the value */    
    

/* the end of the string was found */    
end_Encryption:  
    ldr r4, =0
    strb r9, [r10]
    ldr r0, =cipherText
 
    
    /* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

    /* restore the caller's registers, as required by the ARM calling convention */
    pop {r4-r11,LR}

    mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




