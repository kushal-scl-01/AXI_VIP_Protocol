`ifndef AXI_PACKAGE_SV
`define AXI_PACKAGE_SV

`include "axi_interface.sv"
`include "axi_slave_interface.sv"
package pkg;

	int flag;

	`include "uvm_macros.svh"
	import uvm_pkg::*;

	`include "axi_defines.sv"

	`include "axi_master_config.sv"
	`include "axi_slave_config.sv"

	`include "axi_master_seq_item.sv"
	`include "axi_slave_seq_item.sv"

	`include "axi_memory.sv"

	`include "axi_slave_callback.sv"
	`include "axi_slave_cb_user.sv"
	`include "axi_master_callback.sv"
	`include "axi_master_cb_user.sv"

	`include "axi_master_driver.sv"
	`include "axi_slave_driver.sv"
	`include "axi_slave_driver_bk.sv"

	`include "axi_master_seqr.sv"
	`include "axi_slave_seqr.sv"

	`include "axi_master_monitor.sv"
	`include "axi_slave_monitor.sv"

	`include "axi_master_agent.sv"
	`include "axi_slave_agent.sv"

	`include "axi_scoreboard.sv"

	`include "axi_env.sv"

	`include "axi_master_base_seqs.sv"
	`include "axi_slave_base_seqs.sv"

	`include "axi_mas_sanity_seqs.sv"
	`include "axi_mas_fixed_seqs.sv"
	`include "axi_mas_wrap_seqs.sv"

	`include "axi_base_test.sv"
	`include "axi_sanity_test.sv"
	`include "axi_slv_cb_test.sv"
	`include "axi_mas_cb_test.sv"
	`include "axi_fixed_test.sv"
	`include "axi_wrap_test.sv"

endpackage

`endif 
