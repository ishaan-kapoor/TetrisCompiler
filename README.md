# Tetris Compiler

This project translates our custom Tetris configuration language instructions to python code.

**Everything** is made programmable by the game programmer (using the configuration language) by exposing *all* game variables.

<details><summary>Check detailed explanation of grammar here</summary>
<ul>
<li><h6>Section 1</h6></li>
<li>PRIMITIVE→id=EXPR newline PRIMITIVE | ϵ</li>
<li><h6>Section 2</h6></li>
<li>FUNCTIONS→FUNCTION newline FUNCTIONS | ϵ</li>
<li>FUNCTION→{id BODY}</li>
<li>BODY→STATEMENT BODY | STATEMENT</li>
<li>STATEMENT→IFSTATEMENT | WHILELOOP | id = EXPR | return EXPR</li>
<li>IFSTATEMENT→if ( EXPR ) then STATEMENT end | if ( EXPR ) then STATEMENT else STATEMENT end</li>
<li>WHILELOOP→while ( EXPR ) STATEMENT end</li>
<li>EXPR→ARITHLOGIC | [call id] | [call id with PARAM PARAMLIST]</li>
<li>ARITHLOGIC→TERM ARITH1</li>
<li>TERM→FACTOR TERM1</li>
<li>ARITH1→+ TERM ARITH1 | - TERM ARITH1 | or TERM ARITH1 | ϵ</li>
<li>FACTOR→id | num | ( EXPR ) | ( neg EXPR ) | ( not EXPR )</li>
<li>TERM1→* FACTOR TERM1 | and FACTOR TERM1 | ϵ</li>
<li>PARAM→id = EXPR</li>
<li>PARAMLIST→PARAM PARAMLIST | ϵ</li>
<li><h6>Section 3</h6></li>
<li>ENGINE→[play] | [play with PARAM PARAMLIST]</li>
</ul>
</details>

### Installation and Setup

###### 1. **Install dependencies**:
- `python` for running the output Tetris game executable.
  - install `python-tk` (tkinter) and `numpy` as well
- `flex` and `bison` for generating the scanner and parser files (generating `.c` from `.l` and `.y`)
- `gcc` for compiling the scanner and parser files into compiler.

###### 2. **Unpack the Package**:
Download and unzip the project package.

###### 3. **Build the compiler**:
Run `make` to compile the compiler.
Now you will have the executable `x2021A7PS2091G` in the project directory.

###### 4. **Compile your program into a Tetris game**:
```sh
make INPUT_FILE=program.tetris run
python output.py
```
Alternatively, you can manually compile your program with the following commands:
```sh
make
./x2021A7PS2091G < program.tetris > output.py
python output.py
```
> You might need to use `python3` instead of `python` to run the program.
replace `program.tetris` with your program file.

If you use `make run` without specifying the `INPUT_FILE`, then it uses `testinput.tetris` as the default input file.

## Examples
I have added some example programs in the directory `examples` for you to try out and get a feel of the possibilities.
###### Limit Rotations:
```
Section1

allowed_rotations = 2

Section2

# Could have added >= in scanner but this way, the capabilities of the compiler are more evident
{ rotate if ((engine.rotations > engine.allowed_rotations) or (engine.rotations == engine.allowed_rotations)) then return [ call Print with value = -1.1 ] end engine.rotations = engine.rotations + 1 [ call rotate_CW ] }

Section3

[ play ]
```

This doesn't let the player indefinitely rotate the extetromenones.
Each extetromenone can be rotated only twice in my example, the count resets for each new extetromenone.

###### Verbose Inputs:
```
Section1

Section2

{ move_left  [ call Print with value = 3 ] [ call _move_left  ] }
{ move_right [ call Print with value = 4 ] [ call _move_right ] }

{ rotate [ call Print with value = 5 ] [ call rotate_CW ] }

{ speed_up  [ call Print with value = 6 ] [ call _speed_up  ] }
{ slow_down [ call Print with value = 7 ] [ call _slow_down ] }

{ pre_play  [ call Print with value = 1 ] }
{ post_play [ call Print with value = 2 ] }

Section3

[ play ]
```

This prints integers to `stdout` for each action performed by the player:

###### Invert Inputs
```
Section1

rotate = engine.rotate_AntiCW

Section2

{ move_left  [call _move_right ] }
{ move_right [ call _move_left ] }
{ speed_up   [ call _slow_down ] }
{ slow_down  [ call _speed_up  ] }

Section3

[ play ]
```

This inverts the user inputs, providing a new challenge for the player.
> Note: This also inverts the rotation direction.

###### UI Configurations
This lets the game programer configure the color, window size, etc.
```
Section1

initial_move_down_duration = 1000
width = 20
height = 40
fg_color = 3
bg_color = 2

Section2

Section3

# Overrides the values specified in Section 1
[ play with width = 10 height = 10 ]
```

Since the scanner is not handling strings, I have mapped string values for colors to integers for parameters.
- $0 \rightarrow$ <span style="color:red">*red*</span>
- $1 \rightarrow$ <span style="color:blue">*blue*</span>
- $2 \rightarrow$ <span style="color:green">*green*</span>
- $3 \rightarrow$ <span style="color:yellow">*yellow*</span>
- $4 \rightarrow$ <span style="color:light gray">*light gray*</span>


# Input File specifications

Input file must be divided into three sections:
- `Section1` containing variable declarations
- `Section2` has function declarations
- `Section3` has the main engine function.

You, the reader is suggested to explore the `grammar.y` file and the `.py` files provided and come up with interesting variations of the classic Tetris game of your own.

## Author

- Name: Ishaan Kapoor
- BITS ID: 2021A7PS2091G
- Email: f20212091@goa.bits-pilani.ac.in
