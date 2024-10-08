`ifndef AXI_SCOREBOARD_SV 
`define AXI_SCOREBOARD_SV 

`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class axi_scoreboard extends uvm_scoreboard;

	//factory registration 
	`uvm_component_utils(axi_scoreboard);

	//port to collect data from master monitor
	uvm_analysis_imp_master #(axi_master_seq_item,axi_scoreboard) master_export;

	//port to collect data from slave monitor  
	uvm_analysis_imp_slave #(axi_slave_seq_item,axi_scoreboard) slave_export;

	//instance of master and slave seq item 
	axi_master_seq_item mas_h;
	axi_slave_seq_item slv_h;

	//instance of slave seq item type queue for write and read operation 
	axi_slave_seq_item slv_write_op_q[$];
	axi_slave_seq_item slv_read_op_q[$];

	axi_master_seq_item master_trans_queue[$];
	axi_slave_seq_item slave_trans_queue[$];

	int temp_wdata[$];
	int temp_rdata_q[$];

	bit[((`DATA_WIDTH/8)-1):0] rstrb_q[$];

	//reference memory 
	int mem[int];

	//constructor 
	function new(string name = "axi_scoreboard", uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		master_export = new("master_export",this);
		slave_export  = new("slave_export",this);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		fork
			write_data();
			read_data();
		join
	endtask

	function void write_master (axi_master_seq_item trans_mas);
		`uvm_info("WRITE_SCOREBOARD_MAS",$sformatf("Packet recieved in master write : %0s",trans_mas.sprint()),UVM_LOW)
		master_trans_queue.push_back(trans_mas);
	endfunction

	function void write_slave (axi_slave_seq_item trans_slv);
		//wait(trans_slv.awvalid && trans_slv.awready);
		`uvm_info("WRITE_SCOREBOARD_SLV",$sformatf("Packet recieved in slave write : %0s",trans_slv.sprint()),UVM_LOW)
		slave_trans_queue.push_back(trans_slv);
	endfunction

/*	function void write_memory();
		axi_slave_seq_item tr_slv;
		axi_master_seq_item tr_mas;
		
		wait((slave_trans_queue.size && master_trans_queue.size) != 0);
		tr_slv = slave_trans_queue.pop_front();
		tr_mas = master_trans_queue.pop_front();

		`uvm_info("SCOREBOARD",$sformatf("master transaction : %0s",tr_mas.sprint()),UVM_LOW)
		`uvm_info("SCOREBOARD",$sformatf("slave transaction : %0s",tr_slv.sprint()),UVM_LOW)

		//if(tr_slv[tr_slv.AWID] == tr_mas[tr_mas.WID]) begin 
			mem[tr_slv.start_write_addr] = tr_mas.wdata_q[i];
		//end 

	endfunction
*/
	task write_data();
		forever begin 
			axi_slave_seq_item tr_slv;
		
			wait((slave_trans_queue.size) != 0);
			tr_slv = slave_trans_queue.pop_front();
			//tr_mas = master_trans_queue.pop_front();

			//`uvm_info("SCOREBOARD_WRITE",$sformatf("master transaction : %0s",tr_mas.sprint()),UVM_LOW)
			`uvm_info("SCOREBOARD_WRITE",$sformatf("slave transaction : %0s",tr_slv.sprint()),UVM_LOW)

			/*burst_calc(tr_slv.start_write_addr,
							 tr_slv.awlen,
							 tr_slv.awsize,
							 tr_slv.slv_write_burst_type_e,
							 tr_slv.addr_q);
			*/
		
			//`uvm_info("WRITE_DATA_MEM",$sformatf("Address array size : %0d",$size(req.addr_q)),UVM_LOW) 
			$display($time,": size of address array :%0d",$size(tr_slv.addr_q));
			for(int i = 0; i <= $size(tr_slv.addr_q); i++) begin
      	int n = 0;
				//`uvm_info("WRITE_DATA_MEM",$sformatf("size of strb : %0b",$size(req.wstrb_q[i])),UVM_LOW)
      	$display($time," : size of strb %0d",$size(tr_slv.wstrb_q[i]));
      	for(int j = 0; j <= $size(tr_slv.wstrb_q[i]); j++) begin
        	if(tr_slv.wstrb_q[i][j]) begin
          mem[tr_slv.addr_q[i]+n] = tr_slv.wdata_q[i][j*8 +: 8];
        	n++;
        end
      end
    end
    `uvm_info("SCOREBOARD_MEM","Writing data to Memory in scoreboard",UVM_LOW)
		foreach(mem[i]) begin
			//`uvm_info("MEM",$sformatf("MEM [%0h] : %0h",i,mem[i]),UVM_LOW)
      $display("MEM[%0h]: %0h", i, mem[i]);
    end	
	end 
	endtask

	task read_data ();
		forever begin 
			axi_slave_seq_item tr_slv;
			axi_master_seq_item tr_mas;

    	int burst;
    	int data;
    	int n;
    	`uvm_info(get_name(),"READ MEMORY FUNCTION STARTED",UVM_LOW) 

			wait((slave_trans_queue.size && master_trans_queue.size) != 0);
			tr_slv = slave_trans_queue.pop_front();
			tr_mas = master_trans_queue.pop_front();

			`uvm_info("SCOREBOARD_READ",$sformatf("master transaction : %0s",tr_mas.sprint()),UVM_LOW)
			`uvm_info("SCOREBOARD_READ",$sformatf("slave transaction : %0s",tr_slv.sprint()),UVM_LOW)

			burst_calc(tr_slv.start_read_addr,
								 tr_slv.arlen,
								 tr_slv.arsize,
								 tr_slv.slv_read_burst_type_e,
								 tr_slv.araddr_q);

		 	rstrb_q =  strobe_calc(tr_slv.start_read_addr, tr_slv.arlen,4 ,tr_slv.arsize);

			foreach(tr_slv.araddr_q[i]) begin
      	$display(" READ Addr Queue[%0d]: %0h", i, tr_slv.araddr_q[i]);
      	$display(" READ strb Queue[%0d]: %0d", i, rstrb_q[i]);
    	end
      $display(" READ Addr Queue size %0d",  tr_slv.araddr_q.size);
      $display(" READ strb Queue size %0d",  rstrb_q.size);
    	for(int i = 0; i <= tr_slv.araddr_q.size(); i++) begin
      	data =0;
      	n = 0;   
      	for(int k = 0; k < $size(rstrb_q[k]); k++)begin
       		if(rstrb_q[i][k]) begin
         		if(mem.exists(tr_slv.araddr_q[i]+n)) begin
           		data[k*8 +: 8] = mem[tr_slv.araddr_q[i]+n];
           		$display("mem %0h",mem[tr_slv.araddr_q[i]+n]);
         		end
          $display("Rdata : %0h", data);
          n++;
      	end
      end
      temp_rdata_q.push_back(data);
    end
    //$display(" READ data Queue size %0d",  trns_h.rdata_q.size);
   	//`uvm_info(get_name(),"READ MEMORY FUNCTION COMPLETED",UVM_LOW) 
   	//trns_h.print();
 	end 
 endtask 
	
	function void burst_calc(input bit [`ADDR_WIDTH-1:0] start_write_addr,
									input bit [3:0] awlen,
									input bit [2:0] awsize,
									input burst_type slv_write_burst_type_e,
									output bit [`ADDR_WIDTH-1:0] addr_q[]);
		bit [`ADDR_WIDTH-1:0] LBL;     //Lower boundary lane 
		bit [`ADDR_WIDTH-1:0] UBL;     //Upper boundary lane

		addr_q = new[(awlen+1)];

		$display("inside burst calc function"); 
		if(slv_write_burst_type_e == FIXED) begin 
			foreach(addr_q[i]) addr_q[i] = start_write_addr;
		end

		else if(slv_write_burst_type_e == INCR) begin 
			addr_q[0] = start_write_addr;
			$display("BURST_CALC : Start_write_addr : %h",start_write_addr);
			foreach(addr_q[i]) begin
			if(i!=0) addr_q[i] = addr_q[i-1] + (2**awsize);
			$display("BURST_CALC : addr_q [%0d] : %0h",i,addr_q[i]); 
			end
		end 

		else if(slv_write_burst_type_e == WRAP) begin
			addr_q[0] = start_write_addr;
			LBL = int'(start_write_addr/((2**awsize)*(awlen))) / ((2**awsize)*(awlen));
			UBL = LBL + ((2**awsize)*(awlen));
			$display("Lower boundary : %0d || Upper boundary : %0d",LBL,UBL);
			foreach(addr_q[i]) begin
				if(addr_q[i] == UBL) addr_q[i] = LBL;
				else addr_q[i] = addr_q[i-1] + (2**awsize);
			end 
		end 

	endfunction 

function strb_queue strobe_calc (int start_addr, int burst_len, int byte_lanes, int size);
    int LBL, UBL;
     bit[((`DATA_WIDTH/8)-1):0]strb_q[$];
    bit[((`DATA_WIDTH/8)-1):0] strb;

    repeat(burst_len+1) begin
      strb = 0;
      LBL = start_addr % byte_lanes;
      
      start_addr = (int'(start_addr/2**size)) * (2**size);
      
      UBL = start_addr  + ((2**size) - 1) - ((int'(start_addr/byte_lanes))*byte_lanes); 
      
      $display("value of LBL %0d", LBL);
      $display("value of UBL %0d", UBL);
      
      for(int i = LBL; i <= UBL; i ++) begin
        strb[i] = 1'b1;
      end
      start_addr += (2**size);
      $display("value of strb : %b",strb); 
      strb_q.push_back(strb);

    end
    return strb_q;
  endfunction


endclass 

`endif 
