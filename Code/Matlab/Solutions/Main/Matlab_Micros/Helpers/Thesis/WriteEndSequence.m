function WriteEndSequence( serial_port )

%Write the end sequence.
fwrite(serial_port, 0)

end

