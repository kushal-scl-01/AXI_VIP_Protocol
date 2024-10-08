`ifndef AXI_MASTER_SEQR_SV
`define AXI_MASTER_SEQR_SV

class axi_master_seqr extends uvm_sequencer #(axi_master_seq_item);

	//factory registration 
	`uvm_component_utils(axi_master_seqr)

	//constructor 
	function new(string name = "axi_master_seqr", uvm_component parent = null);
		super.new(name,parent);
	endfunction	

endclass 

`endif 
