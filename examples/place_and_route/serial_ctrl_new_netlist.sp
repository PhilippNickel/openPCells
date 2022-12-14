.SUBCKT serial_ctrl clk data_in write data_ready data_out_shift_reg_in reset_internal enable_data_counter update reset_shift_reg_out enable_shift_register write_shift_register
    X_29_ not_gate $PINS I=curr_state_3 O=_01_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_30_ not_gate $PINS I=curr_state_1 O=_02_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_31_ not_gate $PINS I=curr_state_0 O=_03_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_32_ not_gate $PINS I=command_1 O=_04_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_33_ and_gate $PINS A=curr_state_1 B=_03_ O=_05_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_34_ and_gate $PINS A=_01_ B=curr_state_2 O=_06_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_35_ nand_gate $PINS A=_05_ B=_06_ O=reset_shift_reg_out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_36_ xor_gate $PINS A=curr_state_1 B=curr_state_0 O=_07_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_37_ and_gate $PINS A=_06_ B=_07_ O=update VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_38_ nor_gate $PINS A=curr_state_3 B=curr_state_2 O=_08_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_39_ and_gate $PINS A=_02_ B=_08_ O=enable_data_counter VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_40_ and_gate $PINS A=curr_state_0 B=enable_data_counter O=write VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_41_ nor_gate $PINS A=curr_state_1 B=curr_state_0 O=_09_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_42_ and_gate $PINS A=_08_ B=_09_ O=write_shift_register VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_43_ and_gate $PINS A=_05_ B=_08_ O=receive_command VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_44_ nand_gate $PINS A=command_ready B=command_0 O=_10_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_45_ nand_gate $PINS A=_03_ B=_10_ O=_11_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_46_ nand_gate $PINS A=_08_ B=_11_ O=_12_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_47_ nor_gate $PINS A=_09_ B=_12_ O=_28__0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_48_ nand_gate $PINS A=data_ready B=write O=_13_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_49_ and_gate $PINS A=_01_ B=_13_ O=_14_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_50_ xor_gate $PINS A=command_1 B=command_0 O=_15_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_51_ nand_gate $PINS A=command_ready B=_15_ O=_16_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_52_ nand_gate $PINS A=receive_command B=_16_ O=_17_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_53_ and_gate $PINS A=command_empty B=_09_ O=_18_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_54_ nand_gate $PINS A=command_empty B=_09_ O=_19_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_55_ nand_gate $PINS A=_06_ B=_18_ O=_20_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_56_ and_gate $PINS A=_17_ B=_20_ O=_21_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_57_ nand_gate $PINS A=_14_ B=_21_ O=_28__1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_58_ and_gate $PINS A=command_ready B=_04_ O=_22_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_59_ nand_gate $PINS A=receive_command B=_22_ O=_23_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_60_ nand_gate $PINS A=data_ready B=write_shift_register O=_24_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_61_ nand_gate $PINS A=_06_ B=_19_ O=_25_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_62_ and_gate $PINS A=_24_ B=_25_ O=_26_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_63_ and_gate $PINS A=_23_ B=_26_ O=_27_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_64_ nand_gate $PINS A=_14_ B=_27_ O=_28__2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_65_ buf_gate $PINS I=reset_internal O=_00_ VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_66_ dffpq $PINS CLK=clk D=_28__0 Q=curr_state_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_67_ dffpq $PINS CLK=clk D=_28__1 Q=curr_state_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_68_ dffpq $PINS CLK=clk D=_28__2 Q=curr_state_pre_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_69_ dffnq $PINS CLK=clk D=curr_state_pre_0 Q=curr_state_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_70_ dffnq $PINS CLK=clk D=curr_state_pre_1 Q=curr_state_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_71_ dffnq $PINS CLK=clk D=curr_state_pre_2 Q=curr_state_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_72_ dffnq $PINS CLK=clk D=curr_state_pre_3 Q=curr_state_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_73_ dffpq $PINS CLK=clk D=_00_ Q=curr_state_pre_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_05_reg nor_gate $PINS A=command_1 B=command_0 O=_01_reg VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_06_reg or_gate $PINS A=cmd_reg_3 B=cmd_reg_2 O=_02_reg VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_07_reg nor_gate $PINS A=cmd_reg_4 B=_02_reg O=_03_reg VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_08_reg and_gate $PINS A=_01_reg B=_03_reg O=command_empty VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_09_reg nand_gate $PINS A=cmd_reg_2 B=cmd_reg_4 O=_04_reg VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_10_reg nor_gate $PINS A=cmd_reg_3 B=_04_reg O=command_ready VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_11_reg and_gate $PINS A=data_in B=receive_command O=_00_reg VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_12_reg dffpq $PINS CLK=clk D=_00_reg Q=cmd_reg_pre_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_13_reg dffpq $PINS CLK=clk D=command_0 Q=cmd_reg_pre_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_14_reg dffpq $PINS CLK=clk D=command_1 Q=cmd_reg_pre_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_15_reg dffpq $PINS CLK=clk D=cmd_reg_2 Q=cmd_reg_pre_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_16_reg dffpq $PINS CLK=clk D=cmd_reg_3 Q=cmd_reg_pre_4 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_17_reg dffnq $PINS CLK=clk D=cmd_reg_pre_0 Q=command_0 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_18_reg dffnq $PINS CLK=clk D=cmd_reg_pre_1 Q=command_1 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_19_reg dffnq $PINS CLK=clk D=cmd_reg_pre_2 Q=cmd_reg_2 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_20_reg dffnq $PINS CLK=clk D=cmd_reg_pre_3 Q=cmd_reg_3 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    X_21_reg dffnq $PINS CLK=clk D=cmd_reg_pre_4 Q=cmd_reg_4 VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
.ENDS
