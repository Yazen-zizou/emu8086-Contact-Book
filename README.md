# Contact Book — 8086 Assembly

A console-based contact book written in **x86 (8086) assembly** for DOS, built with [emu8086](https://emu8086-microprocessor-emulator.en.softonic.com/). It stores up to 16 contacts in memory, keeps them **sorted alphabetically**, and validates phone numbers on input.

## Features

- **Add contact**: name + 10-digit phone number, inserted in alphabetical order
- **Search contact**: look up a contact by name
- **Display all**: list every contact in the book
- **Modify contact**: update the phone number of an existing contact
- **Delete contact**: remove a contact and shift the remaining entries
- **Input handling**
  - Names are normalized to lowercase (case-insensitive search and duplicate detection)
  - Phone numbers must be exactly 10 digits; invalid input is rejected and re-requested
  - Duplicate names are refused
  - Clear messages when the book is empty, full, or a contact isn't found

## Menu

```
---------Contact Book--------------

1. Add contact
2. Search contact
3. Display all
4. Modify contact
5. Delete contact
6. EXIT

---------------------------------
```

## Memory layout

Contacts are stored in a fixed-size array of **16 entries × 22 bytes**:

| Offset | Size     | Content                   |
|--------|----------|---------------------------|
| 0      | 10 bytes | Name                      |
| 10     | 1 byte   | `$` terminator            |
| 11     | 10 bytes | Phone number              |
| 21     | 1 byte   | `$` terminator            |

The `$` terminators allow entries to be printed directly with DOS `INT 21h / AH=09h`.

## Procedures

| Procedure       | Role                                                         |
|-----------------|--------------------------------------------------------------|
| `MAIN`          | Menu loop and dispatch                                       |
| `MENU`          | Prints the menu                                              |
| `READ_NAME`     | Reads a name via buffered input (`INT 21h / AH=0Ah`) into `temp1` |
| `TREAT_NAME`    | Converts uppercase letters to lowercase                      |
| `READ_PHONE`    | Reads and validates a 10-digit phone number into `temp2`     |
| `ADD_CONTACT`   | Finds the sorted position, shifts entries, inserts the contact |
| `SEARCH`        | Linear search by name                                        |
| `DISPLAY`       | Prints one contact (address passed on the stack)             |
| `VIEW_ALL`      | Iterates and displays all contacts                           |
| `MODIFY`        | Replaces the phone number of a contact                       |
| `DELETE`        | Removes a contact by shifting following entries up           |
| `RESET_BUFFER`  | Clears the input buffer between reads                        |
| `WAIT_P`        | "Press any key…" pause                                       |

## Getting started

### Requirements

- [emu8086](https://emu8086-microprocessor-emulator.en.softonic.com/) (or any 8086 emulator/assembler supporting the same syntax, e.g. MASM/TASM with minor adjustments)

### Run

1. Open `contact_book.asm` in emu8086.
2. Click **Compile** then **Run** (or press `F5`).
3. Use the number keys `1`–`6` to navigate the menu.

## Example session

```
Enter name of contact
alice

Enter phone of contact
0555123456

The contact is added successfully
```

## Known limitations

- Maximum of **16 contacts**, names limited to **10 characters**
- Phone numbers must be exactly 10 digits
- Only lowercase conversion for `A–Z` (no accented characters)
- Data is held in memory only and is lost when the program exits
- Alphabetical ordering compares the first differing character only when inserting

## Ideas for improvement

- Persist contacts to a file using DOS file interrupts (`INT 21h`)
- Support longer names and international phone formats
- Add search by phone number or partial name
- Fix name-sorting edge cases for names sharing a long prefix

## Concepts practiced

String instructions (`MOVSB`, `CMPSB`, `STOSB`, `REP`), direction flag handling, stack-based parameter passing, DOS interrupts, fixed-size record arrays, and in-memory insertion/deletion.

## License

Released under the [MIT License](LICENSE).
