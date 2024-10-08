`ifndef AXI_SLAVE_AGENT_SV
`define AXI_SLAVE_AGENT_SV

class axi_slave_agent extends uvm_agent;

	//factory registration 
	`uvm_component_utils(axi_slave_agent)
	
	//handle of driver, monitor and sequencer 
	axi_slave_driver drv_h;
	axi_slave_seqr seqr_h;
	axi_slave_monitor mon_h;
	axi_memory mem_h;

	//handle of master config 
	axi_slave_config slave_config;

	//handle of interface 
	virtual axi_slave_intf vintf;

	//constructor 
	function new(string name = "axi_slave_agent", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//create all component of master agent 
	//driver, monitor and sequencer 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		//get slave_config here
			if(!uvm_config_db #(axi_slave_config)::get(this,"","slave_config",slave_config)) begin
			`uvm_fatal("AXI_SLAVE_AGENT","AXI Slave Config is not available")
		end 
		
		mon_h = axi_slave_monitor::type_id::create("mon_h",this);
		if(slave_config.is_active == UVM_ACTIVE) begin
			drv_h = axi_slave_driver::type_id::create("drv_h",this);
			seqr_h = axi_slave_seqr::type_id::create("seqr_h",this);
		end
		mem_h = axi_memory::type_id::create("mem_h",null);

		//get virtual interface through config_db 
		if(!uvm_config_db #(virtual axi_slave_intf)::get(this,"","slv_vintf",vintf)) begin
			`uvm_fatal("AXI_SLAVE_AGENT","Virtual interface is not available")
		end


	endfunction

	//connect driver with sequencer 
	//connect interface with driver and monitor 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(slave_config.is_active == UVM_ACTIVE) begin
			drv_h.seq_item_port.connect(seqr_h.seq_item_export);
			drv_h.vintf = vintf;
			mon_h.seq_item_mon_port.connect(seqr_h.seq_item_mon_export);
			drv_h.mem_h = this.mem_h;
			seqr_h.mem_h = this.mem_h;
		end 
		mon_h.vintf = vintf;
		mon_h.mem_h = this.mem_h;
	endfunction 

endclass

`endif 

