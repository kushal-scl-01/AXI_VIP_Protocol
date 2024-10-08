`ifndef AXI_SLV_INTERFACE_SV
`define AXI_SLV_INTERFACE_SV

`include "axi_defines.sv"
interface axi_slave_intf(input bit aclk,input bit aresetn);

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
	//          clocking block for slave agent                //
	//--------------------------------------------------------//
	clocking slv_drv_cb @(posedge aclk);
		default input #1 output #1;
		input awvalid;
		output awready,arready;
		input wvalid;
		output wready,bvalid,rvalid;
		input wlast;
		output bid,bresp;
		output rdata,rresp,rlast,rid;
		input bready,arvalid;
		input rready;
		input awid,wid;
		input arid;
	endclocking 

	clocking slv_mon_cb @(posedge aclk);
		default input #1 output #1;
		input awid,awaddr,awlen,awburst,awsize,awvalid;
		input wid,wdata,wstrb,wlast,wvalid;
		input bready;
		input bid,bresp,bvalid;
		input arid,araddr,arlen,arsize,arburst,arvalid;
		input rready;
		input rid,rdata,rresp,rlast,rvalid;
		input arready;
		input awready;
		input wready;
	endclocking

endinterface 

`endif 
