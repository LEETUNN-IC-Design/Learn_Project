# Counter — HDLBits Learning Notes

> Ghi chú học tập phần **Counter** trong HDLBits / Digital IC Design.  
> Mục tiêu: hiểu **counter ở mức phần cứng và RTL**, không chỉ nhớ code.

---

## 1. Counter là gì?

Counter là một **mạch tuần tự (sequential circuit)** có nhiệm vụ lưu một trạng thái hiện tại và thay đổi trạng thái theo mỗi clock edge.

Tư duy cơ bản:

```text
Current State
      ↓
Next-State Logic
      ↓
Clock Edge
      ↓
New State
```

Ví dụ counter 4-bit:

```text
0000 → 0001 → 0010 → 0011 → ... → 1111 → 0000
```

Về phần cứng, có thể hình dung:

```text
        ┌──────────────────┐
        │ Next-State Logic │
        │    q + 1         │
        └────────┬─────────┘
                 ↓
              ┌─────┐
CLK ────────► │ DFFs│
              └──┬──┘
                 │
                 ▼
             Current q
                 │
                 └────────── feedback
```

### Ý nghĩa

Counter là một ví dụ rất tốt để bắt đầu hiểu rằng:

> **Verilog RTL đang mô tả phần cứng có state, chứ không phải một chương trình chạy từng dòng.**

---

# 2. Counter 0 → 15 — Count15

Bài đầu tiên là counter 4-bit:

```text
0 → 1 → 2 → ... → 14 → 15 → 0
```

Reset:

```text
reset = 1
    ↓
q = 0
```

Đây là **synchronous active-high reset**, nên reset chỉ được xử lý tại:

```verilog
posedge clk
```

Ví dụ cấu trúc:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 0;
    else
        q <= q + 1;
end
```

### Điều quan trọng học được

4-bit chỉ có thể biểu diễn:

```text
0 → 15
```

nên:

```text
15 + 1
```

sẽ tự wrap về:

```text
0
```

Không nhất thiết phải viết riêng:

```verilog
if (q == 4'd15)
    q <= 0;
```

### Hardware meaning

Đây là:

```text
4 DFF
   +
Adder / increment logic
   +
Reset logic
```

### Ứng dụng

Binary counter được dùng trong:

- Timer
- Event counter
- Address generation
- Clock/event division
- Protocol timing
- FSM timing
- CPU/control logic

---

# 3. Counter 0 → 9 — Count10

Bài tiếp theo yêu cầu:

```text
0 → 1 → 2 → ... → 8 → 9 → 0
```

Khác với Count15, 4-bit vẫn có thể đi tới:

```text
10, 11, ..., 15
```

nhưng ta **không muốn** những trạng thái đó.

Vì vậy phải tạo rollover riêng:

```verilog
if (q == 4'd9)
    q <= 0;
else
    q <= q + 1;
```

### Ý nghĩa

Đây là bước chuyển từ:

> **binary modulo counter**

sang:

> **custom modulo counter**

Counter này có modulus:

```text
MOD-10
```

### Ứng dụng

- Decimal timer
- Digit counter
- Frequency divider
- BCD-related logic
- Digital clock

---

# 4. Counter 1 → 10 — Count1to10

Bài này yêu cầu:

```text
1 → 2 → 3 → ... → 9 → 10 → 1
```

Reset đưa counter về:

```text
1
```

Logic:

```verilog
if (reset)
    q <= 1;
else if (q == 10)
    q <= 1;
else
    q <= q + 1;
```

### Ý nghĩa

Không phải counter nào cũng bắt đầu từ 0.

Một counter có thể có:

```text
initial state
+
valid state range
+
rollover state
```

Đây thực chất là một **state machine đơn giản**.

Có thể nhìn:

```text
Current State → Next State

1  → 2
2  → 3
...
9  → 10
10 → 1
```

### Ứng dụng

Tư duy này sẽ dùng trực tiếp khi thiết kế:

- FSM
- Protocol state
- Round-robin controller
- Timer
- Sequencer

---

# 5. Clock Enable — Countslow

Bài `Countslow` thêm một tín hiệu:

```verilog
slowena
```

Ý nghĩa:

```text
slowena = 1
    → counter được phép tăng

slowena = 0
    → counter giữ nguyên
```

Logic:

```text
reset = 1
    → q = 0

reset = 0, slowena = 1
    → q cập nhật

reset = 0, slowena = 0
    → q giữ nguyên
```

### Hardware mental model

Không nên nghĩ:

```text
slowena
   ↓
tạo clock chậm
```

Mà nên nghĩ:

```text
                 ┌─────────────┐
q + 1 ─────────►│             │
                 │     MUX     ├──► DFF
q ─────────────►│             │
                 └──────▲──────┘
                        │
                     slowena
```

Khi `slowena = 0`, DFF nhận lại chính giá trị `q`.

Tức là:

```text
D = q
```

nên state được giữ nguyên.

### Ý nghĩa quan trọng

Đây là nền tảng của **clock enable** trong RTL.

Không nên tùy tiện tạo clock mới bằng logic như:

```verilog
assign slow_clk = clk & slowena;
```

Trong RTL synchronous thông thường, ta giữ một clock chung và điều khiển việc cập nhật state bằng enable.

### Ứng dụng

Clock enable xuất hiện trong:

- Timer
- UART
- SPI
- PWM
- Protocol controller
- Pipeline control
- Periodic logic
- Low-power design

---

# 6. Counter và State Machine

Sau các bài trên có thể nhìn counter theo cách tổng quát hơn.

Counter không chỉ là:

```verilog
q <= q + 1;
```

Mà là:

```text
             ┌──────────────────┐
             │ Next-State Logic │
             └────────┬─────────┘
                      ↓
Current State ─────► DFF
                      │
                      ▼
                  New State
```

Ví dụ Count10:

```text
Current q       Next q

0       ───────► 1
1       ───────► 2
2       ───────► 3
...
8       ───────► 9
9       ───────► 0
```

Do đó:

> **Counter là một dạng state machine có quy luật chuyển state rất đơn giản.**

Khi học FSM sau này, cách suy nghĩ này sẽ được sử dụng lại.

---

# 7. Module `count4` — Module Reuse

Một bài HDLBits sử dụng module counter có sẵn:

```verilog
module count4(
    input clk,
    input enable,
    input load,
    input [3:0] d,
    output reg [3:0] Q
);
```

Module này đã chịu trách nhiệm:

- lưu state
- clock
- enable
- load
- cập nhật Q

Module bên ngoài không cần viết lại toàn bộ counter.

Thay vào đó, top module phải tạo:

```text
c_enable
c_load
c_d
```

### Cách suy nghĩ

Khi gặp module có sẵn, cần hỏi:

1. Module này đã làm gì?
2. Nó có state không?
3. Input nào điều khiển state?
4. Output là gì?
5. Top module phải tạo control signal nào?

### Ý nghĩa

Đây là bước đầu làm quen với:

> **Hierarchical RTL Design**

Một thiết kế thực tế không phải một module khổng lồ.

Ví dụ:

```text
Top
 ├── Counter
 ├── FIFO
 ├── UART
 ├── Register
 └── Control Logic
```

Các module nhỏ được kết hợp thành hệ thống lớn hơn.

---

# 8. 1Hz Divider — Cascaded Counters

Bài tiếp theo dùng ba BCD counter để tạo tín hiệu 1Hz từ clock 1000Hz.

Tư duy:

```text
1000 Hz
   │
   ▼
Counter 0
   │
   ▼
Counter 1
   │
   ▼
Counter 2
   │
   ▼
1 Hz event
```

Các counter vẫn sử dụng **cùng clock 1000Hz**.

Điểm quan trọng là enable được cascade:

```text
counter0:
    enable = 1

counter1:
    enable = counter0 == 9

counter2:
    enable = counter0 == 9
           && counter1 == 9
```

### Ý nghĩa

Đây là lần đầu thấy nhiều counter phối hợp để tạo một timing system.

Từ một counter đơn:

```text
Counter
```

ta xây được:

```text
Counter + Counter + Counter
```

để tạo:

```text
Timing / Frequency Division
```

### Ứng dụng

Tư duy này được sử dụng trong:

- Timer peripheral
- Baud-rate generation
- UART timing
- Periodic events
- PWM timing
- Digital clock
- Protocol timing

---

# 9. BCD Counter

Một chữ số decimal được biểu diễn bằng 4 bit:

```text
0 = 0000
1 = 0001
2 = 0010
...
9 = 1001
```

Counter BCD:

```text
0 → 1 → 2 → ... → 8 → 9 → 0
```

Không sử dụng:

```text
1010
1011
...
1111
```

cho các chữ số decimal hợp lệ.

### Ý nghĩa

BCD cho phép biểu diễn từng chữ số decimal bằng một nibble.

Điều này đặc biệt hữu ích khi thiết kế:

- Digital clock
- Decimal counter
- Display logic
- Timer
- Seven-segment display systems

---

# 10. 4-Digit BCD Counter — Countbcd

Đây là bài tổng hợp nhiều kiến thức trước đó.

Một số 4 chữ số:

```text
0000 → 0001 → ... → 9999 → 0000
```

được chia thành:

```text
q[3:0]    → ones
q[7:4]    → tens
q[11:8]   → hundreds
q[15:12]  → thousands
```

Ví dụ:

```text
q = 16'h1234

thousands = 1
hundreds  = 2
tens      = 3
ones      = 4
```

---

# 11. Enable Cascade trong Countbcd

Digit thấp hơn phải đạt 9 trước khi digit kế tiếp tăng.

```text
ones:
    luôn được enable

tens:
    enable khi ones == 9

hundreds:
    enable khi ones == 9
            && tens == 9

thousands:
    enable khi ones == 9
            && tens == 9
            && hundreds == 9
```

Có thể hình dung:

```text
             ┌───────────┐
             │   ones    │
             └─────┬─────┘
                   9
                   │
                   ▼
             ┌───────────┐
             │   tens    │
             └─────┬─────┘
                   9
                   │
                   ▼
             ┌───────────┐
             │ hundreds  │
             └─────┬─────┘
                   9
                   │
                   ▼
             ┌───────────┐
             │ thousands │
             └───────────┘
```

Ví dụ:

```text
0009
  ↓
0010
```

ones rollover:

```text
9 → 0
```

và tens được enable:

```text
0 → 1
```

---

Ví dụ:

```text
0099
  ↓
0100
```

ones:

```text
9 → 0
```

tens:

```text
9 → 0
```

hundreds:

```text
0 → 1
```

---

Ví dụ:

```text
0999
  ↓
1000
```

cả ba digit thấp đều rollover và thousands tăng.

### Ý nghĩa lớn

Đây không còn chỉ là một counter đơn.

Nó thể hiện:

```text
Reusable module
       +
Control logic
       +
Multiple state elements
       +
Hierarchical design
       +
Enable cascade
```

Đây là tư duy rất gần với RTL Design thực tế.

---

# 12. Những lỗi quan trọng đã gặp

## 12.1 `output` và `reg`

Nếu viết:

```verilog
output [3:0] q;
```

rồi gán:

```verilog
always @(posedge clk)
    q <= ...;
```

thì trong Verilog thuần, `q` cần là variable:

```verilog
output reg [3:0] q;
```

Trong SystemVerilog có thể dùng:

```verilog
output logic [3:0] q;
```

---

## 12.2 Multiple drivers

Nếu module con đã drive:

```verilog
bcdcount counter0 (..., q[3:0]);
```

thì không được đồng thời tự gán `q[3:0]` ở một `always` khác.

Một signal không nên có nhiều nguồn drive không phù hợp.

### Bài học

Khi dùng module hierarchy:

```text
Ai sở hữu signal này?
```

phải luôn rõ ràng.

---

## 12.3 Sai width

Ví dụ:

```verilog
reg q[2:0];
```

khác với:

```verilog
reg [2:0] q;
```

Cái đầu:

```text
3 phần tử × 1 bit
```

Cái sau:

```text
1 vector × 3 bit
```

Đây là lỗi rất dễ gặp khi làm nhiều counter cùng lúc.

---

## 12.4 Sai phạm vi signal

Nếu khai báo:

```verilog
output [3:1] ena;
```

thì chỉ tồn tại:

```text
ena[1]
ena[2]
ena[3]
```

Không có:

```text
ena[4]
```

Điều này cũng dẫn đến một bài học quan trọng:

> Luôn đọc kỹ interface của module trước khi viết logic.

---

# 13. Hardware Mental Model sau phần Counter

Sau các bài counter, mental model cần hình thành là:

```text
                 ┌──────────────────┐
Inputs ─────────►│ Combinational    │
                 │ Next-State Logic │
                 └────────┬─────────┘
                          │
                          ▼
                       D input
                          │
                    ┌─────▼─────┐
CLK ───────────────►│ DFF / Reg │
                    └─────┬─────┘
                          │
                          ▼
                     Current State
                          │
                          └──────────► feedback
```

Counter thực chất gồm:

```text
State storage
+
Next-state logic
+
Clock
+
Reset
+
Optional enable
```

Khi viết:

```verilog
q <= q + 1;
```

phải nhìn thấy phần cứng phía sau:

```text
q
 ↓
Adder
 ↓
D input
 ↓
DFF
 ↓
q
```

---

# 14. Những gì đã học được từ Counter

Sau nhóm bài này, các kiến thức quan trọng gồm:

- Counter là sequential logic.
- Counter có current state và next state.
- Clock edge quyết định thời điểm state thay đổi.
- Synchronous reset chỉ tác động tại clock edge.
- Có thể tạo counter với range tùy ý.
- Binary counter có thể tự wrap theo số bit.
- Decimal counter cần custom rollover.
- Counter có thể bắt đầu từ giá trị khác 0.
- Clock enable cho phép giữ state hoặc cập nhật state.
- Counter có thể được ghép thành hệ thống lớn hơn.
- Module có thể được tái sử dụng.
- Control logic có thể điều khiển datapath/state module.
- BCD counter dùng 4 bit cho một decimal digit.
- Nhiều BCD counter có thể cascade bằng enable.
- Hierarchical RTL là cách xây dựng design lớn từ các block nhỏ.

---

# 15. Ứng dụng về sau

Các kiến thức Counter sẽ được dùng trực tiếp trong những project RTL tiếp theo.

## Traffic Light FSM

Counter có thể dùng để:

```text
đếm thời gian ở mỗi state
```

Ví dụ:

```text
RED
 ↓
đếm 5 giây
 ↓
GREEN
```

---

## UART

Counter/timer dùng để:

```text
tạo baud timing
```

và xác định thời điểm:

```text
sample bit
transmit bit
```

---

## SPI

Counter dùng để:

```text
đếm số bit đã truyền
```

Ví dụ:

```text
8-bit transfer

bit_count:
0 → 1 → 2 → ... → 7
```

---

## APB

Counter có thể hỗ trợ:

- timeout
- wait cycles
- transaction timing

---

## FIFO

Counter có thể liên quan đến:

- number of entries
- read/write pointer
- occupancy tracking

---

## CPU / RISC-V

Counter có thể được dùng cho:

- instruction sequencing
- performance counters
- timers
- pipeline control
- event counting

---

# 16. Counter → FSM

Một insight quan trọng:

```text
Counter
   ↓
State machine đơn giản
   ↓
FSM
```

Counter:

```text
0 → 1 → 2 → 3 → 0
```

FSM tổng quát hơn:

```text
IDLE → READ → WAIT → DONE → IDLE
```

Cả hai đều có:

```text
Current State
      ↓
Next State Logic
      ↓
DFF
```

Điều khác nhau chủ yếu là **quy luật chuyển state**.

Vì vậy những gì học từ Counter sẽ được sử dụng lại khi học FSM.

---

# 17. Tư duy cần giữ khi làm Counter

Trước khi code, luôn tự hỏi:

### 1. Counter đếm từ đâu đến đâu?

### 2. Reset đưa nó về đâu?

### 3. Khi đạt giá trị cuối thì đi đâu?

### 4. Enable có tồn tại không?

### 5. Enable = 0 thì state làm gì?

### 6. Đây là synchronous hay asynchronous reset?

### 7. State hiện tại là gì?

### 8. Next state là gì?

### 9. Có module con không?

### 10. Ai sở hữu từng signal?

Nếu trả lời được 10 câu này thì code thường chỉ còn là bước cuối cùng.

---

# 18. Tổng kết

Phần Counter đã đi từ:

```text
Counter cơ bản
      ↓
Custom rollover
      ↓
Custom initial state
      ↓
Clock enable
      ↓
Module reuse
      ↓
Frequency divider
      ↓
BCD counter
      ↓
Cascaded BCD counter
      ↓
Hierarchical RTL
```

Điểm quan trọng nhất không phải là nhớ từng đoạn code.

Mà là hiểu:

> **Counter = State + Next-State Logic + Clock + Control**

Và từ một block rất nhỏ như counter, có thể xây dựng những hệ thống RTL lớn hơn.

---

## Learning principle

> **Understand the state first.  
> Derive the next state second.  
> Identify the control signals third.  
> Write the RTL last.**
