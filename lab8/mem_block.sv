module mem_block(
					input[10:0] rom_addr,
					output rom_data
					);
					
reg rom [0:1399];
assign rom_data = rom[rom_addr];

initial begin
	$readmemb("utopia_easy.txt", rom);
end
					
endmodule