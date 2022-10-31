//			---------------------------- COIN DISPENSER DESIGN MODULE -----------------------------------

module coin_dispenser_fsm#(	parameter s_reset		= 3'd0,	//Parameter declaration and Assignment of States
				parameter s_invalid_note	= 3'd1,	// States are assigned using Binary code
				parameter s_sel_den		= 3'd2,
				parameter s_processing		= 3'd3,
				parameter s_invalid_denomination= 3'd4,
				parameter s_collect_coins	= 3'd5,
				parameter s_coins_insufficient 	= 3'd6)
			(output insert_note_out,			//Declaration of outputs
			 output [8:0]rs5_coins_out,
			 output [8:0]rs2_coins_out,
			 output [8:0]rs1_coins_out,
			 output invalid_note_out,
			 output select_denomination_out,
			 output invalid_denomination_out,
			 output processing_out,
			 output collect_coins_out,
			 output coins_insufficient_out,
			 input clk_in,					//Declaration of outputs
			 input rst_in,
			 input note_inserted_in,
			 input [2:0]note_code_in,
			 input den_5_2_1_in,
			 input den_5_2_in,
			 input den_5_1_in,
			 input den_2_1_in);
function [26:0]func_rs5;					// function defination of func_rs5
	input [3:0]den_code_func_rs5;				// Denomination selection code
	input [8:0]note_value_func_rs5;				// Note value
	input [10:0]rs5_coins_count_func_rs5;			// number of Rs.5 coins to dispense
	reg [10:0]quotient;					// declaration of required registers
	begin
		quotient = note_value_func_rs5/5;		// To find max number of Rs.5 coins to dispense for given note

		//if denomination is asked in terms of Rs.5, Rs.2 & Rs.1 or Rs.5 & Rs.1
		if(rs5_coins_count_func_rs5 >= (quotient - 1) && (den_code_func_rs5 == 4'b1000 || den_code_func_rs5 == 4'b0010))
		begin
			func_rs5[26:18] = (note_value_func_rs5 - (5*(quotient-1)));	// Leaves Rs.5 to dispense interms of Rs.2 & Rs.1
			func_rs5[17:11] = quotient -1;					// Number of Rs.5 coins to be dispensed
			func_rs5[10:0] = rs5_coins_count_func_rs5 - quotient -1;	// deducting dispensed coins from stack of Rs.5 coins	
		end

		//if denomination is asked in terms of Rs.5 & Rs.2
		else if((rs5_coins_count_func_rs5 >= (quotient - 2)) && den_code_func_rs5 == 4'b0100)
		begin
			func_rs5[26:18] = (note_value_func_rs5 - (5*(quotient - 2)));	// Leave Rs.10 to dispense interms of Rs.2
			func_rs5[17:11] = quotient  - 2;				// Number of Rs.5 coins to be dispensed
			func_rs5[10:0] = rs5_coins_count_func_rs5 - quotient - 2;	// deducting dispensed coins from stack of Rs.5 coins
		end

		// if rs.5 coins are insufficient to dispense max value of coins. Rest of the value needed to be given in denominations of Rs.2 or Rs.1
		else
		begin
			func_rs5[26:18] = (note_value_func_rs5 - (5 * rs5_coins_count_func_rs5));	// Leaves values based on available Rs.5 Coins
			func_rs5[17:11] = rs5_coins_count_func_rs5;					// dispenses all rest of rs.5 coins
			func_rs5[10:0] = 0;								// Stack of Rs.5 coins will be Zero
		end
	end
endfunction

function [27:0]func_rs2;
	input [3:0]den_code_func_rs2;				// Denomination selection code
	input [8:0]note_value_func_rs2;				// Note value
	input [10:0]rs2_coins_count_func_rs2;			// number of Rs.2 coins to dispense
	reg [10:0]quotient;					// declaration of required registers
	reg [10:0]rem;
	begin
		quotient= note_value_func_rs2/2;		// Finds max number of Rs.2 coins to dispense for given note
		rem = note_value_func_rs2/2;			// Finds any value remains, if max number of Rs.2 coins are dispensed based on note

		// if denomination is asked in Rs.5 & Rs.2 or if leaves any remainder after dispensing max number of Rs.2 coins
		if(((rs2_coins_count_func_rs2 >= quotient) && (den_code_func_rs2 == 4'b0100) && rem==0) || ((rs2_coins_count_func_rs2 >= quotient) && rem != 0))
		begin
			func_rs2[27:19] = (note_value_func_rs2 - (2*quotient));		// Leaves note_value to dispense in terms of Rs.1 if deomination not asked in Rs.5 & Rs.2
			func_rs2[18:11] = quotient;					// Number of Rs.2 coins to be dispensed
			func_rs2[10:0] = rs2_coins_count_func_rs2 - quotient;		// Deducting dispensed coins from stack of Rs.2 coins
		end

		// if denomination is asked in Rs.5, Rs.2 & Rs.1 or in Rs.2 & Rs.1
		else if(rs2_coins_count_func_rs2 >= (quotient-1) && (den_code_func_rs2 == 4'b1000 || den_code_func_rs2 == 4'b0001))
		begin
			func_rs2[27:19] = (note_value_func_rs2 - (2*(quotient-1)));	// Leave Rs.1 to dispense interms of Rs.1
			func_rs2[18:11] = quotient -1;					// Number of Rs.2 coins to be dispensed
			func_rs2[10:0] = rs2_coins_count_func_rs2 - quotient -1;	// Deducting dispensed coins from stack of Rs.2 coins
		end

		else
		// if rs.2 coins are insufficient to dispense max value of coins. Rest of the value needed to be given in denominations of Rs.1
		begin
			func_rs2[27:19] = (note_value_func_rs2 - (2 * rs2_coins_count_func_rs2));	// Leaves value based on available Rs.2 Coins
			func_rs2[18:11] = rs2_coins_count_func_rs2;					// dispenses all rest of Rs.2 coins
			func_rs2[10:0] = 0;								// Stack of Rs.2 coins will be Zero
		end
	end
endfunction

function [28:0]func_rs1;
	input [3:0]den_code_func_rs1;
	input [8:0]note_value_func_rs1;
	input [10:0]rs1_coins_count_func_rs1;

	//if number of Rs.1 coins in stack are sufficent to dispense rest of note value
	if(rs1_coins_count_func_rs1 >= note_value_func_rs1)
	begin
		func_rs1[28:20] = 0;							//Note value will be zero
		func_rs1[19:11] = note_value_func_rs1;					// Number of Rs.1 coins to be dispensed
		func_rs1[10:0] = rs1_coins_count_func_rs1 - note_value_func_rs1;	// Deducting dispensed coins from stack of Rs.1 coins
	end

	// if available Rs.1 coins are insufficient to dispense rest of note value
	else
	begin
		func_rs1[28:20] = note_value_func_rs1 - rs1_coins_count_func_rs1;	// Leave note value based on available Rs.1 coins
		func_rs1[19:11] = rs1_coins_count_func_rs1;				//Number of Rs.1 coins can be dispensed
		func_rs1[10:0] = 0;							// Stack of rs.1 coins will be Zero
	end 
endfunction

// Declaration of registers for output ports		
reg [8:0]note_value;
reg [3:0]den_code;
reg [6:0]rs5_coins;
reg [7:0]rs2_coins;
reg [8:0]rs1_coins;
reg insert_note,invalid_note,processing,collect_coins,coins_insufficient,select_denomination,invalid_denomination;
//Declaration of required registers
reg [2:0]ps,ns;			// ps - Present State, ns - Next State
reg [10:0]rs5_coins_count=500;	// Initialising stack of Rs.5 coins
reg [10:0]rs2_coins_count=500;	// Initialising stack of Rs.2 coins
reg [10:0]rs1_coins_count=500;	// Initialising stack of Rs.1 coins

// State Register
always@(posedge clk_in, negedge rst_in)
begin
	if(!rst_in)	ps<=s_reset;
	else		ps<=ns;
end

// Combinational Logic
always@(ps,note_inserted_in,note_code_in,den_5_2_1_in,den_5_2_in,den_5_1_in,den_2_1_in)
begin
	case(ps)
		s_reset:	begin						//Reset state
					rs5_coins		= 0;		// Assigning Values to outputs
					rs2_coins		= 0;
					rs1_coins		= 0;
					insert_note		= 1;		// Machine asks user to insert note
					invalid_note		= 0;
					select_denomination	= 0;
					processing		= 0;
					invalid_denomination	= 0;
					collect_coins		= 0;
					coins_insufficient	= 0;

				//if note is inserted by user into machine
					if(note_inserted_in == 1)		// Assiging different values for different note_codes
					begin								//	Code	-	Note value
						if(note_code_in == 000)		note_value = 10;	//	000	-	  Rs. 10
						else if(note_code_in == 001)	note_value = 20;	//	001	-	  Rs. 20
						else if(note_code_in == 010)	note_value = 50;	//	010	-	  Rs. 50
						else if(note_code_in == 011)	note_value = 100;	//	011	-	  Rs. 100
						else if(note_code_in == 100)	note_value = 200;	//	100	- 	  Rs. 200
						else				note_value = 201;	// rest of codes-	 > Rs.200

						// if note value is less than 200, then note is accepted and asks user fordenomination
							if(note_value >= 10 && note_value <= 200 && note_inserted_in==1)
								ns = s_sel_den;

						// if note value is greater than 200, then note is invalid
							else
								ns = s_invalid_note;
					end
				//if note is not inserted, machine will be in ready state still it receives a note
					else
						ns = s_reset;
			 	end
		s_invalid_note:	begin						// invalid note state
					rs5_coins		= 0;
					rs2_coins		= 0;
					rs1_coins		= 0;
					insert_note		= 0;
					invalid_note		= 1;		// Machine show invalid note, and return note back
					select_denomination	= 0;
					processing		= 0;
					invalid_denomination	= 0;
					collect_coins		= 0;
					coins_insufficient	= 0;
					ns=s_reset;				// After returning, Machine again goes to reset state resemble machine is ready
				end
		s_sel_den:	begin						// Denomination selection state
					rs5_coins		= 0;
					rs2_coins		= 0;
					rs1_coins		= 0;
					insert_note		= 0;
					invalid_note		= 0;
					select_denomination	= 1;		// if note is accepted, Machine asks for denomination selection
					processing		= 0;
					invalid_denomination	= 0;
					collect_coins		= 0;
					coins_insufficient	= 0;

					// Generation of code based on denimnation selection which will be make easy in further operations
					den_code = {den_5_2_1_in,den_5_2_in,den_5_1_in,den_2_1_in};

					// if any of denomination selected, Machine will go to processing state
					if(den_5_2_1_in== 1 || den_5_2_in == 1 || den_5_1_in == 1 || den_2_1_in == 1)
							ns=s_processing;

					// Machine will be asking for denomination selection until user selects denomination type.
					else
							ns=s_sel_den;
				end
		s_processing:	begin					// Processing State
					insert_note		= 0;
					invalid_note		= 0;
					select_denomination	= 0;
					processing		= 1;	// if user selects denomination, manchine acknowledge user - that it is processing.
					invalid_denomination	= 0;
					collect_coins		= 0;
					coins_insufficient	= 0;
					if(den_code == 4'b1000)		// if denomination asked in Rs.5, Rs.2 & Rs.1 coins
						begin
						//if machine has Rs.5, Rs.2 & Rs.1 coins
							if(rs5_coins_count > 0 && rs2_coins_count > 0 && rs1_coins_count > 0)
							begin
							// Invocation of Rs.5 Coins
								{note_value,rs5_coins,rs5_coins_count} = func_rs5(den_code,note_value,rs5_coins_count);
							// Invocation of Rs.2 Coins	
								{note_value,rs2_coins,rs2_coins_count} = func_rs2(den_code,note_value,rs2_coins_count);
							// Invocation of Rs.1 Coins
								{note_value,rs1_coins,rs1_coins_count} = func_rs1(den_code,note_value,rs1_coins_count);
								if(note_value != 0 && rs1_coins_count == 0)
									ns = s_coins_insufficient;
								else
									ns = s_collect_coins;
							end
						// if machine didn't have any of Rs.5, Rs.2, Rs.1 coins
							else
								ns = s_coins_insufficient;
						end
						else if(den_code == 4'b0100 && note_value > 10)	// if denomination asked in Rs.5 & Rs.2
						begin
							if(rs5_coins_count > 0 && rs2_coins_count >0)
							begin
							// Invocation of Rs.5 Coins
								{note_value,rs5_coins,rs5_coins_count} = func_rs5(den_code,note_value,rs5_coins_count);
							// Invocation of Rs.2 Coins
								{note_value,rs2_coins,rs2_coins_count} = func_rs2(den_code,note_value,rs2_coins_count);
								if(note_value != 0 && rs2_coins_count == 0)
									ns = s_coins_insufficient;
								else
									ns = s_collect_coins;
							end
						// if machine didn't have any of Rs.5, Rs.2 coins
							else
								ns = s_coins_insufficient;
						end
						else if(den_code == 4'b0010)			// if denomination asked in Rs.5 & Rs.1
						begin
							if(rs5_coins_count > 0 && rs1_coins_count > 0)
							begin
							// Invocation of Rs.5 Coins
								{note_value,rs5_coins,rs5_coins_count} = func_rs5(den_code,note_value,rs5_coins_count);
							// Invocation of Rs.1 Coins
								{note_value,rs1_coins,rs1_coins_count} = func_rs1(den_code,note_value,rs1_coins_count);
								if(note_value != 0 && rs1_coins_count == 0)
									ns = s_coins_insufficient;
								else
									ns = s_collect_coins;
							end
						// if machine didn't have any of Rs.5, Rs.1 coins
							else
								ns = s_coins_insufficient;
						end
						else if(den_code == 4'b0001 && note_value > 10)			// if denomination asked in Rs.2 & Rs.1
						begin
							if(rs2_coins_count > 0 && rs1_coins_count > 0)
							begin
							// Invocation of Rs.2 Coins
								{note_value,rs2_coins,rs2_coins_count} = func_rs2(den_code,note_value,rs2_coins_count);
							// Invocation of Rs.1 Coins
								{note_value,rs1_coins,rs1_coins_count} = func_rs1(den_code,note_value,rs1_coins_count);
								if(note_value != 0 && rs1_coins_count == 0)
									ns = s_coins_insufficient;
								else
									ns = s_collect_coins;
							end
						// if machine didn't have any of Rs.2, Rs.1 coins
							else
								ns = s_coins_insufficient;
						end
						else if(note_value <= 10 && (den_code == 4'b0001 || den_code == 4'b0100)) //if denomination asked in Rs.5 & rs.2 or Rs.2 & Rs.1 and note inserted is Rs.10
							ns=s_invalid_denomination;
						else
							ns=s_processing;
					end
		s_invalid_denomination:	begin					// Invalid denomination State
						rs5_coins		= 0;
						rs2_coins		= 0;
						rs1_coins		= 0;
						insert_note		= 0;
						invalid_note		= 0;
						select_denomination	= 0;
						processing		= 0;
						invalid_denomination	= 1;	// Asserts when denomination asked in Rs.5 & Rs.2 and note inserted is Rs.10
						collect_coins		= 0;
						coins_insufficient	= 0;
						ns = s_reset;
					end
		s_coins_insufficient:	begin					// Coins insufficient state
						rs5_coins		= 0;
						rs2_coins		= 0;
						rs1_coins		= 0;
						insert_note		= 0;
						invalid_note		= 0;
						select_denomination	= 0;
						processing		= 0;
						invalid_denomination	= 0;
						collect_coins		= 0;
						coins_insufficient	= 1;	// Asserts incase of insufficient coins
						ns = s_reset;
					end
		s_collect_coins:	begin					// Collect coins state		
						insert_note		= 0;
						invalid_note		= 0;
						select_denomination	= 0;
						processing		= 0;
						invalid_denomination	= 0;
						collect_coins		= 1;	// Asserts incase processing is completed and acknowlege user to collect coins
						coins_insufficient	= 0;
						ns=s_reset;
					end
	endcase
end
// Assign registers values to output ports
assign rs5_coins_out		= rs5_coins;
assign rs2_coins_out		= rs2_coins;
assign rs1_coins_out		= rs1_coins;
assign insert_note_out		= insert_note;
assign invalid_note_out		= invalid_note;
assign select_denomination_out	= select_denomination;
assign processing_out		= processing;
assign invalid_denomination_out	= invalid_denomination;
assign collect_coins_out	= collect_coins;
assign coins_insufficient_out	= coins_insufficient;
endmodule
