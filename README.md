# sokoban-vhdl

Sokoban-clone implemented in VHDL, executed on Altera FPGA - Cyclone II | EP2C20F484C7. There are 4 stages, video output, keyboard input and all the game logic implemented on plain VHDL.

## Running

To execute it, an Altera board (preferably a Cyclone II), and Quartus. It was tested with 9.x family, but should work with newer versions, assuming pins are correctly setup. Like other Altera projects, it's required to compile and deploy the project, plugging a monitor and a keyboard to the board.

## Components

The existing components are connected as showed by the following diagram:

![Sokoban components diagram](/diagram.png)

A brief description of the game logic components:

- Sokoban.vhd: Project top-Level, connect all components and their required inputs and outputs.
- Timer.vhd: Represents the stopwatch, that limits the game time. Has 3 counters (hundred, ten and unity) and a clock divisor. It indicates, synchronously, when the total time is over.
- Mod10.vhd: Decreasing mod10 counter.
- DivClock.vhd: Clock divisor, generated 1 clock/second.
- MemLogica.vhd: Double read-single write memory, connected to DisplayWorks (read-only) and Lógica (read and write). There are 4 of it in the top-level, one for each stage.
- MemLogica_Mux.vhd: simple mux that separates which is the current stage.
- Logica.vhd: Handles all the game logic, managing the logic matrix of the current stage. Receives entries from the keyboard, deciding what is the next game state.
- DisplayWorks.vhd: Responsible for controlling video output, printing one bitmap at a time, give a logic matrix and a bitmap bank.
- ReadMemory.vhd: Read-only memory, stores all the game bitmap.
- TimerExpand.vhd: Connects each possible time with its representation on the bitmap bank.
- Clock_Divider: Used to divide the project clock, being the final used clock 2.7 MHz.

## Authors

* **Alexandre Luiz Brisighello Filho** - (albf)
* **Andre Nakagaki Filliettaz** - (andrentaz)

## License

This project (except dependencies) is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Professor Guido and Professor Cortes (both from Unicamp) for support.
* Rafael Auler and Thiago Borges Abdnur for dependencies.
