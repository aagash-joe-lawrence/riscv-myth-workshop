# RISC-V CPU: MYTH Workshop

Five-day RISC-V workshop: from the ISA and GNU toolchain to a complete **5-stage pipelined RV32I CPU in TL-Verilog**, built in [Makerchip](https://makerchip.com).

**Live project:** [Open the CPU in Makerchip](https://myth.makerchip.com/v196/ide/~0M8f0co7/p-0qRcOp)

<table>
  <tr>
    <td align="center">
      <sub>RISC V Processor Executing Sum of 1 to 9 assembly code</sub>
      <img width="1362" height="682" alt="RISC-V processor executing the sum of 1 to 9 program" src="https://github.com/user-attachments/assets/d2fa7227-53f4-48a4-9979-cee89bb51b9a" />
      <br />
    </td>
  </tr>
</table>

## Contents

- [Day 1: RISC-V ISA and GNU toolchain](#day-1-risc-v-isa-and-gnu-toolchain)
- [Day 2: ABI and Assembly language writing](#day-2-abi-and-assembly-language-writing)
- [Day 3: Digital logic with TL-Verilog and Makerchip](#day-3-digital-logic-with-tl-verilog-and-makerchip)
- [Day 4: Basic RISC-V CPU micro-architecture](#day-4-basic-risc-v-cpu-micro-architecture)
- [Day 5: Complete pipelined CPU](#day-5-complete-pipelined-cpu)
- [Final design](#final-design)
- [Repository structure](#repository-structure)
- [How to run](#how-to-run)
- [Key learnings](#key-learnings)
- [Known limitations](#known-limitations)
- [Credits](#credits)
- [Author](#author)

| Day | Topic | Tools |
|---|---|---|
| 1 | ISA, GNU toolchain, number representation | riscv-gcc, Spike |
| 2 | ABI, function calls, verification flow | riscv-gcc, Spike, iverilog |
| 3 | Digital logic in TL-Verilog | Makerchip |
| 4 | Single-cycle CPU: fetch, decode, control | Makerchip |
| 5 | Pipelining, hazards, load/store, jumps | Makerchip |

---

## Day 1: RISC-V ISA and GNU toolchain

**Goal:** Understand the execution of a simple c program using GCC, RISCV toolchain and spike simulator

**Lab work**

- Wrote a C program to compute the sum from 1 to N
- Compiled with `riscv64-unknown-elf-gcc` and disassembled the output
- Ran and debugged in the Spike simulator
- Explored 64-bit unsigned and signed number representation

**Commands used**

```bash
vim <filename.c> : to create/open a program file
gcc <filename.c> : to compile a c program to laptop architecture(x86 or arm) and run the final binary directly in host laptop
./a.out : when gcc used without mentioning output object file, the executable binary stored in a.out which can be run directly

riscv64-unknown-elf-gcc -O1 -mabi=lp64 -march=rv64i -o <object_file.o> <filename.c> : to compile the risc v object file from c program
riscv64-unknown-elf-gcc -Ofast -mabi=lp64 -march=rv64i -o <object_file.o> <filename.c> : more optimised implementation of the c program
riscv64-unknown-elf-objdump -d 1ton.o : to view the complete riscv assembly code compiled by riscv64-unknown-elf-gcc compiler

spike -d pk 1ton.o : to debug the execution of assembly in simulated riscv processor
```

### Compiling the C program with gcc

The sum 1 to N program was first compiled with `gcc` for the laptop's own architecture (x86 or ARM) and run directly as `a.out`.

![Compiling and running the C program with gcc](https://github.com/user-attachments/assets/6fb6c90a-d977-49cf-a5e2-b34b18fc7397)

*Compiling and running the program on the host machine.*

### Compiling for RISC-V and viewing the assembly

The same program was compiled for RISC-V with `riscv64-unknown-elf-gcc` and disassembled with `objdump`. Using `-Ofast` instead of `-O1` gave smaller, more optimised assembly: the instruction count dropped from 15 to 12.

![Compiling for RISC-V and disassembling the output](https://github.com/user-attachments/assets/6909f025-bb90-46f3-9ce5-ba4316ae032a)

*Compile and disassemble commands.*

<table>
  <tr>
    <td align="center" width="50%">
      <img alt="Assembly output compiled with -O1" src="https://github.com/user-attachments/assets/7b39af98-053a-4a17-b491-4671258a86a4" />
      <br />
      <sub><b>Compiled with -O1</b></sub>
    </td>
    <td align="center" width="50%">
      <img alt="Assembly output compiled with -Ofast" src="https://github.com/user-attachments/assets/ebdea9a5-da5b-4367-b603-ff1c1110c325" />
      <br />
      <sub><b>Compiled with -Ofast</b></sub>
    </td>
  </tr>
</table>

### Spike simulation and debug

Spike's debug mode (`spike -d pk 1ton.o`) runs the program one instruction at a time, so the registers can be inspected after each step. Two instructions were easy to follow:

- `LUI` placed its immediate in the upper bits (31:12) of the register and sign-extended the result to 64 bits. This is how `a0` received hex 1 and `a2` received hex 21.
- `ADDI` reduced the stack pointer `sp` by 16. The second-last hex digit changed from 5 to 4 (`0101_0000` to `0100_0000`), and that one-bit change at bit 4 is 2⁴ = 16.

![Spike debug session showing register contents](https://github.com/user-attachments/assets/4506c1d7-96fc-4899-aa4c-ee371b15bc7f)

*Stepping through the program in Spike and checking registers.*

### Signed and unsigned numbers

The given program declared its variables as `long long int`, but the values on the right-hand side were cast to `int`. The values were therefore limited to the 32-bit `int` range (−2³¹ to 2³¹−1) instead of the intended 64-bit limits (2⁶³−1 and −2⁶³). The corrected version uses `unsigned long long int` and `long long int`.

![The given signed and unsigned number program](https://github.com/user-attachments/assets/8d1797fa-8555-4a23-9310-38c8f97453e6)

*The task program.*

![The corrected program and its output](https://github.com/user-attachments/assets/5b099ad4-e35d-4dd0-9d9f-79241aea55ef)

*The corrected program using 64-bit types.*

---

## Day 2: ABI and Assembly language writing

**Goal:** learn how registers and memory are used by convention, and run assembly code on a RISC-V CPU model.

**Lab work**

- Studied the ABI: 32 registers and their ABI names, load/add/store, double-word memory layout
- Rewrote the sum 1 to N program with counter input in c and using an external assembly function call
- Ran a C program on a RISC-V CPU using spike
- Ran C code on the PicoRV32 processor in simulation with iverilog

The assembly function called from the C program:

```asm
.section .text
.global load
.type load, @function

load:
	add a4, a0, zero // a4=0x0 ,first argument passed to load
	add a2, a0, a1   // a2=0x0 +n ,a1 is second argument passed to load
	add a3, a0, zero // a3=0 ,the counter variable which counts frm 0 to n (a2)

loop:   add a4, a4, a3   // a4= a4+a3 ,the accumulator which is the cumulative sum
	addi a3, a3, 1   // a3=a3+1 the counter incremented
	blt a3, a2, loop // counter<n
	add a0, a4, zero // ans(a4) stored in a0
	ret              // a0 preserves the ans and c program gets the cumulative sum
```

### Sum 1 to N using assembly, simulated with Spike

The C program passes its arguments in `a0` and `a1`, and the assembly function returns the sum in `a0`, following the ABI. The program was compiled for RISC-V and run on Spike.

![C program calling the assembly function](https://github.com/user-attachments/assets/a64f7c47-cb74-4c53-9603-a47310f23e59)

![Spike simulation output of the function call](https://github.com/user-attachments/assets/be022778-725a-47ea-b3e7-6a98909f85f2)

*The C program calling the assembly function, and the result on Spike.*

### Running C code on the PicoRV32 processor with iverilog

The C program was stored in the memory of the PicoRV32 processor and simulated with iverilog.

![iverilog simulation of C code on PicoRV32](https://github.com/user-attachments/assets/e8d679e5-5e0f-4f4b-a005-f8175282995a)

*iverilog simulation output.*

---

## Day 3: Digital logic with TL-Verilog and Makerchip

**Goal:** learn TL-Verilog syntax and the Makerchip workflow.

### Pythagorean example from the Validity tutorial

Reproduced the screenshot from the Validity tutorial's Pythagorean example: rearranged the tabs, zoomed the waveform, and clicked the `$bb_sqin` signal to highlight it in the Nav-TLV pane and the diagram.

![Pythagorean example in Makerchip](https://github.com/user-attachments/assets/c4660041-b552-4394-b616-8aec18f53cca)

*Highlighting `$bb_sqin` across the code, diagram and waveform.*

### Inverter, logic gates, vectors and mux

Wrote an inverter, 2-input logic gates, an explicit vector declaration and a mux.

![Gates, vectors and mux in Makerchip](https://github.com/user-attachments/assets/5c1919cc-6c05-4df8-b22f-768dd83b2428)

*Gates and mux waveforms.*

### Combinational calculator

A calculator built from combinational logic, with the output selected by an operation input.

![Combinational calculator in Makerchip](https://github.com/user-attachments/assets/0e3d25ca-d477-48b4-9a8e-093ae91f00d1)

*Combinational calculator.*

### Free running counter and sequential calculator

A free-running counter, and a calculator that feeds its previous result back in as an input.

![Counter and sequential calculator in Makerchip](https://github.com/user-attachments/assets/11ef57f2-c555-44a9-add2-6d71daa797d3)

*Free running counter and sequential calculator.*

### Pipeline

Split the logic into pipeline stages using TL-Verilog's stage markers.

![Pipelined logic in Makerchip](https://github.com/user-attachments/assets/12e91a81-78b7-4a39-ae50-b3d2b647224c)

*Pipelined logic across stages.*

### Calculator variants: single cycle, 2 cycle, validity and memory

Four versions of the calculator, from a single-cycle design to a 2-cycle design with validity and a version with a single-value memory.

![Single cycle calculator](https://github.com/user-attachments/assets/6dccea17-c899-4f0f-93f2-c23ef91e8066)

*Single cycle calculator.*

![Double cycle calculator](https://github.com/user-attachments/assets/8f64ace0-6a9b-4732-9568-213c5c6b9195)

*Double cycle calculator.*

![Double cycle calculator with validity](https://github.com/user-attachments/assets/c0355576-b212-43d0-af2d-d345b0473d85)

*Double cycle calculator with validity.*

![Calculator with single value memory](https://github.com/user-attachments/assets/b5b3bccb-cb37-4c27-a161-54ff770919a9)

*Calculator with single value memory.*

### Hierarchy

Organised signals using hierarchy in TL-Verilog.

![Hierarchy in Makerchip](https://github.com/user-attachments/assets/095d75d7-fb08-4b08-b2cd-f8a08dad7cae)

*Hierarchy in the diagram and waveform.*

---

## Day 4: Basic RISC-V CPU micro-architecture

Day 4 builds the CPU as a single-cycle design: it completes one instruction per clock cycle, with no wait states and no wrong-path instructions. The test program adds 1 to 9 using `ADD`, `ADDI` and a `BLT` loop, and the final sum is copied to register `r10`.

<table>
  <tr>
    <td align="center" width="50%">
      <img alt="Course implementation plan for the single-cycle CPU" src="https://github.com/user-attachments/assets/1bf675e0-77cf-4586-a959-05237d99a88a" />
      <br />
      <sub>Implementation plan from the course</sub>
    </td>
    <td align="center" width="50%">
      <img alt="Makerchip diagram of my single-cycle CPU" src="https://github.com/user-attachments/assets/95b45f35-691f-455a-b0b6-c4f2bcf731e3" />
      <br />
      <sub>My implemented design in Makerchip</sub>
    </td>
  </tr>
</table>

### Fetch

The program counter `$pc` moves to the next instruction (`pc + 4`), or to the branch target when the previous instruction was a taken branch. The instruction is then read from instruction memory at that address.

```tlv
$pc[31:0] = (>>1$reset)? 32'b0:
            (>>1$taken_br)? >>1$br_tgt_pc: >>1$pc+32'd4;
```

### Decode

Bits `[6:2]` of the instruction give its type (R, I, S, B, U or J), which decides where the immediate and register fields sit in the 32 bits. Immediates are sign-extended. A field such as `rs2` or `rd` is only extracted when the instruction type actually has it, using `?$rs2_valid`, `?$rd_valid` .

```tlv
$dec_bits[10:0] = {$funct7[5],$funct3,$opcode};
         
$is_beq = ($dec_bits ==? 11'bx_000_1100011);
$is_bne = ($dec_bits ==? 11'bx_001_1100011);
$is_blt = ($dec_bits ==? 11'bx_100_1100011);
$is_bge = ($dec_bits ==? 11'bx_101_1100011);
$is_bltu = ($dec_bits ==? 11'bx_110_1100011);
$is_bgeu = ($dec_bits ==? 11'bx_111_1100011);
```

### Register file, ALU and branches

The register file has two read ports and one write port, and writes to `x0` are blocked. The ALU handles `ADD` and `ADDI`. For branches, the target is `pc + imm`, and the condition depends on the instruction. Signed comparisons (`BLT`, `BGE`) are built from the unsigned compare by flipping the result when the two sign bits differ.

```tlv
// Branch calculation
$br_tgt_pc[31:0] = $pc + $imm;
$taken_br = $is_beq? ($src1_value==$src2_value):
            $is_bne? ($src1_value!=$src2_value):
            $is_blt? ($src1_value<$src2_value) ^ ($src1_value[31]!=$src2_value[31]):
            $is_bge? ($src1_value>=$src2_value) ^ ($src1_value[31]!=$src2_value[31]):
            $is_bltu? ($src1_value<$src2_value):
            $is_bgeu? ($src1_value>=$src2_value):1'b0;
```

### Results

![Day 4 waveform showing the sum loop and the final result](https://github.com/user-attachments/assets/bfe97412-7f80-4620-ac77-1d17f29c2e0c)

![Makerchip log showing the Day 4 simulation passed](https://github.com/user-attachments/assets/6505cd10-c6b4-4c75-abe1-f12743062c99)

*Simulation passed.*

---

## Day 5: Complete pipelined CPU

Day 5 turns the single-cycle CPU into a pipelined one by spreading the logic over several cycles, fixing the hazards this creates, and completing the instruction set. The test program now also stores the sum to data memory and loads it back into `r15`, and the simulation passes when `r15` holds 45.

![Course plan for the pipelined CPU](https://github.com/user-attachments/assets/f18d0360-43d9-4d84-b43b-1fb5b905d370)

*Implementation plan from the course.*

### Valid cycles and branch redirect

A branch is resolved late in the pipeline (in `@3`), so by the time the PC is redirected, two instructions from the wrong path have already been fetched. The `$valid` signal marks the cycles after a taken branch, load or jump as invalid, so those instructions cannot write registers or cause another branch.

```tlv
$inc_pc[31:0] = $pc + 32'd4;
                 $pc[31:0] = >>1$reset                        ? 32'b0 :
                 >>3$valid_taken_br               ? >>3$br_tgt_pc :
                 >>3$valid_jump && >>3$is_jal     ? >>3$br_tgt_pc :
                 >>3$valid_jump && >>3$is_jalr    ? >>3$jalr_tgt_pc :
                 >>3$valid_load                   ? >>3$inc_pc : >>1$inc_pc;

$valid = !(>>1$valid_taken_br || >>2$valid_taken_br ||
           >>1$valid_load     || >>2$valid_load     ||
           >>1$valid_jump     || >>2$valid_jump);
```

### Register file bypass

The register file is read in `@2` and written in `@3`, so an instruction can read a register that the instruction right before it is still writing. When the indexes match, the value is taken directly from the write data instead of the register file.

```tlv
// rf output with register file bypass
$src1_value[31:0] = (>>1$rf_wr_en && (>>1$rf_wr_index == $rf_rd_index1)) ? >>1$rf_wr_data : $rf_rd_data1;
$src2_value[31:0] = (>>1$rf_wr_en && (>>1$rf_wr_index == $rf_rd_index2)) ? >>1$rf_wr_data : $rf_rd_data2;
```

### Complete decode and ALU

All of the base RV32I instructions are decoded except `fence`, `ecall` and `ebreak`. The ALU covers the logical, arithmetic and shift operations, set-less-than (signed and unsigned), `LUI`, `AUIPC`, and the return address for `JAL` and `JALR`. Loads and stores use the ALU to calculate the address (`src1 + imm`).

### Load and store

The data memory is accessed in `@4`, and loaded data arrives in `@5`. A load redirects the PC and then writes its data back into the register file through a delayed path, so a load behaves like a branch with a short invalid window. The test program stores the sum with `SW` and reads it back with `LW`.

### Results

<table>
  <tr>
    <td align="center" width="35%">
      <img alt="Makerchip diagram of the pipelined CPU" src="https://github.com/user-attachments/assets/a28fd65f-5e16-4410-9f2d-c5f2d23e0a04" />
      <br />
      <sub>The pipelined CPU in Makerchip</sub>
    </td>
    <td align="center" width="65%">
      <img alt="Day 5 waveform showing the branch, store and load" src="https://github.com/user-attachments/assets/89d89053-2567-425d-9fe4-f1112be10a80" />
      <br />
      <sub>Waveform: loop exit, store and load</sub>
    </td>
  </tr>
</table>

![Makerchip log showing the Day 5 simulation passed](https://github.com/user-attachments/assets/085a86aa-6bb2-4e5b-bee8-b3179008ec71)

*Simulation passed: `r15` holds 45 after the store and load.*

---

## Final design

The CPU is a 5-stage pipelined RV32I design. Each instruction moves through these stages:

| Stage | What happens |
|---|---|
| `@0` | Program counter update and instruction memory address |
| `@1` | Instruction fetched and decoded (type, immediate, fields, instruction) |
| `@2` | Register file read, branch target calculated |
| `@3` | ALU, branch and jump resolution, register bypass, register write |
| `@4` | Data memory read or write |
| `@5` | Loaded data available, written back to the register file |

**Hazards handled:** control hazards (wrong-path instructions marked invalid with `$valid`), read-after-write hazards (register file bypass), and load results arriving late (PC redirect and delayed write-back).

## Repository structure

```
day1/   C program for the toolchain labs
day2/   assembly function, C caller and PicoRV32 files
day3/   TL-Verilog exercises
day4/   single-cycle CPU (.tlv)
day5/   pipelined CPU (.tlv)
README.md
```

## How to run

**Days 1 and 2:** install the RISC-V GNU toolchain (`riscv64-unknown-elf-gcc`), Spike with the proxy kernel (`pk`), and iverilog, then run the commands shown in Day 1.

**Days 3 to 5:** open [makerchip.com](https://makerchip.com), paste the `.tlv` file, then compile and open the waveform. The code loads a shell library from GitHub, so Makerchip needs internet access. The simulation ends with *passed* when the sum reaches 45 (checked in `r10` on Day 4 and in `r15` on Day 5).

## Key learnings

- I have learnt a new HDL: TL Verilog which made my understanding of single cycle processor to a pipelined processor in an easier way, without lots of hours debugging pipeline registers and datapath in system verilog. Its easy to visualise the hazards and connection of signals in different temporal stages.
- A pipelined CPU needs more than just splitting logic into stages: branches and loads resolve late, so wrong-path instructions must be marked invalid, and read-after-write hazards need register file bypass.
- The full flow from C code to hardware: C to assembly with the GNU toolchain, then the same instructions executing on a CPU built from fetch, decode, register file, ALU and branch logic.

## Known limitations

- `JAL` and `JALR` logic is written, but the test program does not exercise it.
- `fence`, `ecall` and `ebreak` are not decoded.
- Loads and stores were tested with one `SW` and one `LW`.

## Credits

Workshop by Kunal Ghosh ([VLSI System Design](https://www.vlsisystemdesign.com/vsd_products/)) and Steve Hoover ([Makerchip](https://www.makerchip.com)). Starter code is from the [RISC-V MYTH Workshop](https://github.com/stevehoover/RISC-V_MYTH_Workshop). 

## Author

Aagash Joe Lawrence J
