;-----------------------------------------------------------------------------;
; Author: Ege Balcı (egebalci[at]pm[dot]me)
; Compatible: Windows 11, 10, 8.1, 8, 7, 2008, Vista
; Version: 1.0 (22 April 2023)
; Architecture: x64
; Size: 99 bytes
;-----------------------------------------------------------------------------;

[BITS 64]

; Windows x64 calling convention:
; http://msdn.microsoft.com/en-us/library/9b372w95.aspx

; Input: Normal function parameters in [RCX,RDX,R8,R9]+[STACK] and the function address in R10
; Output: If SN found, expected return value will be in RAX. If fails R10 will be -1
; Clobbers: RCX, RDX, R8, R9, R10, R11
; Un-Clobbered: RBX, RSI, RDI, RBP , R12, R13, R14, R15.

%define _SearchRange 100 ; Search range for syscall+ret instructions in bytes


syscall_api:
  pop r11                   ; Pop out the return address to R11
  call _syscall_api         ; Search for the SN
  test rax, rax             ; Check if we found the SN
  jz syscall_failed         ; SN could not be found
  mov r10, rcx              ; Move the first parameter into R10
  syscall                   ; Perform the syscamm
  push r11                  ; Push back the return address
  ret                       ; Return to caller
syscall_failed:
  xor r10, r10              ; Zero out R10
  dec r10                   ; R10 = -1
  push r11                  ; Push back the return address
  ret                       ; Return to caller with R10 = -1
_syscall_api:
  push rcx                  ; Save RCX
  push rbp                  ; Save RBP
  mov rbp, rsp              ; Create a new stack frame
  mov rcx, r10              ; Save the function address to RCX for range checking
  push r10                  ; Save one more copy to the stack for the second search
  add r10, _SearchRange     ; Add max address threshold 
find_syscall:
  cmp rcx, r10              ; Check if we are out of the search range
  jg sn_zero                ; If yes, bail out for preventing crash!
  mov eax, dword [rcx]      ; Read the first QWORD from function
  shl eax, 8                ; Discard the first byte
  cmp eax, 0xc3050f00       ; Check if syscall+ret
  jz found_syscall          ; Move to second part...
  inc rcx                   ; If not keep looking
  jmp find_syscall          ; Loopt until found...
found_syscall:
  pop r10                   ; Restore the saved function address to RDX
find_sn:
  ; Now we're looking for the "mov eax, ??" for extracting the syscall number
  cmp rcx, r10              ; Check if we are above the function address 
  jl sn_zero                ; If yes, bail out for preventing crash!
  mov rax, qword [rcx]      ; Read 8 bytes into RAX
  cmp eax, 0xb8d18b4c       ; Check if "mov r10, rcx + mov eax, ??"
  jz found_sn               ; If yes, we found the syscall number !!
  loop find_sn              ; Loop until found...
found_sn:
  shr rax, 32               ; Discard EAX and what you have left is 2 byte SN
  jmp not_found             ; Proudly exit...
sn_zero:
  xor rax,rax               ; Could not found the syscall number (SN=0)
not_found:
  mov rsp, rbp              ; Restore stack frame
  pop rbp                   ; Restore RBP
  pop rcx                   ; Restore RCX
  ret                       ; Return to caller 