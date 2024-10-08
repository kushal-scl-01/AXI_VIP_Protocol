`ifndef AXI_SLAVE_SEQ_ITEM_SV
`define AXI_SLAVE_SEQ_ITEM_SV

//enum to select the burst type 
//typedef enum bit [1:0] {FIXED,INCR,WRAP} burst_type;

//enum to select write or read operation 
//typedef enum bit {WRITE,READ} trans_type;

//enum to select response type 
//typedef enum bit [1:0] {OKAY,EXOKAY,SLVERR,DECERR} resp_type;

class axi_slave_seq_item extends uvm_sequence_item;
	
	//enum to set transaction : write or read transaction 
	//WRITE : Write transaction and READ : Read transaction 
	trans_type slv_trans_type_e;

	//Write Address Channel signals 
	bit [3:0] AWID;
	bit [`ADDR_WIDTH-1:0] start_write_addr;
	//rand bit [`ADDR_WIDTH-1:0] awaddr_q[$];
	rand bit [`ADDR_WIDTH-1:0] addr_q[];
	bit [3:0] awlen; 
	bit [2:0] awsize; 
	burst_type slv_write_burst_type_e;

	//write data channel signals 
	bit [3:0] WID;
	bit [`DATA_WIDTH-1:0] wdata_q[$];
	bit [(`DATA_WIDTH/8)-1:0] wstrb_q[$];

	//write response channel 
	bit [3:0] BID;
	resp_type slv_write_resp_type_e;

	//read address channel signals
	bit [3:0] ARID;
	bit [`ADDR_WIDTH-1:0] start_read_addr;
	bit [`ADDR_WIDTH-1:0] araddr_q[$];
	bit [3:0] arlen;
	bit [2:0] arsize;
	burst_type slv_read_burst_type_e;

	//read flag to indicate read transfer
	bit read_flag;

	//read data channel signals 
	bit [3:0] RID;
	rand bit [`DATA_WIDTH-1:0] rdata_q[$];
	resp_type slv_read_resp_type_e;

	//factory registration
	`uvm_object_utils_begin(axi_slave_seq_item)
		`uvm_field_enum(trans_type,slv_trans_type_e,UVM_ALL_ON)
		`uvm_field_int(AWID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(start_write_addr, UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(burst_type,slv_write_burst_type_e,UVM_ALL_ON)
		`uvm_field_int(awlen,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(awsize,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_array_int(addr_q,UVM_ALL_ON | UVM_DEC)
		`uvm_field_int(WID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_queue_int(wdata_q,UVM_ALL_ON | UVM_HEX)
		`uvm_field_queue_int(wstrb_q,UVM_ALL_ON | UVM_BIN)
		`uvm_field_int(BID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_enum(resp_type,slv_write_resp_type_e,UVM_ALL_ON)
		`uvm_field_int(ARID,UVM_ALL_ON | UVM_HEX)
		`uvm_field_int(start_read_addr,UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(burst_type,slv_read_burst_type_e,UVM_ALL_ON)
		`uvm_field_int(arlen,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_int(arsize, UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_queue_int(araddr_q,UVM_ALL_ON | UVM_HEX)
		`uvm_field_int(RID,UVM_ALL_ON | UVM_UNSIGNED)
		`uvm_field_queue_int(rdata_q,UVM_ALL_ON | UVM_HEX)
		`uvm_field_enum(resp_type,slv_read_resp_type_e,UVM_ALL_ON)
	`uvm_object_utils_end

	//constructor 
	function new(string name = "axi_slave_seq_item");
		super.new(name);
	endfunction

	constraint read_data_size { rdata_q.size() == arlen+1;}

	//constraint address_q_size { solve awlen before addr_q;
		//													addr_q.size() == awlen+1;}

	/*function void post_randomize();
		burst_calc();
	endfunction

	task burst_calc();

	//	addr = new[(awlen+1)];

		bit [`ADDR_WIDTH-1:0] LBL;     //Lower boundary lane 
		bit [`ADDR_WIDTH-1:0] UBL;     //Upper boundary lane
		$display("burst_type : "); 
		if(slv_write_burst_type_e == FIXED) begin 
			foreach(addr_q[i]) addr_q[i] = start_write_addr;
		end

		else if(slv_write_burst_type_e == INCR) begin 
			addr_q[0] = start_write_addr;
			foreach(addr_q[i]) addr_q[i] = addr_q[i-1] + (2**awsize);
		end 

		else if(slv_write_burst_type_e == WRAP) begin
			addr_q[0] = start_write_addr;
			LBL = int'(start_write_addr/((2**awsize)*(awlen))) / ((2**awsize)*(awlen));
			UBL = LBL + ((2**awsize)*(awlen));
			foreach(addr_q[i]) begin
				if(addr_q[i] == UBL) addr_q[i] = LBL;
				else addr_q[i] = addr_q[i-1] + (2**awsize);
			end 
		end 

	endtask 
*/


endclass

`endif
