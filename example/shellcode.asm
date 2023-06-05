[BITS 64]


_start:
  push rbp
  mov rbp, rsp                     ; New stack frame

  mov r10d, 0xF03F2E65             ; Move the CRC32 hash into R10 = crc32("NTDLL.DLL", "NtDelayExecution")
  call api_call                    ; Get the address of NtDelayExecution into RAX
  
  add rsp, 40                      ; Allocate some space for fastcall conv.
  mov rdx, 0xFFDFC7C9FFFFFFFF      ; Move the LARGE_INTEGER delayTime value into RDX
  push rdx                         ; Push delayTime
  mov rdx, rsp                     ; RDX = &delayTime
  mov rcx, 0                       ; bAlertable = FALSE

  mov r10, rax                     ; Move the address of NtDelayExecution function into R10
  call syscall_api                 ; NtDelayExecution(RCX, RDX)

  mov rsp, rbp                     ; Restore the stack frame
  pop rbp                          ; Restore RBP
  ret                              ; Return to caller
  %include "../syscall_api.asm"
  %include "crc32_api_x64.asm"