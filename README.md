# weather-fortran

`weather_analysis.f90` reads hourly weather observations from `weather_dummy_data.csv` and prints each record.

## Key concepts

### Unit numbers

Fortran refers to an open file by an integer "unit" number. There is no file handle object.

```fortran
open(unit=10, file='weather_dummy_data.csv', ...)   ! attach the file to unit 10
read(10, ...)                                       ! read from that same file
```

Units 5 and 6 are usually reserved for keyboard input and screen output, so use 10 or higher. In modern Fortran, `open(newunit=u, ...)` lets the compiler choose a free unit and stores it in `u`.

### `open` arguments

| Argument        | Meaning                                                  |
|-----------------|----------------------------------------------------------|
| `unit=10`       | Refer to this file as unit 10 from now on                |
| `file='...'`    | Path of the file to open                                 |
| `status='old'`  | The file must already exist (error if it doesn't)        |
| `action='read'` | Open read-only                                           |
| `iostat=ios`    | Store a success/failure code in `ios` instead of crashing |

### `iostat=` and `ios`

`iostat=` is an optional argument to `open`, `read`, `write` and `close`. It tells the compiler not to stop the program when an I/O problem occurs, and to put a status code in the given integer variable instead. `ios` is just the variable name used here; it is short for "I/O status".

| Value of `ios` | Meaning                                         |
|----------------|-------------------------------------------------|
| `ios == 0`     | Success                                         |
| `ios < 0`      | End-of-file (or end-of-record) reached          |
| `ios > 0`      | Error (file not found, bad data, etc.)          |

Without `iostat=`, any of these conditions would end the program. If you prefer a named constant to `ios < 0`, the intrinsic module `iso_fortran_env` provides `iostat_end`, so you can write `if (ios == iostat_end)`.

### Format descriptors

The format string in a `read` or `write` statement (the text inside `'( ... )'`) states how many characters each value occupies on the line and how to interpret those characters.

| Descriptor | Meaning                                                       | Example    |
|------------|---------------------------------------------------------------|------------|
| `A`        | Character data; reads the whole field into a string           |            |
| `A32`      | Character data exactly 32 characters wide                     |            |
| `I4`       | Integer, 4 characters wide                                    | `2026`     |
| `I2`       | Integer, 2 characters wide                                    | `17`       |
| `F6.1`     | Real, 6 characters wide in total, 1 digit after the decimal point | `1018.0` |
| `F5.1`     | Real, 5 characters wide, 1 digit after the decimal point      | ` 81.8`    |

The general form is `Iw` (integer, width `w`) and `Fw.d` (real, width `w`, `d` decimal places). The width counts every character, including spaces, minus signs and the `.`, so the columns in the file must line up exactly.

In the main loop, each descriptor is matched in order to one variable:

```fortran
read(10, '(I4, A32, I4, I2, I2, I2, F6.1, F5.1, F6.1, F5.1)', iostat=ios) &
    station_id, name, year, month, day, hour, temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c
```

| Descriptor | Variable           |
|------------|--------------------|
| `I4`       | `station_id`       |
| `A32`      | `name`             |
| `I4`       | `year`             |
| `I2`       | `month`            |
| `I2`       | `day`              |
| `I2`       | `hour`             |
| `F6.1`     | `temp_c`           |
| `F5.1`     | `rel_humidity_pct` |
| `F6.1`     | `pressure_hpa`     |
| `F5.1`     | `dewpoint_c`       |

### `'(A)'`: reading a whole line

`read(10, '(A)', iostat=ios) line` reads the entire line as a single string. The program uses it to skip the CSV header: it reads the header into `line` and then ignores it.

### List-directed I/O: `*`

In `read(10, *)` or `print *, ...`, the `*` means "use default formatting". On input, the values are split on commas or spaces and converted to the type of each variable. This is usually the better choice for CSV files, because the columns don't need fixed widths.

### Declarations

- **`implicit none`**: every variable must be declared. Without it, Fortran's old implicit typing rule applies: any undeclared name starting with I through N is an integer, and any other name is a real. A typo then silently creates a new variable.
- **`character(len=N)`**: a fixed-length string of N characters. Shorter values are padded with trailing blanks, which is why `trim()` is used when printing.
- **`integer`**: whole numbers.
- **`real`**: single-precision floating point by default, about 7 significant digits.

### Variables

| Variable           | Type              | Meaning                                         |
|--------------------|-------------------|-------------------------------------------------|
| `line`             | `character(256)`  | Buffer for one whole line (used for the header) |
| `name`             | `character(32)`   | Station name                                    |
| `station_id`       | `integer`         | Station identifier                              |
| `year`, `month`, `day`, `hour` | `integer` | Observation timestamp                     |
| `u`                | `integer`         | Spare unit-number variable (currently unused)   |
| `ios`              | `integer`         | I/O status code returned through `iostat=`      |
| `temp_c`           | `real`            | Air temperature, °C                             |
| `rel_humidity_pct` | `real`            | Relative humidity, % (0–100)                    |
| `pressure_hpa`     | `real`            | Air pressure, hPa (1 hPa = 1 millibar)          |
| `dewpoint_c`       | `real`            | Dew point temperature, °C                       |

### Other syntax

- **`&`**: line continuation; the statement continues on the next line.
- **`do` ... `end do` with no counter**: an infinite loop. `exit` breaks out of it.
- **`trim(name)`**: returns `name` without its trailing blanks.
- **`close(10)`**: releases the unit when you are done with it. The program doesn't do this yet; it is good practice to add it.

## Known issue

The fixed-width format in the `read` statement doesn't match `weather_dummy_data.csv`:

- The CSV has no station name column. Its columns are `station_id,year,month,day,hour,temp_c,rel_humidity_pct,pressure_hpa,dewpoint_c`.
- The CSV is comma-separated, and its fields vary in width (`1,2026,11,17,0,5.1,...`).

As a result, reading the data rows fails and the loop exits without printing anything. To fix it, remove `name` and use list-directed input:

```fortran
read(10, *, iostat=ios) station_id, year, month, day, hour, &
    temp_c, rel_humidity_pct, pressure_hpa, dewpoint_c
```
