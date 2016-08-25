
module ALARM_BLOCK (RESET, ALARM, HRS, MINS, CLK, CONNECT9, 
    CONNECT10, CONNECT11);

input  RESET,ALARM, HRS, MINS, CLK;
output [3:0] CONNECT9; 
output [5:0] CONNECT10; 
output CONNECT11;

    wire CONNECT1, CONNECT2; /* top level nets that connect major modules */

    ALARM_STATE_MACHINE U0 (.RESET(RESET), .ALARM_BUTTON(ALARM), .HOURS_BUTTON(HRS), 
        .MINUTES_BUTTON(MINS), .CLK(CLK), .HOURS(CONNECT1), .MINS(CONNECT2) );

    ALARM_COUNTER U3 (.RESET(RESET), .HOURS(CONNECT1), .MINS(CONNECT2), .CLK(CLK), 
        .HOURS_OUT(CONNECT9), .MINUTES_OUT(CONNECT10), .AM_PM_OUT(CONNECT11));

endmodule

module ALARM_COUNTER (RESET, HOURS, MINS, CLK, HOURS_OUT, MINUTES_OUT, AM_PM_OUT);
input RESET, HOURS, MINS, CLK;
output [3:0] HOURS_OUT;
output [5:0] MINUTES_OUT;
output AM_PM_OUT;

reg [3:0] HOURS_OUT;
reg [5:0] MINUTES_OUT;
reg AM_PM_OUT;

always @ (posedge CLK or posedge RESET)
begin

    if (RESET) begin
	HOURS_OUT = 0;
  	MINUTES_OUT = 0;
  	AM_PM_OUT = 0;
    end
    else if (MINS & !HOURS)
       begin
       if (MINUTES_OUT == 6'd59)
	  begin
	  MINUTES_OUT = 6'd0;
	  if (HOURS_OUT == 4'd12)
	     begin
	     HOURS_OUT = 4'd1;
	     AM_PM_OUT = !AM_PM_OUT;
	     end
	  else
	     HOURS_OUT = HOURS_OUT + 1'd1;
	  end
       else
	  MINUTES_OUT = MINUTES_OUT + 1'd1;
       end
    else if (!MINS & HOURS)
       begin
       if (HOURS_OUT == 4'd12)
	  begin
	  HOURS_OUT = 4'd1;
	  AM_PM_OUT = !AM_PM_OUT;
	  end
       else
	  HOURS_OUT = HOURS_OUT + 1'd1;
       end

end

endmodule
module ALARM_SM_2(RESET, COMPARE_IN,TOGGLE_ON,CLOCK,RING);
input RESET, COMPARE_IN,TOGGLE_ON,CLOCK;
output RING;
reg RING,CURRENT_STATE,NEXT_STATE;

parameter IDLE=0, ACTIVATE=1;
        always @ (CURRENT_STATE or COMPARE_IN or TOGGLE_ON) begin

	case (CURRENT_STATE) // synopsys parallel_case full_case

	   IDLE:        begin
			RING = 0;
			if (COMPARE_IN && TOGGLE_ON) 
				NEXT_STATE = ACTIVATE;
			else
				NEXT_STATE = IDLE;
			end

	  ACTIVATE:     begin
			RING = 1;
			if (!TOGGLE_ON ) 
				NEXT_STATE = IDLE;
			else
				NEXT_STATE = ACTIVATE;
			end 
	endcase
	end

        always @ (posedge CLOCK or posedge RESET) begin
	  if (RESET) begin
		CURRENT_STATE = 0;
	  end
	  else begin
		CURRENT_STATE = NEXT_STATE;
	  end
	end 
endmodule 
module ALARM_STATE_MACHINE (RESET, ALARM_BUTTON, HOURS_BUTTON, MINUTES_BUTTON, CLK, HOURS, MINS);
input RESET, ALARM_BUTTON, HOURS_BUTTON, MINUTES_BUTTON, CLK;
output HOURS, MINS;

parameter IDLE=0, SET_HOURS=1, SET_MINUTES=2;

reg [1:0] CURRENT_STATE;
reg [1:0] NEXT_STATE;
reg HOURS, MINS;


always @ (CURRENT_STATE or ALARM_BUTTON or HOURS_BUTTON or MINUTES_BUTTON)
begin
    HOURS = 0;
    MINS = 0;
    NEXT_STATE = CURRENT_STATE;

    case (CURRENT_STATE) //synopsys full_case parallel_case

    IDLE: begin
	  if (ALARM_BUTTON & HOURS_BUTTON & !MINUTES_BUTTON)
	     begin
	     NEXT_STATE = SET_HOURS;
	     HOURS = 1;
	     end
	  else if (ALARM_BUTTON & !HOURS_BUTTON & MINUTES_BUTTON)
	     begin
	     NEXT_STATE = SET_MINUTES;
	     MINS = 1;
	     end
	  else
	     NEXT_STATE = IDLE;
	  end
    SET_HOURS: begin
          if (ALARM_BUTTON & HOURS_BUTTON & !MINUTES_BUTTON)
             begin
             NEXT_STATE = SET_HOURS;
             //HOURS = 0;
             HOURS = 1;
             end
          else
             NEXT_STATE = IDLE;
          end
    SET_MINUTES: begin
           if (ALARM_BUTTON & !HOURS_BUTTON & MINUTES_BUTTON)
             begin
             NEXT_STATE = SET_MINUTES;
             //MINS = 0;
             MINS = 1;
             end
          else
             NEXT_STATE = IDLE;
          end
    endcase
end


always @ (posedge CLK or posedge RESET)
begin
  if (RESET) begin
	CURRENT_STATE = 0;
  end
  else begin
	CURRENT_STATE = NEXT_STATE;
  end
end

//always @ (posedge CLK)
//begin
	//CURRENT_STATE = NEXT_STATE;
//end

endmodule
module COMPARATOR(ALARM_HRS,CLOCK_HRS,ALARM_MINS,CLOCK_MINS,ALARM_AM_PM, 
                  CLOCK_AM_PM,RINGER);
input [3:0] ALARM_HRS,CLOCK_HRS;
input [5:0] ALARM_MINS,CLOCK_MINS;
input ALARM_AM_PM, CLOCK_AM_PM;
output RINGER;
reg RINGER;

     always @ (ALARM_HRS or CLOCK_HRS or ALARM_MINS or CLOCK_MINS or 
               ALARM_AM_PM or CLOCK_AM_PM)  begin
	    RINGER = 1'b0;
	if ((ALARM_HRS == CLOCK_HRS) &&  (ALARM_MINS == CLOCK_MINS) && 
           (ALARM_AM_PM == CLOCK_AM_PM)) 
		RINGER = 1'b1;
	 end 

endmodule

           

module CONVERTOR ( T0, T1, T2, T3, T4, T5, A0, B0, C0, D0, E0, F0, G0, A1, B1, 
    C1, D1, E1, F1, G1 );
input  T0, T1, T2, T3, T4, T5;
output A0, B0, C0, D0, E0, F0, G0, A1, B1, C1, D1, E1, F1, G1;
    assign A0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & 
        ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & T1
         & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1
         & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & 
        T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & T4 & T5) | (~T0 & 
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (~T0 & 
        T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4 & T5) | (T0 & ~T1
         & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & 
        ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (T0
         & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (
        T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (
        T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & T4 & T5) | (
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | (T0
         & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (T0
         & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign B0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & T5) | (~T0 & ~
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & 
        ~T1 & T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & T4 & T5) | (~T0 & 
        T1 & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        ~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & T5) | (~
        T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (
        ~T0 & T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (~
        T0 & T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | 
        (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5
        ) | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5)
         | (T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & T5
        ) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3 & ~T4 & T5)
         | (T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0 & ~T1 & T2 & T3 & T4 & T5) | 
        (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5));
    assign C0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & T5) | (~T0 & ~
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & 
        ~T1 & T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & T4 & T5) | (~T0 & 
        T1 & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | 
        (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5
        ) | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5)
         | (T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & T5
        ) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3 & ~T4 & T5)
         | (T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0 & ~T1 & T2 & T3 & T4 & T5) | 
        (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5)
         | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & T4 & T5)
         | (T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5)
         | (T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | 
        (T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (
        T0 & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign D0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & 
        ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & T1
         & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1
         & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & 
        T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & T4 & T5) | (~T0 & 
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (~T0 & 
        T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4 & T5) | (T0 & ~T1
         & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & 
        ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (T0
         & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (
        T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (
        T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & T4 & T5) | (
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | (T0
         & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (T0
         & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign E0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & 
        ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & T1
         & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1
         & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & 
        T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & T4 & T5) | (~T0 & 
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5));
    assign F0 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (T0 & ~T1 & 
        T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (T0 & ~T1
         & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & T5) | (T0 & ~T1
         & T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3 & ~T4 & T5) | (T0 & ~T1
         & T2 & T3 & T4 & ~T5) | (T0 & ~T1 & T2 & T3 & T4 & T5) | (T0 & T1 & ~
        T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & T1 & 
        ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & T4 & T5) | (T0 & T1 & ~
        T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (T0 & T1 & ~
        T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | (T0 & T1 & T2
         & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (T0 & T1 & T2
         & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign G0 = ((~T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~
        T4 & T5) | (~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & 
        T4 & T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & 
        ~T4 & T5) | (~T0 & T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & 
        T4 & T5) | (~T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~
        T4 & T5) | (~T0 & T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4
         & T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & 
        ~T4 & T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3
         & T4 & T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3
         & ~T4 & T5) | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3
         & T4 & T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3
         & ~T4 & T5) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & T2 & ~T3
         & T4 & T5) | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3
         & ~T4 & T5) | (T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0 & ~T1 & T2 & T3
         & T4 & T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3
         & ~T4 & T5) | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3
         & T4 & T5) | (T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3
         & ~T4 & T5) | (T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3
         & T4 & T5) | (T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3
         & ~T4 & T5) | (T0 & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3
         & T4 & T5));
    assign A1 = ((~T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & T4 & T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & 
        T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & T3 & T4 & T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & T1
         & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & 
        T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0
         & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & T2 & ~T3 & T4 & T5) | (~T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0
         & T1 & T2 & T3 & ~T4 & T5) | (~T0 & T1 & T2 & T3 & T4 & ~T5) | (T0 & 
        ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & T4 & T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (T0
         & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (T0
         & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (
        T0 & ~T1 & T2 & ~T3 & T4 & T5) | (T0 & ~T1 & T2 & T3 & ~T4 & T5) | (T0
         & ~T1 & T2 & T3 & T4 & T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0
         & T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0
         & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (T0
         & T1 & ~T2 & T3 & T4 & T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (T0 & 
        T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign B1 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & T5) | (~T0 & ~
        T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & 
        ~T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        ~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & T5) | (~
        T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (~
        T0 & T1 & T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | 
        (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5)
         | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5)
         | (T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & T5
        ) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3 & T4 & T5)
         | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5
        ) | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & T4 & T5)
         | (T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5)
         | (T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5)
         | (T0 & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign C1 = ((~T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2
         & T3 & T4 & T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & 
        T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1
         & T2 & ~T3 & T4 & T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & T4 & T5) | (~T0 & T1
         & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        ~T0 & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (
        ~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & T2 & ~T3 & T4 & ~T5) | (
        ~T0 & T1 & T2 & ~T3 & T4 & T5) | (~T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~
        T0 & T1 & T2 & T3 & ~T4 & T5) | (~T0 & T1 & T2 & T3 & T4 & ~T5) | (~T0
         & T1 & T2 & T3 & T4 & T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5) | (
        T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | 
        (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (
        T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | 
        (T0 & ~T1 & T2 & ~T3 & T4 & T5) | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (
        T0 & ~T1 & T2 & T3 & ~T4 & T5) | (T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0
         & ~T1 & T2 & T3 & T4 & T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0
         & T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (T0
         & T1 & ~T2 & ~T3 & T4 & T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (T0
         & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | (T0 & 
        T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & ~T4 & T5) | (T0 & 
        T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign D1 = ((~T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & 
        T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & T5) | (~T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & 
        T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & T3 & T4 & T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1
         & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & 
        T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0
         & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & T5) | (~T0
         & T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0
         & T1 & T2 & T3 & ~T4 & T5) | (~T0 & T1 & T2 & T3 & T4 & ~T5) | (T0 & 
        ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & T4 & T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (
        T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (
        T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | 
        (T0 & ~T1 & T2 & ~T3 & T4 & T5) | (T0 & ~T1 & T2 & T3 & ~T4 & T5) | (
        T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (
        T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (
        T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5) | (
        T0 & T1 & ~T2 & T3 & T4 & T5) | (T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0
         & T1 & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign E1 = ((~T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & 
        T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3
         & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~
        T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2
         & T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & T1 & T2
         & ~T3 & T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2
         & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~
        T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & 
        T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5) | (T0 & ~T1
         & T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1
         & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1
         & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & ~T5));
    assign F1 = ((~T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & T3 & 
        ~T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3
         & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1 & T2 & 
        ~T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2
         & T3 & T4 & T5) | (~T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & ~
        T2 & ~T3 & T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & T1 & 
        ~T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1
         & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & T2 & ~T3 & T4 & ~T5) | (~T0 & T1
         & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (~T0 & T1
         & T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1
         & ~T2 & ~T3 & T4 & T5) | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~
        T1 & ~T2 & T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (T0 & ~
        T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5) | (T0 & 
        ~T1 & T2 & T3 & ~T4 & T5) | (T0 & ~T1 & T2 & T3 & T4 & ~T5) | (T0 & T1
         & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5) | (T0 & 
        T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & 
        T1 & ~T2 & T3 & T4 & T5) | (T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1
         & T2 & ~T3 & T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & T5));
    assign G1 = ((~T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0 & ~T1 & ~T2 & ~T3
         & T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & ~T2 & 
        T3 & ~T4 & T5) | (~T0 & ~T1 & ~T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2
         & ~T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & ~T1
         & T2 & T3 & ~T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & ~T4 & T5) | (~T0 & ~
        T1 & T2 & T3 & T4 & ~T5) | (~T0 & ~T1 & T2 & T3 & T4 & T5) | (~T0 & T1
         & ~T2 & ~T3 & ~T4 & ~T5) | (~T0 & T1 & ~T2 & ~T3 & T4 & ~T5) | (~T0
         & T1 & ~T2 & ~T3 & T4 & T5) | (~T0 & T1 & ~T2 & T3 & T4 & ~T5) | (~T0
         & T1 & ~T2 & T3 & T4 & T5) | (~T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (~T0
         & T1 & T2 & ~T3 & ~T4 & T5) | (~T0 & T1 & T2 & ~T3 & T4 & ~T5) | (~T0
         & T1 & T2 & T3 & ~T4 & ~T5) | (~T0 & T1 & T2 & T3 & ~T4 & T5) | (T0
         & ~T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & ~T4 & T5) | 
        (T0 & ~T1 & ~T2 & ~T3 & T4 & ~T5) | (T0 & ~T1 & ~T2 & ~T3 & T4 & T5)
         | (T0 & ~T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & ~T1 & ~T2 & T3 & T4 & ~T5
        ) | (T0 & ~T1 & ~T2 & T3 & T4 & T5) | (T0 & ~T1 & T2 & ~T3 & T4 & ~T5)
         | (T0 & ~T1 & T2 & ~T3 & T4 & T5) | (T0 & ~T1 & T2 & T3 & ~T4 & ~T5)
         | (T0 & ~T1 & T2 & T3 & ~T4 & T5) | (T0 & ~T1 & T2 & T3 & T4 & ~T5)
         | (T0 & T1 & ~T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & ~T3 & ~T4 & T5
        ) | (T0 & T1 & ~T2 & T3 & ~T4 & ~T5) | (T0 & T1 & ~T2 & T3 & ~T4 & T5)
         | (T0 & T1 & ~T2 & T3 & T4 & ~T5) | (T0 & T1 & ~T2 & T3 & T4 & T5) | 
        (T0 & T1 & T2 & ~T3 & ~T4 & ~T5) | (T0 & T1 & T2 & ~T3 & T4 & ~T5) | (
        T0 & T1 & T2 & ~T3 & T4 & T5));
endmodule


module CONVERTOR_CKT ( connect13,disp1,disp2); 

input  [9:0]connect13; 
output [13:0]disp1, disp2;
wire[6:0] connect14 ; 
    CONVERTOR U7 (.T0(1'b0), .T1(1'b0), .T2(connect13[9]), .T3(connect13[8]),
	.T4(connect13[7]), .T5(connect13[6]), .A0(connect14[6]),
	.B0(connect14[5]), .C0(connect14[4]), .D0(connect14[3]),
	.E0(connect14[2]), .F0(connect14[1]), .G0(connect14[0]),
	.A1(disp1[6]), .B1(disp1[5]), .C1(disp1[4]), .D1(disp1[3]),
	.E1(disp1[2]), .F1(disp1[1]), .G1(disp1[0]));
    CONVERTOR U8 ( .T0(connect13[5]), .T1(connect13[4]), .T2(connect13[3]),
	.T3(connect13[2]), .T4(connect13[1]), .T5(connect13[0]),
	.A0(disp2[13]), .B0(disp2[12]),	.C0(disp2[11]), 
	.D0(disp2[10]), .E0(disp2[9]), .F0(disp2[8]),
	.G0(disp2[7]), .A1(disp2[6]), .B1(disp2[5]),
	.C1(disp2[4]), .D1(disp2[3]), .E1(disp2[2]),
	.F1(disp2[1]), .G1(disp2[0]));
    HOURS_FILTER U9 ( .TENS_DIGIT_HOURS_IN(connect14),
	.TENS_DIGIT_HOURS_OUT(disp1[13:7]));
endmodule

module HOURS_FILTER (TENS_DIGIT_HOURS_IN, TENS_DIGIT_HOURS_OUT);
input  [6:0] TENS_DIGIT_HOURS_IN;
output [6:0] TENS_DIGIT_HOURS_OUT;

reg [6:0] TENS_DIGIT_HOURS_OUT;

always @ (TENS_DIGIT_HOURS_IN)
   if (TENS_DIGIT_HOURS_IN == 7'b1111110)
      TENS_DIGIT_HOURS_OUT = 7'b0000000;
   else
      TENS_DIGIT_HOURS_OUT = TENS_DIGIT_HOURS_IN;

endmodule
           
module
MUX(ALARM_HRS,ALARM_MINS,ALARM_AM_PM,TIME_HRS,TIME_MINS,TIME_AM_PM,ALARM_SET, OUTBUS);
input [3:0] ALARM_HRS,TIME_HRS;
input [5:0] ALARM_MINS,TIME_MINS;
input ALARM_AM_PM, TIME_AM_PM,ALARM_SET;
output [10:0] OUTBUS;
reg [10:0] OUTBUS;

	always @ (ALARM_SET or ALARM_HRS or ALARM_MINS or ALARM_AM_PM or
                  TIME_HRS or TIME_MINS or TIME_AM_PM)  begin
		OUTBUS = 11'bz;
	if (ALARM_SET)
		OUTBUS = ({ALARM_HRS,ALARM_MINS,ALARM_AM_PM});
	else
		OUTBUS = ({TIME_HRS,TIME_MINS,TIME_AM_PM});
	end
endmodule

module SEVEN2BCD(seven, bcd);

input [13:0] seven;
output [7:0] bcd;

function [3:0] s2b;
input [6:0] s;
reg [7:0] value;
begin
    case (s)
	7'h30: value = 1;
	7'h6d: value = 2;
	7'h79: value = 3;
	7'h33: value = 4;
	7'h5b: value = 5;
	7'h1f: value = 6;
	7'h70: value = 7;
	7'h7f: value = 8;
	7'h7b: value = 9;
	7'h7e: value = 0;
	7'h00: value = 4'hb;
	default: value = 4'hX;
    endcase
    s2b = value;
end
endfunction

assign bcd[3:0] = s2b(seven[6:0]);
assign bcd[7:4] = s2b(seven[13:7]);
endmodule

module TIME_BLOCK ( RESET, SET_TIME, HRS, MINS, CLK, CONNECT6, 
     CONNECT7,
     CONNECT8 );
input  RESET, SET_TIME, HRS, MINS, CLK;
output [3:0] CONNECT6;
output [5:0] CONNECT7;
output  CONNECT8;
    wire CONNECT3, CONNECT4, CONNECT5;
    TIME_STATE_MACHINE U1 (.RESET(RESET), .TIME_BUTTON(SET_TIME), .HOURS_BUTTON(HRS), 
        .MINUTES_BUTTON(MINS), .CLK(CLK), .SECS(CONNECT5), .HOURS(CONNECT3), 
        .MINS(CONNECT4) );
    TIME_COUNTER U2 (.RESET(RESET), .SECS(CONNECT5), .HOURS(CONNECT3), .MINS(CONNECT4), 
        .CLK(CLK), .HOURS_OUT(CONNECT6),
        .MINUTES_OUT(CONNECT7) , 
        .AM_PM_OUT(CONNECT8) );
endmodule

module TIME_COUNTER (RESET, HOURS, MINS, SECS, CLK, HOURS_OUT, MINUTES_OUT, AM_PM_OUT);
input RESET, HOURS, MINS, SECS, CLK;
output [3:0] HOURS_OUT;
output [5:0] MINUTES_OUT;
output AM_PM_OUT;

reg [3:0] HOURS_OUT;
reg [5:0] MINUTES_OUT;
reg [5:0] CURRENT_SECS;
reg AM_PM_OUT;

always @ (posedge CLK or posedge RESET)
begin

    if (RESET) begin
	MINUTES_OUT = 0;
    	HOURS_OUT = 0;
    	AM_PM_OUT = 0;
    	CURRENT_SECS = 0;
    end
    else if (SECS & !MINS & !HOURS)
       begin
       if (CURRENT_SECS == 6'd59)
	  begin
	  CURRENT_SECS = 6'd0;
	  if (MINUTES_OUT == 6'd59)
	     begin
	     MINUTES_OUT = 6'd0;
	     if (HOURS_OUT == 4'd12)
		begin
		HOURS_OUT = 4'd1;
		AM_PM_OUT = !AM_PM_OUT;
		end
	     else
		HOURS_OUT = HOURS_OUT + 1'd1;
	     end
	  else
	     MINUTES_OUT = MINUTES_OUT + 1'd1;
	  end
       else
	  CURRENT_SECS = CURRENT_SECS + 1'd1;
       end
    else if (!SECS & MINS & !HOURS)
       begin
       CURRENT_SECS = 6'd0;
       if (MINUTES_OUT == 6'd59)
	  begin
	  MINUTES_OUT = 6'd0;
	  if (HOURS_OUT == 4'd12)
	     begin
	     HOURS_OUT = 4'd1;
	     AM_PM_OUT = !AM_PM_OUT;
	     end
	  else
	     HOURS_OUT = HOURS_OUT + 1'd1;
	  end
       else
	  MINUTES_OUT = MINUTES_OUT + 1'd1;
       end
    else if (!SECS & !MINS & HOURS)
       begin
       CURRENT_SECS = 6'd0;	
       if (HOURS_OUT == 4'd12)
	  begin
	  HOURS_OUT = 4'd1;
	  AM_PM_OUT = !AM_PM_OUT;
	  end
       else
	  HOURS_OUT = HOURS_OUT + 1'd1;
       end
       
end

endmodule
module TIME_STATE_MACHINE (RESET,TIME_BUTTON, HOURS_BUTTON, MINUTES_BUTTON, CLK, SECS, HOURS, MINS);
input RESET, TIME_BUTTON, HOURS_BUTTON, MINUTES_BUTTON, CLK;
output SECS, HOURS, MINS;

parameter COUNT_TIME=0, SET_HOURS=1, SET_MINUTES=2;

reg [1:0] CURRENT_STATE; 
reg [1:0] NEXT_STATE;
reg SECS, HOURS, MINS;
	

always @ (CURRENT_STATE or TIME_BUTTON or HOURS_BUTTON or MINUTES_BUTTON)
begin
    SECS =0;
    HOURS = 0;
    MINS = 0;
    NEXT_STATE = CURRENT_STATE;
    
    case (CURRENT_STATE) //synopsys full_case parallel_case

    COUNT_TIME: begin
	if (TIME_BUTTON & HOURS_BUTTON & !MINUTES_BUTTON)
	   begin
	   NEXT_STATE = SET_HOURS;
	   HOURS = 1;
	   end
	else if (TIME_BUTTON & !HOURS_BUTTON & MINUTES_BUTTON) 
	   begin
	   NEXT_STATE = SET_MINUTES;
	   MINS = 1;
	   end
	else
	   begin
	   NEXT_STATE = COUNT_TIME;
	   SECS = 1;
	   end
	end
    SET_HOURS: begin
	if (TIME_BUTTON & HOURS_BUTTON & !MINUTES_BUTTON)
	   begin
	   NEXT_STATE = SET_HOURS;
	   //HOURS = 0;
	   HOURS = 1;
	   end
	else
	   begin
	   NEXT_STATE = COUNT_TIME;
	   SECS = 1;
	   HOURS = 0;
	   end
	end
    SET_MINUTES: begin
	 if (TIME_BUTTON & !HOURS_BUTTON & MINUTES_BUTTON)
	   begin
	   NEXT_STATE = SET_MINUTES;
	   //MINS = 0;
	   MINS = 1;
	   end
	else
	   begin
	   NEXT_STATE = COUNT_TIME;
	   SECS = 1;
	   MINS = 0;
	   end
	end
    endcase
end

always @ (posedge CLK or posedge RESET)
begin
  if (RESET) begin
	CURRENT_STATE = 0;
  end
  else begin
	CURRENT_STATE = NEXT_STATE;
  end
end

endmodule
module TOP (RESET, SET_TIME, ALARM, HRS, MINS, TOGGLE_SWITCH, CLK, SPEAKER_OUT, 
    HOUR, MINUTE, AM_PM_DISPLAY );
output [7:0] HOUR, MINUTE;
input  RESET, SET_TIME, ALARM, HRS, MINS, TOGGLE_SWITCH, CLK;
output SPEAKER_OUT, AM_PM_DISPLAY;

/*Top level nets that connect major modules */

wire [13:0] DISP1;
wire [13:0] DISP2;
wire [5:0] KONNECT7,KONNECT10;
wire KONNECT8,KONNECT11,KONNECT12;
wire [3:0] KONNECT6,KONNECT9;
wire [9:0] KONNECT13;
    TIME_BLOCK U1 (.RESET(RESET), .SET_TIME(SET_TIME), .HRS(HRS), .MINS(MINS),  
     .CLK(CLK), .CONNECT6(KONNECT6), .CONNECT7(KONNECT7), .CONNECT8(KONNECT8) );

    ALARM_BLOCK  U2 (.RESET(RESET), .ALARM(ALARM), .HRS(HRS), .MINS(MINS), .CLK(CLK), 
        .CONNECT9(KONNECT9), .CONNECT10(KONNECT10), .CONNECT11(KONNECT11));

    CONVERTOR_CKT U3 (.connect13(KONNECT13),.disp1(DISP1),.disp2(DISP2)); 

    COMPARATOR U4 ( .ALARM_HRS(KONNECT9),.CLOCK_HRS(KONNECT6), 
        .ALARM_MINS(KONNECT10), .CLOCK_MINS(KONNECT7),
        .ALARM_AM_PM(KONNECT11), .CLOCK_AM_PM(KONNECT8), .RINGER(KONNECT12) );

    ALARM_SM_2 U5 (.RESET(RESET), .COMPARE_IN(KONNECT12), .TOGGLE_ON(TOGGLE_SWITCH), .CLOCK(
        CLK), .RING(SPEAKER_OUT) );

    MUX U6 ( .ALARM_HRS(KONNECT9), .ALARM_MINS(KONNECT10),
        .ALARM_AM_PM(KONNECT11), .TIME_HRS(KONNECT6),
        .TIME_MINS(KONNECT7), .TIME_AM_PM(KONNECT8), .ALARM_SET(ALARM),
         .OUTBUS({KONNECT13,AM_PM_DISPLAY}));

    SEVEN2BCD U7(DISP1, HOUR);
    SEVEN2BCD U8(DISP2 & DISP1, MINUTE);
endmodule


