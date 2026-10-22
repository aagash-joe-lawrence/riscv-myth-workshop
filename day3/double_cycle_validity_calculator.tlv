\m5_TLV_version 1d: tl-x.org
\m5
   
   // ============================================
   // Welcome, new visitors! Try the "Learn" menu.
   // ============================================
   
   //use(m5-1.0)   /// uncomment to use M5 macro library.
\SV
   // Macro providing required top-level module definition, random
   // stimulus support, and Verilator config.
   m5_makerchip_module   // (Expanded in Nav-TLV pane.)
\TLV
   
   |calc
      @1
         // Connect SV inputs to TLV pipesignals.
         $reset = *reset;
         $valid_or_reset = $valid || $reset;

         // Free running counter
         $counter[31:0] = ($reset)? 1'b0: >>1$counter + 1;
      ?$valid_or_reset
         @1
            //combinational calculator
            $val1[31:0] = >>2$out;
            $sum[31:0] = $val1 + $val2[31:0];
            $diff[31:0] = $val1 - $val2;
            $prod[31:0] = $val1 * $val2;
            $quot[31:0] = $val1 / $val2;
            $valid = $counter;

         @2
            $out[31:0] = ($reset || !$valid) ? 32'b0 :
                         ($op[1:0] == 2'b00) ? $sum:
                         ($op[1:0] == 2'b01) ? $diff:
                         ($op[1:0] == 2'b10) ? $prod:
                         ($op[1:0] == 2'b11) ? $quot: 32'b0;
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
