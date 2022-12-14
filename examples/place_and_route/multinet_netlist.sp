.SUBCKT multinet in out
    Xinv1 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xinv2 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xinv3 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xinv4 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xinv5 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
    Xinv6 not_gate $PINS I=in O=out VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P
.ENDS
