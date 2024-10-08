`ifndef AXI_MASTER_MONITOR_SV
`define AXI_MASTER_MONITOR_SV

class axi_master_monitor extends uvm_monitor;

	//factory registration 
	`uvm_component_utils(axi_master_monitor)

	//handle of interface 
	virtual intf vintf;

	//handle of slave seq item 
	axi_master_seq_item seq_item_h [bit [3:0]];

	//analysis port
	uvm_analysis_port #(axi_master_seq_item) seq_item_mas_mon_port;

	//constructor 
	function new(string name = "axi_master_monitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase (uvm_phase phase);
		super.build_phase(phase);
		seq_item_mas_mon_port = new("seq_item_mas_mon_port",this);
	endfunction

	task run_phase(uvm_phase phase);
		wait(vintf.aresetn);
		fork
			sample_write_data();
			send_data_scr();
		join	
	endtask 
	
	virtual task sample_write_data();
		forever @(vintf.mas_mon_cb) begin 
			//@( vintf.mas_mon_cb); 
			wait (vintf.mas_mon_cb.wvalid && vintf.mas_mon_cb.wready); 
				`uvm_info("WRITE_DATA","recieved wvalid and wready",UVM_LOW)
				if(!seq_item_h.exists(vintf.mas_mon_cb.wid)) begin
					`uvm_info("WRITE_DATA","Check if wid Exists",UVM_LOW)
					seq_item_h[vintf.mas_mon_cb.wid] = axi_master_seq_item::type_id::create($sformatf("seq_item_h[%0d]",vintf.mas_mon_cb.wid));
				end
				//else begin 
					seq_item_h[vintf.mas_mon_cb.wid].WID = vintf.mas_mon_cb.wid;	
					seq_item_h[vintf.mas_mon_cb.wid].wdata_q.push_back(vintf.mas_mon_cb.wdata);
					seq_item_h[vintf.mas_mon_cb.wid].wstrb_q.push_back(vintf.mas_mon_cb.wstrb);
				//end
				if(vintf.mas_mon_cb.wlast)
					seq_item_h[vintf.mas_mon_cb.wid].write_resp_type_e = resp_type'(vintf.mas_mon_cb.bresp);
				//data_q.push_back(seq_item_h[vintf.slv_mon_cb.wid]);

				$display("inside master monitor sample write data task");
				seq_item_h[vintf.mas_mon_cb.wid].print();
		end 
	endtask

	virtual task send_data_scr();
		forever begin 
			@(vintf.mas_mon_cb);
			wait(vintf.mas_mon_cb.wlast && vintf.mas_mon_cb.wvalid);
			@(negedge vintf.aclk);
		//	mem_h.write_data(seq_item_h[vintf.slv_mon_cb.wid]);
		//	seq_item_h[vintf.slv_mon_cb.wid].read_flag = 1'b0;
			seq_item_mas_mon_port.write(seq_item_h[vintf.mas_mon_cb.wid]);
		end 
	endtask 



	virtual task sample_monitor_data();
		
	endtask 

endclass 

`endif 
