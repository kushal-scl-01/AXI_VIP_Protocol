`ifndef AXI_DEFINES_SV
`define AXI_DEFINES_SV

//enum to select the burst type 
typedef enum bit [1:0] {FIXED,INCR,WRAP} burst_type;

//enum to select write or read operation 
typedef enum bit {WRITE,READ} trans_type;

//enum to select response type 
typedef enum bit [1:0] {OKAY,EXOKAY,SLVERR,DECERR} resp_type;

//Defined address width and data width 
`define ADDR_WIDTH 32
`define DATA_WIDTH 32

`endif 
