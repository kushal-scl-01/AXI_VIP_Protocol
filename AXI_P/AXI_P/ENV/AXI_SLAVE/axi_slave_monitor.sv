`ifndef AXI_SLAVE_MONITOR_SV
`define AXI_SLAVE_MONITOR_SV

class axi_slave_monitor extends uvm_monitor;

	//factory registration 
	`uvm_component_utils(axi_slave_monitor)

	//handle of virtual interface 
	virtual axi_slave_intf vintf;

	//handle of slave seq item 
	axi_slave_seq_item seq_item_h [bit [3:0]];

	//handle of memory 
	axi_memory mem_h;
	
	//analysis port
	uvm_analysis_port #(axi_slave_seq_item) seq_item_mon_port;

	axi_slave_seq_item addr_q[$];
	axi_slave_seq_item data_q[$];

	//constructor 
	function new(string name = "axi_slave_monitor", uvm_component parent = null);
		super.new(name,parent);
		seq_item_mon_port = new("seq_item_mon_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mem_h = axi_memory::type_id::create("mem_h",this);
	endfunction

	task run_phase(uvm_phase phase);
		wait(vintf.aresetn);
		fork
			sample_write_addr();
			sample_write_data();
			sample_read_addr();
			send_data_seqr();
//			temp();
		join	
	endtask 


	virtual task sample_write_addr();
		forever begin 
			@(vintf.slv_mon_cb);
			wait (vintf.slv_mon_cb.awvalid && vintf.slv_mon_cb.awready); 
			if(!seq_item_h.exists(vintf.slv_mon_cb.awid)) begin 
				seq_item_h[vintf.slv_mon_cb.awid] = axi_slave_seq_item::type_id::create($sformatf("seq_item_h[%0d]",vintf.slv_mon_cb.awid)); 
			end 
			seq_item_h[vintf.slv_mon_cb.awid].AWID = vintf.slv_mon_cb.awid;
			seq_item_h[vintf.slv_mon_cb.awid].slv_trans_type_e = trans_type'(WRITE);
			seq_item_h[vintf.slv_mon_cb.awid].start_write_addr = vintf.slv_mon_cb.awaddr;
			seq_item_h[vintf.slv_mon_cb.awid].awlen = vintf.slv_mon_cb.awlen;
			seq_item_h[vintf.slv_mon_cb.awid].awsize = vintf.slv_mon_cb.awsize;
			seq_item_h[vintf.slv_mon_cb.awid].slv_write_burst_type_e = burst_type'(vintf.slv_mon_cb.awburst);
			
			seq_item_mon_port.write(seq_item_h[vintf.slv_mon_cb.awid]);
			
			$display("inside address sample task");
		end 
	endtask 

	virtual task sample_write_data();
		forever begin 
			@( vintf.slv_mon_cb); 
			wait (vintf.slv_mon_cb.wvalid && vintf.slv_mon_cb.wready); 
				`uvm_info("WRITE_DATA","recieved wvalid and wready",UVM_LOW)
				if(!seq_item_h.exists(vintf.slv_mon_cb.wid)) begin
					`uvm_info("WRITE_DATA","Check if wid Exists",UVM_LOW)
					seq_item_h[vintf.slv_mon_cb.wid] = axi_slave_seq_item::type_id::create($sformatf("seq_item_h[%0d]",vintf.slv_mon_cb.wid));
				end
				else begin 
					seq_item_h[vintf.slv_mon_cb.wid].WID = vintf.slv_mon_cb.wid;	
					seq_item_h[vintf.slv_mon_cb.wid].wdata_q.push_back(vintf.slv_mon_cb.wdata);
					seq_item_h[vintf.slv_mon_cb.wid].wstrb_q.push_back(vintf.slv_mon_cb.wstrb);
				end 
				seq_item_h[vintf.slv_mon_cb.wid].slv_write_resp_type_e = resp_type'(vintf.slv_mon_cb.bresp);
				data_q.push_back(seq_item_h[vintf.slv_mon_cb.wid]);

				$display($time," : inside data sample task");
				seq_item_h[vintf.slv_mon_cb.wid].print();
			//	seq_item_mon_port.write(seq_item_h[vintf.slv_mon_cb.wid]);
				//if((vintf.slv_mon_cb.wlast==1) && (vintf.slv_mon_cb.wvalid==1)) begin
					//$display("wdata_q size : %0d",seq_item_h[vintf.slv_mon_cb.wid].wdata_q.size());
					//$display("wstrb_q size : %0d",seq_item_h[vintf.slv_mon_cb.wid].wstrb_q.size());
					//mem_h.write_data(seq_item_h[vintf.slv_mon_cb.wid]);
				//	seq_item_h[vintf.slv_mon_cb.wid].read_flag = 1'b0;
			//		seq_item_mon_port.write(seq_item_h[vintf.slv_mon_cb.wid]);
			//	end
		end 
	endtask
/*
	virtual task temp();
		if(flag) begin 
			seq_item_h.delete(vintf.slv_mon_cb.wid);
			flag = 1'b0;
		end 
	endtask 
*/

	virtual task send_data_seqr();
		forever begin 
			@(vintf.slv_mon_cb);
			wait(vintf.slv_mon_cb.wlast && vintf.slv_mon_cb.wvalid);
			@(negedge vintf.aclk);
			mem_h.write_data(seq_item_h[vintf.slv_mon_cb.wid]);
			seq_item_h[vintf.slv_mon_cb.wid].read_flag = 1'b0;
			seq_item_mon_port.write(seq_item_h[vintf.slv_mon_cb.wid]);
		end 
	endtask 


	virtual task sample_read_addr();
		forever begin 
			@( vintf.slv_mon_cb);
			wait(vintf.slv_mon_cb.arvalid && vintf.slv_mon_cb.arready);
			if(!seq_item_h.exists(vintf.slv_mon_cb.arid)) begin 
				seq_item_h[vintf.slv_mon_cb.arid] = axi_slave_seq_item::type_id::create($sformatf("seq_item_h[%0d]",vintf.slv_mon_cb.arid)); 
			end 
			seq_item_h[vintf.slv_mon_cb.arid].ARID = vintf.slv_mon_cb.arid;
			seq_item_h[vintf.slv_mon_cb.arid].slv_trans_type_e = trans_type'(READ);
			seq_item_h[vintf.slv_mon_cb.arid].start_read_addr = vintf.slv_mon_cb.araddr;
			seq_item_h[vintf.slv_mon_cb.arid].arlen = vintf.slv_mon_cb.arlen;
			$display("seq_item_h[vintf.slv_mon_cb.arid].arlen : %0d",seq_item_h[vintf.slv_mon_cb.arid].arlen);
			seq_item_h[vintf.slv_mon_cb.arid].arsize = vintf.slv_mon_cb.arsize;
			seq_item_h[vintf.slv_mon_cb.arid].slv_read_burst_type_e = burst_type'(vintf.slv_mon_cb.arburst);
			seq_item_h[vintf.slv_mon_cb.arid].read_flag = 1'b1;
			
			//wait(vintf.slv_mon_cb.arvalid && vintf.slv_mon_cb.arready);
			//@(vintf.slv_mon_cb);
			//seq_item_h[vintf.slv_mon_cb.arid].read_flag = 1'b0;
			
			$display("inside read address sample task");
			seq_item_mon_port.write(seq_item_h[vintf.slv_mon_cb.arid]);
			//seq_item_h[vintf.slv_mon_cb.arid].read_flag = 1'b0;
			$display("value of read flag at %0t : %0d",$time,seq_item_h[vintf.slv_mon_cb.arid].read_flag);
			seq_item_h[vintf.slv_mon_cb.arid].print();
 
		end 
	endtask

endclass 

`endif 

