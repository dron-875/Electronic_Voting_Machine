module evm (
    input wire [3:0] voter_switch, // for 4 different party
    input wire Push_Button,
    input wire voting_en,
    input wire reset,
    
	 output reg [6:0] dout, // total limit of total votes 128
    output reg [4:0]v1,  // final vote for all party
    output reg [6:0] seg3, // which party is getting vote, at time of giving vote like party 1,2,3,4
	 output reg [6:0] seg2, // final count for all individual party
	 output reg [3:0] out, // temp reg for seg2
	 output reg [6:0] display_out, // It is the output register for 7-segment 
    
	 input wire sw1, // sw1 to sw4 for all 4 party to enter their votes
    input wire sw2,
    input wire sw3,
    input wire sw4,
    input wire swout // votes check
	 
/*
This module defines an Electronic Voting Machine (EVM) system. It includes inputs for voter switches, a push button, 
voting enable, and reset. The outputs are for displaying the total votes, individual party votes, and 7-segment 
display outputs.	 
*/
);

// Counters to count each party votes
reg [4:0] cnt_reg1 = 0;  // party1
reg [4:0] cnt_reg2 = 0;  // party2
reg [4:0] cnt_reg3 = 0;  // party3
reg [4:0] cnt_reg4 = 0;  // party4

// Counter for party1 votes
always @(posedge Push_Button or posedge reset) begin
    if (reset) begin
        cnt_reg1 <= 0;
    end else if (voter_switch == 4'b0001 && voting_en) begin
        cnt_reg1 <= cnt_reg1 + 1;
    end
end

// Counter for party2 votes
always @(posedge Push_Button or posedge reset) begin
    if (reset) begin
        cnt_reg2 <= 0;
    end else if (voter_switch == 4'b0010 && voting_en) begin
        cnt_reg2 <= cnt_reg2 + 1;
    end
end

// Counter for party3 votes
always @(posedge Push_Button or posedge reset) begin
    if (reset) begin
        cnt_reg3 <= 0;
    end else if (voter_switch == 4'b0100 && voting_en) begin
        cnt_reg3 <= cnt_reg3 + 1;
    end
end

// Counter for party4 votes
always @(posedge Push_Button or posedge reset) begin
    if (reset) begin
        cnt_reg4 <= 0;
    end else if (voter_switch == 4'b1000 && voting_en) begin
        cnt_reg4 <= cnt_reg4 + 1;
    end
end

/*
Each party has a dedicated counter (cnt_reg1, cnt_reg2, cnt_reg3, cnt_reg4). These counters are incremented when 
the corresponding party's switch is selected (voter_switch) and the push button is pressed, provided voting is 
enabled (voting_en). The counters reset to zero when the reset signal is activated.
*/

// Final count (total number of votes)
always @(*) begin
    if (swout && voting_en) begin
        dout = cnt_reg1 + cnt_reg2 + cnt_reg3 + cnt_reg4;
    end else begin
        dout = 7'b0000000;
    end
end

/*
The total number of votes is calculated and assigned to dout when swout is active and voting is enabled.
*/

// For displaying votes
always @(*) begin
    if (sw1 && !sw2 && !sw3 && !sw4 && !swout && voting_en) begin
        v1 = cnt_reg1;
        seg3 = 7'b1001111; // Display '1'
    end else if (!sw1 && sw2 && !sw3 && !sw4 && !swout && voting_en) begin
        v1 = cnt_reg2;
        seg3 = 7'b0010010; // Display '2'
    end else if (!sw1 && !sw2 && sw3 && !sw4 && !swout && voting_en) begin
        v1 = cnt_reg3;
        seg3 = 7'b0000110; // Display '3'
    end else if (!sw1 && !sw2 && !sw3 && sw4 && !swout && voting_en) begin
        v1 = cnt_reg4;
        seg3 = 7'b1001100; // Display '4'
		  end
	 
	 if (sw1 && !sw2 && !sw3 && !sw4 && swout && voting_en) begin
        out = cnt_reg1;
        seg2 =(seven(out[3:0])); // Display votes of candidate '1'
	 end else if (!sw1 && sw2 && !sw3 && !sw4 && swout && voting_en) begin
		  out = cnt_reg2;
        seg2 =(seven(out[3:0]));
	 end else if (!sw1 && !sw2 && sw3 && !sw4 && swout && voting_en) begin 
			out = cnt_reg3;
        seg2 =(seven(out[3:0]));
	 end else if (!sw1 && !sw2 && !sw3 && sw4 && swout && voting_en) begin
		  out = cnt_reg4;
         seg2 =(seven(out[3:0]));
	 end
		  
end

/*
The votes for each party are displayed on a 7-segment display. The seg3 register displays the party number being voted for, 
and seg2 displays the count of votes for each party.
*/

// Integrating 7-Segment

function [6:0]seven;
input [3:0]data_in;
begin
    case (data_in)
        4'b0000:
            display_out = 8'b0000001;  //a,b,c,d,e,f,g,dot (zero)
        4'b0001:
            display_out = 8'b1001111;  //one
        4'b0010:
            display_out = 8'b0010010;  //two
        4'b0011:
            display_out = 8'b0000110;  //three
        4'b0100:
            display_out = 8'b1001100;  //four
        4'b0101:
            display_out = 8'b0100100;  //five
        4'b0110:
            display_out = 8'b0100000;  //six
        4'b0111:
            display_out = 8'b0001111;  //seven
        4'b1000:
            display_out = 8'b0000000;  //eight
        4'b1001:
            display_out = 8'b0000100;  //nine
		endcase
		end
		endfunction
endmodule

/*
This function maps a 4-bit binary input to the corresponding 7-segment display code.
*/



