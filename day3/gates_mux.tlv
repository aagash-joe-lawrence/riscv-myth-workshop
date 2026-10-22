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
   // Connect SV inputs to TLV pipesignals.
   $reset = *reset;
   //invertor
   $out_inv = !$in;
   // 2 input gates
   $and = $a && $b;
   $or = $a || $b;
   $xor = $a ^ $b;
   // vector
   $out_vec[4:0] = $in1[3:0] + $in2[3:0];
   // mux 
   $out_mux[7:0] = $sel ? $in1[7:0] : $in2[7:0];
   
   // Assert these to end simulation (before the cycle limit).
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
