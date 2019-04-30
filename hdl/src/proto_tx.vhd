library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity proto_tx is
    port (
        oNd: out std_logic;
        oData: out std_logic_vector (7 downto 0);

        iSend_pong: in std_logic;

        iProto_nd: in std_logic_vector;
        iProto_data: in std_logic_vector;

        iClk: in std_logic;
        iReset: in std_logic
    );
end entity;

architecture v1 of proto_tx is

    constant cW: natural := iProto_nd'length;

    type tByte_ar is array (natural range <>) of std_logic_vector (7 downto 0);

    type tState is (
        test_ch,
        send_pong,
        inc_ch,
        send_addr,
        send_len,
        send_data
    );

    component fifo
        port (
            iClk: in std_logic;
            iReset: in std_logic;

            iNd: in std_logic;
            iData: in std_logic_vector (7 downto 0);

            oCount: out std_logic_vector (7 downto 0);

            iRd: in std_logic;
            oNd: out std_logic;
            oData: out std_logic_vector
        );
    end component;

    component proto_tx_fsm
        port (
            iClk: in std_logic;
            iReset: in std_logic;

            iCount: in std_logic_vector;
            oRd: out std_logic_vector;
            iNd: in std_logic_vector;
            iData: in std_logic_vector;

            oNd: out std_logic;
            oData: out std_logic_vector (7 downto 0)
        );
    end component;

    signal sIn_data: std_logic_vector (iProto_data'length-1 downto 0);
    signal sIn_ar: tByte_ar (cW-1 downto 0);

    signal sCount: tByte_ar (cW-1 downto 0);
    signal sRd: std_logic_vector (cW-1 downto 0);
    signal sNd: std_logic_vector (cW-1 downto 0);
    signal sData: tByte_ar (cW-1 downto 0);

    signal sN: natural range 0 to cW-1;

    signal sState: tState;

    signal sCnt: natural range 0 to 255;

    signal sSend_pong: std_logic;

begin

    assert iProto_data'length = cW*8
        report "width error"
        severity failure;

    sIn_data <= iProto_data;

    data_paths: for i in cW-1 downto 0 generate

        sIn_ar (i) <= sIn_data ((i+1)*8-1 downto i*8);

        fifo_inst: fifo
            port map (
                iClk => iClk,
                iReset => iReset,

                iNd => iProto_nd(i),
                iData => sIn_ar(i),

                oCount => sCount(i),

                iRd => sRd(i),
                oNd => sNd(i),
                oData => sData(i)
            );

    end generate;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            sState <= test_ch;
            sN <= 0;
            oNd <= '0';
            oData <= (oData'range => '0');
            sRd <= (sRd'range => '0');
        else
            if iClk'event and iClk = '1' then
                oNd <= '0';
                sRd <= (others => '0');

                if iSend_pong = '1' then
                    sSend_pong <= '1';
                end if;

                case sState is
                    when test_ch =>
                        if sSend_pong = '1' then
                            oNd <= '1';
                            oData <= x"55";
                            sSend_pong <= '0';
                        else
                            if to_integer(unsigned (sCount(sN))) > 0 then
                                oNd <= '1';
                                oData <= x"aa";
                                sState <= send_addr;
                            else
                                sState <= inc_ch;
                            end if;
                        end if;

                    when inc_ch =>
                        sState <= test_ch;
                        if sN = cW-1 then
                            sN <= 0;
                        else
                            sN <= sN+1;
                        end if;

                    when send_addr =>
                        sState <= send_len;
                        oNd <= '1';
                        oData <= std_logic_vector(to_unsigned(sN, 8));

                    when send_len =>
                        sRd (sN) <= '1';
                        sState <= send_data;
                        sCnt <= to_integer (unsigned (sCount(sN)));
                        oNd <= '1';
                        oData <= sCount(sN);

                    when send_data =>
                        if sCnt = 1 then
                            sState <= test_ch;
                        end if;
                        sCnt <= sCnt-1;
                        oNd <= '1';
                        oData <= sData(sN);

                    when others =>
                        sState <= test_ch;
                end case;
            end if;
        end if;
    end process;

end v1;
