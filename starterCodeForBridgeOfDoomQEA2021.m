function starterCodeForBridgeOfDoomQEA2021()
% Insert any setup code you want to run here

% u will be our parameter
syms u;

% the original value of alpha: .25
alpha = 0.25;
% this is the equation of the bridge
ri=1.584*cos(2.65*alpha*u+3.71);
rj=-3.96*sin(alpha*u+1.4);
rk=0*alpha*u;
R=[ri,rj,rk];

dr=diff(R,u);
T = diff(R); % Tangent 
T_hat = T/norm(T); % normalized tangent vector

pub = rospublisher('/raw_vel');

% stop the robot if it's going right now
stopMsg = rosmessage(pub);
stopMsg.Data = [0 0];
send(pub, stopMsg);

% Give Neato starting position & T_hat, R
bridgeStart = double(subs(R,u,0));
startingThat = double(subs(T_hat,u,0));
placeNeato(bridgeStart(1),  bridgeStart(2), ...
           startingThat(1), startingThat(2));

% wait a bit for robot to fall onto the bridge
pause(2);

% calculate left & right wheel velocity equations
dT_hat=diff(T_hat,u);
Angular_Velocity_ugly = cross(T_hat,dT_hat);
d = 0.235;
Wheel_Left_ugly = norm(dr) - Angular_Velocity_ugly(3).*(d/2);
Wheel_Left = simplify(Wheel_Left_ugly);
Wheel_Right_ugly = norm(dr) + Angular_Velocity_ugly(3).*(d/2);
Wheel_Right = simplify(Wheel_Right_ugly);

% time to drive!!
pub = rospublisher('/raw_vel');
msg = rosmessage(pub);

rostic;
t = 0;
while 1
     L = double(subs(Wheel_Left,u,t));
     R = double(subs(Wheel_Right,u,t));
     labels = "L         R"
     matrix = [L,R]
     msg.Data = [L,R];
     send(pub,msg);
     t = rostoc;
     if t > 3.2/alpha
         stopMsg = rosmessage(pub);
         stopMsg.Data = [0 0];
         send(pub, stopMsg);
         break
     end
end
end
