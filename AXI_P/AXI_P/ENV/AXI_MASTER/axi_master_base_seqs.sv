`ifndef AXI_MAS_BASE_SEQS_SV
`define AXI_MAS_BASE_SEQS_SV 

class axi_master_base_seqs extends uvm_sequence #(axi_master_seq_item);

	//factory registration 
	`uvm_object_utils(axi_master_base_seqs)

	//handle of axi master sequence item 
	axi_master_seq_item req;

	//no of times want to repeat the transaction 
	rand int no_of_trans;
	int cnt;
	
	//declared soft constraint for no of trans as 1 
	constraint trans {soft no_of_trans == 1;}

	task wait_for_trans_done(int no_of_trans);
		wait(cnt==no_of_trans);
		cnt=0;
	endtask	

	function void response_handler(uvm_sequence_item response);
	  cnt++;
	  $display($time," : response_handler cnt %0d",cnt);
	endfunction

	task pre_start();
		use_response_handler(1);
	endtask 
	
	//constructor 
	function new(string name = "axi_master_base_seqs");
		super.new(name);
	endfunction

endclass 

`endif 
