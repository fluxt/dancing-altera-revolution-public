module audio ( // toplevel
input logic               CLOCK_50,
input logic       [3:0]   KEY,
input logic       [3:0]   SW,

input logic               AUD_ADCDAT,
input logic               AUD_BCLK,
input logic               AUD_ADCLRCK,
input logic               AUD_DACLRCK,
output logic              AUD_DACDAT,
output logic              AUD_XCK,
output logic              I2C_SCLK,
output logic              I2C_SDAT,

// output logic           SRAM_UB_N,    //SRAM  Chip Enable
//                        SRAM_LB_N,    //SRAM  Upper Bit
//                        SRAM_CE_N,    //SRAM  Lower Bit
//                        SRAM_OE_N,    //SRAM  Output Enable
//                        SRAM_WE_N,    //SRAM  Write Enable
// output logic  [19:0]   SRAM_ADDR,    //SRAM  Address
// input  logic  [15:0]   SRAM_DQ,      //SRAM  Data

output logic              FL_WE_N,      //FLASH Write Enable
                          FL_RST_N,     //FLASH Reset
                          FL_WP_N,      //FLASH Write Protect
                          FL_CE_N,      //FLASH Chip Enable
                          FL_OE_N,      //FLASH Output Enable
input  logic              FL_RY,        //FLASH Ready Busy Output
output logic  [22:0]      FL_ADDR,      //FLASH Address
input  logic  [7 :0]      FL_DQ         //FLASH Data

);

logic        reset_ah;  // The push buttons are active low
// logic        init, init_finish, adc_full, data_over;
logic [31:0] delay, delay_count;
logic [31:0] addr; // 16kHz counter
logic [15:0] data;

assign reset_ah = ~KEY[0];

// assign SRAM_UB_N = 1'b0;
// assign SRAM_LB_N = 1'b0;
// assign SRAM_CE_N = 1'b0;
// assign SRAM_OE_N = 1'b0;
// assign SRAM_WE_N = 1'b1;
// assign addr = SRAM_ADDR;
// assign data = {SRAM_DQ[7:0], SRAM_DQ[15:8]};

assign FL_WE_N = 1'b1;
assign FL_RST_N = 1'b1;
assign FL_WP_N = 1'b0;
assign FL_CE_N = 1'b0;
assign FL_OE_N = 1'b0;
assign FL_ADDR = addr[22:0];
assign data = { {2{FL_DQ[7]}}, FL_DQ[6:0], {7{FL_DQ[0]}} }; // hackish volume control. 16 = 2 + 7 + 7;

always_ff @(posedge CLOCK_50)
begin
    if (reset_ah == 1) // End of addr: 595FEE
    begin
            delay_count <= 0;
            addr <= 0;
    end
    else if (SW[0])
    begin
        if (delay_count == 32'd1042) // 50MHz/48kHz ~= 1041.67 ~= 1042
        begin
            delay_count <= 0;
            addr <= addr + 1;
        end
        else
        begin
            delay_count <= delay_count + 1;
        end
    end
end

// you see, I could write a state machine for the audio controller, but there seems to be no functionality issues

audio_interface ai (
    .clk(CLOCK_50),
    .Reset(reset_ah),

    .INIT(),
    .INIT_FINISH(),
    .adc_full(),
    .data_over(),

    .LDATA(data),   // 16 bit speaker output
    .RDATA(data),   // 16 bit speaker output
    .ADCDATA(),     // 32 bit microphone input

    .AUD_ADCDAT(AUD_ADCDAT),
    .AUD_BCLK(AUD_BCLK),
    .AUD_ADCLRCK(AUD_ADCLRCK),
    .AUD_DACLRCK(AUD_DACLRCK),
    .AUD_DACDAT(AUD_DACDAT),
    .AUD_MCLK(AUD_XCK),
    .I2C_SCLK(I2C_SCLK),
    .I2C_SDAT(I2C_SDAT)
);

// hex_driver hex0 (addr[3 :0 ], HEX0);
// hex_driver hex1 (addr[7 :4 ], HEX1);
// hex_driver hex2 (addr[11:8 ], HEX2);
// hex_driver hex3 (addr[15:12], HEX3);
// hex_driver hex4 (addr[19:16], HEX4);
// hex_driver hex5 (addr[23:20], HEX5);
// hex_driver hex6 (addr[27:24], HEX6);
// hex_driver hex7 (addr[31:28], HEX7);


endmodule
