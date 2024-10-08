/*
`ifndef AXI_SLAVE_DRIVER_SV
`define AXI_SLAVE_DRIVER_SV

class axi_slave_driver extends uvm_driver #(axi_slave_seq_item);

	//factory registration
	`uvm_component_utils(axi_slave_driver)

	//callback registration 
	`uvm_register_cb(axi_slave_driver,axi_slave_callback)

	//handle of axi memory 
	axi_memory mem_h;

	//handle of sequence item 
	axi_slave_seq_item read_data_q[$];
	axi_slave_seq_item write_resp_q[$];

	//constructor 
	function new(string name = "axi_slave_driver", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//handle of interface 
	virtual axi_slave_intf vintf;

	task run_phase(uvm_phase phase);
		axi_slave_seq_item req;
		wait(!vintf.aresetn);
		initialization();
		fork
			forever begin 
				fork 
					begin
						forever begin 
							seq_item_port.get_next_item(req);
							`uvm_info("SLAVE_DRV","Packet recieved in slave driver",UVM_LOW)
							req.print();
							if(req.read_flag) read_data_q.push_back(req);
							else write_resp_q.push_back(req);
							seq_item_port.item_done();
						end 
					end 
					begin 
						wait(!vintf.aresetn);
							initialization();
					end 
				join_any 
				disable fork;
				wait(vintf.aresetn);
			end 
			write_addr_resp();
			write_data_resp();
			write_resp();
			send_read_data();
			read_addr_resp();
		join
	endtask 

	virtual task write_addr_resp();
		forever begin 
			@(vintf.slv_drv_cb);
				vintf.slv_drv_cb.awready <= 1'b0;
				wait(vintf.slv_drv_cb.awvalid)
				`uvm_do_callbacks(axi_slave_driver,axi_slave_callback,wait_for_awready())

					vintf.slv_drv_cb.awready <= 1'b1;
		end 
	endtask

	virtual task write_data_resp();
		forever begin 
		@(vintf.slv_drv_cb);
				vintf.slv_drv_cb.wready <= 1'b0;
				wait(vintf.slv_drv_cb.wvalid)
					`uvm_do_callbacks(axi_slave_driver,axi_slave_callback,wait_for_wready())
					vintf.slv_drv_cb.wready <= 1'b1;
		end 
	endtask 

	virtual task write_resp();
		axi_slave_seq_item seq_item_h;
		forever begin 
			wait(write_resp_q.size != 0);
			seq_item_h = write_resp_q.pop_front();
			@(vintf.slv_drv_cb);
				wait(vintf.slv_drv_cb.wlast && vintf.slv_drv_cb.wready && vintf.slv_drv_cb.wvalid);
				vintf.slv_drv_cb.bvalid <= 1'b1;
				vintf.slv_drv_cb.bid <= seq_item_h.AWID;
				vintf.slv_drv_cb.bresp <= resp_type'(seq_item_h.slv_write_resp_type_e);
		
		do 
			begin 
				@(vintf.slv_drv_cb);
			end 
		while(!vintf.slv_drv_cb.bready);

			//@(vintf.slv_drv_cb iff (vintf.slv_drv_cb.bready==0));
				vintf.slv_drv_cb.bvalid <= 1'b0;
		end 
	endtask 

	virtual task send_read_data();
		axi_slave_seq_item seq_item_h;
		forever begin
			wait(read_data_q.size != 0);
			wait(vintf.slv_drv_cb.arvalid && vintf.slv_drv_cb.arready);
			seq_item_h = read_data_q.pop_front();

			for(int i=0; i<=(seq_item_h.arlen+1); i++) begin 
				@(vintf.slv_drv_cb);
					vintf.slv_drv_cb.rvalid <= 1'b1;
					vintf.slv_drv_cb.rid <= seq_item_h.ARID;
					vintf.slv_drv_cb.rdata <= seq_item_h.rdata_q[i];

				do 
					begin 
						@(vintf.slv_drv_cb);
					end 
				while(!vintf.slv_drv_cb.rready);
					//@(vintf.slv_drv_cb iff (vintf.slv_drv_cb.rready==0));
						vintf.slv_drv_cb.rvalid <= 1'b0;
				if(i == (seq_item_h.arlen)) vintf.slv_drv_cb.rlast <= 1'b1;

			end
				vintf.slv_drv_cb.rlast <= 1'b0;
		end 
	endtask

	virtual task read_addr_resp();
		forever begin 
			@(vintf.slv_drv_cb);
				wait(vintf.slv_drv_cb.arvalid);
				vintf.slv_drv_cb.arready <= 1'b1;
				@(vintf.slv_drv_cb) vintf.slv_drv_cb.arready <= 1'b0;
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

*/












/*
	task run_phase(uvm_phase phase);
		forever begin 
		if(!vintf.aresetn) begin 
			vintf.awready <= 1'b0;
			vintf.wready  <= 1'b0;
			vintf.bvalid  <= 1'b0;
			vintf.arready <= 1'b0;
			vintf.rvalid  <= 1'b0;
			mem_h.init();
			wait(vintf.aresetn);
		end 

		wait(vintf.aresetn);
		fork
			forever begin 
				seq_item_port.get(req);
				$display("after get in slave driver");
				req.print();
				fork 
				drive_write_resp(req);
				drive_read_data(req);
				join
			end 
			drive_handshaking_signals();
		join
		end 
	endtask 
	
	//method to drive the signals 
	virtual task drive_handshaking_signals();
	forever begin
		fork 
			begin 
				@(posedge vintf.slv_drv_cb);
					if (vintf.awvalid==1) begin
						`uvm_do_callbacks(axi_slave_driver,axi_slave_callback,wait_for_awready())
						vintf.slv_drv_cb.awready <= 1'b1;
					end
			end 
			begin
				@(posedge vintf.slv_drv_cb);
				if (vintf.slv_drv_cb.wvalid==1) begin
					`uvm_do_callbacks(axi_slave_driver,axi_slave_callback,wait_for_wready())
					vintf.slv_drv_cb.wready <= 1'b1;
				end
			end
			begin
				@(posedge vintf.slv_drv_cb);
				if(vintf.slv_drv_cb.arvalid==1) begin
					vintf.slv_drv_cb.arready <= 1'b1;
				end 
			end 
			join_any
			end
	endtask 

	virtual task drive_write_resp(axi_slave_seq_item req);
	forever begin 
		@(posedge vintf.slv_drv_cb);
			if(vintf.slv_drv_cb.wlast==1) begin
				vintf.slv_drv_cb.bid <= req.AWID; 
				vintf.slv_drv_cb.bresp <= 2'b00;
				vintf.slv_drv_cb.bvalid <= 1'b1;
			end 
	end
	endtask


	task drive_read_data(axi_slave_seq_item req);
		forever begin
			`uvm_info("DRIVE_READ_DATA",$sformatf("Transaction received in slave driver : %s",req.sprint()),UVM_LOW)
			@(posedge vintf.slv_drv_cb);
				if(vintf.slv_drv_cb.arready==1) begin
					vintf.slv_drv_cb.rid <= req.ARID;
					$display("req ARID : %0d",req.ARID);
					vintf.slv_drv_cb.rdata <= req.rdata_q.pop_front();
					vintf.slv_drv_cb.rresp <= 2'b00;
					vintf.slv_drv_cb.rvalid <= 1'b1;
					if(req.rdata_q.size() == 1) vintf.slv_drv_cb.rlast <= 1'b1;
					else vintf.slv_drv_cb.rlast <= 1'b0;
				end 
		end 
	endtask
*/
/*
endclass 

`endif 
*/

