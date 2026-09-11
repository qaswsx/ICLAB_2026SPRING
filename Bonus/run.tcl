clear -all

analyze -sv12 rr.sv rr_checker.sv
elaborate -top rr -create_related_cover {}

clock clk
reset ~rst_n

prove -all -prefer_shortest
