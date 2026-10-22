.section .text
.global load
.type load, @function

load:
	add a4, a0, zero // a4=0x0 ,first argument passed to load
	add a2, a0, a1   // a2=0x0 +n ,a1 is second argument passed to load
	add a3, a0, zero // a3=0 ,the counter variable which counts frm 0 to n (a2)

loop:   add a4, a4, a3   // a4= a4+a3 ,the accumulator which is the cumulative sum
	addi a3, a3, 1   // a3=a3+1 the counter incremented
	blt a3, a2, loop // counter<n
	add a0, a4, zero // ans(a4) stored in a0
	ret              // a0 preserves the ans and c program gets the cumulative sum
