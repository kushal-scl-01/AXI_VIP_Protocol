`ifndef AXI_MASTER_DRIVER_SV
`define AXI_MASTER_DRIVER_SV

class axi_master_driver extends uvm_driver #(axi_master_seq_item);

	//factory registration
	`uvm_component_utils(axi_master_driver)

	//callback registration 
	`uvm_register_cb(axi_master_driver,axi_master_callback)

	//queue type handle of axi_master_seq_item for synchronization 
	axi_master_seq_item write_addr_q[$];
	axi_master_seq_item write_data_q[$];
	axi_master_seq_item write_resp_q[$];
	axi_master_seq_item read_addr_q[$];
	axi_master_seq_item read_data_q[$];

	//semaphore for write response and handhsking signals 
	semaphore write_resp_sem = new(1);
	semaphore read_handhshake_sem = new(1);


	//semaphore declaration for synchronization 
	semaphore sem1 = new(1);
	semaphore sem2 = new(1);
	semaphore sem3 = new(1);
	semaphore sem4 = new(1);
	
	//constructor 
	function new(string name = "axi_master_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//handle of interface 
	virtual intf vintf;

/*	task run_phase(uvm_phase phase);
		forever begin 
			//reset condition 
			if(!vintf.aresetn) begin
				vintf.mas_drv_cb.awvalid <= 1'b0;
				vintf.mas_drv_cb.wvalid <= 1'b0;
				vintf.mas_drv_cb.arvalid <= 1'b0;
				wait(vintf.aresetn);
			end
			
			//wait for reset to deassert 
			wait(vintf.aresetn);

			//get seq_item from sequence 
			seq_item_port.get(req);
			$display("After get in master driver");
			req.print();

			$cast(seq_item_h,req.clone());
			seq_item_q.push_back(seq_item_h);
			
			//drive inputs to DUT 
			drive_to_dut(req);
		end 
	endtask 
	
	//method to drive the signals 
	virtual task drive_to_dut(axi_master_seq_item req);
		$display("master driver drive to dut : ",$time);
		req.print();
		req = seq_item_q.pop_front();
		fork
			drive_write_addr(req);
			drive_write_data(req);
			get_write_response(req);
			drive_read_addr(req);
			drive_read_handshaking_signal(req);
		join_none
	endtask 

	task drive_write_addr(axi_master_seq_item req);
		sem1.get(1);
		@(vintf.mas_drv_cb);
		`uvm_info("WRITE_ADDR","Inside Write address",UVM_LOW)
		vintf.mas_drv_cb.awid <= req.AWID;
		vintf.mas_drv_cb.awaddr <= req.start_write_addr;
		vintf.mas_drv_cb.awlen <= req.awlen;
		vintf.mas_drv_cb.awsize <= req.awsize;
		vintf.mas_drv_cb.awburst <= req.write_burst_type_e;
		vintf.mas_drv_cb.awvalid <= 1'b1;
	
		@(posedge vintf.mas_drv_cb iff (vintf.mas_drv_cb.awready==1));

		//seq_item_port.put_response(rsp);

		`uvm_do_callbacks(axi_master_driver,axi_master_callback,deasserting_awvalid())
		
		vintf.mas_drv_cb.awvalid <= 1'b0;
		$display($time," After driving awvalid 0");
		sem1.put(1);
	endtask

	task drive_write_data(axi_master_seq_item req);
		sem2.get(1);
		`uvm_info("WRITE_DATA","Inside Write data",UVM_LOW)
		@(posedge vintf.mas_drv_cb iff (vintf.mas_drv_cb.awready==1));
		for(int i=0;i<(req.awlen+1);i++) begin
			vintf.mas_drv_cb.wid <= req.AWID;
			vintf.mas_drv_cb.wdata <= req.wdata_q[i];
			vintf.mas_drv_cb.wlast <= (i==req.awlen) ? 1'b1:1'b0;

			foreach(req.wstrb_q[i]) begin
				$display("req.wstrb[%0d] : %4b",i,req.wstrb_q[i]);
			end 
			vintf.mas_drv_cb.wstrb <= req.wstrb_q.pop_front();

			vintf.mas_drv_cb.wvalid <= 1'b1;
			@(posedge vintf.mas_drv_cb iff (vintf.mas_drv_cb.wready==1));
		end 
			
			`uvm_do_callbacks(axi_master_driver,axi_master_callback,deasserting_wvalid())

			vintf.mas_drv_cb.wvalid <= 1'b0;
			vintf.mas_drv_cb.wlast <= 1'b0;
			sem2.put(1);
	endtask 

	task get_write_response(axi_master_seq_item req);
		sem4.get();
		`uvm_info("WRITE_RESP","Inside Write response",UVM_LOW)
		@(posedge vintf.mas_drv_cb iff (vintf.mas_drv_cb.bvalid == 1));
			vintf.mas_drv_cb.bready <= 1'b1;
		sem4.put();
	endtask 


	task drive_read_addr(axi_master_seq_item req);
		sem3.get();
			`uvm_info("READ_ADDR","Inside Read address",UVM_LOW)
			@(vintf.mas_drv_cb iff vintf.wlast);
			vintf.mas_drv_cb.arid <= req.ARID;
			vintf.mas_drv_cb.araddr <= req.start_read_addr;
			vintf.mas_drv_cb.arlen <= req.arlen;
			vintf.mas_drv_cb.arsize <= req.arsize;
			vintf.mas_drv_cb.arburst <= req.read_burst_type_e;
			vintf.mas_drv_cb.arvalid <= 1'b1;

			$display("inside read addr");
			req.print();

			@(vintf.mas_drv_cb iff (vintf.mas_drv_cb.arready==1));
				vintf.mas_drv_cb.arvalid <= 1'b0;
		sem3.put();
	endtask

	task drive_read_handshaking_signal(axi_master_seq_item req);
		$display("in driver handshaking : ",$time);
		@(posedge vintf.mas_drv_cb iff(vintf.mas_drv_cb.rvalid == 1));
				
				vintf.mas_drv_cb.rready <= 1'b1;
			
	endtask 
*/
	
	virtual task run_phase(uvm_phase phase);
		axi_master_seq_item seq_item_h;
		wait(!vintf.aresetn);
			initialization();
		fork
			forever begin 
				seq_item_h = new();
				seq_item_port.get(req);
				req.print();
				if(req != null) begin 
					$cast(seq_item_h,req.clone);
					if(req.trans_type_e == WRITE) begin 
						write_addr_q.push_back(seq_item_h);
						write_data_q.push_back(seq_item_h);
						write_resp_q.push_back(seq_item_h);
					end 
					if(req.trans_type_e == READ) begin 
						read_addr_q.push_back(seq_item_h);
					end 
				end 
				//write_addr_q.push_back(seq_item_h);
				//write_data_q.push_bacn(seq_item_h);
				seq_item_h.print();
			end 
			drive_write_addr();
			drive_write_data();
			drive_write_response();
			drive_read_addr();
			drive_read_handshaking_signal();
		join
	endtask

	virtual task drive_write_addr();
		axi_master_seq_item seq_item_h;
		forever @(vintf.mas_drv_cb) begin 
			wait(write_addr_q.size != 0);
			seq_item_h = write_addr_q.pop_front();
		//	@(vintf.mas_drv_cb);
				vintf.mas_drv_cb.awvalid <= 1'b1;
				vintf.mas_drv_cb.awid <= seq_item_h.AWID;
				vintf.mas_drv_cb.awaddr <= seq_item_h.start_write_addr;
				vintf.mas_drv_cb.awlen <= seq_item_h.awlen;
				vintf.mas_drv_cb.awsize <= seq_item_h.awsize;
				vintf.mas_drv_cb.awburst <= int'(seq_item_h.write_burst_type_e);
				@(vintf.mas_drv_cb iff vintf.awready);
				vintf.mas_drv_cb.awvalid <= 1'b0;

				//callback 
		end 
	endtask 

	virtual task drive_write_data();
		axi_master_seq_item seq_item_h;
		forever @(vintf.mas_drv_cb) begin 
			wait(write_data_q.size != 0);
			//TIME : Trasaction 
			seq_item_h = write_data_q.pop_front();
			//TIME 
			for(int i=0; i<=seq_item_h.awlen; i++) begin 
				//TIME
				//@(vintf.mas_drv_cb);
				//TIME 
					vintf.mas_drv_cb.wvalid <= 1'b1;
					vintf.mas_drv_cb.wid <= seq_item_h.AWID;
					vintf.mas_drv_cb.wdata <= seq_item_h.wdata_q[i];
					vintf.mas_drv_cb.wstrb <= seq_item_h.wstrb_q[i];
					//Values 
					if(seq_item_h.awlen==i) vintf.mas_drv_cb.wlast <= 1'b1;
					else vintf.mas_drv_cb.wlast <= 1'b0;
					//TIME 
					@(vintf.mas_drv_cb iff vintf.wready);
			end 
			vintf.mas_drv_cb.wvalid <= 1'b0;
			vintf.mas_drv_cb.wlast <= 1'b0;
		end 
	endtask 

	virtual task drive_write_response();
		write_resp_sem.get();
	//wait(write_resp_q.size != 0);
		@(vintf.mas_drv_cb iff vintf.bvalid);
			vintf.mas_drv_cb.bready <= 1'b1;
		write_resp_sem.put();
	endtask 

		virtual task drive_read_addr();
		axi_master_seq_item seq_item_h;
		forever begin 
			wait(vintf.wlast);
			wait(vintf.bvalid && vintf.bready);
			wait(read_addr_q.size != 0);
			seq_item_h = read_addr_q.pop_front();
			@(vintf.mas_drv_cb);
				vintf.mas_drv_cb.arvalid <= 1'b1;
				vintf.mas_drv_cb.arid <= seq_item_h.ARID;
				vintf.mas_drv_cb.araddr <= seq_item_h.start_read_addr;
				vintf.mas_drv_cb.arlen <= seq_item_h.arlen;
				vintf.mas_drv_cb.arsize <= seq_item_h.arsize;
				vintf.mas_drv_cb.arburst <= int'(seq_item_h.read_burst_type_e);
				@(vintf.mas_drv_cb iff vintf.arready);
				vintf.mas_drv_cb.arvalid <= 1'b0;

				//callback 
		end 
	endtask

	virtual task drive_read_handshaking_signal();
		forever begin 
			read_handhshake_sem.get();
			//@(vintf.mas_drv_cb);
				//vintf.mas_drv_cb.rready <= 1'b0;
				//wait(vintf.mas_drv_cb.rvalid)
				@(vintf.mas_drv_cb iff (vintf.mas_drv_cb.rvalid));
					vintf.mas_drv_cb.rready <= 1'b1;
			read_handhshake_sem.put();
		end 
	endtask


	/*virtual task drive_read_handshaking_signal();
		read_handhshake_sem.get();
			@(vintf.mas_drv_cb);
				vintf.mas_drv_cb.rready <= 1'b1;
		read_handhshake_sem.put();
	endtask 
*/
	virtual task initialization();
		vintf.mas_drv_cb.awvalid <= 'd0;
		vintf.mas_drv_cb.awid <= 'd0;
		vintf.mas_drv_cb.awaddr <= 'd0;
		vintf.mas_drv_cb.awlen <= 'd0;
		vintf.mas_drv_cb.awsize <= 'd0;
		vintf.mas_drv_cb.awburst <= 'd0;
		vintf.mas_drv_cb.wvalid <= 'd0;
		vintf.mas_drv_cb.wid <= 'd0;
		vintf.mas_drv_cb.wstrb <= 'd0;
		vintf.mas_drv_cb.wdata <= 'd0;
		vintf.mas_drv_cb.arvalid <= 'd0;
		vintf.mas_drv_cb.arid <= 'd0;
		vintf.mas_drv_cb.araddr <= 'd0;
		vintf.mas_drv_cb.arlen <= 'd0;
		vintf.mas_drv_cb.arsize <= 'd0;
		vintf.mas_drv_cb.arburst <= 'd0;
		vintf.mas_drv_cb.wlast <= 'd0;
		vintf.mas_drv_cb.bready <= 'd0;
		vintf.mas_drv_cb.arvalid <= 'd0;
		vintf.mas_drv_cb.rready <= 'd0;
		wait(vintf.aresetn);
	endtask 

endclass 

`endif


