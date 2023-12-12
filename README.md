# Sem3-COAL-Project
Pac Man with Win32API in Assembly

We were required to make this in the Terminal. Someone taunted me, and I wanted to see just what I was capable of. So instead of doing the logical thing of doing what they've asked, I went above and beyond and spent 13 days thoroughly understanding WinAPI, reading books of it, trying to get it to work, failing a lot of times, and I mean a _lot_ of times, until eventually, on day 8 I finally managed to establish a workflow. All I needed was to learn how to draw things, how to move things, and how to time things, and after 8 days of suffering and pain, I had understood all of them.

Then I proceeded to finalize the project in what little time I had. It was frustrating, but fun. I can say that for all of my projects, but especially this. I spent so much work and effort on it, and it paid off, because nobody on their first impression actually believes that this was made in Assembly. And yet, while researching all of this and learning it, I found articles and tutorials and documentation of people doing DirectX and OpenGL in Assembly. They made entire physics engines and 3D environments and even Chess AI's in Assembly, and they did it on machines hundreds of times slower than today, and without internet and without thorough documentation, unless books count. I've obtained a newfound respect for anyone who was responsible for those advancements. I never want to touch assembly again but this journey was absolutely worth it.

To run it, first download the installer from http://www.masm32.com/download.htm. It's super convenient, there's no linking or setup. You just download it, run it, and it'll check if the files can be installed, and if so, it'll install them. Then, for Visual Studio, make sure to enable MASM in build dependencies and set the Debugger to 32-bit. Finally, under Project > Project Properties, Go to Linker > System and set SubSystem to Windows (/SUBSYSTEM:WINDOWS), and in Linker > Advanced, write 'start' in the Entry Point.

Then that's it! Just run it and it'll show up. The directories (other than MASM32 for the WinAPI Library) are portable, so there's no manual re-linking to be done. I hope you have fun playing or watching it as much as I did making it, if not more.

Gameplay video:
https://youtu.be/B0cpoWkWj4A

Also, little Easter Egg. In main.asm, if you write MenuFrames EQU 125 on line 343, and change "mainmenu\0000.bmp" to "mainmeme\0000.bmp", you'll play a different menu background. Enjoy!
