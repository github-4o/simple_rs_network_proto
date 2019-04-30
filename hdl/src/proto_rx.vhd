library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity proto_rx is
    port (
        iNd: in std_logic;
        iData: in std_logic_vector (7 downto 0);

        oProto_nd: out std_logic_vector;
        oProto_data: out std_logic_vector;

        oSend_pong: out std_logic;

        iClk: in std_logic;
        iReset: in std_logic
    );
end entity;

architecture v1 of proto_rx is

    constant cW: natural := oProto_nd'length;

    type tState is (
        idle,
        pong,
        addr,
        len,
        data
    );

    signal sState: tState;
    signal sAddr: natural range 0 to cW-1;
    signal sCnt: natural range 255 downto 0;
    signal sData: std_logic_vector (7 downto 0);

begin

    assign_out_data: for i in cW-1 downto 0 generate

        oProto_data(oProto_data'low+(i+1)*8-1 downto oProto_data'low+i*8)
            <= sData;

    end generate;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            sState <= idle;
            oProto_nd <= (oProto_nd'range => '0');
            sData <= (sData'range => '0');
            sAddr <= 0;
        else
            if iClk'event and iClk = '1' then
                oProto_nd <= (oProto_nd'range => '0');
                case sState is
                    when idle =>
                        if iNd = '1' then
                            if iData = x"55" then
                                sState <= pong;
                            else
                                sState <= addr;
                            end if;
                        end if;

                    when addr =>
                        if iNd = '1' then
                            sAddr <= to_integer(unsigned(iData));
                            sState <= len;
                        end if;

                    when len =>
                        if iNd = '1' then
                            sCnt <= to_integer(unsigned(iData));
                            sState <= data;
                        end if;

                    when data =>
                        if iNd = '1' then
                            oProto_nd(sAddr) <= '1';
                            sData <= iData;
                            if sCnt = 1 then
                                sState <= idle;
                            else
                                sCnt <= sCnt-1;
                            end if;
                        end if;

                    when pong =>
                        sState <= idle;

                    when others =>
                        sState <= idle;
                end case;
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            oSend_pong <= '0';
        else
            if iClk'event and iClk = '1' then
                if sState = pong then
                    oSend_pong <= '1';
                else
                    oSend_pong <= '0';
                end if;
            end if;
        end if;
    end process;

end v1;
