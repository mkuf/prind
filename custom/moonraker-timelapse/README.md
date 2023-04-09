# Moonraker Timelapse in Docker

>  **Usecase**: Create timelapses via moonraker plugin  
>  **Issue**: https://github.com/mkuf/prind/issues/46
> 
>  **Assumptions**:
>  * I use a profile that requires moonraker
>  * I have a webcam
>  * I want to create timelapses
> 
>  About this setup:
>  * moonraker image is built at stack startup
>  * timelapses will be saved to `/opt/timelapse` on the host machine

## Setup
1. Copy the file `Docker.moonraker.ffmpeg` into the `docker/moonraker/` directory
2. Check out the timelapse code to `../` relative to the root of this repository
```
git clone https://github.com/mainsail-crew/moonraker-timelapse ../moonraker-timelapse
```
3. Add the gcode macros provided by moonraker-timelapse to your printers configuration file https://github.com/mainsail-crew/moonraker-timelapse/blob/main/klipper_macro/timelapse.cfg  
4. Add the following to your moonraker.conf
```
[timelapse]
output_path: /opt/timelapse/
```
5. Add your personal config to `docker-compose.override.yaml` and copy it to the root of the repository, overwriting the existing one
6. start the stack as described in the main readme using mainsail or fluidd as profile