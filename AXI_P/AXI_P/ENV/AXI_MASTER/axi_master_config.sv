`ifndef AXI_MASTER_CONFIG_SV
`define AXI_MASTER_CONFIG_SV

class axi_master_config extends uvm_object;

	//in-built enum : set that enum as active by default 
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	//factory registration 
	`uvm_object_utils_begin(axi_master_config)
		`uvm_field_enum(uvm_active_passive_enum,is_active,UVM_ALL_ON) 
	`uvm_object_utils_end

	//constructor 
	function new(string name = "axi_master_config");
		super.new(name);
	endfunction

endclass 

`endif 
