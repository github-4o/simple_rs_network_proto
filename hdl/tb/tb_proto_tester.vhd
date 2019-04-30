library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_proto_tester is
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
end entity;

architecture v1 of tb_proto_tester is

    type tPkg is array (natural range <>) of std_logic_vector (7 downto 0);

begin

    process

        procedure check (data: std_logic_vector (7 downto 0)) is
        begin
            while true loop
                wait until iClk'event and iClk = '0';
                if iNd = '1' then
                    if iData = data then
                        return;
                    else
                        report "data check failed";
                        wait for 100 ns;
                        oTest_error <= '1';
                        wait;
                    end if;
                end if;
            end loop;
        end procedure;

        procedure check (pkg: tPkg) is
        begin
            for i in pkg'low to pkg'high loop
                check(pkg(i));
            end loop;
        end procedure;

        procedure check(n: natural; pkg: tPkg) is
        begin
            check(x"aa");
            check(std_logic_vector(to_unsigned(n, 8)));
            check(std_logic_vector(to_unsigned(pkg'length, 8)));
            check(pkg);
        end procedure;

        procedure send (data: std_logic_vector (7 downto 0)) is
        begin
            wait until iClk'event and iClk = '0';
            oNd <= '1';
            oData <= data;
            wait until iClk'event and iClk = '0';
            oNd <= '0';
            wait until iClk'event and iClk = '0';
            wait until iClk'event and iClk = '0';
        end procedure;

        procedure send (pkg: tPkg) is
        begin
            for i in pkg'low to pkg'high loop
                send(pkg(i));
            end loop;
        end procedure;

        procedure send (n: natural; pkg: tPkg) is
        begin
            assert pkg'length <= 256
                report "pkg len error"
                severity failure;

            send(x"aa");
            send(std_logic_vector(to_unsigned(n, 8)));
            send(std_logic_vector(to_unsigned(pkg'length, 8)));
            send(pkg);
        end procedure;

    begin
        report "tester started";
        oNd <= '0';
        oData <= (oData'range => '0');
        oTest_done <= '0';
        oTest_error <= '0';

        report "waiting for reset";
        if iReset /= '0' then
            wait until iReset = '0';
        end if;
        wait until iReset = '1';

        report "sending ping";
        send(tPkg'(0 => x"55"));
        report "checking pong";
        check(tPkg'(0 => x"55"));

        for i in 0 to 2 loop
            report "sending data to ch " & integer'image(i);
            send(i, tPkg'(0 => x"55"));
            report "checking data from ch " & integer'image(i);
            check(i, tPkg'(0 => x"55"));
        end loop;

        report "tester done";
        wait for 100 ns;
        oTest_done <= '1';
        wait;
    end process;

end v1;
