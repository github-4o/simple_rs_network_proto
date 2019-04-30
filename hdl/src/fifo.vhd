library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fifo is
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
end entity;

architecture v1 of fifo is

    type tMem is array (255 downto 0) of std_logic_vector (7 downto 0);

    signal sCnt: natural range 0 to 256;
    signal sWr_addr: natural range 0 to 255;
    signal sRd_addr: natural range 0 to 255;

    signal sCase: std_logic_vector (1 downto 0);

    signal sMem: tMem;

begin

    oCount <= x"ff" when sCnt = 256 else std_logic_vector(to_unsigned(sCnt, 8));

    sCase <= iNd & iRd;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            sWr_addr <= 0;
        else
            if iClk'event and iClk = '1' then
                if iNd = '1' then
                    sWr_addr <= sWr_addr+1;
                end if;
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            sRd_addr <= 0;
        else
            if iClk'event and iClk = '1' then
                if iRd = '1' then
                    sRd_addr <= sRd_addr+1;
                end if;
            end if;
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            sCnt <= 0;
        else
            if iClk'event and iClk = '1' then
                case sCase is
                    when "10" =>
                        assert sCnt < 256
                            report "overflow"
                            severity failure;
                        sCnt <= sCnt+1;
                    when "01" =>
                        assert sCnt > 0
                            report "underflow"
                            severity failure;
                        sCnt <= sCnt-1;
                    when others =>
                        sCnt <= sCnt;
                end case;
            end if;
        end if;
    end process;

    process (iClk)
    begin
        if iClk'event and iClk = '1' then
            if iNd = '1' then
                sMem (sWr_addr) <= iData;
            end if;

            oData <= sMem(sRd_addr);
        end if;
    end process;

    process (iClk, iReset)
    begin
        if iReset = '0' then
            oNd <= '0';
        else
            if iClk'event and iClk = '1' then
                oNd <= iRd;
            end if;
        end if;
    end process;

end v1;
