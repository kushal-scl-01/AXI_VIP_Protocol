`ifndef AXI_TOP_SV
`define AXI_TOP_SV

import uvm_pkg::*;
import pkg::*;

module top;

	//clock and reset global signals 
	bit aclk = 1'b0;
	bit aresetn;
	
	//instance of interface 
	intf vintf_mas(aclk,aresetn);
	axi_slave_intf vintf_slv(aclk,aresetn);

	//loop back connection for master and slave interface

	//------------------------------------------------//
	//            Write Address channel               //
	//------------------------------------------------//
	assign vintf_slv.awid    = vintf_mas.awid;
	assign vintf_slv.awaddr  = vintf_mas.awaddr;
	assign vintf_slv.awlen   = vintf_mas.awlen;
	assign vintf_slv.awsize  = vintf_mas.awsize;
	assign vintf_slv.awburst = vintf_mas.awburst;
	assign vintf_slv.awvalid = vintf_mas.awvalid;
	assign vintf_mas.awready = vintf_slv.awready;

	//------------------------------------------------//
	//               Write Data channel               //
	//------------------------------------------------//
	assign vintf_slv.wid     = vintf_mas.wid;
	assign vintf_slv.wdata   = vintf_mas.wdata;
	assign vintf_slv.wstrb   = vintf_mas.wstrb;
	assign vintf_slv.wlast   = vintf_mas.wlast;
	assign vintf_slv.wvalid  = vintf_mas.wvalid;
	assign vintf_mas.wready  = vintf_slv.wready;

	//------------------------------------------------//
	//            Write Response channel              //
	//------------------------------------------------//
  assign vintf_mas.bid     = vintf_slv.bid;
  assign vintf_mas.bresp   = vintf_slv.bresp;
  assign vintf_mas.bvalid  = vintf_slv.bvalid;
  assign vintf_slv.bready  = vintf_mas.bready;

	 //------------------------------------------------//
	//             Read Address channel               //
 //------------------------------------------------//
	assign vintf_slv.arid    = vintf_mas.arid;
	assign vintf_slv.araddr  = vintf_mas.araddr;
	assign vintf_slv.arlen   = vintf_mas.arlen;
	assign vintf_slv.arsize  = vintf_mas.arsize;
	assign vintf_slv.arburst = vintf_mas.arburst;
	assign vintf_slv.arvalid = vintf_mas.arvalid;
	assign vintf_mas.arready = vintf_slv.arready;

	//------------------------------------------------//
	//                Read data channel               //
	//------------------------------------------------//
 	assign vintf_mas.rid    = vintf_slv.rid;
 	assign vintf_mas.rdata  = vintf_slv.rdata;
 	assign vintf_mas.rresp   = vintf_slv.rresp;
 	assign vintf_mas.rlast  = vintf_slv.rlast;
 	assign vintf_mas.rvalid = vintf_slv.rvalid;
 	assign vintf_slv.rready = vintf_mas.rready;

	//clock generation 
	initial begin
		forever #5 aclk = ~aclk;
	end 

	//reset can be asserted -> asynchronously 
	//reset can be deasserted -> synchronous 
	task reset();
		aresetn = 1'b0;
		repeat(2)@(posedge aclk);
		aresetn = 1'b1;
	endtask

	//set the virtual interface through config_db 
	initial begin
		uvm_config_db #(virtual intf)::set(null,"*","mas_vintf",vintf_mas);
		uvm_config_db #(virtual axi_slave_intf)::set(null,"*","slv_vintf",vintf_slv);
		fork
			reset();
			run_test("axi_base_test");
		join
	end 		

endmodule 

`endif

//strb[i-1] << 2**awsize
