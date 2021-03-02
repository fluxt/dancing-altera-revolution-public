//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  sprite (input         Clk,                // 50 MHz clock
                              Reset,              // Active-high reset signal
                              run,
                              frame_clk,          // The clock indicating a new frame (~60Hz)
                input [9:0]   DrawX, DrawY,       // Current pixel coordinates
                input [7:0]   Keycode,
                output logic  is_sprite           // Whether current pixel belongs to ball or background
              );

    logic [31:0] delay, delay_count;
    always_ff @(posedge Clk)
    begin
        if (Reset == 1) // End of addr: 595FEE
        begin
                delay_count <= 0;
                delay <= 0;
        end
        else if (run)
        begin
            if (delay_count == 32'd301205) // 50MHz/60Hz * (166bpm/60bpm) ~= 301205
            begin
                delay_count <= 0;
                delay <= delay + 1;
            end
            else
            begin
                delay_count <= delay_count + 1;
            end
        end
    end

    always_comb
    begin
        // Compute whether the pixel corresponds to sprite or background
        if ( rom_data && DrawX < 240 && addr <  1400 ) 
            is_sprite = 1'b1;
        else
            is_sprite = 1'b0;
        
    end

    logic [31:0] x, y;
    logic [31:0] addr;
    logic rom_data;
    assign x = {{22{1'b0}}, DrawX}; 
    assign y = {{22{1'b0}}, DrawY}; 
    assign addr = ((y+delay)/60)*4 + (x/60); // 120 pixels / 60Hz * 60 bpm / (60 seconds per minute)
    mem_block rom(.rom_addr(addr[10:0]), .rom_data(rom_data));
endmodule
