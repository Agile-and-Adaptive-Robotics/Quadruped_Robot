s = serialport('COM6', 57600);
write(s,'T',"char");
write(s, 200, "uint8");
write(s, 20, "uint8");

func = readline(s);
ans = readline(s);

clear s;