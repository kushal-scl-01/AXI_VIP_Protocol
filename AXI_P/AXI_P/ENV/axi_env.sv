`ifndef AXI_ENVIRONMENT_SV
`define AXI_ENVIRONMENT_SV

class axi_env extends uvm_env;
	
	//factory registration 
	`uvm_component_utils(axi_env)

	//constructor 
	function new(string name = "axi_env", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//handle of master and slace config 
	axi_master_config master_config;
	axi_slave_config slave_config;

	//handle of master and slave agent 
	axi_master_agent mas_agent;
	axi_slave_agent slv_agent;

	//instance od scoreboard 
	axi_scoreboard scr_h;

	//to set the configuration 
	//to create master and slave agent
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		//create master config and slave config 
		master_config = axi_master_config::type_id::create("master_config");
		slave_config = axi_slave_config::type_id::create("slave_config");

		//set the configuration for master and slave
		uvm_config_db #(axi_master_config)::set(this,"mas_agent*","master_config",master_config);

		//slave_config.is_active = UVM_PASSIVE;
		uvm_config_db #(axi_slave_config)::set(this,"slv_agent*","slave_config",slave_config);

		//create master agent and slave agent 
		mas_agent = axi_master_agent::type_id::create("mas_agent",this);
		slv_agent = axi_slave_agent::type_id::create("slv_agent",this);

		scr_h = axi_scoreboard::type_id::create("scr_h",this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		mas_agent.mon_h.seq_item_mas_mon_port.connect(scr_h.master_export);
		slv_agent.mon_h.seq_item_mon_port.connect(scr_h.slave_export);
	endfunction

endclass 

`endif 
