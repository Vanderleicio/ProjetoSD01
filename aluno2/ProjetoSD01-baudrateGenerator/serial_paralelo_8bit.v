// Modulo para converter de serial para paralelo sempre que en for habilitada
module serial_paralelo_8bit(input serial,
			    input en,
			    input clk,
			    output wire [7:0] q);
  

  wire clk_control;
  and AND1(clk_control, clk, en);
  
  d_ff d1(serial, clk_control, q[0]);
  d_ff d2(q[0], clk_control, q[1]);
  d_ff d3(q[1], clk_control, q[2]);
  d_ff d4(q[2], clk_control, q[3]);
  d_ff d5(q[3], clk_control, q[4]);
  d_ff d6(q[4], clk_control, q[5]);
  d_ff d7(q[5], clk_control, q[6]);
  d_ff d8(q[6], clk_control, q[7]);  
  
endmodule
