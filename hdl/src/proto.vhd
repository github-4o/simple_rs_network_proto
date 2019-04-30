library ieee;
use ieee.std_logic_1164.all;


entity proto is
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
end entity;

architecture v1 of proto is

    component proto_rx
        port (
            iNd: in std_logic;
            iData: in std_logic_vector (7 downto 0);

            oProto_nd: out std_logic_vector;
            oProto_data: out std_logic_vector;

            oSend_pong: out std_logic;

            iClk: in std_logic;
            iReset: in std_logic
        );
    end component;

    component proto_tx
        port (
            oNd: out std_logic;
            oData: out std_logic_vector (7 downto 0);

            iSend_pong: in std_logic;

            iProto_nd: in std_logic_vector;
            iProto_data: in std_logic_vector;

            iClk: in std_logic;
            iReset: in std_logic
        );
    end component;

    signal sSend_pong: std_logic;

begin

    rx: proto_rx
        port map (
            iNd => iNd,
            iData => iData,

            oProto_nd => oProto_nd,
            oProto_data => oProto_data,

            oSend_pong => sSend_pong,

            iClk => iClk,
            iReset => iReset
        );

    tx: proto_tx
        port map (
            oNd => oNd,
            oData => oData,

            iSend_pong => sSend_pong,

            iProto_nd => iProto_nd,
            iProto_data => iProto_data,

            iClk => iClk,
            iReset => iReset
        );

end v1;
