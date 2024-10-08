`ifndef AXI_MASTER_AGENT_SV
`define AXI_MASTER_AGENT_SV

class axi_master_agent extends uvm_agent;

	//factory registration 
	`uvm_component_utils(axi_master_agent)
	
	//handle of driver, monitor and sequencer 
	axi_master_driver drv_h;
	axi_master_seqr seqr_h;
	axi_master_monitor mon_h;

	//handle of master config 
	axi_master_config master_config;

	//handle of interface 
	virtual intf vintf;

	//constructor 
	function new(string name = "axi_master_agent", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//create all component of master agent 
	//driver, monitor and sequencer 
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		
		//get master_config here
		if(!uvm_config_db #(axi_master_config)::get(this,"","master_config",master_config)) begin
			`uvm_fatal("AXI_MASTER_AGENT","AXI Master Config is not available")
		end 
		
		//create monitor driver and sequencer based on the configuration
		//of master agent 
		mon_h = axi_master_monitor::type_id::create("mon_h",this);
		if(master_config.is_active == UVM_ACTIVE) begin
			drv_h = axi_master_driver::type_id::create("drv_h",this);
			seqr_h = axi_master_seqr::type_id::create("seqr_h",this);
		end

		//get virtual interface through config_db 
		if(!uvm_config_db #(virtual intf)::get(this,"","mas_vintf",vintf)) begin
			`uvm_fatal("AXI_MASTER_AGENT","Virtual interface is not available")
		end
	endfunction

	//connect driver with sequencer 
	//connect interface with driver and monitor 
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(master_config.is_active == UVM_ACTIVE) begin
			drv_h.seq_item_port.connect(seqr_h.seq_item_export);
			drv_h.vintf = this.vintf;
		end 
		mon_h.vintf = this.vintf;
	endfunction 

endclass

`endif 
