`ifndef AXI_MASTER_CB_USER_SV
`define AXI_MASTER_CB_USER_SV

class axi_master_cb_user extends axi_master_callback;

	//constructor
	function new(string name = "axi_master_cb_user");
		super.new(name);
	endfunction

	//method to delay the deasserting for awvalid 
	task deasserting_awvalid();
		#40;
	endtask

	//method to delay the deasserting of wvalid 
	task deasserting_wvalid();
		#30;
	endtask

endclass

`endif
