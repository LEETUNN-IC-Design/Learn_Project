# HDLBits — Sequential Logic / Shift Register / LFSR / Memory & LUT

> Ghi chú học tập Digital IC / RTL Design  
> Mục tiêu: hiểu **bản chất phần cứng** trước khi viết Verilog.

---

## 1. Tổng quan những gì đã học

Trong nhóm bài này, tôi đã đi từ các mạch tuần tự cơ bản đến những cấu trúc gần với RTL thực tế:

- Shift Register
- Load / Enable / Hold
- Shift trái / phải
- Rotate trái / phải
- Arithmetic Shift
- LFSR (Linear Feedback Shift Register)
- Galois LFSR
- Structural / hierarchical RTL
- Module instantiation
- Synchronous / asynchronous reset
- Phân biệt sequential và combinational logic
- Multiplexer (MUX) và memory read
- 8x1 memory
- 3-input LUT
- Tư duy `Current State → Next State → Clock Edge → New State`

Đây là nhóm kiến thức rất quan trọng vì nó bắt đầu chuyển từ **Digital Logic** sang cách tư duy của **RTL Design**.

---

# 2. Tư duy cốt lõi: Verilog mô tả phần cứng

Verilog không phải chương trình chạy từng dòng như C/C++.

Ví dụ:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

không nên hiểu là:

> "Đến dòng này thì chương trình lấy d rồi gán cho q."

Mà phải hiểu:

> Đây là mô tả một **D Flip-Flop**, tại cạnh clock thì D được chốt vào Q.

Với mạch tuần tự, luôn suy nghĩ:

```text
Current State
     ↓
Next-State Logic
     ↓
Clock Edge
     ↓
New State
```

Đây là tư duy nền tảng cho Register, Counter, FSM, FIFO, Pipeline và nhiều RTL block khác.

---

# 3. Shift Register

## 3.1. Bản chất

Shift Register là một dãy Flip-Flop nối tiếp nhau.

Ví dụ 8-bit:

```text
S → Q0 → Q1 → Q2 → Q3 → Q4 → Q5 → Q6 → Q7
```

Mỗi clock, dữ liệu dịch sang vị trí kế tiếp.

Với bài 8-bit memory:

```text
Q0_next = S
Q1_next = Q0
Q2_next = Q1
...
Q7_next = Q6
```

Có thể viết ngắn:

```verilog
Q <= {Q[6:0], S};
```

Ý nghĩa:

```text
new Q[7] = old Q[6]
new Q[6] = old Q[5]
...
new Q[1] = old Q[0]
new Q[0] = S
```

## 3.2. Enable

Enable quyết định có shift hay không:

```text
enable = 1 → shift
enable = 0 → hold
```

RTL:

```verilog
always @(posedge clk) begin
    if (enable)
        Q <= {Q[6:0], S};
end
```

Không cần viết:

```verilog
else
    Q <= Q;
```

vì Flip-Flop tự giữ giá trị khi không được cập nhật.

---

# 4. Load / Enable / Hold

Một pattern rất quan trọng:

```text
if (load)
    load data
else if (enable)
    shift / update
else
    hold
```

Ví dụ:

```verilog
always @(posedge clk) begin
    if (load)
        q <= data;
    else if (enable)
        q <= next_value;
end
```

Có thể hiểu như một MUX trước D Flip-Flop:

```text
             ┌──────────┐
data ───────►│          │
             │   MUX    ├──► DFF ──► Q
next ───────►│          │
             └──────────┘
                 ▲
              control
```

Thứ tự ưu tiên của control rất quan trọng.

Ví dụ:

```text
load > enable > hold
```

Nếu `load=1`, phải load và không được để logic shift chạy tiếp.

---

# 5. Asynchronous và Synchronous Reset

## Synchronous reset

Reset chỉ được kiểm tra tại clock edge:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 0;
    else
        ...
end
```

## Asynchronous reset

Reset có thể tác động ngay cả khi clock chưa thay đổi:

```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 0;
    else
        ...
end
```

Điểm cần nhớ:

```text
Synchronous:
reset nằm trong logic của clock

Asynchronous:
reset xuất hiện trong sensitivity list
```

Ngoài ra cần chú ý reset active-high hay active-low.

Ví dụ:

```verilog
if (reset)
```

→ active-high.

```verilog
if (!resetn)
```

→ active-low.

---

# 6. Shift và Rotate

## Shift

Bit bị đẩy ra ngoài sẽ mất.

Ví dụ right shift:

```text
10110110
   ↓
01011011
```

Bit mới ở bên trái được thêm vào, thường là `0` hoặc sign bit.

## Rotate

Bit bị đẩy ra ngoài được đưa vòng trở lại.

Ví dụ rotate right:

```text
10110110
     ↓
01011011
```

Trong trường hợp này bit ngoài cùng bên phải `0` được đưa về đầu.

Với 100-bit:

```verilog
// rotate right
q <= {q[0], q[99:1]};

// rotate left
q <= {q[98:0], q[99]};
```

### Cách tự kiểm tra

Không học thuộc công thức. Hãy hỏi:

> "Sau clock, bit cũ nào sẽ đi đến vị trí nào?"

---

# 7. Arithmetic Shift

Arithmetic shift quan trọng khi dữ liệu được xem là **signed**.

## Left shift

Thường thêm `0` ở LSB:

```verilog
q <= {q[62:0], 1'b0};
```

Shift 8:

```verilog
q <= {q[55:0], 8'b0};
```

## Arithmetic right shift

Phải giữ sign bit.

Ví dụ:

```text
10110110
   ↓ arithmetic right 1
11011011
```

Bit `1` ở MSB được copy vào vị trí mới.

RTL:

```verilog
q <= {q[63], q[63:1]};
```

Arithmetic right 8:

```verilog
q <= {{8{q[63]}}, q[63:8]};
```

### Replication operator

```verilog
{8{q[63]}}
```

nghĩa là:

```text
q[63] q[63] q[63] q[63] q[63] q[63] q[63] q[63]
```

Đây là kiến thức rất quan trọng khi làm signed datapath.

---

# 8. Concatenation và kiểm tra width

Concatenation:

```verilog
{a, b, c}
```

là ghép các bit/vector lại với nhau.

Ví dụ:

```verilog
{q[62:0], 1'b0}
```

có:

```text
63 + 1 = 64 bit
```

Khi viết shift/rotate, luôn kiểm tra:

> Tổng số bit ở RHS có bằng width của thanh ghi không?

Đây là một lỗi rất dễ gặp trong RTL.

---

# 9. LFSR — Linear Feedback Shift Register

## 9.1. LFSR là gì?

LFSR = Linear Feedback Shift Register.

Nó gồm:

```text
Shift Register
+
Feedback
+
XOR logic
```

Khác với shift register thông thường, LFSR lấy một hoặc nhiều bit trong thanh ghi làm feedback để tạo sequence.

LFSR có tính:

- deterministic
- pseudo-random
- chu kỳ dài
- phần cứng đơn giản

## 9.2. Maximal-length LFSR

Với LFSR `n` bit, maximal-length có thể tạo:

```text
2^n - 1
```

trạng thái khác 0.

Ví dụ 5-bit:

```text
2^5 - 1 = 31
```

Điều này giải thích tại sao reset LFSR về `0` thường không phù hợp: trạng thái toàn 0 có thể trở thành lock-up state.

Reset về:

```verilog
q <= 5'h1;
```

là hợp lý.

---

# 10. Galois LFSR và Tap

Trong bài Galois LFSR, đề cho các tap theo **bit position**.

Ví dụ 5-bit:

```text
position 5 → q[4]
position 3 → q[2]
```

Vì:

```text
bit position:  1 2 3 4 5
Verilog index: 0 1 2 3 4
```

Đây là một điểm rất dễ nhầm.

Với 32-bit:

```text
position 32 → q[31]
position 22 → q[21]
position 2  → q[1]
position 1  → q[0]
```

## Ý nghĩa

Tap xác định vị trí mà feedback được XOR vào.

Tư duy nên là:

```text
old state
   ↓
shift
   ↓
feedback = selected bit
   ↓
XOR feedback vào các tap
   ↓
next state
```

---

# 11. Nonblocking Assignment `<=`

Trong sequential logic, dùng:

```verilog
<=
```

thay vì:

```verilog
=
```

Ví dụ:

```verilog
always @(posedge clk) begin
    q[0] <= q[1];
    q[1] <= q[2];
end
```

Các RHS đều đọc **giá trị cũ** của Q.

Điều này mô tả nhiều Flip-Flop cập nhật đồng thời.

Đây là lý do có thể viết nhiều assignment trong cùng một `always @(posedge clk)`.

---

# 12. Structural RTL và Module Instantiation

Một bước quan trọng đã học là phân biệt:

### Behavioral description

```verilog
always @(posedge clk)
```

Mô tả hành vi của phần cứng.

### Module instantiation

```verilog
simple_shift u0 (...);
simple_shift u1 (...);
```

Mô tả việc **lắp các block phần cứng lại với nhau**.

Không được instantiate module bên trong `always`.

Sai:

```verilog
always @(posedge clk) begin
    simple_shift u0 (...);
end
```

Đúng:

```verilog
simple_shift u0 (...);
simple_shift u1 (...);
```

ở bên ngoài `always`.

Đây là nền tảng của hierarchical RTL:

```text
1-bit cell
    ↓
4-bit block
    ↓
larger block
    ↓
system
```

---

# 13. 1-bit MUXDFF → 4-bit Shift Register

Một cell có thể được hiểu:

```text
        ┌─────┐
R ─────►│     │
w ─────►│ MUX ├──► DFF ──► Q
        │     │
        └─────┘
           ▲
         L / E
```

Logic:

```text
L = 1       → load R
L = 0,E = 1 → shift w
L = 0,E = 0 → hold
```

Sau đó instantiate 4 cell:

```text
w → Q3 → Q2 → Q1 → Q0
```

Tư duy này cực kỳ quan trọng cho RTL Design:

> Thiết kế một cell nhỏ → kiểm tra cell → instantiate nhiều cell để tạo block lớn.

---

# 14. Register và Output Net

Một lỗi quan trọng đã gặp:

Nếu output được drive trực tiếp từ submodule:

```verilog
simple_shift u0 (
    .Q(LEDR[0])
);
```

thì `LEDR` đang được **module khác drive**.

Trong Verilog nên để:

```verilog
output [3:0] LEDR;
```

không phải:

```verilog
output reg [3:0] LEDR;
```

Ngược lại, nếu output được gán trong `always`:

```verilog
always @(*) begin
    Z = ...;
end
```

thì trong Verilog cần:

```verilog
output reg Z;
```

Đây là sự khác nhau giữa:

```text
net driven by hardware connection
vs
variable assigned procedurally
```

---

# 15. Sequential và Combinational — phân biệt rõ

## Sequential

Có state / memory / clock.

Ví dụ:

```verilog
always @(posedge clk)
```

```text
Input → Logic → DFF → State
```

## Combinational

Không lưu state.

Output chỉ phụ thuộc input hiện tại.

Ví dụ:

```verilog
always @(*)
```

hoặc:

```verilog
assign
```

Ví dụ MUX:

```text
Q0 ─┐
Q1 ─┤
Q2 ─┤
... ├── MUX ──► Z
Q7 ─┤
    ▲
    │
   ABC
```

---

# 16. 8×1 Memory và 3-input LUT

Đây là bài rất quan trọng vì kết hợp **register + MUX**.

## Phần ghi dữ liệu

8 DFF tạo thành:

```text
Q[7:0]
```

Shift register:

```text
S → Q0 → Q1 → ... → Q7
```

`enable`:

```text
1 → shift
0 → hold
```

## Phần đọc dữ liệu

`A,B,C` tạo thành địa chỉ 3-bit:

```text
ABC = 000 → Q0
ABC = 001 → Q1
ABC = 010 → Q2
ABC = 011 → Q3
ABC = 100 → Q4
ABC = 101 → Q5
ABC = 110 → Q6
ABC = 111 → Q7
```

Có thể mô tả bằng:

```verilog
case ({A,B,C})
    3'b000: Z = Q[0];
    3'b001: Z = Q[1];
    ...
    3'b111: Z = Q[7];
endcase
```

Hoặc về mặt ý tưởng:

```verilog
Z = Q[{A,B,C}];
```

Đây chính là 8:1 MUX.

---

# 17. LUT — Look-Up Table

Với 3 input:

```text
A, B, C
```

có:

```text
2^3 = 8
```

tổ hợp.

Do đó có thể lưu 8 giá trị output:

```text
Address    Stored bit
000        Q0
001        Q1
010        Q2
011        Q3
100        Q4
101        Q5
110        Q6
111        Q7
```

Sau đó input `ABC` chọn một trong 8 bit.

Đây chính là nguyên lý cơ bản của **LUT**.

FPGA sử dụng LUT để thực hiện logic combinational; bài HDLBits này giúp hiểu nguyên lý ở mức phần cứng.

---

# 18. Một lỗi quan trọng trong bài LUT

Ban đầu có thể dễ viết:

```verilog
always @(posedge clk) begin
    ...
    case ({A,B,C})
        ...
    endcase
end
```

Điều này làm `Z` trở thành một phần của sequential logic.

Nhưng MUX đọc memory phải là:

```text
Q[7:0] + ABC → Z
```

không cần clock.

Do đó phải tách:

```text
Sequential:
    clk + enable + S
           ↓
        Q[7:0]

Combinational:
    Q[7:0] + ABC
           ↓
           Z
```

Đây là một pattern RTL rất quan trọng.

---

# 19. Các lỗi / bài học quan trọng đã gặp

## Lỗi 1 — Nhầm hướng shift

Không nên học thuộc:

```verilog
{q[63:1], 1'b0}
```

Hãy xác định:

> Bit nào đi đến vị trí nào?

Ví dụ:

```text
S → Q0 → Q1 → ...
```

thì:

```verilog
Q <= {Q[6:0], S};
```

## Lỗi 2 — Nhầm shift với rotate

Shift:

```text
bit bị đẩy ra → mất
```

Rotate:

```text
bit bị đẩy ra → quay lại đầu
```

## Lỗi 3 — Sai width

Ví dụ:

```verilog
{q[63], 1'b0}
```

chỉ có 2 bit, không thể đại diện cho thanh ghi 64-bit.

## Lỗi 4 — Quên sign extension

Arithmetic right shift phải copy sign bit:

```verilog
{{8{q[63]}}, q[63:8]}
```

## Lỗi 5 — Nhầm synchronous / asynchronous reset

Synchronous:

```verilog
always @(posedge clk)
```

Asynchronous:

```verilog
always @(posedge clk or posedge reset)
```

## Lỗi 6 — Instantiate module trong `always`

Module instantiation là structural hardware description, không phải câu lệnh chạy theo clock.

## Lỗi 7 — Dùng output `reg` khi submodule drive nó

Nếu output được nối từ module khác, thường dùng net:

```verilog
output [3:0] LEDR;
```

## Lỗi 8 — Đưa MUX vào clocked block

Nếu chỉ đọc/chọn dữ liệu:

```text
MUX → combinational
```

Không cần `posedge clk`.

---

# 20. RTL Mental Models cần nhớ

## Register

```text
D → DFF → Q
```

## Shift Register

```text
DFF → DFF → DFF → DFF
```

## Shift Register có Enable

```text
          ┌──────────┐
new data ─►          │
old data ─►   MUX    ├─► DFF
          └──────────┘
                ▲
              enable
```

## Memory

```text
Write / Storage
      ↓
   Register
      ↓
Read / Select
      ↓
     MUX
```

## LUT

```text
Inputs → Address → MUX → Output
              ↑
          stored bits
```

---

# 21. Connection với Digital IC / RTL / DV

Những kiến thức này không chỉ để giải HDLBits.

## RTL Design

Sẽ gặp trực tiếp:

- Register
- Shift register
- Counter
- FSM
- Datapath
- Pipeline
- FIFO
- Register file
- Memory interface
- MUX
- LUT
- Control logic

## Design Verification

Cũng rất quan trọng vì DV phải hiểu:

- state thay đổi khi nào
- enable hoạt động thế nào
- reset đồng bộ/bất đồng bộ
- shift direction
- boundary condition
- data dependency
- combinational vs sequential
- expected behavior của register/memory

Ví dụ sau này viết assertion:

```text
Nếu enable = 1
→ sau clock Q phải shift đúng 1 vị trí.
```

Hoặc:

```text
ABC = 101
→ Z phải bằng Q[5].
```

Đây chính là nền tảng để viết **SVA, functional coverage và testbench** sau này.

---

# 22. Checklist khi gặp bài Sequential Logic

Trước khi code, tự hỏi:

### Bước 1 — Có clock không?

Nếu có:

```verilog
always @(posedge clk)
```

### Bước 2 — Có reset không?

Xác định:

- active-high / active-low
- synchronous / asynchronous

### Bước 3 — Có state không?

Nếu có → register / DFF.

### Bước 4 — Có enable không?

```text
enable = 1 → update
enable = 0 → hold
```

### Bước 5 — Có load không?

Xác định priority:

```text
reset > load > enable > hold
```

hoặc theo đúng đề bài.

### Bước 6 — Xác định next state

Viết bằng lời trước:

```text
Q0_next = ?
Q1_next = ?
...
```

sau đó mới chuyển sang Verilog.

### Bước 7 — Có MUX/read logic không?

Nếu chỉ chọn output dựa trên input hiện tại:

```text
→ combinational
```

không đưa vào `posedge clk`.

### Bước 8 — Kiểm tra width

Đặc biệt với:

- concatenation
- shift
- rotate
- replication
- indexing

---

# 23. Những gì tôi đã thực sự nắm được sau nhóm bài này

Sau nhóm bài này, tôi không chỉ biết viết syntax Verilog mà đã bắt đầu hiểu:

```text
Verilog
   ↓
Hardware structure
   ↓
Flip-Flop / Register / MUX / XOR
   ↓
State transition
```

Các pattern quan trọng đã hình thành:

```text
Current State
     ↓
Next State
     ↓
Clock
     ↓
New State
```

và:

```text
Storage + Combinational Logic
```

Đây là hai tư duy nền tảng để đi tiếp tới:

```text
Counter
   ↓
FSM
   ↓
Datapath + Control
   ↓
UART / SPI / APB
   ↓
FIFO / Memory
   ↓
RTL Project
   ↓
SystemVerilog
   ↓
Design Verification
```

---

# 24. Kết luận

Nhóm bài này đánh dấu bước chuyển từ:

> **"Biết các cổng logic và viết Verilog"**

sang:

> **"Nhìn code Verilog và hình dung được phần cứng bên dưới."**

Điểm quan trọng nhất cần giữ lại không phải là thuộc các dòng code như:

```verilog
{q[98:0], q[99]}
```

mà là biết suy luận:

```text
Bit nào đi đâu?
State nào được lưu?
Khi nào state thay đổi?
Control nào có priority?
Đâu là sequential?
Đâu là combinational?
MUX đang chọn cái gì?
Register đang lưu cái gì?
```

Nếu trả lời được những câu hỏi đó trước khi code, việc viết RTL sẽ ngày càng trở nên tự nhiên hơn.
