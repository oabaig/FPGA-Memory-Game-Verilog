//ECE 5440
//Omar Baig 8007
//counts to 100 everytime enable is high
module countToN(clk, rst, enable, timeout, N);

	input clk, rst, enable;
	input [9:0] N;
	output timeout;
	reg timeout;

	reg [9:0] count;

	always @(posedge clk)
		begin
			if(timeout == 1)
				begin
					count <= 0;
					timeout <= 0;
				end
			else if(rst == 0)
				begin
					count <= 0;
					timeout <= 0;
				end
			else if(enable == 1)
				begin
					count <= count + 1;
					if(count == N)
						timeout <= 1;
				end
		end 
endmodule