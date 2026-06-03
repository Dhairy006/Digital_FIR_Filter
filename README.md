# ECG Signal Filtering using FIR Low-Pass Filter (MATLAB + Verilog FPGA Implementation)

## Overview

This project implements an **ECG (Electrocardiogram) signal denoising system** using a **35-tap FIR Low-Pass Filter** designed with a **Hanning (Hann) Window**. The project combines software-based signal processing in MATLAB with a hardware realization in Verilog HDL, demonstrating the complete workflow from filter design and analysis to FPGA implementation.

The objective is to remove high-frequency muscle artifacts from an ECG recording while preserving the clinically important low-frequency components of the signal.

The project was developed as part of the Digital Signal Processing / FPGA Design coursework at **Indian Institute of Technology Guwahati (IIT Guwahati)**.

---

## Project Objectives

* Design a linear-phase FIR Low-Pass Filter.
* Remove muscle noise from ECG recordings.
* Analyze filter performance in both time and frequency domains.
* Measure Signal-to-Noise Ratio (SNR) improvement.
* Generate FPGA-compatible coefficient memory files.
* Implement floating-point FIR filtering hardware using Verilog.
* Validate hardware output against MATLAB reference results.
* Deploy and synthesize the design for FPGA implementation.

---

## ECG Dataset

The project uses the dataset:

```text
ecg_muscle_noise.mat
```

which contains:

| Variable  | Description                              |
| --------- | ---------------------------------------- |
| clean_seg | Clean ECG reference signal               |
| noisy_seg | ECG signal corrupted by muscle artifacts |

### Signal Properties

| Parameter          | Value                 |
| ------------------ | --------------------- |
| Sampling Frequency | 360 Hz                |
| Number of Samples  | 1024                  |
| Signal Type        | ECG                   |
| Noise Type         | Muscle Artifact Noise |

---

## FIR Filter Design

The denoising filter is designed using the Window Method.

### Filter Specifications

| Parameter            | Value          |
| -------------------- | -------------- |
| Filter Type          | FIR Low-Pass   |
| Window               | Hanning (Hann) |
| Number of Taps       | 35             |
| Effective Order      | 34             |
| Sampling Frequency   | 360 Hz         |
| Cutoff Frequency     | 40 Hz          |
| Passband             | 0–30 Hz        |
| Stopband             | ≥ 50 Hz        |
| Passband Ripple      | ≤ 1 dB         |
| Stopband Attenuation | ≥ 40 dB        |
| Phase Response       | Linear Phase   |

The filter coefficients are generated using:

```matlab
b = fir1(N-1, Wn, 'low', hann(N));
```

where:

```matlab
N  = 35;
Fc = 40;
Fs = 360;
Wn = Fc/(Fs/2);
```

---

# Software Implementation (MATLAB)

## Main Script

```text
Matlab/filter.m
```

### Features

* Loads ECG dataset
* Designs FIR low-pass filter
* Computes frequency response
* Filters noisy ECG signal
* Generates time-domain plots
* Generates frequency-domain plots
* Computes SNR improvement

### Processing Flow

```text
Load ECG Data
       ↓
Generate FIR Coefficients
       ↓
Analyze Frequency Response
       ↓
Filter Noisy ECG
       ↓
Compare with Clean ECG
       ↓
Compute SNR Improvement
```

---

## Generated Results

### 1. Noisy ECG Signal

Visualizes the corrupted ECG waveform.

### 2. Filter Response

Plots:

* Magnitude Response
* Phase Response

using:

```matlab
freqz()
```

### 3. Time Domain Comparison

Comparison of:

* Noisy ECG
* Filtered ECG
* Clean ECG

### 4. Frequency Domain Comparison

FFT comparison between:

* Noisy ECG
* Filtered ECG

### 5. SNR Evaluation

```matlab
noise_before = noisy_seg - clean_seg;
noise_after  = ecg_filtered - clean_seg;
```

Typical reported result:

```text
SNR before filtering : 10.00 dB
SNR after filtering  : 10.08 dB
SNR Improvement      : 0.08 dB
```

---

# Hardware Implementation (Verilog)

The hardware implementation reproduces FIR filtering using custom IEEE-754 single-precision floating-point arithmetic.

Instead of relying on vendor IP cores, floating-point operations are implemented manually in Verilog.

---

## Hardware Architecture

```text
                 +------------------+
Input Sample --->| Delay Line       |
                 +------------------+
                           |
                           v
                 +------------------+
                 | FIR Coefficients |
                 +------------------+
                           |
                           v
                 +------------------+
                 | Floating Point   |
                 | Multipliers      |
                 +------------------+
                           |
                           v
                 +------------------+
                 | Floating Point   |
                 | Adders           |
                 +------------------+
                           |
                           v
                    Filter Output
```

---

## Verilog Modules

### multiplier.v

IEEE-754 Single Precision Floating-Point Multiplier

#### Features

* Sign extraction
* Exponent handling
* Mantissa multiplication
* NaN handling
* Infinity handling
* Zero handling
* Normalization
* Overflow detection
* Underflow detection

#### Arithmetic

```text
Result = A × B
```

using:

```text
24-bit Mantissa × 24-bit Mantissa
→ 48-bit Product
```

---

### adder.v

IEEE-754 Single Precision Floating-Point Adder

#### Features

* Exponent alignment
* Mantissa shifting
* Addition/Subtraction
* Leading-one detection
* Normalization
* Sign management
* IEEE-754 result packing

#### Operations

```text
Result = A + B
```

or

```text
Result = A - B
```

depending on operand signs.

---

## Memory Initialization Flow

MATLAB generates FPGA-compatible memory files.

Script:

```text
Matlab/matlab_coeffs to mem.m
```

Generates:

```text
coeffs.mem
input_noisy.mem
input_length.txt
```

### coeffs.mem

Contains:

```text
35 FIR coefficients
```

stored as IEEE-754 hexadecimal values.

### input_noisy.mem

Contains:

```text
1024 ECG samples
```

stored as IEEE-754 hexadecimal values.

### input_length.txt

Stores total input sample count.

---

# Project Structure

```text
SET-18/
│
├── ECG Signal Filtering using FIR Low.pdf
├── ECG Signal Filtering using FIR Low.docx
│
├── Matlab/
│   ├── ecg_muscle_noise.mat
│   ├── filter.m
│   ├── matlab_coeffs to mem.m
│   ├── output test to matlab input to plot verilog graph.m
│   ├── coeff generation utilities
│   └── output files
│
├── project_6/
│   ├── coeffs.mem
│   ├── input_noisy.mem
│   ├── project_6.xpr
│   │
│   ├── project_6.srcs/
│   │   ├── sources_1/
│   │   │   ├── adder.v
│   │   │   ├── multiplier.v
│   │   │   └── test.v
│   │   │
│   │   └── sim_1/
│   │       ├── testbench.v
│   │       ├── tb2.v
│   │       └── conv.v
│   │
│   └── Vivado synthesis files
│
└── README.md
```

---

# Simulation and Verification

The Verilog implementation is verified through behavioral simulation.

Verification checks include:

* Floating-point multiplication correctness
* Floating-point addition correctness
* FIR convolution behavior
* Output consistency with MATLAB reference
* Memory file loading
* Boundary condition handling

---

# FPGA Deployment

### Target Platform

```text
ZedBoard
```

### Toolchain

```text
Xilinx Vivado Design Suite
```

### Implementation Flow

```text
Behavioral Simulation
        ↓
Synthesis
        ↓
Implementation
        ↓
Bitstream Generation
        ↓
Resource & Power Analysis
```

---

# Getting Started

## Software Requirements

### MATLAB

Required Toolboxes:

* Signal Processing Toolbox

or

### Python (Alternative)

* NumPy
* SciPy
* Matplotlib

---

## Hardware Requirements

* Xilinx Vivado
* ZedBoard FPGA

---

## Running MATLAB Model

```matlab
cd Matlab
filter
```

Outputs:

* Time-domain plots
* Frequency-domain plots
* Filter response
* SNR calculations

---

## Generating Hardware Memory Files

Run:

```matlab
matlab_coeffs_to_mem
```

Outputs:

```text
coeffs.mem
input_noisy.mem
input_length.txt
```

Copy these files into the Vivado project.

---

## Running Hardware Simulation

1. Open Vivado project:

```text
project_6/project_6.xpr
```

2. Ensure memory files are loaded.

3. Run Behavioral Simulation.

4. Compare generated output against MATLAB results.

5. Proceed to synthesis and implementation.

---

# Key Learning Outcomes

This project demonstrates:

* FIR filter design
* ECG signal denoising
* Window-based filter synthesis
* Frequency-domain analysis
* SNR evaluation
* IEEE-754 floating-point arithmetic
* Verilog HDL design
* FPGA implementation flow
* MATLAB-to-FPGA integration
* Hardware/software co-design methodology

---

# Authors

### Dhairya Shivhare

B.Tech, Electronics and Electrical Engineering (EEE)
Minor in Computer Science and Engineering (CSE)
Indian Institute of Technology Guwahati

### Priyanshu Raj Singh

Indian Institute of Technology Guwahati

### Prachan Reddy

Indian Institute of Technology Guwahati

---

# Acknowledgements

This project was developed as part of academic coursework focused on Digital Signal Processing, FPGA Design, and Hardware Acceleration of Signal Processing Algorithms.

---



---

⭐ If you found this project useful, please consider starring the repository.
