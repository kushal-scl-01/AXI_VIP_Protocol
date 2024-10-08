`ifndef AXI_MAS_INTERFACE_SV
`define AXI_MAS_INTERFACE_SV

`include "axi_defines.sv"
interface intf(input bit aclk,input bit aresetn);

	//--------------------------------------------------------//
	//  declaration of write address channel signals          //
	//--------------------------------------------------------//
 	logic [3:0] awid;           			//write address id : unique id for each transaction
	logic [`ADDR_WIDTH-1:0] awaddr;	 	//write address
	logic [3:0] awlen;			       		//burst length :  1,2,3 ... 16 : number of transfer in burst 
	logic [2:0] awsize;								//burst size : 1,2,4 ... 128 (2**size) : size of each transfer in burst 
	logic [1:0] awburst;							//burst type : FIXED, INCR, WRAP  
	logic awvalid;										//write address valid 
	logic awready;										//write address ready
	
	//--------------------------------------------------------//
	//      declaration of write data channel signals         //
	//--------------------------------------------------------//
	logic [3:0] wid;  								//write id 
	logic [`DATA_WIDTH-1:0] wdata; 		//write data 
	logic [3:0] wstrb;   							//write strobes  
	logic wlast;											//write last
	logic wvalid;											//write valid 
	logic wready;											//write ready

	//--------------------------------------------------------//
	//     declaration of write response channel signals      //
	//--------------------------------------------------------//
	logic [3:0] bid;									//reaponse id 
	logic [1:0] bresp;								//write response 
	logic bvalid;											//write response valid 
	logic bready;											//response ready 

	//--------------------------------------------------------//
	//     declaration of read address channel signals        //
	//--------------------------------------------------------//
	logic [3:0] arid;			  					//read address id 
	logic [`ADDR_WIDTH-1:0] araddr;		//read address 
	logic [3:0] arlen;								//burst length 
	logic [2:0] arsize;								//burst size 
	logic [1:0] arburst;							//burst type
	logic arvalid;										//read address valid 
	logic arready;										//read address ready 

	//declaration of read data channel signals 
	logic [3:0] rid;  								//read id 
	logic [`DATA_WIDTH-1:0] rdata;		//read data 
	logic [1:0] rresp;								//read response 
	logic rlast;											//read last 
	logic rvalid;											//read valid
	logic rready;											//read ready
	
	//--------------------------------------------------------//
	//          clocking block for master agent               //
	//--------------------------------------------------------//
	clocking mas_drv_cb @(posedge aclk);
		default input #1 output #1;
		output awid, awaddr, awlen, awsize, awburst, awvalid; 
		output wid, wdata, wstrb, wlast, wvalid;
		output bready;
		output arid, araddr, arlen, arsize, arburst, arvalid;
		output rready;
		input awready;
		input wready;
		input bid,bresp,bvalid;
		input arready;
		input rid, rdata, rresp, rvalid;
	endclocking 

	//--------------------------------------------------------//
	//          clocking block for slave agent                //
	//--------------------------------------------------------//
	
	clocking mas_mon_cb @(posedge aclk);
		default input #1 output #0;
		input awid,awaddr,awlen,awsize,awburst,awvalid,awready;
		input wid,wdata,wstrb,wlast,wvalid,wready;
		input bid,bresp,bvalid,bready;
		input araddr,arlen,arsize,arburst,arvalid,arready;
		input rid,rdata,rresp,rlast,rvalid,rready;
	endclocking
	
endinterface 

`endif 
