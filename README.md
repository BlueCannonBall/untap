# Untap

A simple program to fix doubled key presses on macOS using just software.

## Installation

Download this GitHub repo, cd to its folder in Terminal, and then run `make` in Terminal to build it. Then run `sudo make install` in Terminal to install it. Your password may be required.

## Usage

Run `untap` in Terminal. By default, it will ignore keypresses within a millisecond of each other. You can change this amount by running Untap with arguments. Examples:

```sh
untap 1000    # 1 millisecond (the number is in microseconds)
untap 10000   # 10 milliseconds
untap 1000000 # 1 second (I don't recommend such a high number)
```