#!/bin/sh
#
# Simple script to convert normal MP4 file 
# to fMP4 fragments and DASH+HLS manifest using ffmpeg and bento4
#
# It takes one parameter (MP4 file name) 
# and produce output folder with all content inside it
# It leave maximum quality stream MP4 file as reference version
#
# oldayn@gmail.com 2017
#
# no audio, bitrate 5M, original resolution
ffmpeg -i $1 -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 5M -maxrate 5M -bufsize 2M out5.mp4
# no audio, bitrate 3M, resize to 1280x720
ffmpeg -i $1 -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 3M -maxrate 3M -bufsize 1M -vf "scale=-1:720" out4.mp4
# audio copy, bitrate 2M, resize to 960x540 (no correct resize for 480)
ffmpeg -i $1 -c:a copy -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 2M -maxrate 2M -bufsize 500k -vf "scale=-1:540" out3.mp4
# no audio, bitrate 1M, resize to 640x360
ffmpeg -i $1 -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 1M -maxrate 1M -bufsize 400k -vf "scale=-1:360" out2.mp4
# no audio, bitrate 500k, resize to 384x216
ffmpeg -i $1 -an -c:v libx264 -x264opts 'keyint=25:min-keyint=25:no-scenecut' -b:v 500k -maxrate 500k -bufsize 200k -vf "scale=-1:216" out1.mp4
# mp4fragment them all
mp4fragment out5.mp4 out5f.mp4
mp4fragment out4.mp4 out4f.mp4
mp4fragment out3.mp4 out3f.mp4
mp4fragment out2.mp4 out2f.mp4
mp4fragment out1.mp4 out1f.mp4
# make split and playlists
bento4/bin/mp4dash --hls --mpd-name=master.mpd out5f.mp4 out4f.mp4 out3f.mp4 out2f.mp4 out1f.mp4 
# some cleanup
mv out3.mp4 output/master.mp4
rm out?.mp4
rm out?f.mp4

