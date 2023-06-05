#!/bin/bash
## ANSI Colors (FG & BG)
RED="$(printf '\033[31m')" GREEN="$(printf '\033[32m')" YELLOW="$(printf '\033[33m')" BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')" CYAN="$(printf '\033[36m')" WHITE="$(printf '\033[37m')" BLACK="$(printf '\033[30m')"
REDBG="$(printf '\033[41m')" GREENBG="$(printf '\033[42m')" YELLOWBG="$(printf '\033[43m')" BLUEBG="$(printf '\033[44m')"
MAGENTABG="$(printf '\033[45m')" CYANBG="$(printf '\033[46m')" WHITEBG="$(printf '\033[47m')" BLACKBG="$(printf '\033[40m')"
RESET="$(printf '\e[0m')"

print_warning() {
  echo ${YELLOW}"[!] ${RESET}${1}"
}
print_error() {
  echo "${RED}[-] ${RESET}${1}"
}
print_fatal() {
  echo -e ${RED}"[!] $1\n${RESET}"
  kill -10 $$
}
print_good() {
  echo "${GREEN}[+] ${RESET}${1}"
}
print_status() {
    echo "${YELLOW}[*] ${RESET}${1}"
}
must_exist() {
  for i in "$@"; do
    command -v $i >/dev/null || print_fatal "$i not installed! Exiting..."
  done
}

must_exist "nasm" "wget" "x86_64-w64-mingw32-gcc" "xxd"
[[ ! -f crc32_api_x64.asm ]] && wget https://raw.githubusercontent.com/EgeBalci/crc32_api/master/crc32_api_x64.asm &>/dev/null
nasm -f bin shellcode.asm -o shellcode || print_fatal "nasm assembly failed!"
[[ -f shellcode ]] && xxd -i shellcode shellcode.h
x86_64-w64-mingw32-gcc stub.c -o example.exe || print_fatal "Compilation failed!"
rm shellcode shellcode.h
print_warning "Do NOT!! use wine for running the example. It won't work cuz raw syscalls ¯\_(ツ)_/¯"
print_good "Example built! -> example.exe" 
