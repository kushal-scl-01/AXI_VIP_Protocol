`ifndef AXI_BASE_TEST_SV
`define AXI_BASE_TEST_SV

class axi_base_test extends uvm_test;

	//factory registration
	`uvm_component_utils(axi_base_test)

	//handle of axi environment 
	axi_env env_h;

	//constructor 
	function new(string name = "axi_base_test", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env_h = axi_env::type_id::create("env_h",this);
	endfunction

	function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass 

`endif 
