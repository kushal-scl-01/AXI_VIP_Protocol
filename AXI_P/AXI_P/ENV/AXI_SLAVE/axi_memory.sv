`ifndef AXI_MEM_SV
`define AXI_MEM_SV

typedef bit[((`DATA_WIDTH/8)-1):0] strb_queue[$];

class axi_memory extends uvm_component;

	//=====================================================//
	//            factory registration                    //
	//===================================================//
	`uvm_component_utils(axi_memory)

	//==================================================//
	//                constructor                       //
	//==================================================//
	function new(string name = "axi_memory",uvm_component parent = null);
		super.new(name,parent);
	endfunction

	//==================================================//
	//Memory declaration : considering memory of 1 byte //
	//==================================================//
	bit [7:0] slv_mem [int];

	bit[((`DATA_WIDTH/8)-1):0] rstrb_q[$];


	//==================================================//
	// Type 				: function 
	// Use 					: Write data into memory 
	// Return type 	: void 
	// Argument 		: Seq_item type handle
	// Description 	: 1. calculate address according to the burst type 
	//								2. Write data into the memory based on address and strobe 
	//==================================================//
	function void write_data(axi_slave_seq_item req);

		burst_calc(req.start_write_addr,
							 req.awlen,
							 req.awsize,
							 req.slv_write_burst_type_e,
							 req.addr_q);

		//`uvm_info("WRITE_DATA_MEM",$sformatf("Address array size : %0d",$size(req.addr_q)),UVM_LOW) 
		$display($time,": size of address array :%0d",$size(req.addr_q));
		for(int i = 0; i <= $size(req.addr_q); i++) begin
       int n = 0;
			// `uvm_info("WRITE_DATA_MEM",$sformatf("size of strb : %0b",$size(req.wstrb_q[i])),UVM_LOW)
      $display($time," : size of strb %0d",$size(req.wstrb_q[i]));
      for(int j = 0; j <= $size(req.wstrb_q[i]); j++) begin
        if(req.wstrb_q[i][j]) begin
          slv_mem[req.addr_q[i]+n] = req.wdata_q[i][j*8 +: 8];
        	n++;
        end
      end
    end
    `uvm_info("WRITE_DATA_MEM","Writing data to Memory",UVM_LOW)
		foreach(slv_mem[i]) begin
			//`uvm_info("MEM",$sformatf("MEM [%0h] : %0h",i,slv_mem[i]),UVM_LOW)
      $display("MEM[%0h]: %0h", i, slv_mem[i]);
    end	

	endfunction
	
/*	function void read_data(axi_slave_seq_item req);
	  req.print();	
		
		burst_calc(req.start_read_addr,
							 req.arlen,
							 req.arsize,
							 req.slv_read_burst_type_e,
							 req.addr_q);

		$display($time," : inside read data function in memory");
			
		for(int i=0;i<$size(req.addr_q);i++) begin
		int m=0;
		$display("size of addr_q : %0d",$size(req.addr_q));
	//	$display("address : %0h ||||| read data : %0h",req.addr_q[i],req.rdata_q[i]);
			if(slv_mem.exists(req.addr_q[i]+m)) begin
				req.rdata_q.push_back(slv_mem[req.addr_q[i]+m]);
				$display("Address : %0h | read data : %0h",req.addr_q[i],req.rdata_q[i]);
			end
			else begin 
				`uvm_info("READ_DATA","No data presents on that address",UVM_LOW)
			end 
			m++;
		end
		`uvm_info("READ_DATA_MEM","Reading data from Memory",UVM_LOW)
	endfunction
*/
	function void read_data (axi_slave_seq_item trns_h);
    int burst;
    int data;
    int n;
    `uvm_info(get_name(),"READ MEMORY FUNCTION STARTED",UVM_LOW) 

		burst_calc(trns_h.start_read_addr,
							 trns_h.arlen,
							 trns_h.arsize,
							 trns_h.slv_read_burst_type_e,
							 trns_h.araddr_q);

		 rstrb_q =  strobe_calc(trns_h.start_read_addr, trns_h.arlen,4 ,trns_h.arsize);

		foreach(trns_h.araddr_q[i]) begin
      $display(" READ Addr Queue[%0d]: %0h", i, trns_h.araddr_q[i]);
      $display(" READ strb Queue[%0d]: %0d", i, rstrb_q[i]);
    end
      $display(" READ Addr Queue size %0d",  trns_h.araddr_q.size);
      $display(" READ strb Queue size %0d",  rstrb_q.size);
    for(int i = 0; i <= trns_h.araddr_q.size(); i++) begin
      data =0;
      n = 0;
      
      for(int k = 0; k < $size(rstrb_q[k]); k++)begin

       if(rstrb_q[i][k]) begin
         if(slv_mem.exists(trns_h.araddr_q[i]+n)) begin
           data[k*8 +: 8] = slv_mem[trns_h.araddr_q[i]+n];
           $display("mem %0h",slv_mem[trns_h.araddr_q[i]+n]);
         end
           $display("Rdata : %0h", data);
           n++;
      end
      end
           trns_h.rdata_q.push_back(data);
    end
      $display(" READ data Queue size %0d",  trns_h.rdata_q.size);
    `uvm_info(get_name(),"READ MEMORY FUNCTION COMPLETED",UVM_LOW) 
    trns_h.print();
 
  endfunction


	function void init();
		//slv_mem.delete();
		`uvm_info("INIT_MEM","Memory is in initial state",UVM_LOW)
	endfunction

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
