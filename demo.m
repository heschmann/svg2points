%% hi
path = svg2points('h 10 v -20 l -10,20 m 45.168155,20.888392 c 0,0 0,38.211448 0,54.995536 0,-14.285334 1.241037,-29.860118 11.177158,-29.860118 9.936121,0 11.598512,13.446504 11.528997,29.800855 13.296671,0 15.924375,-24.095191 15.924375,-24.095191 0,0 0.826288,23.729652 11.966973,23.729652',200);

figure()
hold on
plot(path(1,:),-path(2,:),'k','LineWidth',3)
plot(path(1,:),-path(2,:),'r.')
axis image

%% arcs
arc1 = svg2points('a 25,15 -30 0 1 10,20',300);
arc2 = svg2points('a 25,15 -30 0 0 10,20',300);
arc3 = svg2points('a 25,15 -30 1 0 10,20',300);
arc4 = svg2points('a 25,15 -30 1 1 10,20 z',300);

figure()
hold on
plot(arc1(1,:),-arc1(2,:),'r','LineWidth',3)
plot(arc2(1,:),-arc2(2,:),'g','LineWidth',3)
plot(arc3(1,:),-arc3(2,:),'b','LineWidth',3)
plot(arc4(1,:),-arc4(2,:),'k','LineWidth',3)
axis image