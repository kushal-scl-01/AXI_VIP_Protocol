`ifndef AXI_SLAVE_SEQR_SV
`define AXI_SLAVE_SEQR_SV

class axi_slave_seqr extends uvm_sequencer #(axi_slave_seq_item);

	//factory registration 
	`uvm_component_utils(axi_slave_seqr)

	//handle of memory 
	axi_memory mem_h;

	//analysis export 
	uvm_analysis_export #(axi_slave_seq_item) seq_item_mon_export;

	//analysis fifo 
	uvm_tlm_analysis_fifo #(axi_slave_seq_item) seq_item_fifo;

	//constructor 
	function new(string name = "axi_slave_seqr", uvm_component parent = null);
		super.new(name,parent);
		seq_item_mon_export = new("seq_item_mon_export",this);
		seq_item_fifo = new("seq_item_fifo",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//mem_h = axi_memory::type_id::create("mem_h",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		seq_item_mon_export.connect(seq_item_fifo.analysis_export);
	endfunction

endclass 

`endif 

