`ifndef AXI_FIXED_TEST_SV
`define AXI_FIXED_TEST_SV

class axi_fixed_test extends axi_base_test;

	//factory registration 
	`uvm_component_utils(axi_fixed_test)

	//constructor 
	function new(string name = "axi_fixed_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction 

	//handle of master sanity seqs 
	axi_master_fixed_seqs mas_seqs_h;
	axi_slave_base_seqs slv_seqs_h;

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		fork 
			begin 
				mas_seqs_h = axi_master_fixed_seqs::type_id::create("mas_seqs_h");
				void'(mas_seqs_h.randomize() with {no_of_trans == 5;});
				mas_seqs_h.start(env_h.mas_agent.seqr_h);
			end 
			begin
				slv_seqs_h = axi_slave_base_seqs::type_id::create("slv_seqs_h");
				slv_seqs_h.start(env_h.slv_agent.seqr_h);
			end 
		join_any
		phase.phase_done.set_drain_time(this,2000);
		phase.drop_objection(this);
	endtask

endclass

`endif 
