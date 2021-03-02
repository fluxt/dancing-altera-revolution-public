module keyboard_controller (
									input [15:0] keycode,
									output R_pressed, D_pressed, U_pressed, L_pressed
									);

			always_comb
			begin
				L_pressed = 0;
				R_pressed = 0;
				D_pressed = 0;
				U_pressed = 0;
				case(keycode[15:8])
					8'h04 : L_pressed = 1;
					8'h07 : R_pressed = 1;
					8'h1A : U_pressed = 1;
					8'h16 : D_pressed = 1;
				endcase
				
				case(keycode[7:0])
					8'h04 : L_pressed = 1;
					8'h07 : R_pressed = 1;
					8'h1A : U_pressed = 1;
					8'h16 : D_pressed = 1;
				endcase
			end
									
endmodule