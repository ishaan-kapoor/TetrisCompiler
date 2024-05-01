#    engine.py: A Programmable Tetris-like Games Engine
#    Copyright (C) 2024  Ramprasad S. Joshi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

import tkinter as tk
from tkinter import filedialog
from board import Board
from allextetrominoes import *
from shape import Shape
from copy import deepcopy

colors = ["red", "blue", "green", "yellow", "light gray"]


class TetrisEngine:
    # Programmable: pass a different parameter
    def __init__(self, extetromino_distribution=range(1, 8)):
        # Controls the number, variety and distribution.
        # This can be changed to range(1,74) for the give allextetrominoes module. Or to your list too.
        # If you want some pieces to have more frequency than others, then repeat their index in this
        # list, and in that case give a proper enumerated tuple or a list, not a range or something
        self.extetromino_distribution = extetromino_distribution
        self.initial_move_down_duration = 1000
        self.rotate = self.rotate_CW
        self.move_left = self._move_left
        self.move_right = self._move_right
        self.speed_up = self._speed_up
        self.slow_down = self._slow_down
        self.allowed_rotations = float("inf")
        self.rotations = 0
        self.width = 10
        self.height = 20
        self.fg_color = 4
        self.bg_color = 1

    def run(self, **kwargs):
        self.window = tk.Tk()  # fixed
        self.title = kwargs.get("title", "Ishaan's submission")
        self.window.title(self.title)  # Programmable, inconsequential
        self.width = kwargs.get("width", self.width)  # Essential and programmable
        self.height = kwargs.get("height", self.height)  # Essential and programmable
        self.text_area = tk.Text(  # Essential and partially programmable
            self.window,  # fixed unless you populate more components
            wrap=tk.CHAR,  # programmable, please find some way not to let it wrap
            height=self.height,  # fixed
            width=2 * self.width,  # fixed
            bg=colors[kwargs.get("fg_color", self.fg_color)],  # programmable
            fg=colors[kwargs.get("bg_color", self.bg_color)],  # programmable
            font=("Courier New", "16", "bold"),  # Can be configured jsut like colors
        )
        self.text_area.pack(expand=tk.YES, fill=tk.BOTH)  # fixed
        self.board = Board(width=self.width, height=self.height)  # fixed
        self.pauseStatus = False  # fixed in the beginning, state variable
        # semi-fixed: change by providing a new callback: this is true of all the callbacks
        self.window.bind("<Up>", self.rotate)  # callback
        self.window.bind("<Left>", self.move_left)  # callback
        self.window.bind("<Right>", self.move_right)  # callback
        self.window.bind("<space>", self.drop_piece)  # callback
        self.window.bind("<Down>", self.move_down_force)  # callback
        self.update_duration = 100  # More or less fixed
        self.window.after(self.update_duration, lambda: self.update_step())  # callback
        self.move_down_duration = (
            self.initial_move_down_duration
        )  # fixed, but its progression programmable
        self.window.after(
            self.move_down_duration, lambda: self.move_down_step()
        )  # callback
        self.default_cursor = (
            0,
            int(self.board.width / 2 - 1),
        )  # Programmable. Where the new piece appears
        self.cursor = self.default_cursor  # State variable.

        self.new_piece()  # This sequence is not much programmable.
        self.text_area.insert(tk.END, self.render())
        self.create_menu()
        self.game_over_status = False  # fixed, only reversed at quitting.
        self.deleted_lines = 0  # for scoring
        self.score = tk.StringVar(
            self.window, "No. of Lines Cleared = " + str(self.deleted_lines)
        )
        # for displaying the score
        self.scoreboard = tk.Label(self.window, textvariable=self.score)
        self.scoreboard.pack()
        self.window.mainloop()

    # Each of the methods below are programmable (replaceable) -- but give in the documentation
    # what the game programmer has to provide -- the functionality, role, the entagling of concerns.
    def render(self):
        area = deepcopy(self.board)
        piece = self.piece
        for row in range(self.piece.matrix.shape[0]):
            for column in range(self.piece.matrix.shape[1]):
                if self.piece.matrix[row][column]:
                    area.area[row + self.cursor[0]][column + self.cursor[1]] = True
        return str(area)

    def toggle_pause_status(self):
        self.pauseStatus = not (self.pauseStatus)

    def rotate_CW(self, *_):
        if self.pauseStatus:
            return
        newpiece = Shape(self.piece.matrix)
        newpiece.rotateCW()
        if self.board.collision(newpiece.matrix, self.cursor):
            return False
        else:
            self.piece = newpiece
            return True

    def rotate_AntiCW(self, *_):
        if self.pauseStatus:
            return
        newpiece = Shape(self.piece.matrix)
        newpiece.rotateAntiCW()
        if self.board.collision(newpiece.matrix, self.cursor):
            return False
        else:
            self.piece = newpiece
            return True

    def _move_left(self, *_):
        if self.pauseStatus:
            return
        self.move_piece("LEFT")

    def _move_right(self, *_):
        if self.pauseStatus:
            return
        self.move_piece("RIGHT")

    def drop_piece(self, *_):
        if self.pauseStatus:
            return
        while self.move_piece("DOWN"):
            pass  # Could be: nothing = "doing" # keep dropping

    def move_down_force(self, *_):
        self.move_down_step(True)

    def move_down_step(self, accelerated=False):
        if self.pauseStatus:
            self.window.after(self.move_down_duration, lambda: self.move_down_step())
            return
        if not (self.move_piece("DOWN")):
            self.board.insertShape(self.piece.matrix, self.cursor[0], self.cursor[1])
            tobedeleted = [
                row for row in reversed(range(self.height)) if all(self.board.area[row])
            ]
            if tobedeleted:
                self.deleted_lines += len(tobedeleted)
                self.score.set("No. of Lines Cleared = " + str(self.deleted_lines))
                for row in reversed(tobedeleted):
                    for newrow in reversed(range(row)):
                        for column in range(self.width):
                            self.board.area[newrow + 1][column] = self.board.area[
                                newrow
                            ][column]
                for row in range(len(tobedeleted)):
                    self.board.area[row] = numpy.full_like(self.board.area[row], False)
                if not (self.deleted_lines % 100):
                    self.speed_up()  # programmable
            self.cursor = self.default_cursor
            self.new_piece()
            if self.board.collision(self.piece.matrix, self.cursor):
                string_board = self.render().split("\n")
                string_board[int(self.height / 5)] = "Game Over"
                lastmessage = ""
                for row in range(self.height):
                    lastmessage = lastmessage + string_board[row].strip() + "\n"
                self.text_area.delete(1.0, tk.END)
                self.text_area.insert(1.0, lastmessage)
                self.dialog = tk.simpledialog.Dialog(self.window, "Game Over!")
                self.window.quit()
        if not (accelerated):
            self.window.after(self.move_down_duration, lambda: self.move_down_step())

    def update_step(self):
        if self.pauseStatus:
            self.window.after(self.update_duration, lambda: self.update_step())
            return
        self.text_area.delete(1.0, tk.END)
        self.text_area.insert(tk.END, self.render())
        self.window.after(self.update_duration, lambda: self.update_step())

    def _speed_up(self):  # programmable
        self.move_down_duration = int(numpy.floor(self.move_down_duration * 0.5))

    def _slow_down(self):  # programmable
        self.move_down_duration = int(numpy.ceil(self.move_down_duration * 2))

    def extetricks_help(self):
        self.pauseStatus = True
        help_message = """
			This is EXtendedTETRIckS, extensible to extetrominoes and more.
			Play it like all other tetris clones.
			Copyright (C) 2024 Ramprasad S. Joshi.
			(CS&IS Dept, BITS, Pilani K K Birla Goa Campus, GOA INDIA.)
			+91 832 2580 121. rsj [at] the bits mail id below.
			goa.bits-pilani.ac.in
			https://www.bits-pilani.ac.in/goa/ramprasad-savlaram-joshi
			Developed as a pedagogical resource for
			Birla Institute of Technology and Science, Pilani.
            - modified by Ishaan Kapoor for Compiler Construction course
			"""
        self.text_area.delete(1.0, tk.END)
        self.text_area.insert(tk.END, help_message)
        tk.simpledialog.Dialog(self.window, "Click any button to continue")
        self.pasueStatus = False

    def create_menu(self):
        menu = tk.Menu(self.window)
        self.window.config(menu=menu)

        extetris_menu = tk.Menu(menu)
        menu.add_cascade(label="EXtendedTETRIckS", menu=extetris_menu)
        extetris_menu.add_command(label="New Game", command=self.new_game)
        extetris_menu.add_separator()
        extetris_menu.add_command(label="Pause", command=self.toggle_pause_status)
        extetris_menu.add_separator()
        extetris_menu.add_command(label="Speed-Up", command=self.speed_up)
        extetris_menu.add_command(label="Slow-down", command=self.slow_down)
        extetris_menu.add_separator()
        extetris_menu.add_command(label="Save state", command=self.save_file)
        extetris_menu.add_separator()
        extetris_menu.add_command(label="Quit", command=self.window.quit)
        extetris_menu.add_separator()
        extetris_menu.add_command(label="About", command=self.extetricks_help)

    def new_piece(self, piece=None):
        self.rotations = 0
        if piece == None:
            self.piece = Shape(get_any_extetromino(self.extetromino_distribution))
        else:
            self.piece = piece
        self.cursor = self.default_cursor

    def new_game(self):
        if self.game_over_status:
            self.window.quit()
        self.pauseStatus = True
        self.board.area = numpy.full_like(self.board.area, False)
        self.new_piece()
        self.text_area.delete(1.0, tk.END)
        self.text_area.insert(tk.END, self.render())
        self.cursor = self.default_cursor
        self.move_down_duration = self.initial_move_down_duration
        self.deleted_lines = 0
        self.score.set("No. of Lines Cleared = " + str(self.deleted_lines))
        self.pauseStatus = False

    def save_file(self):
        file = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[("Text Files", "*.txt"), ("All Files", "*.*")],
        )
        if file:
            with open(file, "w") as file_handler:
                file_handler.write(self.text_area.get(1.0, tk.END))
            self.window.title(f"Python Tetris Board - {file}")

    def move_piece(self, direction):
        if direction == "LEFT":
            offset = (0, -1)
        elif direction == "RIGHT":
            offset = (0, 1)
        elif direction == "UP":
            offset = (-1, 0)
        elif direction == "DOWN":
            offset = (1, 0)
        new_cursor = tuple(map(lambda a, b: a + b, self.cursor, offset))
        if self.board.collision(self.piece.matrix, new_cursor):
            return False
        else:
            self.cursor = new_cursor
            return True


if __name__ == "__main__":
    print(
        """ extetricks  Copyright (C) 2024  Ramprasad S. Joshi
    This program comes with ABSOLUTELY NO WARRANTY; for details see the about window.
    This is free software, and you are welcome to redistribute it
    under certain conditions listed in GPL3.0"""
    )
    tetris_engine = TetrisEngine(range(1, int(input("How many EXtetrominoes? ")) + 8))
