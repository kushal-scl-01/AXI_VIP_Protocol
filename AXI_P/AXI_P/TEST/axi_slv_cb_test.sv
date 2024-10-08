`ifndef AXI_SLV_CB_TEST_SV
`define AXI_SLV_CB_TEST_SV

class axi_slv_cb_test extends axi_base_test;

	//factory registration 
	`uvm_component_utils(axi_slv_cb_test)

	axi_slave_cb_user slv_cb_h;

	//constructor 
	function new(string name = "axi_slv_cb_test", uvm_component parent = null);
		super.new(name,parent);
		slv_cb_h = new("slv_cb_h");
		endfunction 

	//handle of master sanity seqs 
	axi_master_sanity_seqs mas_seqs_h;
	axi_slave_base_seqs slv_seqs_h;

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		fork 
			begin 
				mas_seqs_h = axi_master_sanity_seqs::type_id::create("mas_seqs_h");
				void'(mas_seqs_h.randomize() with {no_of_trans == 2;});
				mas_seqs_h.start(env_h.mas_agent.seqr_h);
			end 
			begin
				slv_seqs_h = axi_slave_base_seqs::type_id::create("slv_seqs_h");
				uvm_callbacks #(axi_slave_driver,axi_slave_callback)::add(env_h.slv_agent.drv_h,slv_cb_h);
				slv_seqs_h.start(env_h.slv_agent.seqr_h);
			end 
		join_any
		phase.drop_objection(this);
		phase.phase_done.set_drain_time(this,350);
	endtask

endclass

`endif 
