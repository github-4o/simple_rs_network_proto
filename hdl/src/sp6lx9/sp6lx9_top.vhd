library ieee;
use ieee.std_logic_1164.all;


entity sp6lx9_top is
    port (
        iClk: in std_logic;

        iRs: in std_logic;
        oRs: out std_logic
    );
end entity;

architecture v1 of sp6lx9_top is

    attribute loc: string;
    attribute loc of iClk: signal is "C10";
    attribute loc of iRs: signal is "R7";
    attribute loc of oRs: signal is "T7";

    component mmcm_100_80
        port (
            CLK_IN1: in std_logic;
            CLK_OUT1: out std_logic;
            LOCKED: out std_logic
        );
    end component;

    component grlib_uart
        port (
            rst: in std_ulogic;
            clk: in std_ulogic;

            read: in std_logic;
            dready: out std_logic;
            odata: out std_logic_vector (7 downto 0);

            write: in std_logic;
            idata: in std_logic_vector (7 downto 0);

            tsempty: out std_logic;
            thempty: out std_logic;
            lock: out std_logic;
            enable: out std_logic;

            iRs: in std_logic;
            oRs: out std_logic
        );
    end component;

    signal sClk: std_logic;
    signal sReset: std_logic;

    signal sRx_nd: std_logic;
    signal sRx_data: std_logic_vector (7 downto 0);

    signal sTx_nd: std_logic;
    signal sTx_data: std_logic_vector (7 downto 0);

begin

    sTx_nd <= sRx_nd;
    sTx_data <= sRx_data;

    mmcm: mmcm_100_80
        port map (
            CLK_IN1 => iClk,
            CLK_OUT1 => sClk,
            LOCKED => sReset
        );

    uart: grlib_uart
        port map (
            rst => sReset,
            clk => sClk,

            read => sRx_nd,
            dready => sRx_nd,
            odata => sRx_data,

            write => sTx_nd,
            idata => sTx_data,

            --tsempty: out std_logic;
            --thempty: out std_logic;
            --lock: out std_logic;
            --enable: out std_logic;

            iRs => iRs,
            oRs => oRs
        );

end v1;
