`ifndef AXI_MASTER_CALLBACK_SV
`define AXI_MASTER_CALLBACK_SV 

class axi_master_callback extends uvm_callback;

	//constructor 
	function new(string name = "axi_master_callback");
		super.new(name);
	endfunction

	//empty task deasserting the awvalid for some delay 
	virtual task deasserting_awvalid();
	endtask

	//empty task deasserting the wvalid for some delay 
	virtual task deasserting_wvalid();
	endtask 

endclass 

`endif 
