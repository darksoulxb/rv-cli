rv_cli
[![asciicast](https://asciinema.org/a/MEhe9qaUFcbrYWyO.svg)](https://asciinema.org/a/MEhe9qaUFcbrYWyO)


## Why rv-cli?

- Stop digging through your shell history for that one complicated-long command you ran ages ago. *rv-cli* is a minimal, local-first command manager that turns long, chained terminal strings into single-word shortcuts. 
- it ensures your command database never gets corrupted, even if your terminal crashes or your system loses power mid-save.
- No background daemons or heavy databases; just a lightweight JSON store.

## Features
- Zero-Latency: No background daemons or heavy databases; just a lightweight JSON store.
- Atomic Persistence: Uses temporary file swapping to guarantee data integrity.
- Chained Execution: Supports saving multiple commands under one command.
- Path-Aware: Designed to work seamlessly with Fish, Zsh, and Bash.

## Installation

**Clone the repository:**

   git clone [https://github.com/darksoulxb/rv-cli.git](https://github.com/darksoulxb/rv-cli.git)

   
   cd rv-cli

_fast, no-bs, zero-latency command-line manager built in Python_
