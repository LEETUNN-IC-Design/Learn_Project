# HDLBits — Sequential Logic: Latches & Flip-Flops

Tài liệu tự học, hệ thống hóa kiến thức phần cứng, phân tích mô hình tư duy (Mental Models), sửa chữa lỗi sai thực tế và bài học thiết kế RTL / Design Verification thu thập từ quá trình thực hành trên nền tảng HDLBits.

---

## 1. Overview

Trong thiết kế vi mạch số (Digital IC Design), mọi hệ thống xử lý phức tạp đều được cấu thành từ hai phân lớp mạch cơ bản:

```text
Combinational Logic (Mạch tổ hợp: Không lưu trữ, Out = f(In))
        ↓  [Bổ sung phần tử nhớ để vượt qua giới hạn thời gian]
Sequential Logic (Mạch tuần tự: Có lưu trữ, Out/State = f(In, State))
        ↓
Latch / Flip-Flop (Phần tử nhớ 1-bit cơ sở trên silicon)
        ↓
Register (Tập hợp N Flip-Flop ghép song song trên cùng xung nhịp)
        ↓
Counter / Shift Register / LFSR (Thanh ghi tích hợp logic chuyển dịch trạng thái)
        ↓
Finite State Machine - FSM (Máy trạng thái điều khiển luồng hoạt động)
        ↓
FIFO / Pipeline Stage / Memory Subsystem (Hệ thống đường truyền dữ liệu công nghiệp)

```

* **Sequential logic là gì?** [General concept]
Là mạch điện tử số mà ngõ ra không chỉ phụ thuộc vào tổ hợp các tín hiệu ngõ vào tại thời điểm hiện tại, mà còn phụ thuộc vào **lịch sử hoạt động trước đó** (gọi là trạng thái — *State*).
* **Vì sao bắt buộc phải cần Memory (Bộ nhớ)?** [General concept]
Nếu không có bộ nhớ, hệ thống số không thể:
1. Giữ lại kết quả tính toán tạm thời để thực hiện các thuật toán nhiều bước.
2. Đồng bộ hóa các luồng tín hiệu truyền qua các đường dẫn vật lý có độ trễ chênh lệch.
3. Xây dựng các khối điều khiển tuần tự (bộ đếm chương trình PC trong CPU, bộ giải mã giao thức UART/SPI/AXI).


* **Combinational khác Sequential thế nào?** [General concept]
* Combinational logic là ánh xạ tức thời giữa ngõ vào và ngõ ra ($t_{pd}$ thuần túy do trễ cổng). Mạch không có khái niệm "quá khứ".
* Sequential logic cắt lát dòng thời gian liên tục thành các **bước rời rạc (Discrete clock cycles)**, lưu giữ trạng thái của chu kỳ trước để làm đầu vào tính toán cho chu kỳ tiếp theo.


* **Latch và Flip-Flop giải quyết vấn đề gì?** [General concept]
Chúng là các "van ngăn đập" (Storage barriers) cô lập miền dữ liệu hiện tại với dữ liệu tiếp theo, ngăn chặn hiện tượng vòng lặp hồi tiếp không kiểm soát (Uncontrolled race feedback) trong mạch số.
* **Vị trí của section này trong Roadmap Digital IC Design:**
Đây là **bước chuyển hóa bản lề** từ tư duy mạch tổ hợp tĩnh sang tư duy thiết kế phần cứng động theo xung nhịp (Clock-driven synchronous design), tạo tiền đề cho FSM, Static Timing Analysis (STA), và kiểm thử chức năng (Design Verification).

---

## 2. What I Learned

1. **Hiểu bản chất phần cứng đằng sau cú pháp Verilog:** [From my learning process]
Khối `always` không phải hàm phần mềm chạy từ trên xuống dưới. Nó là công cụ mô tả phần cứng: cấu trúc bên trong khối và sensitivity list quyết định việc tổng hợp ra cổng logic, Latch hay D Flip-Flop.
2. **Cơ chế kích hoạt cạnh (Edge-triggered) vs Kích hoạt mức (Level-sensitive):** [From my learning process]
Nhận biết rõ sự khác biệt sinh tử giữa việc lấy mẫu tại thềm chuyển tiếp xung nhịp (`posedge`/`negedge`) và việc thả nổi dữ liệu đi xuyên qua mạch khi tín hiệu giữ mức cao (`always @(clk)` là Latch, không phải Dual-edge FF).
3. **Phân biệt rạch ròi Synchronous Reset và Asynchronous Reset:** [From my learning process]
Biết cách điều khiển công cụ tổng hợp map vào chân Clear vật lý của cell DFF hay chèn cổng logic vào trước đường dữ liệu $D$.
4. **Bản chất của độ trễ 1 chu kỳ (1-Cycle Latency):** [From my learning process]
Hiểu sâu sắc lý do tại sao các mạch phát hiện cạnh (Edge Detector) và chốt sự kiện (Edge Capture) bắt buộc phải trễ 1 chu kỳ: phần cứng cần 1 nhịp clock để lưu giá trị quá khứ vào DFF làm mốc so sánh.
5. **Tác hại của việc dùng sai Blocking Assignment trong Sequential RTL:** [From my learning process]
Thấy rõ việc cố tình dùng blocking `=` để "triệt tiêu độ trễ" trong mạch phát hiện cạnh sẽ xóa sổ phần tử nhớ DFF và biến toàn bộ mạch thành phép so sánh $in \ \& \ \sim in \equiv 0$ (nối đất).
6. **Ý nghĩa của Seed và Vector nạp ngoài trong LFSR:** [From my learning process]
Hiểu được $r_0, r_1, r_2$ trong mạch LFSR lấy từ đâu ra và tại sao cần chế độ Parallel Load: để nạp giá trị mồi ban đầu, chống kẹt vĩnh viễn ở trạng thái toàn 0 ($000$).
7. **Cấu trúc FSM kinh điển từ sơ đồ cổng:** [From my learning process]
Nhận diện được mô hình Moore Machine: DFFs làm State Register, các cổng logic phía trước làm Next-State Logic, và cổng ngõ ra NOR làm Output Logic.

---

## 3. Core Mental Model

Mô hình tư duy cốt lõi khi làm việc với Sequential Logic:

```text
Combinational Logic:
   Outputs = f(Current Inputs)

Sequential Logic:
   Next State = f(Current Inputs, Current State)
   Outputs    = g(Current State, [Current Inputs])

```

```text
               ┌────────────────────────────────────────────────────────┐
               │                                                        │ Current State
               ▼                                                        │
        ┌───────────────┐     Next State     ┌────────────────┐         │
In ────►│ Combinational ├───────────────────►│ State Register │─────────┴────┐
        │  Next-State   │                    │     (DFFs)     │              │
        │     Logic     │                    └───────┬────────┘              │
        └───────────────┘                            ▲                       │
                                                     │ clk                   ▼
                                                                      ┌───────────────┐
                                                                      │ Combinational ├──► Out
                                                                      │  Output Logic │
                                                                      └───────────────┘

```

* **DFF là bức tường thời gian (Time Barrier):** [General concept]
Trong thiết kế đồng bộ, dữ liệu không được phép chạy tự do. Flip-Flop đóng vai trò bức tường ngăn cách: phía trước chân $D$ là **tương lai (Next State)**, phía sau chân $Q$ là **hiện tại (Current State)**. Bức tường chỉ mở ra trong một khoảnh khắc vô cùng ngắn tại cạnh xung nhịp để tương lai biến thành hiện tại.
* **Đời sống dữ liệu trong 1 chu kỳ clock:** [General concept]
Tại cạnh lên clock thứ $N$, Flip-Flop chốt giá trị mới ra $Q$. Toàn bộ mạng cổng tổ hợp phía sau có đúng một khoảng thời gian bằng chu kỳ clock ($T_{clk}$) để tính toán ra giá trị mới ổn định trước chân $D$ của Flip-Flop tiếp theo, chuẩn bị cho cạnh lên thứ $N+1$.

---

## 4. Latch

* **Định nghĩa:** [General concept]
Latch là phần tử nhớ **nhạy theo mức tín hiệu (Level-sensitive)**.
* **Cơ chế hoạt động:** [General concept]
* **Transparent Mode (Chế độ trong suốt):** Khi tín hiệu cho phép ($EN$) ở mức tích cực ($1$), ngõ ra $Q$ chạy theo mọi biến thiên của ngõ vào $D$. Nhiễu hay glitch ở $D$ đều xuyên thẳng qua $Q$.
* **Hold Mode (Chế độ giữ):** Khi $EN = 0$, latch đóng lại. Ngõ ra $Q$ giữ nguyên giá trị cuối cùng ngay trước thời điểm $EN$ chuyển từ $1 \rightarrow 0$.



### Timing Diagram (ASCII) [General concept]

```text
EN : ___/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\____________
D  : ___/‾‾\__/‾‾‾‾\_________/‾‾‾‾‾‾‾‾‾___
Q  : ___/‾‾\__/‾‾‾‾\______________________
        |<-- Transparent --->|<-- Hold -->|

```

### RTL Modeling của Latch [General concept]

```verilog
// D-Latch có chủ đích (Intentional Latch)
always @(*) begin
    if (ena) begin
        q = d;
    end
    // Không có else -> Giữ nguyên giá trị cũ khi ena = 0
end

```

> ### ⚠️ Mental Model Correction: Latch không phải là Flip-Flop
> 
> 
> [From my learning process]
> **Tôi từng nghĩ:**
> Viết `always @(clk) q <= d;` sẽ tạo ra một Flip-Flop kích hoạt ở cả hai cạnh của xung clock vì danh sách nhạy bắt cả hai chiều của clock.
> **Vấn đề:**
> Cú pháp `always @(clk)` hoàn toàn thiếu từ khóa `posedge` hoặc `negedge`. Điều này biến khối procedural thành **nhạy theo mức (Level-sensitive)**. Trình tổng hợp sẽ suy diễn (infer) ra một **D-Latch** có chân enable nối với clock, chứ không phải một Flip-Flop.
> **Mental model đúng:**
> Flip-Flop bắt buộc phải có `posedge` hoặc `negedge` trong sensitivity list. Không có từ khóa cạnh thì dù biến trong `@(...)` có tên là `clk`, nó vẫn bị đối xử như một tín hiệu mức thông thường và tạo ra Latch.

---

## 5. Flip-Flop

* **Định nghĩa:** [General concept]
D Flip-Flop (DFF) là phần tử nhớ **kích hoạt theo cạnh (Edge-triggered)**.
* **Cơ chế lấy mẫu (Sampling):** [General concept]
DFF không quan tâm trạng thái mức cao hay mức thấp của clock. Nó chỉ "mở mắt" lấy mẫu dữ liệu tại đúng khoảnh khắc vi mô khi clock chuyển tiếp (transition) từ $0 \rightarrow 1$ (`posedge`) hoặc từ $1 \rightarrow 0$ (`negedge`).
* **Tính cách ly dữ liệu:** [General concept]
Sau khi cạnh clock đi qua, dù ngõ vào $D$ có thay đổi, đảo trạng thái hay nhiễu loạn liên tục thì ngõ ra $Q$ vẫn hoàn toàn đứng yên cho đến cạnh xung nhịp tiếp theo.

### Timing Diagram (ASCII) [General concept]

```text
CLK: ___/‾‾\___/‾‾\___/‾‾\___/‾‾\___
        ↑      ↑      ↑      ↑
      sample sample sample sample
D  : _AAAA___BBBBBBB__CCCC___DDDD___
Q  : _____AAAAAAA______BBBBBBB______

```

---

## 6. Latch vs Flip-Flop

| Tiêu chí | Latch | Flip-Flop (DFF) |
| --- | --- | --- |
| **Độ nhạy (Sensitivity)** | Mức (Level-sensitive) [General concept] | Biên thời gian (Edge-triggered) [General concept] |
| **Tín hiệu điều khiển** | Enable ($EN = 1$ hoặc $0$) [General concept] | Clock edge (`posedge` / `negedge`) [General concept] |
| **Tính trong suốt** | Có (Trong suốt suốt khoảng $EN$ tích cực) [General concept] | Hoàn toàn không (Cách ly 1 chu kỳ) [General concept] |
| **Hold Behavior** | Giữ khi $EN$ rớt về mức bất hoạt [General concept] | Giữ ổn định xuyên suốt chu kỳ clock [General concept] |
| **RTL Modeling** | `always @(*)` thiếu nhánh gán [General concept] | `always @(posedge clk)` [General concept] |
| **Ứng dụng tiêu chuẩn** | Clock Gating Cell, Memory bit-cell [General concept] | Toàn bộ thanh ghi dữ liệu, Pipeline, FSM [General concept] |
| **Bẫy tư duy thường gặp** | Vô tình viết thiếu `else` sinh ra Latch [General concept] | Viết `always @(clk)` tưởng nhầm là Dual-edge FF [From my learning process] |

> ### 🧠 Mental Model: Van nước mở dòng vs Máy chụp ảnh
> 
> 
> [General concept]
> * **Latch như một chiếc van nước gạt:** Khi gạt mở ($EN=1$), nước bẩn hay nước sạch từ nguồn $D$ chảy thẳng tuột qua ống $Q$. Khi gạt đóng ($EN=0$), lượng nước đọng lại cuối cùng trong ống được giữ nguyên.
> * **Flip-Flop như một chiếc máy ảnh cơ:** Nút bấm chụp chính là cạnh clock. Chỉ tại khoảnh khắc bấm nút, một bức ảnh tĩnh của dữ liệu $D$ được lưu vào thẻ nhớ $Q$. Người mẫu phía trước ống kính có di chuyển thế nào sau đó thì bức ảnh in ra vẫn không đổi.
> 
> 

---

## 7. Clock

* **Clock là gì?** [General concept]
Clock là tín hiệu dao động vuông tuần hoàn, đóng vai trò "nhịp tim" điều phối sự chuyển dịch dữ liệu đồng bộ trong vi mạch.
* **Clock Period ($T_{clk}$):** Chu kỳ xung nhịp, tính bằng khoảng thời gian giữa hai cạnh cùng chiều liên tiếp ($T_{clk} = 1 / F_{clk}$).
* **Clock không phải là dữ liệu (Clock is NOT Data):** [From my learning process]
Tín hiệu Clock không bao giờ được đưa trực tiếp vào các cổng logic tính toán dữ liệu (như cổng AND, OR, XOR thông thường) để tránh sinh ra Clock Skew và Glitch.

> ### ⚠️ Mental Model Correction: Bản chất của `posedge clk`
> 
> 
> [From my learning process]
> **Tôi từng băn khoăn:**
> Có phải `posedge clk` nghĩa là mạch chạy trong suốt thời gian clock giữ mức cao (`1`)?
> **Bản chất phần cứng đúng:**
> `posedge` là viết tắt của **Positive Edge Transition** ($0 \rightarrow 1$). Nó là một **sự kiện điểm thời gian (Time-instant Event)**, không phải một khoảng thời gian. Khi clock đã lên mức 1 và duy trì trạng thái 1, khối `always @(posedge clk)` hoàn toàn không thực thi thêm lần nào.

---

## 8. Reset

Reset là cơ chế bắt buộc để đưa hệ thống số về một trạng thái ban đầu biết trước (Known State).

### 1. Synchronous Reset (Reset đồng bộ)

* **Bản chất:** [From my learning process] Reset chỉ có hiệu lực khi có **cạnh lên của clock**.
* **RTL Modeling:** Không đưa tín hiệu reset vào sensitivity list.
```verilog
always @(posedge clk) begin
    if (reset) begin
        q <= 1'b0;
    end else begin
        q <= d;
    end
end

```


* **Hardware Reality:** [General concept] Trình tổng hợp chèn thêm cổng AND/MUX vào trước chân $D$ của DFF: $D_{in} = d \ \& \ (\sim reset)$.

### 2. Asynchronous Reset (Reset bất đồng bộ)

* **Bản chất:** [From my learning process] Reset có hiệu lực **ngay lập tức** khi tín hiệu reset nhảy lên mức tích cực, bất kể clock đang ở đâu hay thậm chí clock đã chết.
* **RTL Modeling:** Đưa tín hiệu reset vào sensitivity list cùng với clock.
```verilog
always @(posedge clk or posedge areset) begin
    if (areset) begin
        q <= 1'b0;
    end else begin
        q <= d;
    end
end

```


* **Hardware Reality:** [General concept] Mạch nối trực tiếp vào chân Clear/Reset vật lý chuyên dụng của tế bào DFF trên silicon.

### So sánh Reset thực tế [General concept]

| Thuộc tính | Synchronous Reset | Asynchronous Reset |
| --- | --- | --- |
| **Sensitivity list** | `always @(posedge clk)` | `always @(posedge clk or posedge areset)` |
| **Thời điểm có hiệu lực** | Tại cạnh clock kế tiếp | Tức thì khi reset assert |
| **Khả năng lọc nhiễu** | Cực tốt (Nhiễu ngoài thềm clock bị phớt lờ) | Kém hơn (Nhiễu spike trên đường reset sẽ xóa mạch) |
| **Phụ thuộc Clock** | Clock phải chạy thì mới reset được | Reset được ngay cả khi clock bị mất |

---

## 9. Enable (Clock Enable)

* **Bản chất phần cứng:** [From my learning process]
Khi ta muốn một thanh ghi giữ nguyên giá trị cũ qua nhiều chu kỳ xung nhịp, giải pháp chuẩn không phải là ngắt clock (Gating clock thô sơ gây lệch pha), mà là **dùng bộ chọn MUX hồi tiếp (Feedback MUX)**.

```text
               ┌──────┐
         D ───►│ 1    │
               │  MUX ├────► [ D   Q ] ───┬──► Q
   ┌──────────►│ 0    │      [       ]    │
   │           └──────┘      [ > clk ]    │
   │              ▲                       │
   │              │ EN                    │
   └──────────────┴───────────────────────┘

```

* **Cơ chế:** [From my learning process]
* Khi $EN = 1$: MUX chọn dữ liệu mới $D$. Tại `posedge clk`, $Q \Leftarrow D$.
* Khi $EN = 0$: MUX lấy chính ngõ ra $Q$ đưa ngược lại chân $D$. Tại `posedge clk`, $Q \Leftarrow Q$ (Giữ nguyên trạng thái).



```verilog
always @(posedge clk) begin
    if (ena) begin
        q <= d;
    end
    // Không cần viết else q <= q; trình tổng hợp tự động suy luận mạch MUX hồi tiếp
end

```

---

## 10. Blocking (`=`) vs Non-blocking (`<=`) Assignment

### 1. Simulation Semantics (Cơ chế mô phỏng Verilog IEEE) [General concept]

* **Blocking (`=`):** Thực thi tuần tự theo dòng lệnh. Biến vế trái nhận giá trị mới ngay lập tức và chặn dòng lệnh phía dưới cho đến khi phép gán hoàn tất.
* **Non-blocking (`<=`):** Đánh giá tất cả các biểu thức vế phải (RHS) tại thời điểm hiện tại, sau đó xếp lịch cập nhật đồng loạt vào hàng đợi NBA (Non-blocking Assignment Queue) vào cuối bước thời gian delta.

> ### ⚠️ Mental Model Correction: Không thể dùng Blocking để triệt tiêu độ trễ trong Sequential RTL
> 
> 
> [From my learning process]
> **Tôi từng nghĩ:**
> "Tại sao mạch phát hiện cạnh phải cố tình trễ 1 chu kỳ? Dùng blocking assignment gán trực tiếp `in_dly = in;` rồi tính `pedge = in & ~in_dly;` thì có được không?"
> **Vấn đề cốt tử về mặt phần cứng:**
> Nếu dùng blocking `=`:
> 1. Dòng 1: `in_dly = in;` $\rightarrow$ `in_dly` nhận ngay giá trị hiện tại của `in`.
> 2. Dòng 2: `pedge = in & ~in_dly;` trở thành `pedge = in & ~in;`.
> 3. Về mặt đại số Boole: $in \ \& \ \overline{in} \equiv \mathbf{0}$.
> 
> 
> **Hậu quả:**
> Trình tổng hợp sẽ thấy ngõ ra `pedge` luôn luôn bằng 0. Nó sẽ **xóa sạch toàn bộ Flip-Flop và hàn chết chân `pedge` xuống Ground (GND)**. Mạch hoàn toàn bị tiêu diệt!
> **Mental model đúng:**
> Muốn phát hiện sự kiện (cạnh lên/cạnh xuống), bắt buộc phải có một phần tử nhớ vật lý (DFF) lưu lại trạng thái của chu kỳ trước. Sự trễ 1 chu kỳ là **quy luật vật lý tất yếu** để mạch có ký ức, không phải lỗi do phép gán non-blocking sinh ra.

---

## 11. Latch Inference (Hiện tượng suy luận Latch ngoài ý muốn)

* **Cơ chế suy diễn:** [General concept]
Trong khối tổ hợp `always @(*)`, nếu một biến không được gán giá trị trong **tất cả mọi nhánh rẽ điều kiện** (thiếu `else` trong `if`, thiếu `default` trong `case`):

$$\text{Không gán giá trị} \longrightarrow \text{Biến phải giữ lại giá trị cũ} \longrightarrow \text{Mạch tổ hợp không tự nhớ được} \longrightarrow \text{Trình tổng hợp chèn thêm Latch vật lý}$$


* **Nguy cơ trong thiết kế:** [General concept]
Accidental Latch làm biến dạng timing, sinh ra vòng lặp tổ hợp không đồng bộ, gây méo dạng sóng và khiến công cụ STA báo lỗi timing closure nghiêm trọng.

---

## 12. `always` Block & Sensitivity List

Bản tóm tắt tương quan giữa danh sách nhạy và phần cứng được tổng hợp [General concept]:

| Cú pháp Sensitivity List | Phần cứng được tổng hợp | Ứng dụng thiết kế |
| --- | --- | --- |
| `always @(*)` | Mạch tổ hợp thuần túy (Cổng logic, MUX, ALU) | Combinational Logic |
| `always @(posedge clk)` | D Flip-Flop thường hoặc DFF có Synchronous Reset | Synchronous Registers |
| `always @(posedge clk or posedge rst)` | D Flip-Flop có chân Asynchronous Reset vật lý | Asynchronous Registers |
| `always @(clk)` | **D-Latch nhạy mức** (RẤT NGUY HIỂM) | Tránh tuyệt đối trong RTL chuẩn |

---

## 13. Timing Intuition

```text
                  Setup Time       Hold Time
                 |◄─────────►|    |◄─────────►|
Clock: ______________________/‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
                             ▲
                        Sampling Edge
Data : ───< VÙNG DỮ LIỆU ỔN ĐỊNH BẮT BUỘC >───────────

```

* **Setup Time ($t_{su}$):** [General concept] Khoảng thời gian tối thiểu dữ liệu $D$ phải đứng yên ổn định **trước** cạnh xung nhịp.
* **Hold Time ($t_h$):** [General concept] Khoảng thời gian tối thiểu dữ liệu $D$ phải tiếp tục đứng yên ổn định **sau** cạnh xung nhịp.
* **Hiện tượng vi phạm Timing (Metastability):** [General concept] Nếu dữ liệu biến đổi trong cửa sổ $[t_{su}, t_h]$, Flip-Flop không thể xác định được mức 0 hay 1, ngõ ra sẽ dao động vô định ở vùng điện áp lửng lơ, gây sập hệ thống.
* **Độ trễ 1 chu kỳ (1-Cycle Latency):** [From my learning process] Dữ liệu đi vào chân $D$ của Flip-Flop sẽ xuất hiện ở chân $Q$ ở chu kỳ xung nhịp tiếp theo. Mọi xử lý sau Flip-Flop đều trễ 1 chu kỳ so với phía trước nó.

---

## 14. Hardware Inference from RTL (Nhìn Verilog đoán Hardware)

### Pattern 1: D Flip-Flop cơ bản [General concept]

```verilog
always @(posedge clk) q <= d;

```

$\rightarrow$ **Hardware:** 1 con DFF cơ bản. Chân $D$ nối tín hiệu `d`, chân $Q$ nối tín hiệu `q`.

### Pattern 2: DFF với Asynchronous Reset [From my learning process]

```verilog
always @(posedge clk or posedge areset) begin
    if (areset) q <= 1'b0;
    else        q <= d;
end

```

$\rightarrow$ **Hardware:** 1 con DFF có chân Clear vật lý tích cực mức cao. Khi `areset` nhảy lên 1, chân $Q$ lập tức về 0 độc lập với xung clock.

### Pattern 3: DFF với Synchronous Reset [From my learning process]

```verilog
always @(posedge clk) begin
    if (sync_rst) q <= 1'b0;
    else          q <= d;
end

```

$\rightarrow$ **Hardware:** 1 con DFF thường kết hợp với một cổng logic tổ hợp trước chân $D$ ($D_{in} = d \ \& \ \sim sync\_rst$).

### Pattern 4: DFF với Enable (MUX hồi tiếp) [From my learning process]

```verilog
always @(posedge clk) begin
    if (en) q <= d;
end

```

$\rightarrow$ **Hardware:** 1 con DFF kết hợp MUX 2-to-1: khi `en = 0`, MUX chọn đường dây từ ngõ ra $Q$ đưa ngược lại ngõ vào $D$.

---

## 15. HDLBits Exercises

### Problem: `exams/m2014_q4d`

* **Concept:** [From my learning process] Mạch Flip-Flop có logic phản hồi tổ hợp (XOR Feedback).
* **Hardware:** 1 cổng XOR 2 ngõ vào kết hợp 1 D Flip-Flop kích cạnh lên. Ngõ vào cổng XOR gồm tín hiệu ngoài `in` và tín hiệu hồi tiếp từ ngõ ra `out`.
* **Important RTL idea:** Phương trình trạng thái kế tiếp: $D = in \oplus out$. Viết ngắn gọn `out <= in ^ out;` tại `posedge clk`.
* **What I wrote:** Hoàn thành mạch Toggle-FF có điều khiển.
* **Lesson:** Khi `in = 1`, mạch hoạt động như một Toggle Flip-Flop đảo trạng thái liên tục; khi `in = 0`, mạch giữ nguyên giá trị.

---

### Problem: `mt2015_muxdff`

* **Concept:** [From my learning process] Một tầng cơ sở của thanh ghi dịch hỗ trợ nạp dữ liệu song song (Shift register cell with parallel load).
* **Hardware:** 1 bộ MUX 2-to-1 đặt trước chân $D$ của DFF, điều khiển bởi tín hiệu chọn $L$ (Load).
* **Important RTL idea:** $D = L \ ? \ r\_in : q\_in$.
* **Lesson:** Nhận diện mạch nạp song song tiêu chuẩn: $L=1$ nạp dữ liệu ngoài, $L=0$ nối tầng dữ liệu dịch từ phía trước.

---

### Problem: Sơ đồ Mạch LFSR (ECE253 2015 Midterm Q5)

* **Concept:** [From my learning process] Mạch thanh ghi dịch phản hồi tuyến tính (LFSR) 3-bit có khả năng nạp giá trị mồi ban đầu (Seed).
* **Hardware:** 3 tầng MUX-DFF mắc nối tiếp, ngõ vào $D_2$ nhận phản hồi từ cổng XOR: $Q_1 \oplus Q_2$.
* **Câu hỏi tôi đã hỏi:** [From my learning process]
*"Bạn nhìn cái mạch này $R_0, R_1, R_2$ ở đâu ra?"* và *"Ý nghĩa của nó là để làm cái gì?"*
* **Root cause:** Nhầm lẫn rằng các tín hiệu $r_i$ tự sinh ra bên trong mạch, chưa hiểu khái niệm nạp dữ liệu khởi tạo từ bên ngoài cho thanh ghi.
* **Hardware Reality:**
1. $r_0, r_1, r_2$ là **Parallel Data Inputs** cấp từ bên ngoài chip (switches, CPU bus).
2. Ý nghĩa sống còn của nó: Nếu LFSR chẳng may rơi vào trạng thái toàn 0 ($\{Q_2, Q_1, Q_0\} = \{0, 0, 0\}$), do $0 \oplus 0 = 0$, mạch sẽ bị **kẹt chết vĩnh viễn ở trạng thái 0**. Chân $L=1$ cho phép nạp vector $\{r_2, r_1, r_0\} \neq 0$ (Seed) để đánh thức và vận hành mạch tạo chuỗi giả ngẫu nhiên (PRBS).



---

### Problem: `exams/2014_q4a`

* **Concept:** [From my learning process] Một tầng hoàn chỉnh của Universal Shift Register gồm cả tính năng Hold, Shift và Load.
* **Hardware:** Hai bộ MUX 2-to-1 mắc nối tiếp phía trước chân $D$ của 1 con DFF.
* **Important RTL idea:** Thứ tự ưu tiên phần cứng: MUX điều khiển bởi tín hiệu $L$ (Load) nằm sát chân $D$ hơn MUX điều khiển bởi $E$ (Enable), do đó $L$ có độ ưu tiên cao hơn $E$.
* **RTL Implementation:**
```verilog
always @(posedge clk) begin
    if (L)      Q <= R;
    else if (E) Q <= w;
end

```



---

### Problem: `exams/ece241_2014_q4`

* **Concept:** [From my learning process] Nhận diện Máy trạng thái hữu hạn (FSM) từ sơ đồ cổng logic và Flip-Flops.
* **Hardware:** 3 DFF $\{q_1, q_2, q_3\}$ làm State Register, 3 cổng logic tính Next-State, và cổng NOR 3 ngõ vào tính ngõ ra $z = \sim(q_1 \vert{} q_2 \vert{} q_3)$.
* **Câu hỏi tôi đã hỏi:** [From my learning process] *"Ý nghĩa của bài này là gì?"*
* **Lesson:** Đây là cấu trúc FSM kinh điển dạng Moore Machine. Tách bạch rõ 2 miền: Miền tuần tự (Sequential state update trong `always @(posedge clk)`) và Miền tổ hợp (Combinational output gán qua `assign z = ~(q1 | q2 | q3);`).

---

### Problem: `exams/ece241_2013_q7`

* **Concept:** [From my learning process] Hiện thực hóa JK Flip-Flop bằng D Flip-Flop và cổng logic.
* **Hardware:** Phương trình kích thích ngõ vào chân $D$: $D = J \cdot \overline{Q} + \overline{K} \cdot Q$.
* **What I wrote:** [From my learning process] Dùng chuỗi điều kiện lồng nhau:
```verilog
if (~j) begin
    if (~k) Q <= Q;
    else    Q <= 0;
end else begin
    if (~k) Q <= 1;
    else    Q <= ~Q;
end

```


* **Câu hỏi tôi đã hỏi:** [From my learning process] *"Ý nghĩa của bài này là gì?"*
* **Hardware Reality:** Trong công nghiệp vi mạch ASIC hiện đại, **không có cell JK-FF chuyên dụng** vì tốn diện tích và khó kiểm soát timing STA. 100% các ô nhớ là DFF. Bài tập này chứng minh ta có thể dùng DFF cơ bản kết hợp mạch tổ hợp phía trước để giả lập mọi loại Flip-Flop khác.

---

### Problem: `edgedetect`

* **Concept:** [From my learning process] Phát hiện cạnh lên ($0 \rightarrow 1$) trên vector 8-bit và tạo xung kích hoạt dài đúng 1 chu kỳ clock.
* **Hardware:** 1 thanh ghi đệm trễ `in_dly` và 1 dãy cổng AND: $pedge = in \ \& \ (\sim in\_dly)$.
* **Thắc mắc & Lỗi tư duy:** [From my learning process]
1. Không hiểu vì sao ngõ ra `pedge` hiển thị các số Hex `0, 2, c, 0` trên waveform.
2. Thắc mắc tại sao lại bị trễ 1 chu kỳ và định dùng blocking `=` để gán trực tiếp.


* **Lesson:**
* Số Hex trên bus đại diện cho các bit chuyển đổi độc lập ($0x0c = 8'b0000\_1100$ nghĩa là cả bit 2 và bit 3 cùng có cạnh lên tại chu kỳ đó).
* Bắt buộc phải có độ trễ 1 chu kỳ để chốt trạng thái quá khứ vào DFF.



---

### Problem: `edgedetect2`

* **Concept:** [From my learning process] Phát hiện mọi sự biến đổi trạng thái (Any Edge: $0 \rightarrow 1$ lẫn $1 \rightarrow 0$).
* **Hardware:** Thanh ghi trễ kết hợp cổng XOR: $anyedge = in \oplus in\_dly$.
* **What I wrote:** [From my learning process]
```verilog
always @(posedge clk) begin
    in_dly  <= in;
    anyedge <= in ^ in_dly;
end

```


* **Status:** Pass $100\%$ ngay lần nộp đầu tiên. Thể hiện sự làm chủ hoàn toàn toán tử XOR trong việc so sánh sự khác biệt trạng thái giữa hai chu kỳ.

---

### Problem: `edgecapture`

* **Concept:** [From my learning process] Bắt cạnh xuống ($1 \rightarrow 0$) trên bus 32-bit và chốt giữ mức 1 vĩnh viễn (Sticky bit/Interrupt Status Register) cho tới khi có Synchronous Reset.
* **What I wrote (Mã lỗi ban đầu):** [From my learning process]
```verilog
reg in_dly [31:0]; // ❌ Lỗi cú pháp mảng
always @(posedge clk) begin
    in_dly <= in;
    if (reset) begin
        out <= '0;
    end else begin
        out <= out | (in & ~in_dly); // ❌ Bắt nhầm cạnh lên
    end
end

```


* **Mistakes:**
1. `reg in_dly [31:0];` khai báo mảng ô nhớ (Memory Array) thay vì vector bus.
2. Bắt nhầm cạnh lên ($0 \rightarrow 1$) thay vì cạnh xuống ($1 \rightarrow 0$).
3. Khai báo `output [31:0] out` thiếu từ khóa `reg`.


* **Correct RTL:**
```verilog
reg [31:0] in_dly;
always @(posedge clk) begin
    in_dly <= in;
    if (reset) begin
        out <= 32'b0;
    end else begin
        out <= out | (~in & in_dly); // Cạnh xuống: Quá khứ là 1 (in_dly), Hiện tại là 0 (~in)
    end
end

```



---

### Problem: `dualedge`

* **Concept:** [From my learning process] Xây dựng mạch chốt dữ liệu ở cả hai cạnh của xung clock (Dual-edge triggered Flip-Flop).
* **What I wrote:** [From my learning process]
```verilog
always @(clk) begin
    q <= d;
end

```


* **What happened:** Bị compiler cảnh báo và kết quả mô phỏng waveform bị **lệch/thọt 1 chu kỳ clock**.
* **Root cause:** `always @(clk)` mô tả một **D Latch nhạy mức**, không phải Flip-Flop. Phép gán non-blocking bên trong một khối nhạy mức gây trễ delta mô phỏng, dẫn đến sai lệch pha nghiêm trọng.
* **Hardware Reality:** Để chốt cả 2 cạnh trên FPGA, bắt buộc phải dùng **2 con DFF đơn lẻ** chạy song song ở 2 cạnh đối lập rồi dùng MUX chọn ngõ ra:
```verilog
reg q_pos, q_neg;
always @(posedge clk) q_pos <= d;
always @(negedge clk) q_neg <= d;
assign q = clk ? q_pos : q_neg;

```



---

## 16. Mistakes & Debugging Lessons

### Mistake #1: Nhầm lẫn cú pháp Vector Bus và Mảng bộ nhớ (Memory Array)

* **What I did:** [From my learning process] Viết `reg in_dly [31:0];` thay vì `reg [31:0] in_dly;`.
* **Why it looked reasonable:** Thói quen lập trình mảng trong C/C++ (`int arr[32];`).
* **Why it was wrong:**
* `[31:0] in_dly` (đứng trước): Định nghĩa độ rộng bus là 32 đường dây. Có thể gán nguyên vector: `in_dly <= in;`.
* `in_dly [31:0]` (đứng sau): Định nghĩa một RAM gồm 32 ô nhớ, mỗi ô nhớ chỉ có 1 bit. Không thể gán trực tiếp cả vector vào mảng mà không qua chỉ số phần tử `in_dly[i]`.


* **Lesson:** Luôn nhớ quy tắc: **Độ rộng bit đứng TRƯỚC, Số lượng phần tử đứng SAU**.

---

### Mistake #2: Cố tạo Dual-Edge Flip-Flop bằng `always @(clk)`

* **What I did:** [From my learning process] Viết `always @(clk) q <= d;`.
* **Why it looked reasonable:** Nghĩ rằng bỏ `posedge`/`negedge` thì clock đổi mức nào cũng sẽ chốt.
* **Why it was wrong:** Trình biên dịch hiểu đây là một Latch nhạy mức (Level-sensitive). Ngõ ra bị lệch pha chu kỳ (thọt clock) do cơ chế lập lịch delta cycle của simulator.
* **Lesson:** FPGA không hỗ trợ tế bào Dual-edge FF đơn lẻ. Bắt buộc phải dùng 2 Flip-Flop đơn cạnh (`posedge` và `negedge`) rồi ghép ngõ ra qua MUX hoặc XOR.

---

### Mistake #3: Định dùng Blocking Assignment để triệt tiêu độ trễ trong Edge Detection

* **What I thought:** [From my learning process] Viết `in_dly = in; pedge = in & ~in_dly;` để không bị trễ 1 chu kỳ.
* **Why it was wrong:** Ép `in_dly` nhận ngay giá trị mới của `in`, biến biểu thức thành $in \ \& \ \sim in \equiv 0$. Bộ tổng hợp sẽ triệt tiêu hoàn toàn Flip-Flop và nối đất ngõ ra.
* **Lesson:** Mạch phát hiện cạnh bắt buộc phải có độ trễ 1 chu kỳ để lưu trạng thái quá khứ. Không thể "lách" quy luật vật lý bằng phép gán phần mềm.

---

### Mistake #4: Đảo ngược cực tính chuyển tiếp tín hiệu (Polarity Inversion)

* **What I did:** [From my learning process] Đề yêu cầu bắt cạnh xuống ($1 \rightarrow 0$), nhưng lại viết `in & ~in_dly`.
* **Why it was wrong:**
* `in & ~in_dly`: Hiện tại là 1, Quá khứ là 0 $\rightarrow$ **Cạnh lên ($0 \rightarrow 1$)**.
* `~in & in_dly`: Hiện tại là 0, Quá khứ là 1 $\rightarrow$ **Cạnh xuống ($1 \rightarrow 0$)**.


* **Lesson:** Luôn nhẩm bảng chân trị trước khi viết biểu thức bắt cạnh:

$$\text{Fall Edge} = (\text{Hiện tại} == 0) \ \& \ (\text{Quá khứ} == 1) \equiv \mathbf{(\sim in) \ \& \ in\_dly}$$



---

### Mistake #5: Thiếu từ khóa `reg` dưới cờ ``default_nettype none`

* **What I did:** [From my learning process] Khai báo `output [31:0] out;` sau đó gán giá trị cho nó bên trong khối `always`.
* **Why it was wrong:** Mặc định cổng output không có từ khóa `reg` sẽ được coi là kiểu `wire`. Khối procedural chỉ cho phép gán vào biến kiểu `reg`. Dưới cờ ``default_nettype none`, compiler sẽ bắt lỗi cú pháp ngay lập tức.
* **Lesson:** Mọi tín hiệu được gán bên trong `always @(posedge clk)` đều phải được khai báo là `output reg` hoặc `reg`.

---

## 17. Common Traps

* [x] **Latch $\neq$ Flip-Flop:** Latch nhạy theo mức; Flip-Flop nhạy theo biên thời gian.
* [x] **`posedge` không phải khoảng thời gian:** `@(posedge clk)` chỉ diễn ra trong một khoảnh khắc chuyển tiếp cực ngắn.
* [x] **Clock Enable $\neq$ Ngắt Clock:** Enable được thực hiện bằng MUX hồi tiếp dữ liệu, không phải ngắt đường clock vật lý.
* [x] **Reset Async $\neq$ Reset Sync:** Async có mặt trong `@(posedge clk or posedge rst)`; Sync chỉ nằm ở `if (rst)` dưới `@(posedge clk)`.
* [x] **`always` block không phải hàm C/C++:** Các khối phần cứng chạy song song $100\%$, không có thứ tự chạy trước sau giữa các khối.
* [x] **Không thể triệt tiêu độ trễ thanh ghi bằng blocking assignment:** Dùng `=` trong sequential logic sẽ xóa sổ Flip-Flop và phá hủy chức năng lưu trữ.
* [x] **Incomplete Assignment gây ra Accidental Latch:** Viết thiếu nhánh trong `always @(*)` sẽ biến mạch tổ hợp thành chốt Latch nguy hiểm.

---

## 18. Concept Map

```text
                        ┌───────────────────────────────┐
                        │   Sequential Logic Circuit    │
                        └───────────────┬───────────────┘
                                        │
                ┌───────────────────────┴───────────────────────┐
                ▼                                               ▼
      ┌──────────────────┐                             ┌──────────────────┐
      │  Level-Sensitive │                             │  Edge-Triggered  │
      │     (Latches)    │                             │   (Flip-Flops)   │
      └─────────┬────────┘                             └────────┬─────────┘
                │                                               │
      ┌─────────┴────────┐                    ┌─────────────────┼─────────────────┐
      ▼                  ▼                    ▼                 ▼                 ▼
 ┌─────────┐       ┌───────────┐        ┌───────────┐     ┌───────────┐     ┌───────────┐
 │ D-Latch │       │ SR-Latch  │        │   Clock   │     │   Reset   │     │  Enable   │
 └─────────┘       └───────────┘        └─────┬─────┘     └─────┬─────┘     └─────┬─────┘
                                              │                 │                 │
                                        ┌─────┴─────┐     ┌─────┴─────┐           ▼
                                        ▼           ▼     ▼           ▼     ┌───────────┐
                                      Posedge    Negedge Sync       Async   │  Feedback │
                                                                            │    MUX    │
                                                                            └─────┬─────┘
                                                                                  │
  ┌───────────────────────────────────────────────────────────────────────────────┘
  ▼
┌──────────────────┐
│   N-bit DFFs     │ ──► Register
└─────────┬────────┘
          ├────────► Shift Register / LFSR (Nạp song song Seed & Chống kẹt 000)
          ├────────► Edge Detector & Edge Capture Register (Interrupt Sticky Bit)
          ├────────► Binary Counter / Decade Counter
          └────────► State Register trong Finite State Machine (Moore / Mealy)

```

---

## 19. Connection to Next Topics

Kiến thức về Latches và Flip-Flops đóng vai trò nền tảng trực tiếp để bước tiếp vào các chuyên đề sau [General concept]:

1. **Thanh ghi đa năng (Universal Shift Registers):**
* Ghép song song $N$ tế bào MUX-DFF (`mt2015_muxdff` và `exams/2014_q4a`).
* Điều khiển chuyển đổi linh hoạt giữa: Giữ (Hold), Dịch (Shift), và Nạp song song (Parallel Load).


2. **Bộ đếm (Counters):**
* DFF đóng vai trò thanh ghi lưu giá trị đếm hiện tại.
* Logic tổ hợp phía trước thực hiện phép cộng nhị phân ($Count_{next} = Count + 1$).


3. **Máy trạng thái hữu hạn (FSM):**
* Chuỗi DFF lưu mã hóa trạng thái hiện tại (State Register).
* Mạng logic tổ hợp tính toán trạng thái kế tiếp (Next-State Logic) dựa trên State hiện tại và Input bên ngoài.


4. **Bộ nhớ đệm hàng đợi (FIFO):**
* Mảng thanh ghi (Register Array) lưu dữ liệu tạm thời.
* Con trỏ đọc (Read Pointer) và con trỏ ghi (Write Pointer) thực chất là các bộ đếm chạy trên nền Flip-Flop.



---

## 20. Connection to RTL Design & Design Verification (DV)

### Dưới góc nhìn của RTL Designer [General concept]:

* **Pipelining (Đường ống hóa):** Chèn các tầng DFF vào giữa các mạng logic tổ hợp quá dài để chia nhỏ thời gian trễ $t_{pd}$, giúp chip đạt được tần số xung nhịp cao (đạt Timing Closure trong STA).
* **Clock Domain Crossing (CDC):** Hiểu rõ hiện tượng Metastability của DFF để thiết kế mạch đồng bộ 2-FF (2-Flip-Flop Synchronizer) khi truyền tín hiệu qua các miền xung nhịp khác nhau.
* **Low-Power Design:** Hiểu cơ chế Clock Enable để thay thế việc chạy clock liên tục bằng các cell Clock Gating tích hợp (ICG cell), tiết kiệm năng lượng tiêu thụ trên chip.

### Dưới góc nhìn của Design Verification (DV) Engineer [General concept]:

* **Tại sao DV engineer bắt buộc phải hiểu sâu Sequential RTL?**
Nếu không hiểu cơ chế lấy mẫu tại biên xung nhịp và độ trễ 1 chu kỳ của DFF, kỹ sư DV không thể:
1. Viết testbench điều khiển đúng thời điểm đưa stimulus vào (Drive data) và lấy mẫu ngõ ra (Sample data) mà không bị lỗi tranh chấp chạy đua (Race condition).
2. Viết các câu lệnh kiểm tra ràng buộc thời gian (SystemVerilog Assertions - SVA):
```systemverilog
// Kiểm tra: Khi có cạnh xuống của tín hiệu, out phải chốt lên 1 ở chu kỳ kế tiếp
property p_falling_edge_captured;
    @(posedge clk) disable iff (reset)
    $fell(in) |=> (out == 1'b1);
endproperty
assert property (p_falling_edge_captured);

```


3. Phân tích độ bao phủ chức năng (Functional Coverage) và độ bao phủ lật bit (Toggle Coverage) của các thanh ghi trong chip.



---

## 21. Knowledge Checklist

Đánh giá trung thực dựa trên bằng chứng thu thập được trong quá trình học và làm bài:

* [x] Phân biệt được sự khác nhau căn bản giữa Combinational Logic và Sequential Logic. *(Đã chứng minh)*
* [x] Hiểu bản chất hoạt động của D Flip-Flop kích hoạt theo cạnh (`posedge`/`negedge`). *(Đã chứng minh)*
* [x] Hiểu và cài đặt thành công Synchronous Reset và Asynchronous Reset trong RTL. *(Đã chứng minh)*
* [x] Hiểu bản chất phần cứng của Clock Enable (MUX hồi tiếp). *(Đã chứng minh)*
* [x] Nắm vững nguyên lý và phương trình phát hiện cạnh lên, cạnh xuống và cả hai cạnh. *(Đã chứng minh)*
* [x] Hiểu lý do tại sao mạch phát hiện cạnh bắt buộc phải có độ trễ 1 chu kỳ clock. *(Đã chứng minh)*
* [x] Hiểu ý nghĩa của Seed và cơ chế nạp song song để chống kẹt trạng thái trong LFSR. *(Đã chứng minh)*
* [ ] **Làm chủ Latch và ranh giới Latch vs Flip-Flop:** Cần củng cố thêm (từng nhầm `always @(clk)` là Dual-edge FF). *(Needs Practice)*
* [ ] **Bản chất mô phỏng của Blocking vs Non-blocking:** Cần củng cố thêm về hàng đợi sự kiện IEEE (Event Scheduling Queue) để hiểu sâu vì sao `=` gây lỗi trong sequential. *(Needs Practice)*
* [ ] **Tính toán thời gian vi mô (Setup Time, Hold Time, STA margin):** Mới nắm trực giác, chưa chứng minh khả năng tính toán định lượng trên waveform thực tế. *(Needs Practice)*

---

## 22. Final Self-Assessment
| **Latch** | **Needs Practice** | Nhận biết được hành vi mức, nhưng từng viết `always @(clk)` tưởng là tạo Dual-edge FF. | Dễ nhầm lẫn giữa Latch nhạy mức và Flip-Flop nếu thiếu từ khóa cạnh. |
| **D Flip-Flop** | **Solid** | Viết thành thạo các biến thể DFF (`dff8r`, `m2014_q4b`, `m2014_q4c`, `m2014_q4d`). | Cần luôn nhớ khai báo `output reg` dưới cờ ``default_nettype none`. |
| **Clock** | **Solid** | Hiểu đúng bản chất lấy mẫu tại thềm chuyển tiếp cạnh xung nhịp `posedge`. | Cần ghi nhớ không bao giờ đưa clock vào cổng tổ hợp logic thông thường. |
| **Reset** | **Solid** | Phân biệt chính xác cách viết Async Reset (trong sensitivity list) và Sync Reset (chỉ ở `if`). | Chú ý thứ tự ưu tiên khi Reset và Set cùng xảy ra đồng thời. |
| **Enable** | **Solid** | Làm chủ cấu trúc MUX ghép trước DFF và hiểu đúng thứ tự ưu tiên giữa Load và Enable. | Không có điểm yếu lớn ở phần này. |
| **Blocking / Non-blocking** | **Needs Practice** | Đã hiểu tác hại triệt tiêu logic của `=`, nhưng tư duy ban đầu vẫn bị ảnh hưởng bởi lập trình phần mềm. | Cần nghiên cứu sâu hơn về các vùng lập lịch sự kiện (Event Regions: Active, Inactive, NBA). |
| **Timing & Latency** | **Needs Practice** | Đã hiểu nguyên lý trễ 1 chu kỳ của DFF, nhưng chưa làm bài tập tính toán định lượng Setup/Hold. | Cần luyện tập thêm các bài toán vi phạm thời gian Setup/Hold trong STA. |
| **Sequential RTL** | **Solid** | Viết RTL mạch lạc, tổng hợp đúng chức năng, xử lý tốt các phép toán bitwise trên vector bus. | Cần cẩn thận với cú pháp khai báo Vector Bus `[MSB:LSB] name` vs Memory Array `name [0:DEPTH-1]`. |
| **Hardware Mental Model** | **Needs Practice** | Đã hiểu FSM và LFSR từ sơ đồ cổng, nhưng ban đầu gặp lúng túng khi đọc nguồn gốc tín hiệu ngõ vào ($r_i$). | Cần duy trì thói quen phác thảo sơ đồ phần cứng ra giấy trước khi gõ code RTL. |

---