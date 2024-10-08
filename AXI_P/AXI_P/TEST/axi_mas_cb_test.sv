`ifndef AXI_MAS_CB_TEST_SV
`define AXI_MAS_CB_TEST_SV

class axi_mas_cb_test extends axi_base_test;

	//factory registration 
	`uvm_component_utils(axi_mas_cb_test)

	axi_master_cb_user mas_cb_h;

	//constructor 
	function new(string name = "axi_mas_cb_test", uvm_component parent = null);
		super.new(name,parent);
		mas_cb_h = new("mas_cb_h");
		endfunction 

	//handle of master sanity seqs 
	axi_master_sanity_seqs mas_seqs_h;
	axi_slave_base_seqs slv_seqs_h;

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		fork 
			begin 
				mas_seqs_h = axi_master_sanity_seqs::type_id::create("mas_seqs_h");
				uvm_callbacks #(axi_master_driver,axi_master_callback)::add(env_h.mas_agent.drv_h,mas_cb_h);
				void'(mas_seqs_h.randomize() with {no_of_trans == 2;});
				mas_seqs_h.start(env_h.mas_agent.seqr_h);
			end 
			begin
				slv_seqs_h = axi_slave_base_seqs::type_id::create("slv_seqs_h");
				slv_seqs_h.start(env_h.slv_agent.seqr_h);
			end 
		join_any
		phase.drop_objection(this);
		phase.phase_done.set_drain_time(this,300);
	endtask

endclass

`endif 
