# Plex Apple TV2G Client
## CREDIT TO
Original project author, and libPLEX-OSS library creator: quiqueck

Main project developers: b0bben and ccjensen

Apple TV guru and project consultant: tomcool420

## PREPARING
1. You need to install the "beigelist" on your Apple TV (if you installed the Plex-Plugin using apt, it is already there )
2. Set up a password-less ssh connection to your Apple TV using [O'Reilly's instructions](http://oreilly.com/pub/h/66)
3. You need the iPhone 4.2 SDK installed on your machine!
4. You need to get transcoder keys from the plex team in order to make playback work.
5. Install the plex-client on your Apple TV (prepares the correct skeletons) using:
		   
		echo "deb http://www.ambertation.de ./downloads/PLEX/" > /etc/apt/sources.list.d/plex.list
		apt-get update
		apt-get install com.plex.client-plugin
		
6. Get a copy of the Plex Apple TV Client using a the link at the github repository
7. cd into the code's base directory (with name Plex-ATV-Plugin)
8. Get build dependencies (ATV2Includes and SMFramework). These are included as submodules in the _contrib folder. The folders will be empty when you do a fresh clone, so type in:
      git submodule init
   This will initialize the folders
9. now either:
   
   * Retrieve the latest commit (recommended): 
	   
            git submodule update
   
   * Retrieve the entire branch (if you intend to submit code changes to this repository):
            
            git submodule add
	
	This fill the `_contrib/SMFramework` and `_contrib/ATV2Includes` folders
10. At this point all the code should be present

## BUILDING
### SMFramework
This might not be required, but the Plex client does very often stay on the 'bleeding edge' with SMFramework.
1. cd into SMFramework folder
2. Run to build a new deb (will also update the SMFramework headers folder in ATV2Includes):
   make clean package
3. To install new build of SMFramework on your apple tv:
   make install package

### Plex Apple TV Client
1. Open PlexATV/atvTwo.xcodeproj
2. Make sure you are building 4.2|Release|atvTwo|armv6
3. Make sure your appleTV is turned on and that you can log in using root@appletv.local (without using a password)
4. Set the transcoder keys in PlexATV/Classes/HWAppliance.mm
5. Hit [cmd]+B in Xcode. The plugin is build and copied to the Apple TV and. After that AppleTV.app is restarted

## License
### For libPLEX-OSS.a
This license applies to libPLEX-OSS.a and all included header files in include/ambertation-plex and include/plex-oss.

Copyright (c) 2010 F. Bauer

Redistribution and use of the libPLEX-OSS.a code or any derivative works are permitted provided that the following conditions are met:
- Redistributions may not bea sold, nor may they be used in a commercial product or activity.
- Redistributions must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- It is not allowed to redistribute a modified version of the libPLEX-OSS.a  
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


### For the Apple TV Plugin (Excluding libPLEX-OSS.a)
The Plugin code itself is based on the sample code created 
from [NitoTV](http://www.iclarified.com/entry/index.php?enid=12374)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.