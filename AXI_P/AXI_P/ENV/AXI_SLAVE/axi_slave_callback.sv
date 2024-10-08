`ifndef AXI_SLAVE_CALLBACK_SV
`define AXI_SLAVE_CALLBACK_SV

class axi_slave_callback extends uvm_callback;

	//constructor 
	function new(string name = "axi_slave_callback");
		super.new(name);
	endfunction

	//task for waiting for awready to be asserted 
	virtual task wait_for_awready();
	endtask

	//task for waiting for wready to be asserted 
	virtual task wait_for_wready();
	endtask 

endclass 

`endif 
