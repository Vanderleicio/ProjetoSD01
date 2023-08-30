module TRIS(inout PORT, input DIR, input SEND, output READ);
	assign PORT = DIR ? SEND : 1'bz;
	assign READ = DIR ? 1'bz : PORT;
endmodule