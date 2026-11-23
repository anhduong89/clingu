% --- BEGIN INSTANCE METADATA ---
% network_id: ny_0
% horizon: 60
% time_window_duration: 3
% capacity: 4
% rho_demand: 0.020
% rho_agent: 1.000
% demand_mode: uniform
% dirichlet_alpha: n/a
% demand_seed: n/a
% init_seed: 0
% throughput_passenger_ceiling: 280
% throughput_flight_ceiling: 70
% total_passengers: 6
% agents_min_estimated: 3
% nb_agents: 3
% nb_seg: 10
% generated: 2026-06-30T00:42:46
% --- END INSTANCE METADATA ---
agent(0..2).
init_loc(0, dandy).
init_loc(1, ryend).
init_loc(2, dandy).
emax(0, 60).
emax(1, 60).
emax(2, 60).
emin(0, 0).
emin(1, 0).
emin(2, 0).
dischg_rate(0, 4).
dischg_rate(1, 4).
dischg_rate(2, 4).
capacity(0, 4).
capacity(1, 4).
capacity(2, 4).
b_init(0, 60).
b_init(1, 60).
b_init(2, 60).
initial_request(0,(jfk,lga),1).
initial_request(1,(jfk,teb),1).
initial_request(2,(jfk,ryend),1).
initial_request(3,(jfk,cri),1).
initial_request(4,(jfk,cimbl),1).
initial_request(5,(jfk,dandy),1).
initial_request(6,(lga,jfk),0).
initial_request(7,(lga,teb),0).
initial_request(8,(lga,ryend),0).
initial_request(9,(lga,cri),0).
initial_request(10,(lga,cimbl),0).
initial_request(11,(lga,dandy),0).
initial_request(12,(teb,jfk),0).
initial_request(13,(teb,lga),0).
initial_request(14,(teb,ryend),0).
initial_request(15,(teb,cri),0).
initial_request(16,(teb,cimbl),0).
initial_request(17,(teb,dandy),0).
initial_request(18,(ryend,jfk),0).
initial_request(19,(ryend,lga),0).
initial_request(20,(ryend,teb),0).
initial_request(21,(ryend,cri),0).
initial_request(22,(ryend,cimbl),0).
initial_request(23,(ryend,dandy),0).
initial_request(24,(cri,jfk),0).
initial_request(25,(cri,lga),0).
initial_request(26,(cri,teb),0).
initial_request(27,(cri,ryend),0).
initial_request(28,(cri,cimbl),0).
initial_request(29,(cri,dandy),0).
initial_request(30,(cimbl,jfk),0).
initial_request(31,(cimbl,lga),0).
initial_request(32,(cimbl,teb),0).
initial_request(33,(cimbl,ryend),0).
initial_request(34,(cimbl,cri),0).
initial_request(35,(cimbl,dandy),0).
initial_request(36,(dandy,jfk),0).
initial_request(37,(dandy,lga),0).
initial_request(38,(dandy,teb),0).
initial_request(39,(dandy,ryend),0).
initial_request(40,(dandy,cri),0).
initial_request(41,(dandy,cimbl),0).
time_window(0..19).
cost((jfk,lga),0,0).
cost((jfk,lga),1,0).
cost((jfk,lga),2,0).
cost((jfk,lga),3,8).
cost((jfk,lga),4,11).
cost((jfk,lga),5,16).
cost((jfk,lga),6,21).
cost((jfk,lga),7,21).
cost((jfk,lga),8,18).
cost((jfk,lga),9,15).
cost((jfk,lga),10,13).
cost((jfk,lga),11,14).
cost((jfk,lga),12,15).
cost((jfk,lga),13,15).
cost((jfk,lga),14,13).
cost((jfk,lga),15,10).
cost((jfk,lga),16,7).
cost((jfk,lga),17,5).
cost((jfk,lga),18,4).
cost((jfk,lga),19,3).
cost((jfk,teb),0,0).
cost((jfk,teb),1,0).
cost((jfk,teb),2,0).
cost((jfk,teb),3,0).
cost((jfk,teb),4,0).
cost((jfk,teb),5,0).
cost((jfk,teb),6,26).
cost((jfk,teb),7,29).
cost((jfk,teb),8,31).
cost((jfk,teb),9,32).
cost((jfk,teb),10,30).
cost((jfk,teb),11,27).
cost((jfk,teb),12,25).
cost((jfk,teb),13,25).
cost((jfk,teb),14,23).
cost((jfk,teb),15,21).
cost((jfk,teb),16,19).
cost((jfk,teb),17,15).
cost((jfk,teb),18,11).
cost((jfk,teb),19,7).
cost((jfk,ryend),0,0).
cost((jfk,ryend),1,0).
cost((jfk,ryend),2,0).
cost((jfk,ryend),3,0).
cost((jfk,ryend),4,0).
cost((jfk,ryend),5,0).
cost((jfk,ryend),6,26).
cost((jfk,ryend),7,29).
cost((jfk,ryend),8,31).
cost((jfk,ryend),9,32).
cost((jfk,ryend),10,30).
cost((jfk,ryend),11,28).
cost((jfk,ryend),12,25).
cost((jfk,ryend),13,25).
cost((jfk,ryend),14,23).
cost((jfk,ryend),15,21).
cost((jfk,ryend),16,19).
cost((jfk,ryend),17,15).
cost((jfk,ryend),18,11).
cost((jfk,ryend),19,7).
cost((jfk,cri),0,0).
cost((jfk,cri),1,0).
cost((jfk,cri),2,3).
cost((jfk,cri),3,4).
cost((jfk,cri),4,8).
cost((jfk,cri),5,12).
cost((jfk,cri),6,12).
cost((jfk,cri),7,10).
cost((jfk,cri),8,8).
cost((jfk,cri),9,7).
cost((jfk,cri),10,7).
cost((jfk,cri),11,8).
cost((jfk,cri),12,9).
cost((jfk,cri),13,8).
cost((jfk,cri),14,6).
cost((jfk,cri),15,3).
cost((jfk,cri),16,3).
cost((jfk,cri),17,2).
cost((jfk,cri),18,1).
cost((jfk,cri),19,1).
cost((jfk,cimbl),0,0).
cost((jfk,cimbl),1,0).
cost((jfk,cimbl),2,0).
cost((jfk,cimbl),3,0).
cost((jfk,cimbl),4,13).
cost((jfk,cimbl),5,17).
cost((jfk,cimbl),6,22).
cost((jfk,cimbl),7,25).
cost((jfk,cimbl),8,23).
cost((jfk,cimbl),9,20).
cost((jfk,cimbl),10,18).
cost((jfk,cimbl),11,17).
cost((jfk,cimbl),12,18).
cost((jfk,cimbl),13,18).
cost((jfk,cimbl),14,17).
cost((jfk,cimbl),15,14).
cost((jfk,cimbl),16,11).
cost((jfk,cimbl),17,7).
cost((jfk,cimbl),18,5).
cost((jfk,cimbl),19,4).
cost((jfk,dandy),0,0).
cost((jfk,dandy),1,0).
cost((jfk,dandy),2,0).
cost((jfk,dandy),3,0).
cost((jfk,dandy),4,0).
cost((jfk,dandy),5,0).
cost((jfk,dandy),6,28).
cost((jfk,dandy),7,30).
cost((jfk,dandy),8,32).
cost((jfk,dandy),9,34).
cost((jfk,dandy),10,33).
cost((jfk,dandy),11,31).
cost((jfk,dandy),12,29).
cost((jfk,dandy),13,27).
cost((jfk,dandy),14,25).
cost((jfk,dandy),15,23).
cost((jfk,dandy),16,21).
cost((jfk,dandy),17,18).
cost((jfk,dandy),18,13).
cost((jfk,dandy),19,9).
cost((lga,jfk),0,0).
cost((lga,jfk),1,0).
cost((lga,jfk),2,0).
cost((lga,jfk),3,20).
cost((lga,jfk),4,19).
cost((lga,jfk),5,17).
cost((lga,jfk),6,15).
cost((lga,jfk),7,15).
cost((lga,jfk),8,15).
cost((lga,jfk),9,16).
cost((lga,jfk),10,16).
cost((lga,jfk),11,16).
cost((lga,jfk),12,15).
cost((lga,jfk),13,15).
cost((lga,jfk),14,13).
cost((lga,jfk),15,10).
cost((lga,jfk),16,8).
cost((lga,jfk),17,6).
cost((lga,jfk),18,4).
cost((lga,jfk),19,2).
cost((lga,teb),0,0).
cost((lga,teb),1,0).
cost((lga,teb),2,0).
cost((lga,teb),3,18).
cost((lga,teb),4,16).
cost((lga,teb),5,14).
cost((lga,teb),6,13).
cost((lga,teb),7,13).
cost((lga,teb),8,13).
cost((lga,teb),9,14).
cost((lga,teb),10,14).
cost((lga,teb),11,14).
cost((lga,teb),12,13).
cost((lga,teb),13,13).
cost((lga,teb),14,11).
cost((lga,teb),15,8).
cost((lga,teb),16,6).
cost((lga,teb),17,5).
cost((lga,teb),18,3).
cost((lga,teb),19,1).
cost((lga,ryend),0,0).
cost((lga,ryend),1,0).
cost((lga,ryend),2,0).
cost((lga,ryend),3,0).
cost((lga,ryend),4,0).
cost((lga,ryend),5,26).
cost((lga,ryend),6,24).
cost((lga,ryend),7,22).
cost((lga,ryend),8,21).
cost((lga,ryend),9,22).
cost((lga,ryend),10,22).
cost((lga,ryend),11,22).
cost((lga,ryend),12,22).
cost((lga,ryend),13,22).
cost((lga,ryend),14,19).
cost((lga,ryend),15,17).
cost((lga,ryend),16,14).
cost((lga,ryend),17,11).
cost((lga,ryend),18,7).
cost((lga,ryend),19,5).
cost((lga,cri),0,0).
cost((lga,cri),1,0).
cost((lga,cri),2,0).
cost((lga,cri),3,20).
cost((lga,cri),4,19).
cost((lga,cri),5,17).
cost((lga,cri),6,15).
cost((lga,cri),7,15).
cost((lga,cri),8,15).
cost((lga,cri),9,16).
cost((lga,cri),10,16).
cost((lga,cri),11,16).
cost((lga,cri),12,15).
cost((lga,cri),13,15).
cost((lga,cri),14,13).
cost((lga,cri),15,10).
cost((lga,cri),16,8).
cost((lga,cri),17,6).
cost((lga,cri),18,4).
cost((lga,cri),19,2).
cost((lga,cimbl),0,0).
cost((lga,cimbl),1,0).
cost((lga,cimbl),2,13).
cost((lga,cimbl),3,13).
cost((lga,cimbl),4,11).
cost((lga,cimbl),5,9).
cost((lga,cimbl),6,9).
cost((lga,cimbl),7,9).
cost((lga,cimbl),8,10).
cost((lga,cimbl),9,10).
cost((lga,cimbl),10,10).
cost((lga,cimbl),11,10).
cost((lga,cimbl),12,9).
cost((lga,cimbl),13,9).
cost((lga,cimbl),14,7).
cost((lga,cimbl),15,5).
cost((lga,cimbl),16,4).
cost((lga,cimbl),17,3).
cost((lga,cimbl),18,1).
cost((lga,cimbl),19,0).
cost((lga,dandy),0,0).
cost((lga,dandy),1,0).
cost((lga,dandy),2,0).
cost((lga,dandy),3,0).
cost((lga,dandy),4,24).
cost((lga,dandy),5,22).
cost((lga,dandy),6,20).
cost((lga,dandy),7,19).
cost((lga,dandy),8,19).
cost((lga,dandy),9,19).
cost((lga,dandy),10,20).
cost((lga,dandy),11,20).
cost((lga,dandy),12,19).
cost((lga,dandy),13,19).
cost((lga,dandy),14,17).
cost((lga,dandy),15,14).
cost((lga,dandy),16,12).
cost((lga,dandy),17,8).
cost((lga,dandy),18,6).
cost((lga,dandy),19,4).
cost((teb,jfk),0,0).
cost((teb,jfk),1,0).
cost((teb,jfk),2,0).
cost((teb,jfk),3,0).
cost((teb,jfk),4,0).
cost((teb,jfk),5,0).
cost((teb,jfk),6,31).
cost((teb,jfk),7,29).
cost((teb,jfk),8,28).
cost((teb,jfk),9,27).
cost((teb,jfk),10,27).
cost((teb,jfk),11,28).
cost((teb,jfk),12,28).
cost((teb,jfk),13,27).
cost((teb,jfk),14,25).
cost((teb,jfk),15,22).
cost((teb,jfk),16,19).
cost((teb,jfk),17,16).
cost((teb,jfk),18,11).
cost((teb,jfk),19,7).
cost((teb,lga),0,0).
cost((teb,lga),1,0).
cost((teb,lga),2,0).
cost((teb,lga),3,17).
cost((teb,lga),4,16).
cost((teb,lga),5,14).
cost((teb,lga),6,13).
cost((teb,lga),7,13).
cost((teb,lga),8,14).
cost((teb,lga),9,14).
cost((teb,lga),10,14).
cost((teb,lga),11,14).
cost((teb,lga),12,13).
cost((teb,lga),13,13).
cost((teb,lga),14,11).
cost((teb,lga),15,8).
cost((teb,lga),16,6).
cost((teb,lga),17,5).
cost((teb,lga),18,3).
cost((teb,lga),19,1).
cost((teb,ryend),0,0).
cost((teb,ryend),1,0).
cost((teb,ryend),2,0).
cost((teb,ryend),3,0).
cost((teb,ryend),4,20).
cost((teb,ryend),5,19).
cost((teb,ryend),6,17).
cost((teb,ryend),7,16).
cost((teb,ryend),8,17).
cost((teb,ryend),9,17).
cost((teb,ryend),10,18).
cost((teb,ryend),11,17).
cost((teb,ryend),12,17).
cost((teb,ryend),13,16).
cost((teb,ryend),14,14).
cost((teb,ryend),15,12).
cost((teb,ryend),16,9).
cost((teb,ryend),17,6).
cost((teb,ryend),18,4).
cost((teb,ryend),19,2).
cost((teb,cri),0,0).
cost((teb,cri),1,0).
cost((teb,cri),2,0).
cost((teb,cri),3,0).
cost((teb,cri),4,0).
cost((teb,cri),5,28).
cost((teb,cri),6,26).
cost((teb,cri),7,25).
cost((teb,cri),8,24).
cost((teb,cri),9,24).
cost((teb,cri),10,24).
cost((teb,cri),11,24).
cost((teb,cri),12,24).
cost((teb,cri),13,23).
cost((teb,cri),14,21).
cost((teb,cri),15,18).
cost((teb,cri),16,16).
cost((teb,cri),17,12).
cost((teb,cri),18,8).
cost((teb,cri),19,5).
cost((teb,cimbl),0,0).
cost((teb,cimbl),1,0).
cost((teb,cimbl),2,12).
cost((teb,cimbl),3,12).
cost((teb,cimbl),4,11).
cost((teb,cimbl),5,9).
cost((teb,cimbl),6,9).
cost((teb,cimbl),7,9).
cost((teb,cimbl),8,10).
cost((teb,cimbl),9,10).
cost((teb,cimbl),10,10).
cost((teb,cimbl),11,9).
cost((teb,cimbl),12,9).
cost((teb,cimbl),13,9).
cost((teb,cimbl),14,7).
cost((teb,cimbl),15,4).
cost((teb,cimbl),16,4).
cost((teb,cimbl),17,3).
cost((teb,cimbl),18,1).
cost((teb,cimbl),19,0).
cost((teb,dandy),0,0).
cost((teb,dandy),1,0).
cost((teb,dandy),2,12).
cost((teb,dandy),3,12).
cost((teb,dandy),4,11).
cost((teb,dandy),5,9).
cost((teb,dandy),6,9).
cost((teb,dandy),7,9).
cost((teb,dandy),8,10).
cost((teb,dandy),9,10).
cost((teb,dandy),10,10).
cost((teb,dandy),11,9).
cost((teb,dandy),12,9).
cost((teb,dandy),13,9).
cost((teb,dandy),14,7).
cost((teb,dandy),15,4).
cost((teb,dandy),16,4).
cost((teb,dandy),17,3).
cost((teb,dandy),18,1).
cost((teb,dandy),19,0).
cost((ryend,jfk),0,0).
cost((ryend,jfk),1,0).
cost((ryend,jfk),2,0).
cost((ryend,jfk),3,0).
cost((ryend,jfk),4,0).
cost((ryend,jfk),5,0).
cost((ryend,jfk),6,31).
cost((ryend,jfk),7,30).
cost((ryend,jfk),8,28).
cost((ryend,jfk),9,27).
cost((ryend,jfk),10,28).
cost((ryend,jfk),11,28).
cost((ryend,jfk),12,28).
cost((ryend,jfk),13,27).
cost((ryend,jfk),14,25).
cost((ryend,jfk),15,22).
cost((ryend,jfk),16,19).
cost((ryend,jfk),17,16).
cost((ryend,jfk),18,11).
cost((ryend,jfk),19,7).
cost((ryend,lga),0,0).
cost((ryend,lga),1,0).
cost((ryend,lga),2,0).
cost((ryend,lga),3,0).
cost((ryend,lga),4,0).
cost((ryend,lga),5,26).
cost((ryend,lga),6,24).
cost((ryend,lga),7,23).
cost((ryend,lga),8,22).
cost((ryend,lga),9,22).
cost((ryend,lga),10,23).
cost((ryend,lga),11,23).
cost((ryend,lga),12,23).
cost((ryend,lga),13,22).
cost((ryend,lga),14,19).
cost((ryend,lga),15,17).
cost((ryend,lga),16,14).
cost((ryend,lga),17,11).
cost((ryend,lga),18,7).
cost((ryend,lga),19,5).
cost((ryend,teb),0,0).
cost((ryend,teb),1,0).
cost((ryend,teb),2,0).
cost((ryend,teb),3,0).
cost((ryend,teb),4,20).
cost((ryend,teb),5,19).
cost((ryend,teb),6,17).
cost((ryend,teb),7,16).
cost((ryend,teb),8,17).
cost((ryend,teb),9,17).
cost((ryend,teb),10,18).
cost((ryend,teb),11,17).
cost((ryend,teb),12,17).
cost((ryend,teb),13,16).
cost((ryend,teb),14,14).
cost((ryend,teb),15,12).
cost((ryend,teb),16,9).
cost((ryend,teb),17,6).
cost((ryend,teb),18,4).
cost((ryend,teb),19,2).
cost((ryend,cri),0,0).
cost((ryend,cri),1,0).
cost((ryend,cri),2,0).
cost((ryend,cri),3,0).
cost((ryend,cri),4,24).
cost((ryend,cri),5,22).
cost((ryend,cri),6,21).
cost((ryend,cri),7,20).
cost((ryend,cri),8,19).
cost((ryend,cri),9,20).
cost((ryend,cri),10,20).
cost((ryend,cri),11,20).
cost((ryend,cri),12,20).
cost((ryend,cri),13,19).
cost((ryend,cri),14,17).
cost((ryend,cri),15,14).
cost((ryend,cri),16,12).
cost((ryend,cri),17,8).
cost((ryend,cri),18,5).
cost((ryend,cri),19,4).
cost((ryend,cimbl),0,0).
cost((ryend,cimbl),1,0).
cost((ryend,cimbl),2,0).
cost((ryend,cimbl),3,16).
cost((ryend,cimbl),4,15).
cost((ryend,cimbl),5,13).
cost((ryend,cimbl),6,12).
cost((ryend,cimbl),7,12).
cost((ryend,cimbl),8,13).
cost((ryend,cimbl),9,13).
cost((ryend,cimbl),10,13).
cost((ryend,cimbl),11,13).
cost((ryend,cimbl),12,13).
cost((ryend,cimbl),13,12).
cost((ryend,cimbl),14,10).
cost((ryend,cimbl),15,7).
cost((ryend,cimbl),16,6).
cost((ryend,cimbl),17,4).
cost((ryend,cimbl),18,2).
cost((ryend,cimbl),19,1).
cost((ryend,dandy),0,0).
cost((ryend,dandy),1,0).
cost((ryend,dandy),2,12).
cost((ryend,dandy),3,12).
cost((ryend,dandy),4,10).
cost((ryend,dandy),5,9).
cost((ryend,dandy),6,9).
cost((ryend,dandy),7,9).
cost((ryend,dandy),8,9).
cost((ryend,dandy),9,10).
cost((ryend,dandy),10,9).
cost((ryend,dandy),11,9).
cost((ryend,dandy),12,9).
cost((ryend,dandy),13,9).
cost((ryend,dandy),14,6).
cost((ryend,dandy),15,4).
cost((ryend,dandy),16,4).
cost((ryend,dandy),17,3).
cost((ryend,dandy),18,1).
cost((ryend,dandy),19,0).
cost((cri,jfk),0,0).
cost((cri,jfk),1,0).
cost((cri,jfk),2,11).
cost((cri,jfk),3,11).
cost((cri,jfk),4,9).
cost((cri,jfk),5,8).
cost((cri,jfk),6,8).
cost((cri,jfk),7,8).
cost((cri,jfk),8,9).
cost((cri,jfk),9,9).
cost((cri,jfk),10,9).
cost((cri,jfk),11,8).
cost((cri,jfk),12,8).
cost((cri,jfk),13,8).
cost((cri,jfk),14,6).
cost((cri,jfk),15,4).
cost((cri,jfk),16,4).
cost((cri,jfk),17,2).
cost((cri,jfk),18,1).
cost((cri,jfk),19,0).
cost((cri,lga),0,0).
cost((cri,lga),1,0).
cost((cri,lga),2,0).
cost((cri,lga),3,20).
cost((cri,lga),4,19).
cost((cri,lga),5,17).
cost((cri,lga),6,16).
cost((cri,lga),7,15).
cost((cri,lga),8,16).
cost((cri,lga),9,16).
cost((cri,lga),10,16).
cost((cri,lga),11,16).
cost((cri,lga),12,16).
cost((cri,lga),13,15).
cost((cri,lga),14,13).
cost((cri,lga),15,10).
cost((cri,lga),16,8).
cost((cri,lga),17,6).
cost((cri,lga),18,4).
cost((cri,lga),19,2).
cost((cri,teb),0,0).
cost((cri,teb),1,0).
cost((cri,teb),2,0).
cost((cri,teb),3,0).
cost((cri,teb),4,0).
cost((cri,teb),5,28).
cost((cri,teb),6,26).
cost((cri,teb),7,25).
cost((cri,teb),8,24).
cost((cri,teb),9,24).
cost((cri,teb),10,24).
cost((cri,teb),11,24).
cost((cri,teb),12,24).
cost((cri,teb),13,24).
cost((cri,teb),14,21).
cost((cri,teb),15,18).
cost((cri,teb),16,16).
cost((cri,teb),17,12).
cost((cri,teb),18,8).
cost((cri,teb),19,5).
cost((cri,ryend),0,0).
cost((cri,ryend),1,0).
cost((cri,ryend),2,0).
cost((cri,ryend),3,0).
cost((cri,ryend),4,24).
cost((cri,ryend),5,22).
cost((cri,ryend),6,21).
cost((cri,ryend),7,20).
cost((cri,ryend),8,19).
cost((cri,ryend),9,20).
cost((cri,ryend),10,20).
cost((cri,ryend),11,20).
cost((cri,ryend),12,20).
cost((cri,ryend),13,19).
cost((cri,ryend),14,17).
cost((cri,ryend),15,14).
cost((cri,ryend),16,12).
cost((cri,ryend),17,8).
cost((cri,ryend),18,5).
cost((cri,ryend),19,4).
cost((cri,cimbl),0,0).
cost((cri,cimbl),1,0).
cost((cri,cimbl),2,0).
cost((cri,cimbl),3,19).
cost((cri,cimbl),4,17).
cost((cri,cimbl),5,16).
cost((cri,cimbl),6,14).
cost((cri,cimbl),7,14).
cost((cri,cimbl),8,15).
cost((cri,cimbl),9,15).
cost((cri,cimbl),10,15).
cost((cri,cimbl),11,15).
cost((cri,cimbl),12,14).
cost((cri,cimbl),13,14).
cost((cri,cimbl),14,12).
cost((cri,cimbl),15,9).
cost((cri,cimbl),16,7).
cost((cri,cimbl),17,5).
cost((cri,cimbl),18,3).
cost((cri,cimbl),19,1).
cost((cri,dandy),0,0).
cost((cri,dandy),1,0).
cost((cri,dandy),2,0).
cost((cri,dandy),3,0).
cost((cri,dandy),4,0).
cost((cri,dandy),5,27).
cost((cri,dandy),6,26).
cost((cri,dandy),7,25).
cost((cri,dandy),8,24).
cost((cri,dandy),9,24).
cost((cri,dandy),10,24).
cost((cri,dandy),11,24).
cost((cri,dandy),12,24).
cost((cri,dandy),13,23).
cost((cri,dandy),14,21).
cost((cri,dandy),15,18).
cost((cri,dandy),16,16).
cost((cri,dandy),17,12).
cost((cri,dandy),18,8).
cost((cri,dandy),19,5).
cost((cimbl,jfk),0,0).
cost((cimbl,jfk),1,0).
cost((cimbl,jfk),2,0).
cost((cimbl,jfk),3,0).
cost((cimbl,jfk),4,23).
cost((cimbl,jfk),5,21).
cost((cimbl,jfk),6,19).
cost((cimbl,jfk),7,17).
cost((cimbl,jfk),8,17).
cost((cimbl,jfk),9,17).
cost((cimbl,jfk),10,18).
cost((cimbl,jfk),11,18).
cost((cimbl,jfk),12,18).
cost((cimbl,jfk),13,18).
cost((cimbl,jfk),14,17).
cost((cimbl,jfk),15,15).
cost((cimbl,jfk),16,13).
cost((cimbl,jfk),17,9).
cost((cimbl,jfk),18,6).
cost((cimbl,jfk),19,4).
cost((cimbl,lga),0,0).
cost((cimbl,lga),1,0).
cost((cimbl,lga),2,13).
cost((cimbl,lga),3,13).
cost((cimbl,lga),4,11).
cost((cimbl,lga),5,8).
cost((cimbl,lga),6,8).
cost((cimbl,lga),7,8).
cost((cimbl,lga),8,9).
cost((cimbl,lga),9,9).
cost((cimbl,lga),10,9).
cost((cimbl,lga),11,9).
cost((cimbl,lga),12,9).
cost((cimbl,lga),13,9).
cost((cimbl,lga),14,7).
cost((cimbl,lga),15,5).
cost((cimbl,lga),16,5).
cost((cimbl,lga),17,4).
cost((cimbl,lga),18,1).
cost((cimbl,lga),19,0).
cost((cimbl,teb),0,0).
cost((cimbl,teb),1,0).
cost((cimbl,teb),2,13).
cost((cimbl,teb),3,13).
cost((cimbl,teb),4,10).
cost((cimbl,teb),5,8).
cost((cimbl,teb),6,8).
cost((cimbl,teb),7,8).
cost((cimbl,teb),8,9).
cost((cimbl,teb),9,9).
cost((cimbl,teb),10,9).
cost((cimbl,teb),11,9).
cost((cimbl,teb),12,9).
cost((cimbl,teb),13,9).
cost((cimbl,teb),14,7).
cost((cimbl,teb),15,5).
cost((cimbl,teb),16,5).
cost((cimbl,teb),17,3).
cost((cimbl,teb),18,1).
cost((cimbl,teb),19,0).
cost((cimbl,ryend),0,0).
cost((cimbl,ryend),1,0).
cost((cimbl,ryend),2,0).
cost((cimbl,ryend),3,17).
cost((cimbl,ryend),4,15).
cost((cimbl,ryend),5,12).
cost((cimbl,ryend),6,10).
cost((cimbl,ryend),7,11).
cost((cimbl,ryend),8,11).
cost((cimbl,ryend),9,12).
cost((cimbl,ryend),10,12).
cost((cimbl,ryend),11,12).
cost((cimbl,ryend),12,12).
cost((cimbl,ryend),13,12).
cost((cimbl,ryend),14,10).
cost((cimbl,ryend),15,8).
cost((cimbl,ryend),16,7).
cost((cimbl,ryend),17,5).
cost((cimbl,ryend),18,3).
cost((cimbl,ryend),19,1).
cost((cimbl,cri),0,0).
cost((cimbl,cri),1,0).
cost((cimbl,cri),2,0).
cost((cimbl,cri),3,20).
cost((cimbl,cri),4,17).
cost((cimbl,cri),5,15).
cost((cimbl,cri),6,12).
cost((cimbl,cri),7,12).
cost((cimbl,cri),8,13).
cost((cimbl,cri),9,14).
cost((cimbl,cri),10,14).
cost((cimbl,cri),11,14).
cost((cimbl,cri),12,14).
cost((cimbl,cri),13,14).
cost((cimbl,cri),14,12).
cost((cimbl,cri),15,10).
cost((cimbl,cri),16,8).
cost((cimbl,cri),17,6).
cost((cimbl,cri),18,4).
cost((cimbl,cri),19,2).
cost((cimbl,dandy),0,0).
cost((cimbl,dandy),1,0).
cost((cimbl,dandy),2,15).
cost((cimbl,dandy),3,15).
cost((cimbl,dandy),4,12).
cost((cimbl,dandy),5,10).
cost((cimbl,dandy),6,9).
cost((cimbl,dandy),7,9).
cost((cimbl,dandy),8,10).
cost((cimbl,dandy),9,10).
cost((cimbl,dandy),10,10).
cost((cimbl,dandy),11,10).
cost((cimbl,dandy),12,10).
cost((cimbl,dandy),13,10).
cost((cimbl,dandy),14,8).
cost((cimbl,dandy),15,6).
cost((cimbl,dandy),16,6).
cost((cimbl,dandy),17,4).
cost((cimbl,dandy),18,2).
cost((cimbl,dandy),19,0).
cost((dandy,jfk),0,0).
cost((dandy,jfk),1,0).
cost((dandy,jfk),2,0).
cost((dandy,jfk),3,0).
cost((dandy,jfk),4,0).
cost((dandy,jfk),5,0).
cost((dandy,jfk),6,33).
cost((dandy,jfk),7,32).
cost((dandy,jfk),8,31).
cost((dandy,jfk),9,30).
cost((dandy,jfk),10,30).
cost((dandy,jfk),11,30).
cost((dandy,jfk),12,30).
cost((dandy,jfk),13,30).
cost((dandy,jfk),14,27).
cost((dandy,jfk),15,24).
cost((dandy,jfk),16,22).
cost((dandy,jfk),17,18).
cost((dandy,jfk),18,13).
cost((dandy,jfk),19,9).
cost((dandy,lga),0,0).
cost((dandy,lga),1,0).
cost((dandy,lga),2,0).
cost((dandy,lga),3,0).
cost((dandy,lga),4,24).
cost((dandy,lga),5,22).
cost((dandy,lga),6,21).
cost((dandy,lga),7,19).
cost((dandy,lga),8,19).
cost((dandy,lga),9,20).
cost((dandy,lga),10,20).
cost((dandy,lga),11,20).
cost((dandy,lga),12,20).
cost((dandy,lga),13,19).
cost((dandy,lga),14,17).
cost((dandy,lga),15,14).
cost((dandy,lga),16,12).
cost((dandy,lga),17,8).
cost((dandy,lga),18,5).
cost((dandy,lga),19,4).
cost((dandy,teb),0,0).
cost((dandy,teb),1,0).
cost((dandy,teb),2,12).
cost((dandy,teb),3,12).
cost((dandy,teb),4,11).
cost((dandy,teb),5,9).
cost((dandy,teb),6,9).
cost((dandy,teb),7,9).
cost((dandy,teb),8,10).
cost((dandy,teb),9,10).
cost((dandy,teb),10,10).
cost((dandy,teb),11,9).
cost((dandy,teb),12,9).
cost((dandy,teb),13,9).
cost((dandy,teb),14,7).
cost((dandy,teb),15,4).
cost((dandy,teb),16,4).
cost((dandy,teb),17,3).
cost((dandy,teb),18,1).
cost((dandy,teb),19,0).
cost((dandy,ryend),0,0).
cost((dandy,ryend),1,0).
cost((dandy,ryend),2,12).
cost((dandy,ryend),3,12).
cost((dandy,ryend),4,10).
cost((dandy,ryend),5,9).
cost((dandy,ryend),6,9).
cost((dandy,ryend),7,9).
cost((dandy,ryend),8,9).
cost((dandy,ryend),9,9).
cost((dandy,ryend),10,9).
cost((dandy,ryend),11,9).
cost((dandy,ryend),12,9).
cost((dandy,ryend),13,9).
cost((dandy,ryend),14,6).
cost((dandy,ryend),15,4).
cost((dandy,ryend),16,4).
cost((dandy,ryend),17,3).
cost((dandy,ryend),18,1).
cost((dandy,ryend),19,0).
cost((dandy,cri),0,0).
cost((dandy,cri),1,0).
cost((dandy,cri),2,0).
cost((dandy,cri),3,0).
cost((dandy,cri),4,0).
cost((dandy,cri),5,27).
cost((dandy,cri),6,26).
cost((dandy,cri),7,25).
cost((dandy,cri),8,24).
cost((dandy,cri),9,24).
cost((dandy,cri),10,24).
cost((dandy,cri),11,24).
cost((dandy,cri),12,24).
cost((dandy,cri),13,23).
cost((dandy,cri),14,21).
cost((dandy,cri),15,18).
cost((dandy,cri),16,16).
cost((dandy,cri),17,12).
cost((dandy,cri),18,8).
cost((dandy,cri),19,5).
cost((dandy,cimbl),0,0).
cost((dandy,cimbl),1,0).
cost((dandy,cimbl),2,14).
cost((dandy,cimbl),3,14).
cost((dandy,cimbl),4,12).
cost((dandy,cimbl),5,11).
cost((dandy,cimbl),6,10).
cost((dandy,cimbl),7,11).
cost((dandy,cimbl),8,11).
cost((dandy,cimbl),9,11).
cost((dandy,cimbl),10,11).
cost((dandy,cimbl),11,11).
cost((dandy,cimbl),12,11).
cost((dandy,cimbl),13,10).
cost((dandy,cimbl),14,8).
cost((dandy,cimbl),15,6).
cost((dandy,cimbl),16,5).
cost((dandy,cimbl),17,3).
cost((dandy,cimbl),18,2).
cost((dandy,cimbl),19,0).
min_cost((jfk,lga),0,0).
min_cost((jfk,lga),1,0).
min_cost((jfk,lga),2,0).
min_cost((jfk,lga),3,8).
min_cost((jfk,lga),4,9).
min_cost((jfk,lga),5,14).
min_cost((jfk,lga),6,19).
min_cost((jfk,lga),7,20).
min_cost((jfk,lga),8,17).
min_cost((jfk,lga),9,14).
min_cost((jfk,lga),10,13).
min_cost((jfk,lga),11,14).
min_cost((jfk,lga),12,14).
min_cost((jfk,lga),13,15).
min_cost((jfk,lga),14,12).
min_cost((jfk,lga),15,9).
min_cost((jfk,lga),16,6).
min_cost((jfk,lga),17,5).
min_cost((jfk,lga),18,3).
min_cost((jfk,lga),19,2).
min_cost((jfk,teb),0,0).
min_cost((jfk,teb),1,0).
min_cost((jfk,teb),2,0).
min_cost((jfk,teb),3,0).
min_cost((jfk,teb),4,0).
min_cost((jfk,teb),5,0).
min_cost((jfk,teb),6,24).
min_cost((jfk,teb),7,28).
min_cost((jfk,teb),8,30).
min_cost((jfk,teb),9,31).
min_cost((jfk,teb),10,29).
min_cost((jfk,teb),11,27).
min_cost((jfk,teb),12,25).
min_cost((jfk,teb),13,25).
min_cost((jfk,teb),14,23).
min_cost((jfk,teb),15,21).
min_cost((jfk,teb),16,18).
min_cost((jfk,teb),17,14).
min_cost((jfk,teb),18,10).
min_cost((jfk,teb),19,7).
min_cost((jfk,ryend),0,0).
min_cost((jfk,ryend),1,0).
min_cost((jfk,ryend),2,0).
min_cost((jfk,ryend),3,0).
min_cost((jfk,ryend),4,0).
min_cost((jfk,ryend),5,0).
min_cost((jfk,ryend),6,24).
min_cost((jfk,ryend),7,28).
min_cost((jfk,ryend),8,30).
min_cost((jfk,ryend),9,31).
min_cost((jfk,ryend),10,29).
min_cost((jfk,ryend),11,27).
min_cost((jfk,ryend),12,25).
min_cost((jfk,ryend),13,25).
min_cost((jfk,ryend),14,23).
min_cost((jfk,ryend),15,21).
min_cost((jfk,ryend),16,18).
min_cost((jfk,ryend),17,14).
min_cost((jfk,ryend),18,10).
min_cost((jfk,ryend),19,7).
min_cost((jfk,cri),0,0).
min_cost((jfk,cri),1,0).
min_cost((jfk,cri),2,3).
min_cost((jfk,cri),3,3).
min_cost((jfk,cri),4,7).
min_cost((jfk,cri),5,12).
min_cost((jfk,cri),6,12).
min_cost((jfk,cri),7,9).
min_cost((jfk,cri),8,7).
min_cost((jfk,cri),9,7).
min_cost((jfk,cri),10,7).
min_cost((jfk,cri),11,8).
min_cost((jfk,cri),12,9).
min_cost((jfk,cri),13,8).
min_cost((jfk,cri),14,5).
min_cost((jfk,cri),15,3).
min_cost((jfk,cri),16,3).
min_cost((jfk,cri),17,2).
min_cost((jfk,cri),18,1).
min_cost((jfk,cri),19,1).
min_cost((jfk,cimbl),0,0).
min_cost((jfk,cimbl),1,0).
min_cost((jfk,cimbl),2,0).
min_cost((jfk,cimbl),3,0).
min_cost((jfk,cimbl),4,12).
min_cost((jfk,cimbl),5,16).
min_cost((jfk,cimbl),6,21).
min_cost((jfk,cimbl),7,25).
min_cost((jfk,cimbl),8,22).
min_cost((jfk,cimbl),9,19).
min_cost((jfk,cimbl),10,17).
min_cost((jfk,cimbl),11,17).
min_cost((jfk,cimbl),12,18).
min_cost((jfk,cimbl),13,18).
min_cost((jfk,cimbl),14,16).
min_cost((jfk,cimbl),15,13).
min_cost((jfk,cimbl),16,10).
min_cost((jfk,cimbl),17,6).
min_cost((jfk,cimbl),18,5).
min_cost((jfk,cimbl),19,4).
min_cost((jfk,dandy),0,0).
min_cost((jfk,dandy),1,0).
min_cost((jfk,dandy),2,0).
min_cost((jfk,dandy),3,0).
min_cost((jfk,dandy),4,0).
min_cost((jfk,dandy),5,0).
min_cost((jfk,dandy),6,28).
min_cost((jfk,dandy),7,29).
min_cost((jfk,dandy),8,31).
min_cost((jfk,dandy),9,33).
min_cost((jfk,dandy),10,32).
min_cost((jfk,dandy),11,30).
min_cost((jfk,dandy),12,28).
min_cost((jfk,dandy),13,27).
min_cost((jfk,dandy),14,25).
min_cost((jfk,dandy),15,23).
min_cost((jfk,dandy),16,20).
min_cost((jfk,dandy),17,16).
min_cost((jfk,dandy),18,12).
min_cost((jfk,dandy),19,8).
min_cost((lga,jfk),0,0).
min_cost((lga,jfk),1,0).
min_cost((lga,jfk),2,0).
min_cost((lga,jfk),3,20).
min_cost((lga,jfk),4,18).
min_cost((lga,jfk),5,16).
min_cost((lga,jfk),6,14).
min_cost((lga,jfk),7,14).
min_cost((lga,jfk),8,15).
min_cost((lga,jfk),9,15).
min_cost((lga,jfk),10,16).
min_cost((lga,jfk),11,15).
min_cost((lga,jfk),12,15).
min_cost((lga,jfk),13,14).
min_cost((lga,jfk),14,12).
min_cost((lga,jfk),15,10).
min_cost((lga,jfk),16,7).
min_cost((lga,jfk),17,5).
min_cost((lga,jfk),18,3).
min_cost((lga,jfk),19,1).
min_cost((lga,teb),0,0).
min_cost((lga,teb),1,0).
min_cost((lga,teb),2,0).
min_cost((lga,teb),3,17).
min_cost((lga,teb),4,15).
min_cost((lga,teb),5,14).
min_cost((lga,teb),6,13).
min_cost((lga,teb),7,13).
min_cost((lga,teb),8,13).
min_cost((lga,teb),9,14).
min_cost((lga,teb),10,14).
min_cost((lga,teb),11,13).
min_cost((lga,teb),12,13).
min_cost((lga,teb),13,12).
min_cost((lga,teb),14,10).
min_cost((lga,teb),15,8).
min_cost((lga,teb),16,6).
min_cost((lga,teb),17,4).
min_cost((lga,teb),18,2).
min_cost((lga,teb),19,0).
min_cost((lga,ryend),0,0).
min_cost((lga,ryend),1,0).
min_cost((lga,ryend),2,0).
min_cost((lga,ryend),3,0).
min_cost((lga,ryend),4,0).
min_cost((lga,ryend),5,25).
min_cost((lga,ryend),6,23).
min_cost((lga,ryend),7,22).
min_cost((lga,ryend),8,21).
min_cost((lga,ryend),9,22).
min_cost((lga,ryend),10,22).
min_cost((lga,ryend),11,22).
min_cost((lga,ryend),12,22).
min_cost((lga,ryend),13,21).
min_cost((lga,ryend),14,19).
min_cost((lga,ryend),15,16).
min_cost((lga,ryend),16,14).
min_cost((lga,ryend),17,9).
min_cost((lga,ryend),18,6).
min_cost((lga,ryend),19,4).
min_cost((lga,cri),0,0).
min_cost((lga,cri),1,0).
min_cost((lga,cri),2,0).
min_cost((lga,cri),3,20).
min_cost((lga,cri),4,18).
min_cost((lga,cri),5,16).
min_cost((lga,cri),6,15).
min_cost((lga,cri),7,15).
min_cost((lga,cri),8,15).
min_cost((lga,cri),9,16).
min_cost((lga,cri),10,16).
min_cost((lga,cri),11,16).
min_cost((lga,cri),12,15).
min_cost((lga,cri),13,14).
min_cost((lga,cri),14,12).
min_cost((lga,cri),15,10).
min_cost((lga,cri),16,7).
min_cost((lga,cri),17,5).
min_cost((lga,cri),18,3).
min_cost((lga,cri),19,1).
min_cost((lga,cimbl),0,0).
min_cost((lga,cimbl),1,0).
min_cost((lga,cimbl),2,13).
min_cost((lga,cimbl),3,12).
min_cost((lga,cimbl),4,10).
min_cost((lga,cimbl),5,9).
min_cost((lga,cimbl),6,9).
min_cost((lga,cimbl),7,9).
min_cost((lga,cimbl),8,10).
min_cost((lga,cimbl),9,10).
min_cost((lga,cimbl),10,10).
min_cost((lga,cimbl),11,9).
min_cost((lga,cimbl),12,9).
min_cost((lga,cimbl),13,9).
min_cost((lga,cimbl),14,6).
min_cost((lga,cimbl),15,4).
min_cost((lga,cimbl),16,4).
min_cost((lga,cimbl),17,2).
min_cost((lga,cimbl),18,0).
min_cost((lga,cimbl),19,0).
min_cost((lga,dandy),0,0).
min_cost((lga,dandy),1,0).
min_cost((lga,dandy),2,0).
min_cost((lga,dandy),3,0).
min_cost((lga,dandy),4,23).
min_cost((lga,dandy),5,22).
min_cost((lga,dandy),6,20).
min_cost((lga,dandy),7,19).
min_cost((lga,dandy),8,19).
min_cost((lga,dandy),9,19).
min_cost((lga,dandy),10,20).
min_cost((lga,dandy),11,20).
min_cost((lga,dandy),12,19).
min_cost((lga,dandy),13,18).
min_cost((lga,dandy),14,16).
min_cost((lga,dandy),15,13).
min_cost((lga,dandy),16,11).
min_cost((lga,dandy),17,7).
min_cost((lga,dandy),18,5).
min_cost((lga,dandy),19,3).
min_cost((teb,jfk),0,0).
min_cost((teb,jfk),1,0).
min_cost((teb,jfk),2,0).
min_cost((teb,jfk),3,0).
min_cost((teb,jfk),4,0).
min_cost((teb,jfk),5,0).
min_cost((teb,jfk),6,30).
min_cost((teb,jfk),7,29).
min_cost((teb,jfk),8,28).
min_cost((teb,jfk),9,27).
min_cost((teb,jfk),10,27).
min_cost((teb,jfk),11,28).
min_cost((teb,jfk),12,28).
min_cost((teb,jfk),13,27).
min_cost((teb,jfk),14,24).
min_cost((teb,jfk),15,21).
min_cost((teb,jfk),16,18).
min_cost((teb,jfk),17,14).
min_cost((teb,jfk),18,10).
min_cost((teb,jfk),19,6).
min_cost((teb,lga),0,0).
min_cost((teb,lga),1,0).
min_cost((teb,lga),2,0).
min_cost((teb,lga),3,17).
min_cost((teb,lga),4,15).
min_cost((teb,lga),5,14).
min_cost((teb,lga),6,13).
min_cost((teb,lga),7,13).
min_cost((teb,lga),8,13).
min_cost((teb,lga),9,14).
min_cost((teb,lga),10,14).
min_cost((teb,lga),11,14).
min_cost((teb,lga),12,13).
min_cost((teb,lga),13,12).
min_cost((teb,lga),14,10).
min_cost((teb,lga),15,7).
min_cost((teb,lga),16,6).
min_cost((teb,lga),17,4).
min_cost((teb,lga),18,2).
min_cost((teb,lga),19,0).
min_cost((teb,ryend),0,0).
min_cost((teb,ryend),1,0).
min_cost((teb,ryend),2,0).
min_cost((teb,ryend),3,0).
min_cost((teb,ryend),4,20).
min_cost((teb,ryend),5,18).
min_cost((teb,ryend),6,17).
min_cost((teb,ryend),7,16).
min_cost((teb,ryend),8,17).
min_cost((teb,ryend),9,17).
min_cost((teb,ryend),10,17).
min_cost((teb,ryend),11,17).
min_cost((teb,ryend),12,17).
min_cost((teb,ryend),13,16).
min_cost((teb,ryend),14,13).
min_cost((teb,ryend),15,11).
min_cost((teb,ryend),16,8).
min_cost((teb,ryend),17,6).
min_cost((teb,ryend),18,4).
min_cost((teb,ryend),19,2).
min_cost((teb,cri),0,0).
min_cost((teb,cri),1,0).
min_cost((teb,cri),2,0).
min_cost((teb,cri),3,0).
min_cost((teb,cri),4,0).
min_cost((teb,cri),5,27).
min_cost((teb,cri),6,26).
min_cost((teb,cri),7,24).
min_cost((teb,cri),8,23).
min_cost((teb,cri),9,24).
min_cost((teb,cri),10,24).
min_cost((teb,cri),11,24).
min_cost((teb,cri),12,24).
min_cost((teb,cri),13,23).
min_cost((teb,cri),14,20).
min_cost((teb,cri),15,17).
min_cost((teb,cri),16,15).
min_cost((teb,cri),17,11).
min_cost((teb,cri),18,7).
min_cost((teb,cri),19,5).
min_cost((teb,cimbl),0,0).
min_cost((teb,cimbl),1,0).
min_cost((teb,cimbl),2,12).
min_cost((teb,cimbl),3,12).
min_cost((teb,cimbl),4,10).
min_cost((teb,cimbl),5,9).
min_cost((teb,cimbl),6,9).
min_cost((teb,cimbl),7,9).
min_cost((teb,cimbl),8,9).
min_cost((teb,cimbl),9,10).
min_cost((teb,cimbl),10,10).
min_cost((teb,cimbl),11,9).
min_cost((teb,cimbl),12,9).
min_cost((teb,cimbl),13,8).
min_cost((teb,cimbl),14,6).
min_cost((teb,cimbl),15,4).
min_cost((teb,cimbl),16,4).
min_cost((teb,cimbl),17,2).
min_cost((teb,cimbl),18,0).
min_cost((teb,cimbl),19,0).
min_cost((teb,dandy),0,0).
min_cost((teb,dandy),1,0).
min_cost((teb,dandy),2,12).
min_cost((teb,dandy),3,12).
min_cost((teb,dandy),4,10).
min_cost((teb,dandy),5,9).
min_cost((teb,dandy),6,9).
min_cost((teb,dandy),7,9).
min_cost((teb,dandy),8,9).
min_cost((teb,dandy),9,10).
min_cost((teb,dandy),10,10).
min_cost((teb,dandy),11,9).
min_cost((teb,dandy),12,9).
min_cost((teb,dandy),13,8).
min_cost((teb,dandy),14,6).
min_cost((teb,dandy),15,4).
min_cost((teb,dandy),16,4).
min_cost((teb,dandy),17,2).
min_cost((teb,dandy),18,0).
min_cost((teb,dandy),19,0).
min_cost((ryend,jfk),0,0).
min_cost((ryend,jfk),1,0).
min_cost((ryend,jfk),2,0).
min_cost((ryend,jfk),3,0).
min_cost((ryend,jfk),4,0).
min_cost((ryend,jfk),5,0).
min_cost((ryend,jfk),6,30).
min_cost((ryend,jfk),7,29).
min_cost((ryend,jfk),8,28).
min_cost((ryend,jfk),9,27).
min_cost((ryend,jfk),10,28).
min_cost((ryend,jfk),11,28).
min_cost((ryend,jfk),12,28).
min_cost((ryend,jfk),13,27).
min_cost((ryend,jfk),14,24).
min_cost((ryend,jfk),15,21).
min_cost((ryend,jfk),16,18).
min_cost((ryend,jfk),17,14).
min_cost((ryend,jfk),18,10).
min_cost((ryend,jfk),19,6).
min_cost((ryend,lga),0,0).
min_cost((ryend,lga),1,0).
min_cost((ryend,lga),2,0).
min_cost((ryend,lga),3,0).
min_cost((ryend,lga),4,0).
min_cost((ryend,lga),5,25).
min_cost((ryend,lga),6,24).
min_cost((ryend,lga),7,22).
min_cost((ryend,lga),8,22).
min_cost((ryend,lga),9,22).
min_cost((ryend,lga),10,23).
min_cost((ryend,lga),11,23).
min_cost((ryend,lga),12,22).
min_cost((ryend,lga),13,21).
min_cost((ryend,lga),14,18).
min_cost((ryend,lga),15,16).
min_cost((ryend,lga),16,13).
min_cost((ryend,lga),17,9).
min_cost((ryend,lga),18,6).
min_cost((ryend,lga),19,4).
min_cost((ryend,teb),0,0).
min_cost((ryend,teb),1,0).
min_cost((ryend,teb),2,0).
min_cost((ryend,teb),3,0).
min_cost((ryend,teb),4,20).
min_cost((ryend,teb),5,18).
min_cost((ryend,teb),6,17).
min_cost((ryend,teb),7,16).
min_cost((ryend,teb),8,17).
min_cost((ryend,teb),9,17).
min_cost((ryend,teb),10,18).
min_cost((ryend,teb),11,17).
min_cost((ryend,teb),12,17).
min_cost((ryend,teb),13,16).
min_cost((ryend,teb),14,13).
min_cost((ryend,teb),15,11).
min_cost((ryend,teb),16,8).
min_cost((ryend,teb),17,6).
min_cost((ryend,teb),18,4).
min_cost((ryend,teb),19,2).
min_cost((ryend,cri),0,0).
min_cost((ryend,cri),1,0).
min_cost((ryend,cri),2,0).
min_cost((ryend,cri),3,0).
min_cost((ryend,cri),4,24).
min_cost((ryend,cri),5,22).
min_cost((ryend,cri),6,20).
min_cost((ryend,cri),7,19).
min_cost((ryend,cri),8,19).
min_cost((ryend,cri),9,20).
min_cost((ryend,cri),10,20).
min_cost((ryend,cri),11,20).
min_cost((ryend,cri),12,20).
min_cost((ryend,cri),13,19).
min_cost((ryend,cri),14,16).
min_cost((ryend,cri),15,13).
min_cost((ryend,cri),16,11).
min_cost((ryend,cri),17,7).
min_cost((ryend,cri),18,5).
min_cost((ryend,cri),19,3).
min_cost((ryend,cimbl),0,0).
min_cost((ryend,cimbl),1,0).
min_cost((ryend,cimbl),2,0).
min_cost((ryend,cimbl),3,16).
min_cost((ryend,cimbl),4,14).
min_cost((ryend,cimbl),5,13).
min_cost((ryend,cimbl),6,12).
min_cost((ryend,cimbl),7,12).
min_cost((ryend,cimbl),8,13).
min_cost((ryend,cimbl),9,13).
min_cost((ryend,cimbl),10,13).
min_cost((ryend,cimbl),11,13).
min_cost((ryend,cimbl),12,12).
min_cost((ryend,cimbl),13,12).
min_cost((ryend,cimbl),14,9).
min_cost((ryend,cimbl),15,7).
min_cost((ryend,cimbl),16,6).
min_cost((ryend,cimbl),17,4).
min_cost((ryend,cimbl),18,2).
min_cost((ryend,cimbl),19,0).
min_cost((ryend,dandy),0,0).
min_cost((ryend,dandy),1,0).
min_cost((ryend,dandy),2,12).
min_cost((ryend,dandy),3,11).
min_cost((ryend,dandy),4,10).
min_cost((ryend,dandy),5,9).
min_cost((ryend,dandy),6,9).
min_cost((ryend,dandy),7,9).
min_cost((ryend,dandy),8,9).
min_cost((ryend,dandy),9,10).
min_cost((ryend,dandy),10,9).
min_cost((ryend,dandy),11,9).
min_cost((ryend,dandy),12,9).
min_cost((ryend,dandy),13,8).
min_cost((ryend,dandy),14,6).
min_cost((ryend,dandy),15,4).
min_cost((ryend,dandy),16,4).
min_cost((ryend,dandy),17,2).
min_cost((ryend,dandy),18,0).
min_cost((ryend,dandy),19,0).
min_cost((cri,jfk),0,0).
min_cost((cri,jfk),1,0).
min_cost((cri,jfk),2,11).
min_cost((cri,jfk),3,11).
min_cost((cri,jfk),4,9).
min_cost((cri,jfk),5,8).
min_cost((cri,jfk),6,8).
min_cost((cri,jfk),7,8).
min_cost((cri,jfk),8,9).
min_cost((cri,jfk),9,9).
min_cost((cri,jfk),10,9).
min_cost((cri,jfk),11,8).
min_cost((cri,jfk),12,8).
min_cost((cri,jfk),13,7).
min_cost((cri,jfk),14,5).
min_cost((cri,jfk),15,4).
min_cost((cri,jfk),16,4).
min_cost((cri,jfk),17,2).
min_cost((cri,jfk),18,0).
min_cost((cri,jfk),19,0).
min_cost((cri,lga),0,0).
min_cost((cri,lga),1,0).
min_cost((cri,lga),2,0).
min_cost((cri,lga),3,20).
min_cost((cri,lga),4,18).
min_cost((cri,lga),5,17).
min_cost((cri,lga),6,15).
min_cost((cri,lga),7,15).
min_cost((cri,lga),8,15).
min_cost((cri,lga),9,16).
min_cost((cri,lga),10,16).
min_cost((cri,lga),11,16).
min_cost((cri,lga),12,15).
min_cost((cri,lga),13,14).
min_cost((cri,lga),14,12).
min_cost((cri,lga),15,9).
min_cost((cri,lga),16,7).
min_cost((cri,lga),17,5).
min_cost((cri,lga),18,3).
min_cost((cri,lga),19,1).
min_cost((cri,teb),0,0).
min_cost((cri,teb),1,0).
min_cost((cri,teb),2,0).
min_cost((cri,teb),3,0).
min_cost((cri,teb),4,0).
min_cost((cri,teb),5,27).
min_cost((cri,teb),6,26).
min_cost((cri,teb),7,24).
min_cost((cri,teb),8,24).
min_cost((cri,teb),9,24).
min_cost((cri,teb),10,24).
min_cost((cri,teb),11,24).
min_cost((cri,teb),12,24).
min_cost((cri,teb),13,23).
min_cost((cri,teb),14,20).
min_cost((cri,teb),15,17).
min_cost((cri,teb),16,15).
min_cost((cri,teb),17,11).
min_cost((cri,teb),18,7).
min_cost((cri,teb),19,5).
min_cost((cri,ryend),0,0).
min_cost((cri,ryend),1,0).
min_cost((cri,ryend),2,0).
min_cost((cri,ryend),3,0).
min_cost((cri,ryend),4,24).
min_cost((cri,ryend),5,22).
min_cost((cri,ryend),6,20).
min_cost((cri,ryend),7,19).
min_cost((cri,ryend),8,19).
min_cost((cri,ryend),9,20).
min_cost((cri,ryend),10,20).
min_cost((cri,ryend),11,20).
min_cost((cri,ryend),12,20).
min_cost((cri,ryend),13,19).
min_cost((cri,ryend),14,16).
min_cost((cri,ryend),15,13).
min_cost((cri,ryend),16,11).
min_cost((cri,ryend),17,7).
min_cost((cri,ryend),18,5).
min_cost((cri,ryend),19,3).
min_cost((cri,cimbl),0,0).
min_cost((cri,cimbl),1,0).
min_cost((cri,cimbl),2,0).
min_cost((cri,cimbl),3,18).
min_cost((cri,cimbl),4,17).
min_cost((cri,cimbl),5,15).
min_cost((cri,cimbl),6,14).
min_cost((cri,cimbl),7,14).
min_cost((cri,cimbl),8,14).
min_cost((cri,cimbl),9,15).
min_cost((cri,cimbl),10,15).
min_cost((cri,cimbl),11,15).
min_cost((cri,cimbl),12,14).
min_cost((cri,cimbl),13,13).
min_cost((cri,cimbl),14,11).
min_cost((cri,cimbl),15,8).
min_cost((cri,cimbl),16,6).
min_cost((cri,cimbl),17,5).
min_cost((cri,cimbl),18,3).
min_cost((cri,cimbl),19,1).
min_cost((cri,dandy),0,0).
min_cost((cri,dandy),1,0).
min_cost((cri,dandy),2,0).
min_cost((cri,dandy),3,0).
min_cost((cri,dandy),4,0).
min_cost((cri,dandy),5,27).
min_cost((cri,dandy),6,25).
min_cost((cri,dandy),7,24).
min_cost((cri,dandy),8,23).
min_cost((cri,dandy),9,24).
min_cost((cri,dandy),10,24).
min_cost((cri,dandy),11,24).
min_cost((cri,dandy),12,24).
min_cost((cri,dandy),13,23).
min_cost((cri,dandy),14,20).
min_cost((cri,dandy),15,17).
min_cost((cri,dandy),16,15).
min_cost((cri,dandy),17,10).
min_cost((cri,dandy),18,7).
min_cost((cri,dandy),19,5).
min_cost((cimbl,jfk),0,0).
min_cost((cimbl,jfk),1,0).
min_cost((cimbl,jfk),2,0).
min_cost((cimbl,jfk),3,0).
min_cost((cimbl,jfk),4,23).
min_cost((cimbl,jfk),5,20).
min_cost((cimbl,jfk),6,18).
min_cost((cimbl,jfk),7,16).
min_cost((cimbl,jfk),8,16).
min_cost((cimbl,jfk),9,17).
min_cost((cimbl,jfk),10,18).
min_cost((cimbl,jfk),11,18).
min_cost((cimbl,jfk),12,18).
min_cost((cimbl,jfk),13,18).
min_cost((cimbl,jfk),14,16).
min_cost((cimbl,jfk),15,14).
min_cost((cimbl,jfk),16,12).
min_cost((cimbl,jfk),17,8).
min_cost((cimbl,jfk),18,6).
min_cost((cimbl,jfk),19,3).
min_cost((cimbl,lga),0,0).
min_cost((cimbl,lga),1,0).
min_cost((cimbl,lga),2,13).
min_cost((cimbl,lga),3,12).
min_cost((cimbl,lga),4,10).
min_cost((cimbl,lga),5,8).
min_cost((cimbl,lga),6,8).
min_cost((cimbl,lga),7,8).
min_cost((cimbl,lga),8,9).
min_cost((cimbl,lga),9,9).
min_cost((cimbl,lga),10,9).
min_cost((cimbl,lga),11,9).
min_cost((cimbl,lga),12,9).
min_cost((cimbl,lga),13,9).
min_cost((cimbl,lga),14,7).
min_cost((cimbl,lga),15,5).
min_cost((cimbl,lga),16,5).
min_cost((cimbl,lga),17,3).
min_cost((cimbl,lga),18,1).
min_cost((cimbl,lga),19,0).
min_cost((cimbl,teb),0,0).
min_cost((cimbl,teb),1,0).
min_cost((cimbl,teb),2,13).
min_cost((cimbl,teb),3,12).
min_cost((cimbl,teb),4,9).
min_cost((cimbl,teb),5,8).
min_cost((cimbl,teb),6,8).
min_cost((cimbl,teb),7,8).
min_cost((cimbl,teb),8,8).
min_cost((cimbl,teb),9,9).
min_cost((cimbl,teb),10,9).
min_cost((cimbl,teb),11,9).
min_cost((cimbl,teb),12,9).
min_cost((cimbl,teb),13,8).
min_cost((cimbl,teb),14,6).
min_cost((cimbl,teb),15,5).
min_cost((cimbl,teb),16,5).
min_cost((cimbl,teb),17,3).
min_cost((cimbl,teb),18,0).
min_cost((cimbl,teb),19,0).
min_cost((cimbl,ryend),0,0).
min_cost((cimbl,ryend),1,0).
min_cost((cimbl,ryend),2,0).
min_cost((cimbl,ryend),3,17).
min_cost((cimbl,ryend),4,14).
min_cost((cimbl,ryend),5,11).
min_cost((cimbl,ryend),6,10).
min_cost((cimbl,ryend),7,10).
min_cost((cimbl,ryend),8,11).
min_cost((cimbl,ryend),9,12).
min_cost((cimbl,ryend),10,12).
min_cost((cimbl,ryend),11,12).
min_cost((cimbl,ryend),12,12).
min_cost((cimbl,ryend),13,12).
min_cost((cimbl,ryend),14,10).
min_cost((cimbl,ryend),15,8).
min_cost((cimbl,ryend),16,7).
min_cost((cimbl,ryend),17,4).
min_cost((cimbl,ryend),18,2).
min_cost((cimbl,ryend),19,0).
min_cost((cimbl,cri),0,0).
min_cost((cimbl,cri),1,0).
min_cost((cimbl,cri),2,0).
min_cost((cimbl,cri),3,19).
min_cost((cimbl,cri),4,17).
min_cost((cimbl,cri),5,14).
min_cost((cimbl,cri),6,12).
min_cost((cimbl,cri),7,12).
min_cost((cimbl,cri),8,13).
min_cost((cimbl,cri),9,13).
min_cost((cimbl,cri),10,14).
min_cost((cimbl,cri),11,14).
min_cost((cimbl,cri),12,14).
min_cost((cimbl,cri),13,13).
min_cost((cimbl,cri),14,11).
min_cost((cimbl,cri),15,9).
min_cost((cimbl,cri),16,8).
min_cost((cimbl,cri),17,5).
min_cost((cimbl,cri),18,3).
min_cost((cimbl,cri),19,1).
min_cost((cimbl,dandy),0,0).
min_cost((cimbl,dandy),1,0).
min_cost((cimbl,dandy),2,15).
min_cost((cimbl,dandy),3,14).
min_cost((cimbl,dandy),4,11).
min_cost((cimbl,dandy),5,9).
min_cost((cimbl,dandy),6,9).
min_cost((cimbl,dandy),7,9).
min_cost((cimbl,dandy),8,10).
min_cost((cimbl,dandy),9,10).
min_cost((cimbl,dandy),10,10).
min_cost((cimbl,dandy),11,10).
min_cost((cimbl,dandy),12,10).
min_cost((cimbl,dandy),13,10).
min_cost((cimbl,dandy),14,8).
min_cost((cimbl,dandy),15,6).
min_cost((cimbl,dandy),16,6).
min_cost((cimbl,dandy),17,3).
min_cost((cimbl,dandy),18,1).
min_cost((cimbl,dandy),19,0).
min_cost((dandy,jfk),0,0).
min_cost((dandy,jfk),1,0).
min_cost((dandy,jfk),2,0).
min_cost((dandy,jfk),3,0).
min_cost((dandy,jfk),4,0).
min_cost((dandy,jfk),5,0).
min_cost((dandy,jfk),6,33).
min_cost((dandy,jfk),7,32).
min_cost((dandy,jfk),8,31).
min_cost((dandy,jfk),9,30).
min_cost((dandy,jfk),10,30).
min_cost((dandy,jfk),11,30).
min_cost((dandy,jfk),12,30).
min_cost((dandy,jfk),13,29).
min_cost((dandy,jfk),14,26).
min_cost((dandy,jfk),15,23).
min_cost((dandy,jfk),16,21).
min_cost((dandy,jfk),17,16).
min_cost((dandy,jfk),18,12).
min_cost((dandy,jfk),19,8).
min_cost((dandy,lga),0,0).
min_cost((dandy,lga),1,0).
min_cost((dandy,lga),2,0).
min_cost((dandy,lga),3,0).
min_cost((dandy,lga),4,23).
min_cost((dandy,lga),5,22).
min_cost((dandy,lga),6,20).
min_cost((dandy,lga),7,19).
min_cost((dandy,lga),8,19).
min_cost((dandy,lga),9,20).
min_cost((dandy,lga),10,20).
min_cost((dandy,lga),11,20).
min_cost((dandy,lga),12,20).
min_cost((dandy,lga),13,18).
min_cost((dandy,lga),14,16).
min_cost((dandy,lga),15,13).
min_cost((dandy,lga),16,11).
min_cost((dandy,lga),17,7).
min_cost((dandy,lga),18,5).
min_cost((dandy,lga),19,3).
min_cost((dandy,teb),0,0).
min_cost((dandy,teb),1,0).
min_cost((dandy,teb),2,12).
min_cost((dandy,teb),3,12).
min_cost((dandy,teb),4,10).
min_cost((dandy,teb),5,9).
min_cost((dandy,teb),6,9).
min_cost((dandy,teb),7,9).
min_cost((dandy,teb),8,9).
min_cost((dandy,teb),9,10).
min_cost((dandy,teb),10,10).
min_cost((dandy,teb),11,9).
min_cost((dandy,teb),12,9).
min_cost((dandy,teb),13,8).
min_cost((dandy,teb),14,6).
min_cost((dandy,teb),15,4).
min_cost((dandy,teb),16,4).
min_cost((dandy,teb),17,2).
min_cost((dandy,teb),18,0).
min_cost((dandy,teb),19,0).
min_cost((dandy,ryend),0,0).
min_cost((dandy,ryend),1,0).
min_cost((dandy,ryend),2,12).
min_cost((dandy,ryend),3,11).
min_cost((dandy,ryend),4,10).
min_cost((dandy,ryend),5,9).
min_cost((dandy,ryend),6,9).
min_cost((dandy,ryend),7,9).
min_cost((dandy,ryend),8,9).
min_cost((dandy,ryend),9,9).
min_cost((dandy,ryend),10,9).
min_cost((dandy,ryend),11,9).
min_cost((dandy,ryend),12,9).
min_cost((dandy,ryend),13,8).
min_cost((dandy,ryend),14,6).
min_cost((dandy,ryend),15,4).
min_cost((dandy,ryend),16,4).
min_cost((dandy,ryend),17,2).
min_cost((dandy,ryend),18,0).
min_cost((dandy,ryend),19,0).
min_cost((dandy,cri),0,0).
min_cost((dandy,cri),1,0).
min_cost((dandy,cri),2,0).
min_cost((dandy,cri),3,0).
min_cost((dandy,cri),4,0).
min_cost((dandy,cri),5,27).
min_cost((dandy,cri),6,25).
min_cost((dandy,cri),7,24).
min_cost((dandy,cri),8,23).
min_cost((dandy,cri),9,23).
min_cost((dandy,cri),10,24).
min_cost((dandy,cri),11,24).
min_cost((dandy,cri),12,24).
min_cost((dandy,cri),13,23).
min_cost((dandy,cri),14,20).
min_cost((dandy,cri),15,17).
min_cost((dandy,cri),16,15).
min_cost((dandy,cri),17,10).
min_cost((dandy,cri),18,7).
min_cost((dandy,cri),19,5).
min_cost((dandy,cimbl),0,0).
min_cost((dandy,cimbl),1,0).
min_cost((dandy,cimbl),2,14).
min_cost((dandy,cimbl),3,14).
min_cost((dandy,cimbl),4,12).
min_cost((dandy,cimbl),5,10).
min_cost((dandy,cimbl),6,10).
min_cost((dandy,cimbl),7,10).
min_cost((dandy,cimbl),8,11).
min_cost((dandy,cimbl),9,11).
min_cost((dandy,cimbl),10,11).
min_cost((dandy,cimbl),11,11).
min_cost((dandy,cimbl),12,11).
min_cost((dandy,cimbl),13,10).
min_cost((dandy,cimbl),14,7).
min_cost((dandy,cimbl),15,5).
min_cost((dandy,cimbl),16,5).
min_cost((dandy,cimbl),17,3).
min_cost((dandy,cimbl),18,1).
min_cost((dandy,cimbl),19,0).
vertiport(jfk;lga;teb;ryend;cri;cimbl;dandy).
% distance= miles/10
distance((jfk, jfk), 0).
distance((jfk, lga), 10).
distance((jfk, teb), 19).
distance((jfk, ryend), 19).
distance((jfk, cri), 6).
distance((jfk, cimbl), 13).
distance((jfk, dandy), 20).
distance((lga, jfk), 10).
distance((lga, lga), 0).
distance((lga, teb), 9).
distance((lga, ryend), 15).
distance((lga, cri), 11).
distance((lga, cimbl), 7).
distance((lga, dandy), 13).
distance((teb, jfk), 19).
distance((teb, lga), 9).
distance((teb, teb), 0).
distance((teb, ryend), 11).
distance((teb, cri), 16).
distance((teb, cimbl), 6).
distance((teb, dandy), 6).
distance((ryend, jfk), 19).
distance((ryend, lga), 15).
distance((ryend, teb), 11).
distance((ryend, ryend), 0).
distance((ryend, cri), 13).
distance((ryend, cimbl), 9).
distance((ryend, dandy), 6).
distance((cri, jfk), 6).
distance((cri, lga), 11).
distance((cri, teb), 16).
distance((cri, ryend), 13).
distance((cri, cri), 0).
distance((cri, cimbl), 10).
distance((cri, dandy), 16).
distance((cimbl, jfk), 13).
distance((cimbl, lga), 7).
distance((cimbl, teb), 6).
distance((cimbl, ryend), 9).
distance((cimbl, cri), 10).
distance((cimbl, cimbl), 0).
distance((cimbl, dandy), 7).
distance((dandy, jfk), 20).
distance((dandy, lga), 13).
distance((dandy, teb), 6).
distance((dandy, ryend), 6).
distance((dandy, cri), 16).
distance((dandy, cimbl), 7).
distance((dandy, dandy), 0).
flight_time((jfk, jfk), 0).
flight_time((jfk, lga), 6).
flight_time((jfk, teb), 11).
flight_time((jfk, ryend), 11).
flight_time((jfk, cri), 3).
flight_time((jfk, cimbl), 8).
flight_time((jfk, dandy), 12).
flight_time((lga, jfk), 6).
flight_time((lga, lga), 0).
flight_time((lga, teb), 5).
flight_time((lga, ryend), 9).
flight_time((lga, cri), 6).
flight_time((lga, cimbl), 4).
flight_time((lga, dandy), 8).
flight_time((teb, jfk), 11).
flight_time((teb, lga), 5).
flight_time((teb, teb), 0).
flight_time((teb, ryend), 7).
flight_time((teb, cri), 10).
flight_time((teb, cimbl), 4).
flight_time((teb, dandy), 4).
flight_time((ryend, jfk), 11).
flight_time((ryend, lga), 9).
flight_time((ryend, teb), 7).
flight_time((ryend, ryend), 0).
flight_time((ryend, cri), 8).
flight_time((ryend, cimbl), 5).
flight_time((ryend, dandy), 4).
flight_time((cri, jfk), 3).
flight_time((cri, lga), 6).
flight_time((cri, teb), 10).
flight_time((cri, ryend), 8).
flight_time((cri, cri), 0).
flight_time((cri, cimbl), 6).
flight_time((cri, dandy), 10).
flight_time((cimbl, jfk), 8).
flight_time((cimbl, lga), 4).
flight_time((cimbl, teb), 4).
flight_time((cimbl, ryend), 5).
flight_time((cimbl, cri), 6).
flight_time((cimbl, cimbl), 0).
flight_time((cimbl, dandy), 4).
flight_time((dandy, jfk), 12).
flight_time((dandy, lga), 8).
flight_time((dandy, teb), 4).
flight_time((dandy, ryend), 4).
flight_time((dandy, cri), 10).
flight_time((dandy, cimbl), 4).
flight_time((dandy, dandy), 0).
charge_time((jfk, jfk), 0).
charge_time((jfk, lga), 10).
charge_time((jfk, teb), 18).
charge_time((jfk, ryend), 18).
charge_time((jfk, cri), 6).
charge_time((jfk, cimbl), 13).
charge_time((jfk, dandy), 19).
charge_time((lga, jfk), 10).
charge_time((lga, lga), 0).
charge_time((lga, teb), 9).
charge_time((lga, ryend), 14).
charge_time((lga, cri), 10).
charge_time((lga, cimbl), 6).
charge_time((lga, dandy), 13).
charge_time((teb, jfk), 18).
charge_time((teb, lga), 9).
charge_time((teb, teb), 0).
charge_time((teb, ryend), 11).
charge_time((teb, cri), 15).
charge_time((teb, cimbl), 6).
charge_time((teb, dandy), 6).
charge_time((ryend, jfk), 18).
charge_time((ryend, lga), 14).
charge_time((ryend, teb), 11).
charge_time((ryend, ryend), 0).
charge_time((ryend, cri), 13).
charge_time((ryend, cimbl), 8).
charge_time((ryend, dandy), 6).
charge_time((cri, jfk), 6).
charge_time((cri, lga), 10).
charge_time((cri, teb), 15).
charge_time((cri, ryend), 13).
charge_time((cri, cri), 0).
charge_time((cri, cimbl), 9).
charge_time((cri, dandy), 15).
charge_time((cimbl, jfk), 13).
charge_time((cimbl, lga), 6).
charge_time((cimbl, teb), 6).
charge_time((cimbl, ryend), 8).
charge_time((cimbl, cri), 9).
charge_time((cimbl, cimbl), 0).
charge_time((cimbl, dandy), 7).
charge_time((dandy, jfk), 19).
charge_time((dandy, lga), 13).
charge_time((dandy, teb), 6).
charge_time((dandy, ryend), 6).
charge_time((dandy, cri), 15).
charge_time((dandy, cimbl), 7).
charge_time((dandy, dandy), 0).
flight_windows((jfk, jfk), 0).
flight_windows((jfk, lga), 2).
flight_windows((jfk, teb), 4).
flight_windows((jfk, ryend), 4).
flight_windows((jfk, cri), 1).
flight_windows((jfk, cimbl), 3).
flight_windows((jfk, dandy), 4).
flight_windows((lga, jfk), 2).
flight_windows((lga, lga), 0).
flight_windows((lga, teb), 2).
flight_windows((lga, ryend), 3).
flight_windows((lga, cri), 2).
flight_windows((lga, cimbl), 2).
flight_windows((lga, dandy), 3).
flight_windows((teb, jfk), 4).
flight_windows((teb, lga), 2).
flight_windows((teb, teb), 0).
flight_windows((teb, ryend), 3).
flight_windows((teb, cri), 4).
flight_windows((teb, cimbl), 2).
flight_windows((teb, dandy), 2).
flight_windows((ryend, jfk), 4).
flight_windows((ryend, lga), 3).
flight_windows((ryend, teb), 3).
flight_windows((ryend, ryend), 0).
flight_windows((ryend, cri), 3).
flight_windows((ryend, cimbl), 2).
flight_windows((ryend, dandy), 2).
flight_windows((cri, jfk), 1).
flight_windows((cri, lga), 2).
flight_windows((cri, teb), 4).
flight_windows((cri, ryend), 3).
flight_windows((cri, cri), 0).
flight_windows((cri, cimbl), 2).
flight_windows((cri, dandy), 4).
flight_windows((cimbl, jfk), 3).
flight_windows((cimbl, lga), 2).
flight_windows((cimbl, teb), 2).
flight_windows((cimbl, ryend), 2).
flight_windows((cimbl, cri), 2).
flight_windows((cimbl, cimbl), 0).
flight_windows((cimbl, dandy), 2).
flight_windows((dandy, jfk), 4).
flight_windows((dandy, lga), 3).
flight_windows((dandy, teb), 2).
flight_windows((dandy, ryend), 2).
flight_windows((dandy, cri), 4).
flight_windows((dandy, cimbl), 2).
flight_windows((dandy, dandy), 0).
max_flight_windows(5).
edge((jfk,jfk)).
edge((jfk,lga)).
edge((jfk,teb)).
edge((jfk,ryend)).
edge((jfk,cri)).
edge((jfk,cimbl)).
edge((jfk,dandy)).
edge((lga,jfk)).
edge((lga,lga)).
edge((lga,teb)).
edge((lga,ryend)).
edge((lga,cri)).
edge((lga,cimbl)).
edge((lga,dandy)).
edge((teb,jfk)).
edge((teb,lga)).
edge((teb,teb)).
edge((teb,ryend)).
edge((teb,cri)).
edge((teb,cimbl)).
edge((teb,dandy)).
edge((ryend,jfk)).
edge((ryend,lga)).
edge((ryend,teb)).
edge((ryend,ryend)).
edge((ryend,cri)).
edge((ryend,cimbl)).
edge((ryend,dandy)).
edge((cri,jfk)).
edge((cri,lga)).
edge((cri,teb)).
edge((cri,ryend)).
edge((cri,cri)).
edge((cri,cimbl)).
edge((cri,dandy)).
edge((cimbl,jfk)).
edge((cimbl,lga)).
edge((cimbl,teb)).
edge((cimbl,ryend)).
edge((cimbl,cri)).
edge((cimbl,cimbl)).
edge((cimbl,dandy)).
edge((dandy,jfk)).
edge((dandy,lga)).
edge((dandy,teb)).
edge((dandy,ryend)).
edge((dandy,cri)).
edge((dandy,cimbl)).
edge((dandy,dandy)).
