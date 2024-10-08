`ifndef AXI_SLAVE_DRIVER_BK_SV
`define AXI_SLAVE_DRIVER_BK_SV 

class axi_slave_driver extends uvm_driver #(axi_slave_seq_item);
	
	//factory registration
	`uvm_component_utils(axi_slave_driver)

	//handle of axi_slave_seq_item 
	axi_slave_seq_item seq_item_h_temp;
	axi_slave_seq_item seq_item_h_read;
	axi_slave_seq_item write_resp_q[$];
	axi_slave_seq_item read_data_q[$];

	//callback registration 
	`uvm_register_cb(axi_slave_driver,axi_slave_callback)
	
	//constructor 
	function new(string name = "axi_slave_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//handle of interface 
	virtual axi_slave_intf vintf;

	//handle of axi memory 
	axi_memory mem_h;
	
	semaphore sem1 = new(1);
	semaphore sem2 = new(1);

	virtual task run_phase (uvm_phase phase);
		axi_slave_seq_item seq_item_h;
		wait(!vintf.aresetn);
			initialization();
		fork
			forever begin 
				fork
					begin 
						forever begin
							seq_item_h = new();
							seq_item_port.get_next_item(req);
							//seq_item_port.get(req);
							$display("Packet recieved from slave sequence");
							req.print();
							$cast(seq_item_h_temp,req.clone());
							$cast(seq_item_h_read,req.clone());
							//if(req.slv_trans_type_e == READ) begin 
							if(req.read_flag) begin 
							read_data_q.push_back(seq_item_h_read);
							$display($time ,"read data queueeee : %0p",read_data_q);
							end
							else begin
							write_resp_q.push_back(req);
							end 
							seq_item_port.item_done();
						end 
					end 
					begin 
						wait(!vintf.aresetn);
							//initialization();
					end 
				join_any
				disable fork;
							initialization();
			//	wait(vintf.aresetn);
			end
			write_addr_handshaking_signal();
			write_data_handshaking_signal();
			read_addr_handshaking_signal();
			drive_write_response();
			drive_read_data();
		join 

	endtask

	virtual task write_addr_handshaking_signal();
		forever begin 
			@(vintf.slv_drv_cb);
				vintf.slv_drv_cb.awready <= 1'b0;
				wait(vintf.slv_drv_cb.awvalid)
					vintf.slv_drv_cb.awready <= 1'b1;
		end 
	endtask 

	virtual task write_data_handshaking_signal();
		forever begin 
			@(vintf.slv_drv_cb);
				vintf.slv_drv_cb.wready <= 1'b0;
				wait(vintf.slv_drv_cb.wvalid)
					vintf.slv_drv_cb.wready <= 1'b1;
		end 
	endtask

	virtual task drive_write_response();
		axi_slave_seq_item seq_item_h;
		forever begin
	//		sem1.get();
			wait(write_resp_q.size != 0);
				seq_item_h = write_resp_q.pop_front();
				$display("Response channel");
				wait(vintf.slv_drv_cb.wvalid && vintf.slv_drv_cb.wready && vintf.slv_drv_cb.wlast);
				//@(vintf.slv_drv_cb);
					vintf.slv_drv_cb.bvalid <= 1'b1;
					vintf.slv_drv_cb.bid <= seq_item_h.AWID;
					vintf.slv_drv_cb.bresp <= resp_type'(seq_item_h.slv_write_resp_type_e);
					do begin @(vintf.slv_drv_cb); end 
					while (!vintf.slv_drv_cb.bready);
					flag = 1'b1;
					vintf.slv_drv_cb.bvalid <= 1'b0;
		//		sem1.put();
		end 
	endtask

	virtual task drive_read_data();
		axi_slave_seq_item seq_item_h;
	forever /*@(vintf.slv_drv_cb)*/ begin 
			//wait(vintf.slv_drv_cb.arvalid && vintf.slv_drv_cb.arready);
			wait(read_data_q.size != 0);
			
			seq_item_h = read_data_q.pop_front();
			//if(seq_item_h.read_flag) 
			//TODO: Print 
			 `uvm_info($sformatf("%0d_%s",`__LINE__,get_name()),$sformatf("READ_DATA_QUEUE %0d",read_data_q.size),UVM_LOW)
			 `uvm_info($sformatf("%0d_%s",`__LINE__,get_name()),$sformatf("in slave driver : seq item h : %0s",seq_item_h.sprint()),UVM_LOW)
			for(int i=0; i<=seq_item_h.arlen; i++) begin
				$display("size of arlen in read data task in slave : %0d",seq_item_h.arlen);
				@(vintf.slv_drv_cb);
					vintf.slv_drv_cb.rvalid <= 1'b1;
					vintf.slv_drv_cb.rid <= seq_item_h.ARID;
			 `uvm_info($sformatf("%0d_%s",`__LINE__,get_name()),$sformatf("Driving read data : %0h",seq_item_h.rdata_q[i]),UVM_LOW)
					vintf.slv_drv_cb.rdata <= seq_item_h.rdata_q[i];
			
					if(i==(seq_item_h.arlen)) vintf.slv_drv_cb.rlast <= 1'b1;
					else vintf.slv_drv_cb.rlast <= 1'b0;
				
			do begin @(vintf.slv_drv_cb); end 
				while(!vintf.slv_drv_cb.rready);

			end 
			vintf.slv_drv_cb.rvalid <= 1'b0;
			vintf.slv_drv_cb.rlast <= 1'b0;
			$display("RID in slave read data task : %0d",vintf.slv_drv_cb.rid);
		//	seq_item_h.rdata_q.delete();
		end 
	endtask 

/*
	virtual task drive_read_data();
	//	axi_slave_seq_item seq_item_h;
		forever begin 
			sem2.get();
			wait(vintf.slv_drv_cb.arvalid && vintf.slv_drv_cb.arready);
		//	wait(read_data_q.size != 0);
		//	seq_item_h = read_data_q.pop_front();
			$display("drive read data");
			for(int i=0;i<=$size(seq_item_h_read.rdata_q);i++) begin 
				@(vintf.slv_drv_cb);
					vintf.slv_drv_cb.rvalid <= 1'b1;
					vintf.slv_drv_cb.rid <= seq_item_h_read.ARID;
					vintf.slv_drv_cb.rdata <= seq_item_h_read.rdata_q[i];
				//	$disaplay("seq_item_h : read_data queue : %0p",seq_item_h.rdata_q);

					@(vintf.slv_drv_cb iff vintf.rready);

					//do begin @(vintf.slv_drv_cb); end 
					//while (!vintf.slv_drv_cb.rready);
						vintf.slv_drv_cb.rvalid <= 1'b0;
					if(i == (seq_item_h_read.arlen+1)) vintf.slv_drv_cb.rlast <= 1'b1;
			end 
					vintf.slv_drv_cb.rlast <= 1'b0;
			sem2.put();
		end 
	endtask 
*/
	virtual task read_addr_handshaking_signal();
		forever begin 
			@(vintf.slv_drv_cb);
				wait(vintf.slv_drv_cb.arvalid);
					vintf.slv_drv_cb.arready <= 1'b1;
				@(vintf.slv_drv_cb)
					vintf.slv_drv_cb.arready <= 1'b0;
		end 
	endtask 

	virtual task initialization();
		vintf.slv_drv_cb.awready <= 1'b0;
		vintf.slv_drv_cb.arready <= 1'b0;
		vintf.slv_drv_cb.wready <= 1'b0;
		vintf.slv_drv_cb.bid <= 1'b0;
		vintf.slv_drv_cb.bresp <= 1'b0;
		vintf.slv_drv_cb.bvalid <= 1'b0;
		vintf.slv_drv_cb.rid <= 1'b0;
		vintf.slv_drv_cb.rdata <= 1'b0;
		vintf.slv_drv_cb.rresp <= 1'b0;
		vintf.slv_drv_cb.rlast <= 1'b0;
		vintf.slv_drv_cb.rvalid <= 1'b0;
		wait(vintf.aresetn);
	endtask 


endclass 

`endif 
