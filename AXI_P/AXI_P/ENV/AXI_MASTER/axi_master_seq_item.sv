`ifndef AXI_MASTER_SEQ_ITEM_SV
`define AXI_MASTER_SEQ_ITEM_SV

//enum to select the burst type 
typedef enum bit [1:0] {FIXED,INCR,WRAP} burst_type;

//enum to select write or read operation 
typedef enum bit {WRITE,READ} trans_type;

//enum to select response type 
typedef enum bit [1:0] {OKAY,EXOKAY,SLVERR,DECERR} resp_type;

class axi_master_seq_item extends uvm_sequence_item;

	//enum to set transaction : write or read transaction
	//WRITE : Write transaction & READ : Read transaction 
	rand trans_type trans_type_e;
	
	//Write Address Channel signals 
	rand bit [3:0] AWID;
	rand bit [`ADDR_WIDTH-1:0] start_write_addr;
	//rand bit [`ADDR_WIDTH-1:0] awaddr_q[$];
	rand bit [3:0] awlen; 
	rand bit [2:0] awsize; 
	rand burst_type write_burst_type_e;

	//write data channel signals 
	bit [3:0] WID;
	rand bit [`DATA_WIDTH-1:0] wdata_q[$];
	rand bit [(`DATA_WIDTH/8)-1:0] wstrb_q[$];

	//write response channel 
	bit [3:0] BID;
	resp_type write_resp_type_e;

	//global variable for strobe 
	// bit[((`DATA_WIDTH/8)-1):0] strb = 'd0;
	
	//read address channel signals
	rand bit [3:0] ARID;
	rand bit [`ADDR_WIDTH-1:0] start_read_addr;
	//rand bit [`ADDR_WIDTH-1:0] araddr_q[$];
	rand bit [3:0] arlen;
	rand bit [2:0] arsize;
	rand burst_type read_burst_type_e;

	//read data channel signals 
	bit [3:0] RID;
	bit [`DATA_WIDTH-1:0] rdata;
	resp_type read_resp_type_e;

	int queue[$];
	
	//factory registration
	`uvm_object_utils_begin(axi_master_seq_item)
		`uvm_field_enum(trans_type,trans_type_e,UVM_ALL_ON)
		`uvm_field_int(AWID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(start_write_addr, UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(burst_type,write_burst_type_e,UVM_ALL_ON)
		`uvm_field_int(awlen,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(awsize,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(WID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_queue_int(wdata_q,UVM_ALL_ON | UVM_HEX)
		`uvm_field_queue_int(wstrb_q,UVM_ALL_ON | UVM_BIN)
		`uvm_field_int(BID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_enum(resp_type,write_resp_type_e,UVM_ALL_ON)
		`uvm_field_int(ARID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(start_read_addr, UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(burst_type,read_burst_type_e,UVM_ALL_ON)
		`uvm_field_int(arlen,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(arsize,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(RID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(rdata,UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(resp_type,read_resp_type_e,UVM_ALL_ON)
	`uvm_object_utils_end

	//constructor 
	function new(string name = "axi_master_seq_item");
		super.new(name);
	endfunction

	//Constraint for master 
	constraint data_size {
												solve awlen before wdata_q;
												wdata_q.size() == awlen + 1;
											 }

	constraint strb_size {
												solve awlen before wstrb_q;
												wstrb_q.size() == awlen + 1;
											 }

	constraint awlen_val_wrap {
														 solve write_burst_type_e before awlen;
														 if(write_burst_type_e == WRAP) awlen inside {1,3,7,15};
														}

	constraint aligned_addr_wrap {
			solve write_burst_type_e before start_write_addr;
			solve awsize before start_write_addr;
			if(write_burst_type_e == WRAP) 
				start_write_addr == int'(start_write_addr/(2**awsize))*(2**awsize);
	}

	constraint unique_id {
		foreach(queue[i]) {
		if(i>0) !(AWID inside {queue});
		}
	}

	//4KB means 4^12 = 4096
	//starting address % 4^12 and add this rem into the data size 
	//That must be less than 4^12
	constraint not_exceed_4K_boundary {
		solve awsize before start_write_addr;
		solve awlen before start_write_addr;
		(int'(start_write_addr) % 4096)+((2**awsize)*(awlen+1)) < 4096;
	}

	function void post_randomize();
		queue.push_back(AWID);
		foreach(queue[i]) 
			$display("1 : queue_post_randomize : %0d",queue[i]);
		$display("queue_size : %0d",queue.size());
		if(queue.size == 16) begin
			$display("inside post randomize if");
			queue.delete();
		end
		$display("queue_post_randomize : %0p",queue);
		strobe_calc(start_write_addr, awlen, (`DATA_WIDTH/8) , awsize);
		//wstrb_q.push_back(strb);
	endfunction
	
	function void strobe_calc (int unsigned start_addr, int burst_len, int byte_lanes, int size);
    int LBL, UBL;
    bit[((`DATA_WIDTH/8)-1):0] strb = 'd0;

		if(wstrb_q.size()!=0) begin 
			wstrb_q.delete();
		end 

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
      wstrb_q.push_back(strb);
    end
  endfunction


endclass 

`endif 
