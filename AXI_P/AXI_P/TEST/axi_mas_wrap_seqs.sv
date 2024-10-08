`ifndef AXI_MAS_WRAP_SEQ_SV
`define AXI_MAS_WRAP_SEQ_SV

class axi_master_wrap_seqs extends axi_master_base_seqs;

	//factory registration 
	`uvm_object_utils(axi_master_wrap_seqs)

	bit [`ADDR_WIDTH-1:0] temp_addr;
	int temp_len;
	int temp_size;

	//constructor 
	function new(string name = "axi_master_wrap_seqs");
		super.new(name);
	endfunction

	task body();
		repeat(no_of_trans) begin
			`uvm_info("axi_master_wrap_seqs","Inside body method of master sanity seqs",UVM_LOW)
				`uvm_do_with(req,{write_burst_type_e == WRAP;
													trans_type_e == WRITE;
												//	awlen == 8;
												//	awsize == 2;
												 })
			temp_addr = req.start_write_addr;
			temp_len = req.awlen;
			temp_size = req.awsize;
				`uvm_do_with(req,{read_burst_type_e == WRAP;
													start_read_addr == temp_addr;
													trans_type_e == READ;
													arlen == temp_len;
													arsize == temp_size;
												 })
		end 
	endtask 

endclass

`endif 
