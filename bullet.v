module bullet(clk,resetn,tx,ty,td,ready,fire,bx,by,bd,start);
	input clk,resetn,start;//xe tank san sang
	input [7:0] tx; 
	input [6:0] ty; 
	input [1:0] td; 
	input ready; // kiem tra xem vien dan co san sang de dc ban k
	input fire; //cho phep ban
	output reg [7:0] bx; 
	output reg [6:0] by; 
	output reg [2:0] bd; 
	
	//khai bao bien
	reg [2:0] current_state,next_state;	//trang thai
	reg divider_enable; // bat dau` bo dem
	reg [19:0] dividerout; // counter
	reg divider; // 1 cycle bo dem
	//khai bao cac trang thai
	localparam   
					WAIT = 3'd0,   
					READY = 3'd1,  
					UP      = 3'd2,
					DOWN    = 3'd3,
					LEFT    = 3'd4,
					RIGHT   = 3'd5;				
		// su chuyen trang thai
		always@(*)
		begin: state_table 
				case (current_state)
					WAIT: next_state = start ? READY : WAIT;
					READY: begin 
								if(!fire)// cho phep ban
									next_state = READY;
								else begin 
									case(td) 
										2'd0: next_state = UP;
										2'd1: next_state = DOWN;
										2'd2: next_state = LEFT;
										2'd3: next_state = RIGHT;
									endcase
								end
							end
					UP: next_state = ready ? READY : UP;
					DOWN: next_state = ready ? READY : DOWN;
					LEFT: next_state = ready ? READY : LEFT;
					RIGHT: next_state = ready ? READY : RIGHT;
					default: next_state = READY;
				endcase
		end
												 
		//ke thua` trang thai
		always@(posedge clk)
		begin: state_FFs
			if(!resetn) 
				current_state <= WAIT;
			else // 
				current_state <= next_state;
		end 
		// trien khai tung qua trinh xay ra trong tung trang thai
		always @(*)
		begin: output_logic
			divider_enable = 1'b0;
			bd = 3'd0;
			case (current_state) 
				READY: begin 
					divider_enable = 1'b0; 
					bd = 3'd0;
					end
				UP: begin
					divider_enable = 1'b1;
					bd = 3'b100;
					end
				DOWN: begin
					divider_enable = 1'b1;
					bd = 3'b101;
					end
				LEFT: begin
					divider_enable = 1'b1;
					bd = 3'b110;
					end
				RIGHT: begin
					divider_enable = 1'b1;
					bd = 3'b111;
					end
			endcase
		end
		// bo dem
	always @(posedge clk)
		begin:ratedivider
			if(!resetn)begin
				dividerout <=  20'd0;
				divider <= 1'd0;
				end
			else if(dividerout == 20'b10100000010100000111)begin
				dividerout <= 20'd0;
				divider <= 1'd1;
				end
			else if(divider_enable == 1'd0)begin
				dividerout <= 20'd0;
				divider <= 1'd0;
				end
			else begin
				dividerout <= dividerout + 1'b1;
				divider <= 1'd0;
				end
		end
	
	always @(posedge clk)
		begin
			if(!bd[2])begin //bit thu 3 kiem tra xem co vien dan k ? neu k thi cap nhat trang thai cua xe tank
				bx <= tx;
				by <= ty;
				end
			else if(divider == 1'd1)begin
				case(bd[1:0])
					2'd0: begin 
						bx <= bx;
						by <= by-1'd1;
						end
					2'd1: begin 
						bx <= bx;
						by <= by+1'd1;
						end
					2'd2: begin 
						bx <= bx-1'd1;
						by <= by;
						end
					2'd3: begin 
						bx <= bx+1'd1;
						by <= by;
						end
				endcase
			end
			else begin
				bx <= bx;
				by <= by;
				end
		end
endmodule 
