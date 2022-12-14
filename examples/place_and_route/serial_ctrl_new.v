(* src = "control.v:1.1-131.10" *)
module serial_ctrl(clk, data_in, write, data_ready, data_out_shift_reg_in, reset_internal, enable_data_counter, update, reset_shift_reg_out, enable_shift_register, write_shift_register);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  wire _08_;
  wire _09_;
  wire _10_;
  wire _11_;
  wire _12_;
  wire _13_;
  wire _14_;
  wire _15_;
  wire _16_;
  wire _17_;
  wire _18_;
  wire _19_;
  wire _20_;
  wire _21_;
  wire _22_;
  wire _23_;
  wire _24_;
  wire _25_;
  wire _26_;
  wire _27_;
  (* force_downto = 32'd1 *)
  (* src = "control.v:0.0-0.0|control.v:64.13-125.20|/usr/bin/../share/yosys/techmap.v:575.21-575.22" *)
  wire [2:0] _28_;
  (* src = "control.v:3.11-3.14" *)
  input clk;
  wire clk;
  (* src = "control.v:56.16-56.23" *)
  wire [1:0] command;
  (* src = "control.v:55.10-55.23" *)
  wire command_empty;
  (* src = "control.v:54.10-54.23" *)
  wire command_ready;
  (* src = "control.v:29.15-29.25" *)
  wire [3:0] curr_state;
  (* src = "control.v:28.15-28.29" *)
  wire [3:0] curr_state_pre;
  (* src = "control.v:4.11-4.18" *)
  input data_in;
  wire data_in;
  (* src = "control.v:7.11-7.32" *)
  input data_out_shift_reg_in;
  wire data_out_shift_reg_in;
  (* src = "control.v:6.11-6.21" *)
  input data_ready;
  wire data_ready;
  (* src = "control.v:9.12-9.31" *)
  output enable_data_counter;
  wire enable_data_counter;
  (* src = "control.v:12.12-12.33" *)
  output enable_shift_register;
  wire enable_shift_register;
  (* src = "control.v:52.10-52.25" *)
  wire receive_command;
  (* src = "control.v:8.11-8.25" *)
  input reset_internal;
  wire reset_internal;
  (* src = "control.v:11.12-11.31" *)
  output reset_shift_reg_out;
  wire reset_shift_reg_out;
  (* src = "control.v:10.12-10.18" *)
  output update;
  wire update;
  (* src = "control.v:5.12-5.17" *)
  output write;
  wire write;
  (* src = "control.v:13.12-13.32" *)
  output write_shift_register;
  wire write_shift_register;
  not_gate _29_ (
    .I(curr_state[3]),
    .O(_01_)
  );
  not_gate _30_ (
    .I(curr_state[1]),
    .O(_02_)
  );
  not_gate _31_ (
    .I(curr_state[0]),
    .O(_03_)
  );
  not_gate _32_ (
    .I(command[1]),
    .O(_04_)
  );
  and_gate _33_ (
    .A(curr_state[1]),
    .B(_03_),
    .O(_05_)
  );
  and_gate _34_ (
    .A(_01_),
    .B(curr_state[2]),
    .O(_06_)
  );
  nand_gate _35_ (
    .A(_05_),
    .B(_06_),
    .O(reset_shift_reg_out)
  );
  xor_gate _36_ (
    .A(curr_state[1]),
    .B(curr_state[0]),
    .O(_07_)
  );
  and_gate _37_ (
    .A(_06_),
    .B(_07_),
    .O(update)
  );
  nor_gate _38_ (
    .A(curr_state[3]),
    .B(curr_state[2]),
    .O(_08_)
  );
  and_gate _39_ (
    .A(_02_),
    .B(_08_),
    .O(enable_data_counter)
  );
  and_gate _40_ (
    .A(curr_state[0]),
    .B(enable_data_counter),
    .O(write)
  );
  nor_gate _41_ (
    .A(curr_state[1]),
    .B(curr_state[0]),
    .O(_09_)
  );
  and_gate _42_ (
    .A(_08_),
    .B(_09_),
    .O(write_shift_register)
  );
  and_gate _43_ (
    .A(_05_),
    .B(_08_),
    .O(receive_command)
  );
  nand_gate _44_ (
    .A(command_ready),
    .B(command[0]),
    .O(_10_)
  );
  nand_gate _45_ (
    .A(_03_),
    .B(_10_),
    .O(_11_)
  );
  nand_gate _46_ (
    .A(_08_),
    .B(_11_),
    .O(_12_)
  );
  nor_gate _47_ (
    .A(_09_),
    .B(_12_),
    .O(_28_[0])
  );
  nand_gate _48_ (
    .A(data_ready),
    .B(write),
    .O(_13_)
  );
  and_gate _49_ (
    .A(_01_),
    .B(_13_),
    .O(_14_)
  );
  xor_gate _50_ (
    .A(command[1]),
    .B(command[0]),
    .O(_15_)
  );
  nand_gate _51_ (
    .A(command_ready),
    .B(_15_),
    .O(_16_)
  );
  nand_gate _52_ (
    .A(receive_command),
    .B(_16_),
    .O(_17_)
  );
  and_gate _53_ (
    .A(command_empty),
    .B(_09_),
    .O(_18_)
  );
  nand_gate _54_ (
    .A(command_empty),
    .B(_09_),
    .O(_19_)
  );
  nand_gate _55_ (
    .A(_06_),
    .B(_18_),
    .O(_20_)
  );
  and_gate _56_ (
    .A(_17_),
    .B(_20_),
    .O(_21_)
  );
  nand_gate _57_ (
    .A(_14_),
    .B(_21_),
    .O(_28_[1])
  );
  and_gate _58_ (
    .A(command_ready),
    .B(_04_),
    .O(_22_)
  );
  nand_gate _59_ (
    .A(receive_command),
    .B(_22_),
    .O(_23_)
  );
  nand_gate _60_ (
    .A(data_ready),
    .B(write_shift_register),
    .O(_24_)
  );
  nand_gate _61_ (
    .A(_06_),
    .B(_19_),
    .O(_25_)
  );
  and_gate _62_ (
    .A(_24_),
    .B(_25_),
    .O(_26_)
  );
  and_gate _63_ (
    .A(_23_),
    .B(_26_),
    .O(_27_)
  );
  nand_gate _64_ (
    .A(_14_),
    .B(_27_),
    .O(_28_[2])
  );
  buf_gate _65_ (
    .I(reset_internal),
    .O(_00_)
  );
  (* src = "control.v:59.5-127.8" *)
  dffpq _66_ (
    .CLK(clk),
    .D(_28_[0]),
    .Q(curr_state_pre[0])
  );
  (* src = "control.v:59.5-127.8" *)
  dffpq _67_ (
    .CLK(clk),
    .D(_28_[1]),
    .Q(curr_state_pre[1])
  );
  (* src = "control.v:59.5-127.8" *)
  dffpq _68_ (
    .CLK(clk),
    .D(_28_[2]),
    .Q(curr_state_pre[2])
  );
  (* src = "control.v:128.5-130.8" *)
  dffnq _69_ (
    .CLK(clk),
    .D(curr_state_pre[0]),
    .Q(curr_state[0])
  );
  (* src = "control.v:128.5-130.8" *)
  dffnq _70_ (
    .CLK(clk),
    .D(curr_state_pre[1]),
    .Q(curr_state[1])
  );
  (* src = "control.v:128.5-130.8" *)
  dffnq _71_ (
    .CLK(clk),
    .D(curr_state_pre[2]),
    .Q(curr_state[2])
  );
  (* src = "control.v:128.5-130.8" *)
  dffnq _72_ (
    .CLK(clk),
    .D(curr_state_pre[3]),
    .Q(curr_state[3])
  );
  (* src = "control.v:59.5-127.8" *)
  dffpq _73_ (
    .CLK(clk),
    .D(_00_),
    .Q(curr_state_pre[3])
  );
  assign enable_shift_register = enable_data_counter;
  wire _00_reg;
  wire _01_reg;
  wire _02_reg;
  wire _03_reg;
  wire _04_reg;
  wire [4:0] cmd_reg;
  (* src = "command_register.v:15.15-15.26" *)
  wire [4:0] cmd_reg_pre;
  (* src = "command_register.v:7.18-7.25" *)
  nor_gate _05_reg (
    .A(command[1]),
    .B(command[0]),
    .O(_01_reg)
  );
  or_gate _06_reg (
    .A(cmd_reg[3]),
    .B(cmd_reg[2]),
    .O(_02_reg)
  );
  nor_gate _07_reg (
    .A(cmd_reg[4]),
    .B(_02_reg),
    .O(_03_reg)
  );
  and_gate _08_reg (
    .A(_01_reg),
    .B(_03_reg),
    .O(command_empty)
  );
  nand_gate _09_reg (
    .A(cmd_reg[2]),
    .B(cmd_reg[4]),
    .O(_04_reg)
  );
  nor_gate _10_reg (
    .A(cmd_reg[3]),
    .B(_04_reg),
    .O(command_ready)
  );
  and_gate _11_reg (
    .A(data_in),
    .B(receive_command),
    .O(_00_reg)
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _12_reg (
    .CLK(clk),
    .D(_00_reg),
    .Q(cmd_reg_pre[0])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _13_reg (
    .CLK(clk),
    .D(command[0]),
    .Q(cmd_reg_pre[1])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _14_reg (
    .CLK(clk),
    .D(command[1]),
    .Q(cmd_reg_pre[2])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _15_reg (
    .CLK(clk),
    .D(cmd_reg[2]),
    .Q(cmd_reg_pre[3])
  );
  (* src = "command_register.v:19.5-26.8" *)
  dffpq _16_reg (
    .CLK(clk),
    .D(cmd_reg[3]),
    .Q(cmd_reg_pre[4])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _17_reg (
    .CLK(clk),
    .D(cmd_reg_pre[0]),
    .Q(command[0])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _18_reg (
    .CLK(clk),
    .D(cmd_reg_pre[1]),
    .Q(command[1])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _19_reg (
    .CLK(clk),
    .D(cmd_reg_pre[2]),
    .Q(cmd_reg[2])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _20_reg (
    .CLK(clk),
    .D(cmd_reg_pre[3]),
    .Q(cmd_reg[3])
  );
  (* src = "command_register.v:16.5-18.8" *)
  dffnq _21_reg (
    .CLK(clk),
    .D(cmd_reg_pre[4]),
    .Q(cmd_reg[4])
  );
  assign cmd_reg[1:0] = command;
endmodule

