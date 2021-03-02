//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper (
                       input              Clk, Reset, run,
                       input              is_sprite,          // Whether current pixel belongs to sprite 
                                                              //   or background
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;

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
    
    logic [31:0] x, y, x_sprite, y_sprite;
    assign x = {{22{1'b0}}, DrawX}; 
    assign y = {{22{1'b0}}, DrawY};
    assign x_sprite = ((y+delay)%60);
    assign y_sprite = (x%60);

    // Assign color based on is_ball signal
    always_comb
    begin
        if (DrawX < 270 && DrawY >=28 && DrawY < 32)
        begin
        	Red = 8'hff;
        	Green = 8'h00;
        	Blue = 8'h00;
        end
        else if (is_sprite == 1'b1) 
        begin
            // White ball
            Red = x_sprite[7:0] + y_sprite[7:0];
            //Green = 8'hff;
            //Blue = 8'hff;
            Green = x_sprite[7:0] + y_sprite[7:0];
            Blue = x_sprite[7:0] + y_sprite[7:0];
        end
        else
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end

    //logic [31:0] addr;
    //logic rom_data;
    //assign addr = ((y+delay)/60)*4 + (x/60); // 120 pixels / 60Hz * 60 bpm / (60 seconds per minute)
    //mem_block rom(.rom_addr(addr[9:0]), .rom_data(rom_data));

endmodule
