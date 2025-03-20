# **Hardware Implementation of an Image Decompressor (SystemVerilog)**
A digital systems design project implementing an image decompressor in **SystemVerilog** based on the **McMaster Image Compression (.mic18) specification**. The decompressed image is displayed using an **Altera DE2-115 FPGA board**.

## **Getting Started**
### **Prerequisites**
- **Quartus Prime** for synthesis and FPGA programming
- **ModelSim** for simulation
- **Altera DE2-115 FPGA Board**
- **Basic understanding of digital systems and hardware design**

### **Setup**
1. Clone this repository:
   ```bash
   git clone https://github.com/AbaanKhan970/Image-Decompressor.git
   cd Image-Decompressor
   ```
2. Open the **Quartus Prime** project file and compile the SystemVerilog source files.
3. Use **ModelSim** to run testbenches and verify functionality.
4. Program the **Altera DE2-115 FPGA** and connect a **VGA monitor** for output display.

## **Project Overview**
The project is divided into multiple **milestones**, each focusing on a key part of the decompression pipeline.

### **Milestone 1: Upsampling and Color Space Conversion**
- Converts **YUV** to **RGB**.
- Upsamples **U and V** components.
- Stores the final **RGB image in SRAM**.
- **Key Components:**
  - Finite State Machines (FSMs)
  - SRAM and Dual-Port RAM (DPRAM) interfacing
  - VGA Display Controller

### **Milestone 2: Inverse Discrete Cosine Transform (IDCT)**
- Uses **matrix multiplication** to perform **IDCT**.
- Recovers the **downsampled image**.
- **Key Components:**
  - SRAM fetch and store operations
  - Fixed-point arithmetic for IDCT calculations

### **Milestone 3: Lossless Decoding and Dequantization** *(Incomplete)*
- Implements **lossless decoding** of the bitstream.
- **Dequantizes** the frequency domain image.

## **Controls and Usage**
- **UART Interface**: Transfers compressed image data from PC to FPGA.
- **SRAM Controller**: Manages decompressed image storage.
- **VGA Output**: Displays the decompressed image.

## **Code Structure**
The implementation follows a **modular hardware design**, splitting different functions into separate SystemVerilog modules.

### **Core Components**
#### **project.sv** (Top-Level Module)
- Controls the flow of data between modules.

#### **milestone1.sv** (Upsampling & Color Conversion)
- Converts YUV to RGB and performs upsampling.

#### **milestone2.sv** (IDCT Implementation)
- Uses matrix multiplication to perform **Inverse Discrete Cosine Transform**.

#### **uart_interface.sv** (UART Communication)
- Handles image data transfer from PC to FPGA.

#### **sram_controller.sv** (SRAM Read/Write)
- Manages memory operations for decompressed image storage.

#### **vga_controller.sv** (VGA Display)
- Reads decompressed image from SRAM and outputs it to a monitor.

## **Features**
✔️ **Hardware-based image decompression**  
✔️ **Real-time VGA output on an FPGA**  
✔️ **Efficient SRAM and DPRAM utilization**  
✔️ **SystemVerilog implementation with FSMs**  
✔️ **Fixed-point arithmetic for optimized computation**  

