module mux_8_to_1 (
  input [2:0] select,     // Entrada de seleção de 3 bits
  input A,
  input B,
  input C,
  input D,
  input E,
  input F,
  input G,
  input H,
  output y// Saída do MUX
);





//assign y = ((select == 3'b000) & data_inputs[0]) | ((select == 3'b001) & data_inputs[1]) | ((select == 3'b010) & data_inputs[2]) | ((select == 3'b011) & data_inputs[3]) | ((select == 3'b100) & data_inputs[4]) | ((select == 3'b101) & data_inputs[5]) | ((select == 3'b110) & data_inputs[6]) | ((select == 3'b111) & data_inputs[7]) ;

assign y = 		(select == 3'b111) ? A :
               (select == 3'b110) ? B :
               (select == 3'b101) ? C :
               (select == 3'b100) ? D :
               (select == 3'b011) ? E :
               (select == 3'b010) ? F :
               (select == 3'b001) ? G :
					H; //3'b000
					
endmodule
