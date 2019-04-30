library ieee;
use ieee.std_logic_1164.all;


entity testbench is
end entity;

architecture v1 of testbench is

    component proto
        port (
            iNd: in std_logic;
            iData: in std_logic_vector (7 downto 0);
            oNd: out std_logic;
            oData: out std_logic_vector (7 downto 0);

            iProto_nd: in std_logic_vector;
            iProto_data: in std_logic_vector;
            oProto_nd: out std_logic_vector;
            oProto_data: out std_logic_vector;

            iClk: in std_logic;
            iReset: in std_logic
        );
    end component;

    component tb_proto_tester
        port (
            iNd: in std_logic;
            iData: in std_logic_vector (7 downto 0);
            oNd: out std_logic;
            oData: out std_logic_vector (7 downto 0);

            iClk: in std_logic;
            iReset: in std_logic;

            oTest_done: out std_logic;
            oTest_error: out std_logic
        );
    end component;

    signal iClk: std_logic;
    signal iReset: std_logic;

    signal iNd: std_logic;
    signal iData: std_logic_vector (7 downto 0);
    signal oNd: std_logic;
    signal oData: std_logic_vector (7 downto 0);

    signal iProto_nd: std_logic_vector (2 downto 0);
    signal iProto_data: std_logic_vector (3*8-1 downto 0);
    signal oProto_nd: std_logic_vector (2 downto 0);
    signal oProto_data: std_logic_vector (3*8-1 downto 0);

    signal oTest_done: std_logic;
    signal oTest_error: std_logic;

begin

    process
    begin
        iClk <= '0';
        wait for 5 ns;
        iClk <= '1';
        wait for 5 ns;
    end process;

    process
    begin
        iReset <= '0';
        wait for 101 ns;
        iReset <= '1';
        wait;
    end process;

    assert oTest_done /= '1'
        report "test done at " & time'image(now) & " :)"
        severity failure;

    assert oTest_error /= '1'
        report "test failed at " & time'image(now) & " :("
        severity failure;

    iProto_nd <= oProto_nd;
    iProto_data <= oProto_data;

    uut: proto
        port map (
            iNd => iNd,
            iData => iData,
            oNd => oNd,
            oData => oData,

            iProto_nd => iProto_nd,
            iProto_data => iProto_data,
            oProto_nd => oProto_nd,
            oProto_data => oProto_data,

            iClk => iClk,
            iReset => iReset
        );

    tester: tb_proto_tester
        port map (
            iNd => oNd,
            iData => oData,
            oNd => iNd,
            oData => iData,

            iClk => iClk,
            iReset => iReset,

            oTest_done => oTest_done,
            oTest_error => oTest_error
        );

end v1;
