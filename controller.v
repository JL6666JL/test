/*控制器模块*/
`timescale 1ns / 1ps

module controller(
    input CLK,//时钟
    input SW,//开关
    input dead,//鸟是否死亡
    input is_up,//键位抬起
    input VGAfeedback,//VGA的反馈
    output reg debounce,//消抖信号，保证每次键位抬起只发挥一次作用
    output reg [2:0] state,//状态
    output reg [2:0]confeedback,//向键盘的反馈
    output [3:0] LED
    );

parameter the_begin=3'b100 ;//开始
parameter bird_down =3'b001 ;//鸟向下
parameter bird_up =3'b010 ;//鸟向上
parameter bird_dead =3'b011 ;//鸟死，游戏结束

reg [2:0] cur=the_begin;

assign LED[0]=(cur==the_begin);
assign LED[1]=(cur==bird_down);
assign LED[2]=(cur==bird_up);
assign LED[3]=(cur==bird_dead);



always @(posedge CLK or negedge SW) begin
    debounce<=0;
    if(SW==0) begin
        cur<=the_begin;
        state<=the_begin;
    end
    else begin
        if(VGAfeedback) begin
            case (cur)
            the_begin:begin
                cur<=bird_down;
                state<=bird_down;
            end
            bird_down:begin
                if(dead) begin
                    cur<=bird_dead;
                    state<=bird_dead;
                end
                else begin
                    if(is_up) begin
                        confeedback<=confeedback+1;
                        cur<=bird_up;
                        state<=bird_up;
                        debounce<=1'b1;
                    end
                    else begin
                        confeedback<=0;
                        cur<=bird_down;
                        state<=bird_down;
                    end
                end
            end
            bird_up:begin
                if(dead) begin
                    cur<=bird_dead;
                    state<=bird_dead;
                end
                else begin
                    cur<=bird_down;
                    state<=bird_down;
                end
            end
            bird_dead:begin
                state<=bird_dead;
            end
        endcase
        end
    end
end
endmodule
