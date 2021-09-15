set /p Rev=<"G:\My Drive\code\Processing\sketchbook\3.0\s068_waves2\run.txt"
copy /y "G:\My Drive\code\Processing\sketchbook\3.0\s068_waves2\s068_waves2.pde" "C:\Leo\1_work\capturas\processing\s068_waves2\vids\%Rev%.pde"
ffmpeg -framerate 30 -i "C:\Leo\1_work\capturas\processing\s068_waves2\%Rev%\%%04d.jpg" -s 1080x1080 -c:v libx264  -preset veryslow -crf 20 -pix_fmt yuv420p "C:\Leo\1_work\capturas\processing\s068_waves2\vids\%Rev%.mp4"
pause