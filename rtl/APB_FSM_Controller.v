module apb_controller(

input Hclk,Hresetn,valid,Hwrite,Hwritereg,
input [31:0] Hwdata,Haddr,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,
input [2:0] tempselx,
output reg Pwrite,Penable,
output reg Hreadyout,
output reg [2:0] Pselx,
output reg [31:0] Paddr,Pwdata);

//PARAMETERS

parameter ST_IDLE=3'b000;
parameter ST_WWAIT=3'b001;
parameter ST_READ= 3'b010;
parameter ST_WRITE=3'b011;
parameter ST_WRITEP=3'b100;
parameter ST_RENABLE=3'b101;
parameter ST_WENABLE=3'b110;
parameter ST_WENABLEP=3'b111;

// PRESENT STATE LOGIC

reg [2:0] PRESENT_STATE,NEXT_STATE;

always @(posedge Hclk)
begin
  if (~Hresetn)
    PRESENT_STATE <= ST_IDLE;
  else
    PRESENT_STATE <= NEXT_STATE;
end

// NEXT STATE LOGIC

always @(*)
begin
  case (PRESENT_STATE)
    ST_IDLE:
      if (~valid)
        NEXT_STATE = ST_IDLE;
      else if (valid && Hwrite)
        NEXT_STATE = ST_WWAIT;
      else 
        NEXT_STATE = ST_READ;

    ST_WWAIT:
      if (~valid)
        NEXT_STATE = ST_WRITE;
      else
        NEXT_STATE = ST_WRITEP;

    ST_READ:
      NEXT_STATE = ST_RENABLE;

    ST_WRITE:
      if (~valid)
        NEXT_STATE = ST_WENABLE;
      else
        NEXT_STATE = ST_WENABLEP;

    ST_WRITEP:
      NEXT_STATE = ST_WENABLEP;

    ST_RENABLE:
      if (~valid)
        NEXT_STATE = ST_IDLE;
      else if (valid && Hwrite)
        NEXT_STATE = ST_WWAIT;
      else
        NEXT_STATE = ST_READ;

    ST_WENABLE:
      if (~valid)
        NEXT_STATE = ST_IDLE;
      else if (valid && Hwrite)
        NEXT_STATE = ST_WWAIT;
      else
        NEXT_STATE = ST_READ;

    ST_WENABLEP:
      if (~valid && Hwritereg)
        NEXT_STATE = ST_WRITE;
      else if (valid && Hwritereg)
        NEXT_STATE = ST_WRITEP;
      else
        NEXT_STATE = ST_READ;

    default:
      NEXT_STATE = ST_IDLE;
  endcase
end

// OUTPUT LOGIC: COMBINATIONAL

reg Penable_temp, Hreadyout_temp, Pwrite_temp;
reg [2:0] Pselx_temp;
reg [31:0] Paddr_temp, Pwdata_temp;

always @(*)
begin
  // Default assignments to avoid latch inference
  Penable_temp = 0;
  Hreadyout_temp = 1;
  Pwrite_temp = 0;
  Pselx_temp = 3'b000;
  Paddr_temp = 32'b0;
  Pwdata_temp = 32'b0;

  case (PRESENT_STATE)
    ST_IDLE:
      if (valid && ~Hwrite)
      begin
        Paddr_temp = Haddr;
        Pwrite_temp = Hwrite;
        Pselx_temp = tempselx;
        Hreadyout_temp = 0;
      end

    ST_WWAIT:
    begin
      Paddr_temp = Haddr1;
      Pwrite_temp = 1;
      Pselx_temp = tempselx;
      Pwdata_temp = Hwdata;
      Hreadyout_temp = 0;
    end

    ST_READ:
    begin
      Penable_temp = 1;
      Hreadyout_temp = 1;
    end

    ST_WRITE:
    begin
      Penable_temp = 1;
      Hreadyout_temp = 1;
    end

    ST_WRITEP:
    begin
      Penable_temp = 1;
      Hreadyout_temp = 1;
    end

    ST_RENABLE:
      if (valid && ~Hwrite)
      begin
        Paddr_temp = Haddr;
        Pwrite_temp = Hwrite;
        Pselx_temp = tempselx;
        Hreadyout_temp = 0;
      end
      else if (valid && Hwrite)
      begin
        Hreadyout_temp = 1;
      end

    ST_WENABLEP:
    begin
      Paddr_temp = Haddr2;
      Pwrite_temp = Hwrite;
      Pselx_temp = tempselx;
      Pwdata_temp = Hwdata;
      Hreadyout_temp = 0;
    end

    ST_WENABLE:
    begin
      Hreadyout_temp = 0;
    end
  endcase
end

// OUTPUT LOGIC: SEQUENTIAL

always @(posedge Hclk)
begin
  if (~Hresetn)
  begin
    Paddr <= 0;
    Pwrite <= 0;
    Pselx <= 0;
    Pwdata <= 0;
    Penable <= 0;
    Hreadyout <= 0;
  end
  else
  begin
    Paddr <= Paddr_temp;
    Pwrite <= Pwrite_temp;
    Pselx <= Pselx_temp;
    Pwdata <= Pwdata_temp;
    Penable <= Penable_temp;
    Hreadyout <= Hreadyout_temp;
  end
end

endmodule
