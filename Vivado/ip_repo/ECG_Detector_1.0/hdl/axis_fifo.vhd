----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Antti Siirilä
-- 
-- Create Date: 12/09/2014 07:29:32 AM
-- Design Name: 
-- Module Name: axis_fifo - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- mod: 			  
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ecg_components.all;

entity axis_fifo is
	generic (
		-- Users to add parameters here
		C_FIFO_DEPTH	: integer := 10;
		C_AXIS_TUSER_WIDTH	: integer	:= 8;
		TUSER_EN	: boolean	:= false;
		TSTRB_EN	: boolean	:= false;
		TLAST_EN	: boolean   := false; -- add the parameters to the upper modules
		TLAST_GEN	: boolean	:= false;
		TLAST_PROP	: boolean	:= true;
		PACKET_LENGTH	: integer	:= 5;
        SYSTEM_CLK_FREQ  : integer   := 100000000;
        SAMPLE_FREQ         : integer := 500;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_AXIS_TDATA_WIDTH.
		C_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		-- Ready to accept data in
		S_AXIS_TREADY	: out std_logic;
		-- Data in
		S_AXIS_TDATA	: in std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		-- Byte qualifier
		S_AXIS_TSTRB	: in std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '0');
		-- Indicates boundary of last packet
		S_AXIS_TLAST	: in std_logic := '0';
		-- Data is in valid
		S_AXIS_TVALID	: in std_logic;
		
		S_AXIS_TUSER	: in std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0) := (others => '0');
		M_AXIS_TUSER	: out std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);
		
		SAMPLE_VALID    : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		AXIS_ACLK	: in std_logic;
		-- 
		AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
	);
end axis_fifo;

architecture implementation of axis_fifo is
	--Total number of output data.
	-- Total number of output data                                              
	constant NUMBER_OF_WORDS : integer := C_FIFO_DEPTH;                                   
	constant PACKET : integer := PACKET_LENGTH;
	 -- function called clogb2 that returns an integer which has the   
	 -- value of the ceiling of the log base 2.                              
	function clogb2 (bit_depth : integer) return integer is                  
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;                                                                    

	 -- WAIT_COUNT_BITS is the width of the wait counter.                       
	 constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);               
	                                                                                  
	-- In this example, Depth of FIFO is determined by the greater of                 
	-- the number of input words and output words.                                    
	constant depth : integer := NUMBER_OF_WORDS;                               
	                                                                                  
	-- bit_num gives the minimum number of bits needed to address 'depth' size of FIFO
	constant bit_num : integer := clogb2(depth);                                      
	                                                                                  
	-- Define the states of state machine                                             
	-- The control state machine oversees the writing of input streaming data to the FIFO,
	-- and outputs the streaming data from the FIFO                                   
	type state_out is ( IDLE,        -- This is the initial/idle state                    
	                INIT_COUNTER,  -- This state initializes the counter, ones        
	                                -- the counter reaches C_M_START_COUNT count,     
	                                -- the state machine changes state to INIT_WRITE  
	                SEND_STREAM);  -- In this state the                               
	                             -- stream data is output through M_AXIS_TDATA        
	-- State variable                                                                 
	signal  state_master : state_out;                                                   
	-- Example design FIFO read pointer                                               
	signal read_pointer, read_pointer_peak : integer range 0 to bit_num-1;                               

	-- AXI Stream internal signals
	--wait counter. The master waits for the user defined number of clock cycles before initiating a transfer.
	signal count	: std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
	--streaming data valid
	signal axis_tvalid	: std_logic;
	--streaming data valid delayed by one clock cycle
	signal axis_tvalid_delay	: std_logic;
	--Last of the streaming data 
	signal axis_tlast	: std_logic;
	--Last of the streaming data delayed by one clock cycle
	signal axis_tlast_delay	: std_logic;
	--FIFO implementation signals
	signal stream_data_out	: std_logic_vector(C_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	--The master has issued all the streaming data stored in FIFO
	signal tx_done	: std_logic;
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	
	type state_in is ( IDLE,        -- This is the initial/idle state 
	                WRITE_FIFO); -- In this state FIFO is written with the
	                             -- input stream data S_AXIS_TDATA
		-- State variable of the slave if
	signal  state_slave : state_in;

	signal axis_tready	: std_logic;
	signal writes_done	: std_logic;
	signal fifo_wren	: std_logic;
	signal write_pointer, write_pointer_peak, packet_delimiter : integer range 0 to bit_num-1;
	signal packet_count, packet_count_peak : integer range 0 to PACKET_LENGTH-1;
	signal fifo_empty	: std_logic;
	signal fifo_full	: std_logic;
	signal stream_user_out	: std_logic_vector(C_AXIS_TUSER_WIDTH-1 downto 0);
	signal x_s_axis_tlast	: std_logic;
	signal x_m_tready, x_s_tvalid, x_s_tlast, r_tlast_done	: std_logic;
	signal x_tlast_select	:std_logic_vector(1 downto 0);
	type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_WORDS-1)) of std_logic_vector(7 downto 0);
	type NYBLE_FIFO_TYPE is array (0 to (NUMBER_OF_WORDS-1)) of std_logic_vector(3 downto 0);
	

-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

begin






	x_m_tready <=  M_AXIS_TREADY;
	x_s_tlast <=  S_AXIS_TLAST;
	x_s_tvalid <=  S_AXIS_TVALID;
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
-- MASTER
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------

	-- I/O Connections assignments

	M_AXIS_TVALID	<= axis_tvalid_delay;
	M_AXIS_TDATA	<= stream_data_out;
	M_AXIS_TLAST	<= axis_tlast_delay;
	M_AXIS_TSTRB	<= S_AXIS_TSTRB;
	


	-- Control state machine implementation                                               
	process(AXIS_ACLK)                                                                        
	begin                                                                                       
	  if (rising_edge (AXIS_ACLK)) then                                                       
	    if(AXIS_ARESETN = '0') then                                                           
	      -- Synchronous reset (active low)                                                     
	      state_master      <= IDLE;                                                          
	      count <= (others => '0');                                                             
	    else                                                                                    
		
	      case (state_master) is                                                              
	        when IDLE     =>                                                                    
	          -- The slave starts accepting tdata when                                          
	          -- there tvalid is asserted to mark the                                           
	          -- presence of valid streaming data                                               
	          --if (count = "0")then                                                            
	            state_master <= INIT_COUNTER;                                                 
	          --else                                                                              
	          --  state_master <= IDLE;                                                         
	          --end if;                                                                           
	                                                                                            
	          when INIT_COUNTER =>                                                              
	            -- This state is responsible to wait for user defined C_M_START_COUNT           
	            -- number of clock cycles.                                                      
	            if ( count = std_logic_vector(to_unsigned((C_M_START_COUNT - 1), WAIT_COUNT_BITS))) then
	              state_master  <= SEND_STREAM;                                               
	            else                                                                            
	              count <= std_logic_vector (unsigned(count) + 1);                              
	              state_master  <= INIT_COUNTER;                                              
	            end if;                                                                         
	                                                                                            
	        when SEND_STREAM  =>                                                                
	          -- The example design streaming master functionality starts                       
	          -- when the master drives output tdata from the FIFO and the slave                
	          -- has finished storing the S_AXIS_TDATA                                          
	          if (tx_done = '1') then                                                           
	            state_master <= IDLE;                                                         
	          else                                                                              
	            state_master <= SEND_STREAM;                                                  
	          end if;                                                                           
	                                                                                            
	        when others    =>                                                                   
	          state_master <= IDLE;                                                           
	                                                                                            
	      end case;
		 
	    end if;                                                                                 
	  end if;                                                                                   
	end process;                                                                                


	--tvalid generation
	--axis_tvalid is asserted when the control state machine's state is SEND_STREAM and
	--the receiving fifo is not empty.
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	axis_tvalid <= '1' when ((state_master = SEND_STREAM) and (fifo_empty = '0')) else '0';
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------
	                                                                                               
	-- AXI tlast generation                                                                        
	-- axis_tlast is asserted number of output streaming data is NUMBER_OF_WORDS-1          
	-- (0 to NUMBER_OF_WORDS-1)                                                             
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	x_tlast_select <= 	"00" when (TLAST_EN and not TLAST_GEN and not TLAST_PROP) else
						"01" when ( TLAST_PROP and not TLAST_EN and not TLAST_GEN) else
						"10" when ( TLAST_GEN and not TLAST_EN and not TLAST_PROP) else
						"11";
	axis_tlast <= '1' when 	(((read_pointer_peak = write_pointer) and (tx_en = '1') and (fifo_wren = '0') and (x_tlast_select = "00"))
							or ( (x_tlast_select = "10") and (r_tlast_done = '1'))
							or ((x_tlast_select = "01") and (packet_delimiter = read_pointer) and (tx_en = '1') and (fifo_wren = '0')))
							else '0';                     
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------
	                                                                                               
	-- Delay the axis_tvalid and axis_tlast signal by one clock cycle                              
	-- to match the latency of M_AXIS_TDATA                                                        
	process(AXIS_ACLK)                                                                           
	begin                                                                                          
	  if (rising_edge (AXIS_ACLK)) then                                                          
	    if(AXIS_ARESETN = '0') then                                                              
			axis_tvalid_delay <= '0';                                                                
			axis_tlast_delay <= '0';   
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
			fifo_full <= '0';
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

	    else                                                                                       
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
		
	      axis_tvalid_delay <= axis_tvalid;                                                        
	      axis_tlast_delay <= axis_tlast;     
			fifo_full <= '0';
			if write_pointer_peak = read_pointer then
				fifo_full <= '1';
			end if;
			if fifo_full = '1' then
				if write_pointer = read_pointer then
					fifo_full <= '1';
				end if;
			end if;
		
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

	    end if;                                                                                    
	  end if;                                                                                      
	end process;                                                                                   


	--read_pointer pointer

	process(AXIS_ACLK)                                                       
	begin                                                                            
	  if (rising_edge (AXIS_ACLK)) then                                            
	    if(AXIS_ARESETN = '0') then                                                
	      read_pointer <= 0;                                                         
	      tx_done  <= '0';                                                           
		  if(TLAST_EN = false) and (TLAST_GEN = true) then
			packet_count <= 0;
		    r_tlast_done <= '0';
		  end if;
	    else 
		    r_tlast_done <= '0';
			
			if tx_en = '1' then
			    if (read_pointer < NUMBER_OF_WORDS-1) then                         
				                                                    
				  -- read pointer is incremented after every read from the FIFO          
				  -- when FIFO read signal is enabled.  

	-----------------------------------------------------------------------------
	-- mod: 	START		  
	-----------------------------------------------------------------------------
				
					
			
					read_pointer <= read_pointer + 1; 
				else
					read_pointer <= 0;
				end if;
		
				if(TLAST_EN = false) and (TLAST_GEN = true) then
					if packet_count < PACKET-1 then
						packet_count <= packet_count + 1;
						
					else
						packet_count <= 0;
					end if;
					if packet_count = PACKET-1 then
						r_tlast_done <= '1';
					end if;
				end if;
	-----------------------------------------------------------------------------
	-- mod: 	END	  
	-----------------------------------------------------------------------------
				  tx_done <= '0';                                                        
			end if;                                                                  
	-----------------------------------------------------------------------------
	-- mod: 	START		  
	-----------------------------------------------------------------------------
			if (fifo_empty = '1') then                         
	-----------------------------------------------------------------------------
	-- mod: 	END		  
	-----------------------------------------------------------------------------
				-- tx_done is asserted when NUMBER_OF_WORDS numbers of streaming data
				-- has been out.                                                         
				tx_done <= '1';                                                          
			end  if;
			
	    end  if;                                                                     
	  end  if;                                                                       
	end process;                                                                     

-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
fifo_empty <= '1' when((read_pointer = write_pointer) and (fifo_full = '0')) else '0';
--fifo_full <= '1' when(write_pointer_peak = read_pointer) else '0';

-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

	--FIFO read enable generation 

	tx_en <= x_m_tready and axis_tvalid;                                   
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	                                                                                
	-- FIFO Implementation                                                          
	                                                                                
	-- Streaming output data is read from FIFO                                      
	  -- process(AXIS_ACLK)                                                          
	  -- variable  sig_one : integer := 1;                                             
	  -- begin                                                                         
	    -- if (rising_edge (AXIS_ACLK)) then                                         
	      -- if(AXIS_ARESETN = '0') then                                             
	    	-- stream_data_out <= std_logic_vector(to_unsigned(sig_one,C_AXIS_TDATA_WIDTH));  
	      -- elsif (tx_en = '1') then -- && M_AXIS_TSTRB(byte_index)                   
	        -- stream_data_out <= std_logic_vector( to_unsigned(read_pointer,C_AXIS_TDATA_WIDTH) + to_unsigned(sig_one,C_AXIS_TDATA_WIDTH));
	      -- end if;                                                                   
	     -- end if;                                                                    
	   -- end process;                                                                 
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
-- SLAVE
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------
	-- I/O Connections assignments

	S_AXIS_TREADY	<= axis_tready;
	-- Control state machine implementation
	process(AXIS_ACLK)
	begin
	  if (rising_edge (AXIS_ACLK)) then
	    if(AXIS_ARESETN = '0') then
	      -- Synchronous reset (active low)
	      state_slave      <= IDLE;
	    else
		
	      case (state_slave) is
	        when IDLE     => 
	          -- The sink starts accepting tdata when 
	          -- there tvalid is asserted to mark the
	          -- presence of valid streaming data 
	          if (x_s_tvalid = '1' and fifo_full = '0')then
	            state_slave <= WRITE_FIFO;
	          else
	            state_slave <= IDLE;
	          end if;
	      
	        when WRITE_FIFO => 
	          -- When the sink has accepted all the streaming input data,
	          -- the interface swiches functionality to a streaming master
	          if (writes_done = '1') then
	            state_slave <= IDLE;
	          else
	            -- The sink accepts and stores tdata 
	            -- into FIFO
	            state_slave <= WRITE_FIFO;
	          end if;
	        
	        when others    => 
	          state_slave <= IDLE;
	        
	      end case;
		 
	    end if;  
	  end if;
	end process;
	-- AXI Streaming Sink 
	-- 
	-- The example design sink is always ready to accept the S_AXIS_TDATA  until
	-- the FIFO is not filled with NUMBER_OF_WORDS number of input words.
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	axis_tready <= '1' when ((state_slave = WRITE_FIFO) and (fifo_full = '0')) else '0';
	-- in tlast disabled and tlast generate mode we ignore the in coming tlast signal.
	x_s_axis_tlast <= x_s_tlast when (x_tlast_select = "01") else '0';
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

	process(AXIS_ACLK)
	begin
	  if (rising_edge (AXIS_ACLK)) then
	    if(AXIS_ARESETN = '0') then
	      write_pointer <= 0;
	      writes_done <= '0';
		  packet_delimiter <= -1;
	    else
			
			
			if (fifo_wren = '1') then
			    if (write_pointer < NUMBER_OF_WORDS-1) then
				
				  -- write pointer is incremented after every write to the FIFO
				  -- when FIFO write signal is enabled.
	-----------------------------------------------------------------------------
	-- mod: 	START		  
	-----------------------------------------------------------------------------

					write_pointer <= write_pointer + 1;
				else
					write_pointer <= 0;
				end if;
				
				
	-----------------------------------------------------------------------------
	-- mod: 	ENd		  
	-----------------------------------------------------------------------------
				  
			end if;
			writes_done <= '0';
	-----------------------------------------------------------------------------
	-- mod: 	START		  
	-----------------------------------------------------------------------------
			if (fifo_full = '1') then
					
	-----------------------------------------------------------------------------
	-- mod: 	END		  
	-----------------------------------------------------------------------------
				  -- reads_done is asserted when NUMBER_OF_WORDS numbers of streaming data 
				  -- has been written to the FIFO which is also marked by x_s_axis_tlast(kept for optional usage).
				  writes_done <= '1';
			end if;
			if  x_s_axis_tlast = '1' then
					-- register the index where the last word of the packet is stored.
					packet_delimiter <= write_pointer;
				  writes_done <= '1';
			
			end if;
		
				-- In tlast propagate mode: once the t_last is generated, then the packet delimiter can be reset.
		if axis_tlast = '1' then
			packet_delimiter <= -1;
		end if;
		
	    end if;
	  end if;
	end process;
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
write_pointer_peak <= 0 when (write_pointer = NUMBER_OF_WORDS-1) else write_pointer + 1;
read_pointer_peak <= 0 when (read_pointer = NUMBER_OF_WORDS-1) else read_pointer + 1;
packet_count_peak <= 0 when (packet_count = PACKET-1) else packet_count + 1;
-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------

	-- FIFO write enable generation
	fifo_wren <= x_s_tvalid and axis_tready;

	-- FIFO Implementation
	 FIFO_GEN: for byte_index in 0 to ((C_AXIS_TDATA_WIDTH/8)-1) generate

	 signal stream_data_fifo : BYTE_FIFO_TYPE;
	 begin   
	  -- Streaming input data is stored in FIFO
	  process(AXIS_ACLK)
	  begin
	    if (rising_edge (AXIS_ACLK)) then
			
				if (fifo_wren = '1') then
					stream_data_fifo(write_pointer) <= S_AXIS_TDATA((byte_index*8+7) downto (byte_index*8));				
				end if;
			
-----------------------------------------------------------------------------
-- mod: 	START		  
-----------------------------------------------------------------------------
	    if(AXIS_ARESETN = '0') then                                             
			stream_data_out((byte_index*8+7) downto (byte_index*8)) <= (others => '0');  
	    else
			
				if (tx_en = '1') then -- && M_AXIS_TSTRB(byte_index)                   
					stream_data_out((byte_index*8+7) downto (byte_index*8)) <= stream_data_fifo(read_pointer);
				end if;
			
		end if;                                                                   

-----------------------------------------------------------------------------
-- mod: 	END		  
-----------------------------------------------------------------------------
	    end  if;
	  end process;

	end generate FIFO_GEN;
-----------------------------------------------------------------------------
-- addition: 	START		  
-----------------------------------------------------------------------------
	
	TUSER_GEN:if TUSER_EN = true generate
	
		M_AXIS_TUSER <= stream_user_out;

		USER_FIFO_GEN: for byte_index in 0 to ((C_AXIS_TUSER_WIDTH/4)-1) generate
		signal stream_user_fifo : NYBLE_FIFO_TYPE;
		begin
	   process(AXIS_ACLK)
        begin
			if rising_edge (AXIS_ACLK) then
				
					if (fifo_wren = '1') then
						stream_user_fifo(write_pointer) <= S_AXIS_TUSER((byte_index*4+3) downto (byte_index*4));				
					end if;
				
					if(AXIS_ARESETN = '0') then                                             
						stream_user_out((byte_index*4+3) downto (byte_index*4)) <= (others => '0');  
					else
						
							if (tx_en = '1') then -- && M_AXIS_TSTRB(byte_index)                   
								stream_user_out((byte_index*4+3) downto (byte_index*4)) <= stream_user_fifo(read_pointer);
							end if;
						
					end if;                                                                   

			end  if;
		end process;
		end generate USER_FIFO_GEN;
		
	end generate TUSER_GEN;
	
	SAMPLE_VALID <= fifo_wren;

-----------------------------------------------------------------------------
-- addition: 	END		  
-----------------------------------------------------------------------------


end implementation;
-----------------------------------------------------------------------------
-- mod: 			  
-----------------------------------------------------------------------------
