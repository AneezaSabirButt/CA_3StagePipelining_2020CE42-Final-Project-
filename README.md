# 3-Stage Pipelined Processor

## Overview

This repository contains the Verilog code for a simple 3-stage pipelined processor implemented using Questasim and Visual Studio Code. The processor includes an ALU (Arithmetic Logic Unit), controller, data memory, instruction memory, and various other supporting modules.

## Components

### ALU (Arithmetic Logic Unit)

The ALU module performs various arithmetic and logical operations based on the provided control signals. It supports R-Type and I-Type instructions, including addition, subtraction, XOR, OR, AND, set less than (SLT), set less than unsigned (SLTU), logical shifts, and more.

### Controller

The controller module decodes instruction opcodes and generates control signals for the different stages of the pipeline. It distinguishes between R-Type, I-Type, S-Type, B-Type, U-Type, and J-Type instructions and generates the necessary signals for proper execution.

### Control Register for Memory and Writeback Stage

This module manages control signals for memory and writeback stages. It helps control the flow of data between stages and handles stall conditions.

### Data Memory

The data memory module provides a simple data memory implementation, allowing the processor to read and write data during execution.

### Instruction Memory

The instruction memory module loads machine code instructions for program execution.

### LS Unit (Load/Store Unit)

The LS Unit handles load and store operations, managing data loading and storing based on memory addresses.

### Program Counter (PC)

The PC module manages the program counter, ensuring proper updating based on branching and control flow instructions.

### Register File

The register file module provides a set of registers for storing intermediate data during execution.

### Other Supporting Modules

- IR (Instruction Register): Holds the current instruction during execution.
- I_reg (Immediate Register): Generates immediate values based on instruction types.
- Fwd_Flush_Stall_Unit: Manages data forwarding, flushing, and stalling based on pipeline hazards.
- Mux_PC: Selects the input for the program counter based on branching conditions.
- Mux_ALU: Selects the input for the ALU based on control signals.
- Imm_Gen: Generates immediate values for different instruction types.
- Mux_WData: Selects the data to be written back based on control signals.
- Brn_Cond: Evaluates branching conditions based on register values and control signals.

## Testbench

The `RISC_V_tb` testbench simulates the operation of the processor, providing a way to verify its correctness and performance.

## Usage

To use the processor, instantiate the `RISC_V` module in your Verilog project and connect it to your desired input and output modules.
Feel free to explore the provided Verilog code and modify it to suit your specific requirements.

## Simulation

Use Questasim or your preferred simulator to run simulations and validate the functionality of the processor. You can refer to the provided testbench (`RISC_V_tb`) for simulation examples.

## How to Run the Simulation in Visual Studio Code
1. vlog *.sv
2. vsim -c -voptargs=+acc RISC_V_tb -do "run -all"

## Files Description
    - RISC_V.v: Top-level module that instantiates all the components and connects them.
    - RISC_V_tb.v: Testbench for simulating the processor.
    - DataMem_machine_code.txt: Initial content of the data memory.
    - Instmem_machine_code_factorial.txt: Initial content of the instruction memory.

## Notes
This is a basic 3-stage pipelined processor. Ensure that the provided memory content is suitable for the intended program.
