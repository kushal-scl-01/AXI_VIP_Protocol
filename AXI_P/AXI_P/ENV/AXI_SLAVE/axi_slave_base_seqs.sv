`ifndef AXI_SLAVE_BASE_SEQS_SV
`define AXI_SLAVE_BASE_SEQS_SV 

class axi_slave_base_seqs extends uvm_sequence #(axi_slave_seq_item);

	//factory registration 
	`uvm_object_utils(axi_slave_base_seqs)

	//memory of 1 byte 
	bit [7:0] slave_mem [int];

	//handle of slave seq item 
	axi_slave_seq_item req;

	//declaration of p_sequencer 
	`uvm_declare_p_sequencer(axi_slave_seqr)

	//constructor 
	function new(string name = "axi_slave_base_seqs");
		super.new(name);
	endfunction

	task body();
		int temp;
		forever begin
				
			p_sequencer.seq_item_fifo.get(req);

			`uvm_info("SLAVE_BASE_SEQS",$sformatf("In base seqs recieved transaction : %0s",req.sprint()),UVM_LOW)
			`uvm_info("SLAVE_BASE_SEQS",$sformatf("read flag at %0t : %0d",$time,req.read_flag),UVM_LOW)
			if(req.read_flag) begin
				temp = req.ARID;
				$display("temp id : %0h",temp);
				p_sequencer.mem_h.read_data(req);
				req.RID = temp;
				`uvm_send(req);
				`uvm_info("SLAVE_BASE_SEQS",$sformatf("sent from base sequence : %0s",req.sprint()),UVM_LOW)
			end 
			else begin 
				`uvm_send(req);
				`uvm_info("SLAVE_BASE_SEQS",$sformatf("sent response to driver : %0s",req.sprint()),UVM_LOW)
			end 
		end 
	endtask 

endclass 

`endif 
