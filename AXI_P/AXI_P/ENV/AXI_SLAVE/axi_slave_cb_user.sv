`ifndef AXI_SLAVE_CB_USER_SV
`define AXI_SLAVE_CB_USER_SV

class axi_slave_cb_user extends axi_slave_callback;

	//constructor
	function new(string name = "axi_slave_cb_user");
		super.new(name);
	endfunction

	task wait_for_awready();
		#40;
	endtask

	task wait_for_wready();
		#30;
	endtask

endclass

`endif
